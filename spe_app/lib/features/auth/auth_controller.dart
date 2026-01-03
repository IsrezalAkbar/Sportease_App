import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spe_app/data/models/user_model.dart';

import 'auth_service.dart';
import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref: ref);
  },
);

final authStateProvider = StreamProvider((ref) {
  return ref.read(authControllerProvider.notifier).authStateChanges();
});

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;
  final _service = AuthService();

  AuthController({required this.ref}) : super(const AuthState()) {
    _init();
  }

  void _init() {
    _service.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        state = const AuthState(user: null);
      } else {
        final userData = await _service.getUserData(firebaseUser.uid);

        // Jika user dihapus dari Firestore oleh admin, logout otomatis
        if (userData == null) {
          await _service.logout();
          state = const AuthState(user: null);
        } else {
          state = AuthState(user: userData);
        }
      }
    });
  }

  Stream authStateChanges() => _service.authStateChanges();

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
    String role = 'user',
    required String username,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      // Validasi username tidak boleh kosong
      if (username.trim().isEmpty) {
        throw Exception('Username wajib diisi!');
      }

      // Cek uniqueness username
      final usernameExists = await _service.isUsernameExists(username.trim());
      if (usernameExists) {
        throw Exception(
          'Username "$username" sudah digunakan. Silakan pilih username lain.',
        );
      }

      final cred = await _service.register(email, password);

      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        role: role,
        joinedCommunities: [],
        username: username.trim(),
      );

      await _service.saveUserData(user);

      // Kirim email verifikasi
      await _service.sendEmailVerification();

      state = state.copyWith(isLoading: false, user: user);

      if (context.mounted) {
        // Redirect ke halaman verifikasi email
        Navigator.pushReplacementNamed(
          context,
          '/email-verification',
          arguments: {'email': email, 'role': role, 'name': name},
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
    String? selectedRole,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      // Hardcoded admin login
      if (email.trim() == 'adminspe' && password == 'admin123') {
        final adminUser = UserModel(
          uid: 'admin-static-id',
          name: 'Admin SPE',
          email: 'adminspe',
          role: 'admin',
          joinedCommunities: [],
          username: 'adminspe',
        );

        state = state.copyWith(isLoading: false, user: adminUser);

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/admin');
        }
        return;
      }

      // Cek apakah input adalah username atau email
      String emailToLogin = email;
      if (!email.contains('@')) {
        // Input adalah username, cari email-nya
        final userByUsername = await _service.getUserByUsername(email.trim());
        if (userByUsername == null) {
          throw Exception('Username atau password salah');
        }
        emailToLogin = userByUsername.email;
      }

      final cred = await _service.login(emailToLogin, password);

      final user = await _service.getUserData(cred.user!.uid);

      if (user == null) {
        throw Exception('User data tidak ditemukan');
      }

      if (selectedRole != null && user.role != selectedRole) {
        await _service.logout();
        throw Exception(
          'Akun ini terdaftar sebagai ${user.role}, bukan $selectedRole',
        );
      }

      // Cek apakah email sudah diverifikasi
      if (!cred.user!.emailVerified) {
        state = state.copyWith(isLoading: false, user: user);

        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/email-verification',
            arguments: {
              'email': user.email,
              'role': user.role,
              'name': user.name,
            },
          );
        }
        return;
      }

      state = state.copyWith(isLoading: false, user: user);

      if (context.mounted) {
        // Route akan ditentukan oleh CheckAuthPage berdasarkan status
        Navigator.pushReplacementNamed(context, '/check');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah')),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> refreshUserData() async {
    final currentUser = state.user;
    if (currentUser != null) {
      final userData = await _service.getUserData(currentUser.uid);
      state = state.copyWith(user: userData);
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState(user: null);
  }

  void clearAuthState() {
    state = const AuthState(user: null);
  }

  /// Kirim ulang email verifikasi
  Future<void> sendEmailVerification() async {
    await _service.sendEmailVerification();
  }

  /// Reload user untuk cek status verifikasi
  Future<void> reloadUser() async {
    await _service.reloadUser();
  }

  /// Cek apakah email sudah diverifikasi
  bool get isEmailVerified => _service.isEmailVerified;

  Future<void> signInWithGoogle({
    required BuildContext context,
    required String role,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final credential = await _service.signInWithGoogle();

      // Cek apakah user sudah ada di database
      final existingUser = await _service.getUserData(credential.user!.uid);

      if (existingUser != null) {
        // User sudah terdaftar, cek role
        if (existingUser.role != role) {
          await _service.logout();
          throw Exception(
            'Akun ini terdaftar sebagai ${existingUser.role}, bukan $role',
          );
        }
        state = state.copyWith(isLoading: false, user: existingUser);

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/check');
        }
      } else {
        // User baru, daftarkan dengan role yang dipilih
        // Generate username default dari email (bisa diubah nanti)
        String defaultUsername =
            credential.user!.email?.split('@').first ?? 'user';
        int counter = 1;
        while (await _service.isUsernameExists(defaultUsername)) {
          defaultUsername =
              '${credential.user!.email?.split('@').first ?? 'user'}$counter';
          counter++;
        }

        final user = UserModel(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? 'User',
          email: credential.user!.email ?? '',
          role: role,
          joinedCommunities: [],
          photoUrl: credential.user!.photoURL,
          username: defaultUsername,
        );

        await _service.saveUserData(user);
        state = state.copyWith(isLoading: false, user: user);

        // Google sign-in sudah terverifikasi otomatis, langsung ke app
        if (context.mounted) {
          String route;
          if (role == 'pengelola') {
            route = '/first-field-registration';
          } else {
            route = '/main';
          }
          Navigator.pushReplacementNamed(context, route);
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
