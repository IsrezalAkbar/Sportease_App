import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spe_app/data/models/user_model.dart';

class UserDataSource {
  final _db = FirebaseFirestore.instance;

  /// Ambil data user dari Firestore
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Simpan user saat register
  Future<void> createUser(UserModel user) async {
    await _db.collection("users").doc(user.uid).set(user.toMap());
  }

  /// Update data profil user
  Future<void> updateUser(UserModel user) async {
    await _db.collection("users").doc(user.uid).update(user.toMap());
  }

  /// Update foto profil user
  Future<void> updatePhoto(String uid, String url) async {
    await _db.collection("users").doc(uid).update({"photoUrl": url});
  }

  /// User join komunitas (untuk tab komunitas di profil)
  Future<void> joinCommunity(String uid, String communityId) async {
    await _db.collection("users").doc(uid).update({
      "joinedCommunities": FieldValue.arrayUnion([communityId]),
    });
  }

  /// Digunakan admin untuk mengubah role
  Future<void> changeRole(String uid, String role) async {
    await _db.collection("users").doc(uid).update({"role": role});
  }

  /// Ambil semua user untuk fitur admin
  Stream<List<UserModel>> getAllUsers() {
    return _db
        .collection("users")
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => UserModel.fromMap(d.data())).toList(),
        );
  }

  /// Hapus user dari database Firestore
  ///
  /// CATATAN PENTING:
  /// Method ini hanya menghapus data user dari Firestore.
  /// User masih bisa login via Firebase Auth jika punya kredensial.
  ///
  /// Untuk menghapus user dari Firebase Auth, perlu:
  /// 1. Firebase Admin SDK (backend)
  /// 2. Cloud Functions
  /// 3. Atau user menghapus akun sendiri
  ///
  /// Solusi:
  /// - User yang dihapus dari Firestore tidak akan bisa akses app
  /// - Saat login, check if user exists di Firestore
  /// - Jika tidak ada, logout otomatis
  Future<void> deleteUser(String uid) async {
    await _db.collection("users").doc(uid).delete();
  }

  /// Cek apakah username sudah dipakai
  Future<bool> isUsernameExists(String username) async {
    final query = await _db
        .collection("users")
        .where("username", isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Ambil user berdasarkan username
  Future<UserModel?> getUserByUsername(String username) async {
    final query = await _db
        .collection("users")
        .where("username", isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return UserModel.fromMap(query.docs.first.data());
  }
}
