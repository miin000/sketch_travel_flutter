import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/models/osm_location.dart';

class LocationSearchController extends GetxController {
  final Rx<bool> isLoading = false.obs;
  final Rx<List<OsmLocation>> searchResults = Rx<List<OsmLocation>>([]);
  final _box = GetStorage();
  final String _recentSearchKey = 'recent_searches';

  // Danh sách Đề xuất (theo Figma)
  final List<Map<String, String>> suggestions = [
    {
      'name': 'Vịnh Hạ Long',
      'image': 'https://example.com/ha_long_bay.jpg' // Thay bằng link ảnh thật
    },
    {
      'name': 'Nha Trang',
      'image': 'https://example.com/nha_trang.jpg' // Thay bằng link ảnh thật
    },
    {
      'name': 'Đà Lạt',
      'image': 'https://example.com/da_lat.jpg' // Thay bằng link ảnh thật
    },
  ];

  // Lấy lịch sử tìm kiếm
  final Rx<List<String>> _recentSearches = Rx<List<String>>([]);
  List<String> get recentSearches => _recentSearches.value;

  @override
  void onInit() {
    super.onInit();
    _recentSearches.value = List<String>.from(_box.read(_recentSearchKey) ?? []);
  }

  // Thêm vào lịch sử tìm kiếm
  void _addRecentSearch(String query) {
    if (query.isEmpty) return;

    var list = _recentSearches.value;
    // Xóa nếu đã tồn tại để đẩy lên đầu
    list.remove(query);
    // Thêm lên đầu
    list.insert(0, query);
    // Giới hạn 5 mục
    if (list.length > 5) {
      list = list.sublist(0, 5);
    }
    _recentSearches.value = list;
    _box.write(_recentSearchKey, list);
  }

  // Xóa kết quả (khi nhấn "Back" hoặc "X")
  void clearResults() {
    searchResults.value = [];
  }

  // Gọi API Nominatim
  Future<void> searchLocation(String query) async {
    if (query.isEmpty) return;

    isLoading.value = true;
    searchResults.value = []; // Xóa kết quả cũ

    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=10&accept-language=vi');

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'com.sketchtravel.app' // API yêu cầu 1 User-Agent
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        searchResults.value = data
            .map((json) => OsmLocation.fromJson(json))
            .toList();
      } else {
        Get.snackbar('Lỗi API', 'Không thể tìm kiếm: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    } finally {
      isLoading.value = false;
      // === SỬA LỖI TẠI ĐÂY (Dòng 89) ===
      if (searchResults.value.isNotEmpty) { // Thêm .value
        _addRecentSearch(query); // Chỉ lưu nếu tìm thấy
      }
    }
  }

  // TODO: Hàm tìm kiếm bằng ảnh
  void searchByImage() {
    Get.snackbar(
      'Sắp có!',
      'Chức năng tìm kiếm bằng hình ảnh đang được phát triển.',
    );
  }
}