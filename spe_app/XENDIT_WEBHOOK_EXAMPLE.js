// Firebase Cloud Functions untuk Xendit Webhook
// File: functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Xendit Webhook Handler
 *
 * Endpoint ini akan menerima notifikasi dari Xendit ketika status pembayaran berubah
 * URL: https://<region>-<project-id>.cloudfunctions.net/xenditWebhook
 *
 * Setup di Dashboard Xendit:
 * 1. Settings > Webhooks
 * 2. Tambah webhook baru dengan URL di atas
 * 3. Pilih events: invoice.paid, invoice.expired
 */
exports.xenditWebhook = functions.https.onRequest(async (req, res) => {
  // Log request untuk debugging
  console.log("Xendit Webhook received:", {
    headers: req.headers,
    body: req.body,
  });

  // Verifikasi webhook token untuk keamanan
  // Token ini bisa didapatkan dari Dashboard Xendit
  const xenditCallbackToken =
    functions.config().xendit?.webhook_token ||
    "YOUR_WEBHOOK_VERIFICATION_TOKEN";
  const callbackToken = req.headers["x-callback-token"];

  if (callbackToken !== xenditCallbackToken) {
    console.error("Invalid webhook token");
    return res.status(401).send("Unauthorized");
  }

  // Parse data dari Xendit
  const {
    id, // Xendit Invoice ID
    external_id, // Booking ID yang kita kirim
    status, // PAID, EXPIRED, PENDING
    payment_method, // BCA_VA, OVO, DANA, dll
    payment_channel, // Detail metode pembayaran
    paid_at, // Timestamp pembayaran
    updated, // Timestamp update terakhir
    amount, // Jumlah pembayaran
  } = req.body;

  try {
    // Update semua booking dengan external_id yang match
    // Format external_id adalah: {bookingId} atau {bookingId}_{time}
    const baseBookingId = external_id.split("_")[0];

    const bookingsSnapshot = await admin
      .firestore()
      .collection("bookings")
      .where("bookingId", ">=", baseBookingId)
      .where("bookingId", "<=", baseBookingId + "\uf8ff")
      .get();

    if (bookingsSnapshot.empty) {
      console.log("No bookings found for external_id:", external_id);
      return res.status(200).send("OK - No bookings found");
    }

    // Update batch untuk efisiensi
    const batch = admin.firestore().batch();
    let updatedCount = 0;

    bookingsSnapshot.forEach((doc) => {
      const bookingData = doc.data();

      // Hanya update jika invoice ID match
      if (bookingData.xenditInvoiceId === id) {
        const updateData = {
          paymentStatus: mapXenditStatus(status),
        };

        // Tambahkan informasi pembayaran jika sudah dibayar
        if (status === "PAID" || status === "SETTLED") {
          updateData.paymentMethod = payment_method || payment_channel;
          updateData.paidAt = paid_at
            ? admin.firestore.Timestamp.fromDate(new Date(paid_at))
            : admin.firestore.FieldValue.serverTimestamp();
        }

        batch.update(doc.ref, updateData);
        updatedCount++;

        console.log(
          `Updating booking ${doc.id} to status: ${updateData.paymentStatus}`
        );
      }
    });

    // Commit batch update
    await batch.commit();

    console.log(
      `Successfully updated ${updatedCount} bookings for invoice ${id}`
    );

    // Kirim response sukses ke Xendit
    res.status(200).json({
      status: "success",
      message: `Updated ${updatedCount} bookings`,
    });
  } catch (error) {
    console.error("Error processing webhook:", error);
    // Tetap return 200 agar Xendit tidak retry terus-menerus
    res.status(200).json({
      status: "error",
      message: error.message,
    });
  }
});

/**
 * Map status dari Xendit ke status aplikasi
 */
function mapXenditStatus(xenditStatus) {
  switch (xenditStatus.toUpperCase()) {
    case "PAID":
    case "SETTLED":
      return "paid";
    case "EXPIRED":
      return "expired";
    case "PENDING":
    default:
      return "pending";
  }
}

/**
 * Function untuk cek status pembayaran manual (opsional)
 * Bisa dipanggil dari aplikasi jika ingin re-check status
 */
exports.checkPaymentStatus = functions.https.onCall(async (data, context) => {
  // Pastikan user sudah login
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User harus login untuk cek status pembayaran"
    );
  }

  const { bookingId } = data;

  if (!bookingId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "bookingId is required"
    );
  }

  try {
    // Ambil data booking
    const bookingDoc = await admin
      .firestore()
      .collection("bookings")
      .doc(bookingId)
      .get();

    if (!bookingDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Booking tidak ditemukan"
      );
    }

    const bookingData = bookingDoc.data();

    // Cek ke Xendit API untuk status terbaru
    if (bookingData.xenditInvoiceId) {
      const xenditApiKey = functions.config().xendit?.api_key;
      const response = await fetch(
        `https://api.xendit.co/v2/invoices/${bookingData.xenditInvoiceId}`,
        {
          headers: {
            Authorization: `Basic ${Buffer.from(xenditApiKey + ":").toString(
              "base64"
            )}`,
          },
        }
      );

      if (response.ok) {
        const invoiceData = await response.json();

        // Update status jika berbeda
        const newStatus = mapXenditStatus(invoiceData.status);
        if (newStatus !== bookingData.paymentStatus) {
          await bookingDoc.ref.update({
            paymentStatus: newStatus,
            ...(newStatus === "paid" && {
              paymentMethod: invoiceData.payment_method,
              paidAt: admin.firestore.FieldValue.serverTimestamp(),
            }),
          });
        }

        return {
          status: newStatus,
          invoiceUrl: invoiceData.invoice_url,
        };
      }
    }

    return {
      status: bookingData.paymentStatus,
    };
  } catch (error) {
    console.error("Error checking payment status:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Gagal cek status pembayaran"
    );
  }
});
