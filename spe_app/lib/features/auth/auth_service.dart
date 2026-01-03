import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spe_app/data/models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> saveUserData(UserModel user) async {
    await _db.collection("users").doc(user.uid).set(user.toMap());
  }

  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Normalisasi pesan error agar lebih jelas untuk pengguna
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Kata sandi salah. Coba lagi atau reset password.';
          break;
        case 'user-not-found':
          message = 'Akun tidak ditemukan. Periksa email/username Anda.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'invalid-credential':
          // Firebase kadang mengembalikan invalid-credential untuk kredensial email/password yang tidak valid
          message =
              'Kredensial tidak valid. Pastikan email dan password benar, atau login dengan Google jika akun dibuat dengan Google.';
          break;
        case 'user-disabled':
          message = 'Akun Anda dinonaktifkan. Hubungi admin.';
          break;
        case 'too-many-requests':
          message =
              'Terlalu banyak percobaan login. Coba lagi beberapa menit nanti.';
          break;
        case 'network-request-failed':
          message = 'Koneksi internet bermasalah. Periksa jaringan Anda.';
          break;
        default:
          message = e.message ?? 'Gagal login. Coba lagi nanti.';
      }
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google Sign-In dibatalkan');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User tidak ditemukan');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// Cek apakah username sudah dipakai
  Future<bool> isUsernameExists(String username) async {
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Ambil user berdasarkan username (untuk login)
  Future<UserModel?> getUserByUsername(String username) async {
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return UserModel.fromMap(query.docs.first.data());
  }

  /// Kirim email verifikasi ke user
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User tidak ditemukan');
    }

    if (user.emailVerified) {
      throw Exception('Email sudah terverifikasi');
    }

    await user.sendEmailVerification();
  }

  /// Reload user untuk cek status verifikasi terbaru
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  /// Cek apakah email sudah diverifikasi
  bool get isEmailVerified {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;
}
