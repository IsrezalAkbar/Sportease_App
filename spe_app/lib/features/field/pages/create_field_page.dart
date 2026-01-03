import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/shared/image_picker_helper.dart';
import '../../../features/media/cloudinary_controller.dart';
import '../../../data/repositories/field_repo.dart';
import '../../../data/models/field_model.dart';
import '../../location/location_picker_page.dart';
import '../../auth/auth_controller.dart';
import '../../../core/config/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CreateFieldPage extends ConsumerStatefulWidget {
  const CreateFieldPage({super.key});

  @override
  ConsumerState<CreateFieldPage> createState() => _CreateFieldPageState();
}

class _CreateFieldPageState extends ConsumerState<CreateFieldPage> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final facilityCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  List<String> photos = [];
  GeoPoint? pickedLocation;
  String? pickedAddress;
  bool isSubmitting = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    facilityCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cloudState = ref.watch(cloudinaryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Tambah Lapangan Baru",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Info Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_business,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Tambahkan lapangan baru untuk memperluas bisnis Anda. Lapangan akan ditinjau admin sebelum dipublikasikan.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Informasi Dasar', Icons.edit_note),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    "Nama Lapangan",
                    nameCtrl,
                    Icons.sports_soccer,
                    "Contoh: Lapangan Futsal Sudirman",
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    "Deskripsi",
                    descCtrl,
                    Icons.description_outlined,
                    "Deskripsikan lapangan Anda",
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    "Harga per jam",
                    priceCtrl,
                    Icons.payments_outlined,
                    "Contoh: 150000",
                    keyboardType: TextInputType.number,
                    prefix: const Text(
                      "Rp ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    "Fasilitas",
                    facilityCtrl,
                    Icons.check_circle_outline,
                    "Contoh: WiFi, Parkir, Kantin, Toilet",
                    helperText: "Pisahkan dengan koma",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Location Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Lokasi Lapangan', Icons.location_on),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    "Nama Lokasi",
                    locationCtrl,
                    Icons.place_outlined,
                    "Akan terisi otomatis dari peta",
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildPickLocationButton(context),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Photo Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Foto Lapangan', Icons.photo_library),
                  const SizedBox(height: 16),
                  _buildPhotoUploadButton(context),
                  if (cloudState.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text(
                              'Mengupload foto...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (photos.isNotEmpty) const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: photos
                        .map(
                          (url) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => photos.remove(url));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade600,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSubmitButton(context),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInput(
    String label,
    TextEditingController ctrl,
    IconData icon,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
    String? helperText,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: !isSubmitting,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            prefix: prefix,
            helperText: helperText,
            helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickLocationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSubmitting
            ? null
            : () async {
                final result = await Navigator.push<LocationPickerResult>(
                  context,
                  MaterialPageRoute(builder: (_) => const LocationPickerPage()),
                );

                if (!mounted) return;

                if (result != null) {
                  setState(() {
                    pickedLocation = GeoPoint(
                      result.latitude,
                      result.longitude,
                    );
                    pickedAddress = result.address;
                    locationCtrl.text = result.address ?? 'Lokasi terpilih';
                  });
                  if (!context.mounted) return;

                  // Detect source from address or use default
                  final sourceIcon = (result.address?.length ?? 0) > 100
                      ? '🗺️'
                      : '🔑';
                  final sourceName = (result.address?.length ?? 0) > 100
                      ? 'OpenStreetMap'
                      : 'Google';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "$sourceIcon Lokasi berhasil dipilih via $sourceName!\n${result.address}",
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
        icon: Icon(
          pickedLocation == null ? Icons.map_outlined : Icons.check_circle,
          size: 20,
        ),
        label: Text(
          pickedLocation == null
              ? "Pilih Lokasi pada Maps"
              : "Lokasi Terpilih ✓",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: pickedLocation == null
              ? AppColors.primary
              : Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildPhotoUploadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isSubmitting
            ? null
            : () async {
                final file = await ImagePickerHelper.pickImage();
                if (file == null) return;

                final url = await ref
                    .read(cloudinaryProvider.notifier)
                    .upload(file);
                if (url != null) {
                  setState(() => photos.add(url));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto berhasil diupload!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
        icon: const Icon(Icons.add_photo_alternate, size: 20),
        label: Text(
          photos.isEmpty
              ? "Upload Foto Lapangan"
              : "Tambah Foto (${photos.length})",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSubmitting
              ? [Colors.grey, Colors.grey]
              : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSubmitting
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : () => _submitField(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Mengirim...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Simpan Lapangan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitField(BuildContext context) async {
    if (pickedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi belum dipilih.")));
      return;
    }

    if (photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload minimal 1 foto lapangan.")),
      );
      return;
    }

    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama lapangan harus diisi.")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final authState = ref.read(authControllerProvider);
      final userId = authState.user?.uid;
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User tidak ditemukan")));
        setState(() => isSubmitting = false);
        return;
      }

      final id = const Uuid().v4();
      final model = FieldModel(
        fieldId: id,
        ownerId: userId,
        name: nameCtrl.text.trim(),
        locationName: locationCtrl.text.trim(),
        locationLatLng: pickedLocation!,
        description: descCtrl.text.trim(),
        facilityList: facilityCtrl.text
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        photos: photos,
        pricePerHour: int.tryParse(priceCtrl.text) ?? 0,
        isApproved: false,
      );

      await FieldRepo().create(model);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✅ Lapangan berhasil ditambahkan!\nMenunggu persetujuan admin.",
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      setState(() => isSubmitting = false);
    }
  }
}
