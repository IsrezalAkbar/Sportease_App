# 🎨 Payment UI - Quick Reference Guide

## Visual Layout

```
┌─────────────────────────────────────────────┐
│  PROGRESS INDICATOR                         │
│  ○─────────○─────────●                      │
│  Pilih Jadwal │ Review Order │ Pembayaran  │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  TOTAL PEMBAYARAN                           │
│  Rp 650.000                                 │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  METODE PEMBAYARAN                          │
│                                             │
│  E-Wallet                                   │
│  ┌─────────────────────────────────────┐   │
│  │ 🔵 GoPay                    ◉       │   │
│  │    Pembayaran dengan GoPay          │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🟣 OVO                      ○       │   │
│  │    Pembayaran dengan OVO            │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🔷 DANA                     ○       │   │
│  │    Pembayaran dengan DANA           │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🔶 LinkAja                  ○       │   │
│  │    Pembayaran dengan LinkAja        │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🟠 ShopeePay                ○       │   │
│  │    Pembayaran dengan ShopeePay      │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Bank Transfer (Virtual Account)            │
│  ┌─────────────────────────────────────┐   │
│  │ 🏦 BCA                      ○       │   │
│  │    Transfer ke Virtual Account BCA  │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🏦 BNI                      ○       │   │ ← NEW!
│  │    Transfer ke Virtual Account BNI  │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🏦 Mandiri                  ○       │   │ ← NEW!
│  │    Transfer ke Virtual Account      │   │
│  │    Mandiri                          │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🏦 BRI                      ○       │   │
│  │    Transfer ke Virtual Account BRI  │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🏦 Permata                  ○       │   │
│  │    Transfer ke Virtual Account      │   │
│  │    Permata                          │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Toko (Retail)                              │
│  ┌─────────────────────────────────────┐   │
│  │ 🏪 Alfamart                 ○       │   │
│  │    Bayar di Alfamart                │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 🏪 Indomaret                ○       │   │
│  │    Bayar di Indomaret               │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Lainnya                                    │
│  ┌─────────────────────────────────────┐   │
│  │ 📱 QRIS                     ○       │   │
│  │    Scan QRIS dengan e-wallet atau   │   │
│  │    app bank                         │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │ 💳 Kartu Kredit             ○       │   │
│  │    Pembayaran dengan Kartu Kredit/  │   │
│  │    Debit                            │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│          BAYAR                              │
│   (Large button - Full width)               │
└─────────────────────────────────────────────┘
```

---

## 🎯 Payment Methods Breakdown

### E-Wallet (Section 1)

| Icon | Name      | Code      | Support   |
| ---- | --------- | --------- | --------- |
| 🔵   | GoPay     | GOPAY     | ✅ Active |
| 🟣   | OVO       | OVO       | ✅ Active |
| 🔷   | DANA      | DANA      | ✅ Active |
| 🔶   | LinkAja   | LINKAJA   | ✅ Active |
| 🟠   | ShopeePay | SHOPEEPAY | ✅ Active |

### Bank Transfer - Virtual Account (Section 2) ⭐ NEW

| Icon | Name    | Code    | Type    | Support    |
| ---- | ------- | ------- | ------- | ---------- |
| 🏦   | BCA     | BCA     | Bank VA | ✅ Active  |
| 🏦   | BNI     | BNI     | Bank VA | ✅ **NEW** |
| 🏦   | Mandiri | MANDIRI | Bank VA | ✅ **NEW** |
| 🏦   | BRI     | BRI     | Bank VA | ✅ Active  |
| 🏦   | Permata | PERMATA | Bank VA | ✅ Active  |

### Retail/Toko (Section 3)

| Icon | Name      | Code      | Support   |
| ---- | --------- | --------- | --------- |
| 🏪   | Alfamart  | ALFAMART  | ✅ Active |
| 🏪   | Indomaret | INDOMARET | ✅ Active |

### Lainnya / Others (Section 4)

| Icon | Name         | Code        | Support   |
| ---- | ------------ | ----------- | --------- |
| 📱   | QRIS         | QRIS        | ✅ Active |
| 💳   | Kartu Kredit | CREDIT_CARD | ✅ Active |

---

## 🎨 Color Scheme

| Element         | Color           | Hex Code                  |
| --------------- | --------------- | ------------------------- |
| Primary         | Merah Maroon    | #8D153A                   |
| Background      | Light Gray      | #FAFAFA / Colors.grey[50] |
| Card Background | White           | #FFFFFF                   |
| Border          | Light Gray      | Colors.grey[200]          |
| Border Active   | Primary Merah   | #8D153A                   |
| Text Primary    | Black           | #000000                   |
| Text Secondary  | Gray            | Colors.grey[600]          |
| Label           | Gray            | Colors.grey[400]          |
| Icon Background | Very Light Gray | Colors.grey[100]          |

---

## 🔘 Radio Button States

### Unselected

```
Border: 2px solid gray[300]
Outer Radius: 10px circle
Inner: Empty
```

### Selected

```
Border: 2px solid #8D153A (Primary)
Outer Radius: 10px circle
Inner: Filled circle with #8D153A
Inner Radius: Center dot
```

