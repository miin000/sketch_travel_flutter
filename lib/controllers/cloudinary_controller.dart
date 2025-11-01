import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:get/get.dart';

class CloudinaryController extends GetxController {
  static CloudinaryController instance = Get.find();

  // === 1. ĐIỀN THÔNG TIN CỦA BẠN VÀO ĐÂY ===
  final String _cloudName = 'dcfuybexm';
  final String _uploadPreset = 'sketchtravel_preset';
  final String _apiKey = '589461956614462';
  // ======================================

  late final CloudinaryPublic _cloudinary;

  @override
  void onInit() {
    super.onInit();
    _cloudinary = CloudinaryPublic(
      _cloudName,
      _uploadPreset,
      cache: false, // Tắt cache
    );
  }

  /// Tải ảnh lên Cloudinary và trả về URL
  Future<String> uploadImage(Uint8List imageBytes) async {
    try {
      print('Cloudinary: Bắt đầu tải ảnh lên...');
      CloudinaryResponse response = await _cloudinary.uploadFile(

        CloudinaryFile.fromBytesData(
          imageBytes, // Dữ liệu ảnh

          // === SỬA LỖI TẠI ĐÂY (Dòng 34) ===
          // Thêm tham số 'identifier' (tên file) bắt buộc
          identifier: 'user_profile_${DateTime.now().millisecondsSinceEpoch}',
          // =================================

          folder: 'profilePics',
          context: {'api_key': _apiKey},
        ),
      );

      print('Cloudinary: Tải lên thành công! URL: ${response.secureUrl}');
      return response.secureUrl; // Trả về đường dẫn HTTPS

    } on CloudinaryException catch (e) {
      print('Cloudinary: Lỗi tải ảnh: ${e.message}');
      rethrow; // Ném lỗi ra để AuthController bắt
    } catch (e) {
      print('Cloudinary: Lỗi không xác định: $e');
      rethrow;
    }
  }
}