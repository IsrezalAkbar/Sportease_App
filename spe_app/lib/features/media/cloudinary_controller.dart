import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/cloudinary_service.dart';

final cloudinaryProvider =
    StateNotifierProvider<CloudinaryController, CloudinaryState>(
      (ref) => CloudinaryController(),
    );

class CloudinaryState {
  final bool isLoading;
  final String? url;
  final String? error;

  const CloudinaryState({this.isLoading = false, this.url, this.error});

  CloudinaryState copyWith({bool? isLoading, String? url, String? error}) {
    return CloudinaryState(
      isLoading: isLoading ?? this.isLoading,
      url: url,
      error: error,
    );
  }
}

class CloudinaryController extends StateNotifier<CloudinaryState> {
  CloudinaryController() : super(const CloudinaryState());
  final _service = CloudinaryService();

  Future<String?> upload(File file) async {
    try {
      state = state.copyWith(isLoading: true);

      final url = await _service.uploadImage(file);

      state = state.copyWith(isLoading: false, url: url);
      return url;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}