---

## 📱 Payment Method Item Components

### Layout Structure

```
┌─ Container ─────────────────────────────┐
│ ┌─ Icon Box ──┐  ┌─ Info ──┐  ┌─ Radio ┐│
│ │             │  │ Title   │  │   ◉    ││
│ │    Icon     │  │ Desc    │  │        ││
│ │  48 x 48    │  │         │  │ 20x20  ││
│ └─────────────┘  └─────────┘  └────────┘│
└─────────────────────────────────────────┘
```

### Dimensions

- **Container**: Full width, padding 12px all
- **Icon Box**: 48x48px, gray[100] background, rounded 8px
- **Icon**: 24px emoji
- **Title**: 14px, FontWeight.w600
- **Description**: 12px, gray[600]
- **Spacing**: 12px between icon & info
- **Radio Button**: 20x20px circle

---

## 🎬 Interactive States

### Default State

- Border: 1px solid gray[200]
- Background: white
- Radio: Unselected

### Hover State (Tap)

- Background: Slight opacity change
- Cursor: Pointer

### Selected State

- Border: 2px solid #8D153A
- Background: white
- Radio: Selected (filled)

### Disabled State (When Processing)

- Button: Disabled opacity
- Show: Loading spinner

---

## ⚡ User Interactions

### Select Payment Method

```
1. User taps on payment method card
2. Card border changes to #8D153A (2px)
3. Radio button fills with #8D153A
4. _selectedMethod state updates
5. UI rebuilds to reflect selection
```

### Click Bayar Button

```
1. User taps "Bayar" button
2. Button disabled + shows loading spinner
3. _processPayment() method called
4. Creates Xendit invoice
5. If success → Opens payment URL
6. If error → Shows error SnackBar
```

---

## 🔄 Payment Flow (BNI Example)

### Step 1: Select BNI

```dart
_selectedMethod = PaymentMethods.bni;
// UI updates - BNI card shows border & filled radio
```

### Step 2: Click Bayar

```dart
_processPayment(context, args);
```

### Step 3: Create Invoice

```dart
invoice = await _xenditService.createInvoice(
  externalId: bookingId,
  amount: totalPrice,
  paymentMethod: 'BNI',  // ← BNI selected
  description: 'Pembayaran Booking Lapangan',
  // ...
);
```

### Step 4: Open Payment URL

```dart
launchUrl(
  Uri.parse(invoice.invoiceUrl),
  mode: LaunchMode.externalApplication
);
```

### Step 5: User Pays

- User transfers ke Virtual Account BNI yang diberikan Xendit
- Confirmation dialog ditampilkan
- Status booking berubah ke "paid" (via webhook)

---

## 📲 Responsive Behavior

### Small Screens (< 480px)

- Single column layout ✓ (maintained)
- Padding adjusted automatically
- Font sizes readable
- Radio button visible

### Medium Screens (480px - 768px)

- Same layout, larger padding
- Comfortable spacing

### Large Screens (> 768px)

- Same layout, max content width constraints
- Better spacing

---

## ✅ Accessibility Features

1. **Radio Buttons**: 20x20px (easy tap target)
2. **Color Contrast**: #8D153A on white (✓ WCAG AA)
3. **Text Labels**: Clear, descriptive names
4. **Icons**: Emoji + text (not icon-only)
5. **Touch Feedback**: Visual border change
6. **Error Messages**: Clear SnackBar feedback
7. **Loading State**: Visible spinner + disabled button

---

## 🧪 Testing Checklist

- [ ] GoPay dapat dipilih & radio button berubah
- [ ] OVO dapat dipilih
- [ ] DANA dapat dipilih
- [ ] LinkAja dapat dipilih
- [ ] ShopeePay dapat dipilih
- [ ] BCA dapat dipilih
- [ ] **BNI dapat dipilih** (NEW)
- [ ] **Mandiri dapat dipilih** (NEW)
- [ ] BRI dapat dipilih
- [ ] Permata dapat dipilih
- [ ] Alfamart dapat dipilih
- [ ] Indomaret dapat dipilih
- [ ] QRIS dapat dipilih
- [ ] Kartu Kredit dapat dipilih
- [ ] Bayar button terdisable saat processing
- [ ] Loading spinner muncul
- [ ] Payment URL terbuka dengan benar
- [ ] Invoice dibuat di Xendit dengan method yang benar
- [ ] Error handling berfungsi

---

## 🐛 Common UI Issues & Fixes

| Issue                       | Cause                       | Fix                         |
| --------------------------- | --------------------------- | --------------------------- |
| Radio button tidak terlihat | Border radius terlalu besar | Cek border radius = 20      |
| Text terpotong              | Width container terbatas    | Check Expanded widget       |
| Spacing tidak konsisten     | Padding berbeda per item    | Use const SizedBox          |
| Icon terlalu besar/kecil    | Font size tidak sesuai      | Adjust to 24px              |
| Border tidak cukup tebal    | Border width 1px            | Change to 2px saat selected |

---

Fitur pembayaran UI siap untuk production! 🚀
