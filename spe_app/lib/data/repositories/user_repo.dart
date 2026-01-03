import '../datasources/firestore_user_ds.dart';
import 'package:spe_app/data/models/user_model.dart';

class UserRepo {
  final _ds = UserDataSource();

  /// Saat login / startup
  Future<UserModel?> getUser(String uid) => _ds.getUser(uid);

  /// Alias untuk getUser (untuk kejelasan di admin)
  Future<UserModel?> getUserById(String uid) => _ds.getUser(uid);

  /// Saat user baru register
  Future<void> create(UserModel user) => _ds.createUser(user);

  /// Update profil user
  Future<void> update(UserModel user) => _ds.updateUser(user);

  /// Update foto profil
  Future<void> updatePhoto(String uid, String url) => _ds.updatePhoto(uid, url);

  /// Tambah komunitas ke joined list
  Future<void> joinCommunity(String uid, String communityId) =>
      _ds.joinCommunity(uid, communityId);

  /// Admin: ubah role user
  Future<void> changeRole(String uid, String role) => _ds.changeRole(uid, role);

  /// Admin: hapus user
  Future<void> delete(String uid) => _ds.deleteUser(uid);

  /// Untuk admin: melihat daftar semua user
  Stream<List<UserModel>> get allUsers => _ds.getAllUsers();

  /// Cek username sudah dipakai atau belum
  Future<bool> isUsernameExists(String username) =>
      _ds.isUsernameExists(username);

  /// Ambil user berdasarkan username (untuk login)
  Future<UserModel?> getUserByUsername(String username) =>
      _ds.getUserByUsername(username);
}
