import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/controllers/location_search_controller.dart';
import '/controllers/user_search_controller.dart';

import '/models/osm_location.dart';
import '/models/user.dart' as UserModel; // Đặt bí danh

import '/views/screens/location_screen.dart';
import '/views/screens/profile_screen.dart';
import '/constants.dart';

class SearchScreen extends StatefulWidget {
  final bool isPickerMode;

  SearchScreen({Key? key, this.isPickerMode = false}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {

  // Controllers cho UI
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();

  // Controllers cho Logic
  final LocationSearchController _locationController = Get.put(LocationSearchController());
  final UserSearchController _userController = Get.put(UserSearchController());

  String _hintText = "Tìm kiếm địa điểm"; // Placeholder (giống trong ảnh)

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi tab để cập nhật placeholder
    // Nếu là picker, chỉ hiển thị tab Địa điểm
    _tabController = TabController(length: widget.isPickerMode ? 1 : 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Cập nhật hint text khi đổi tab
  void _handleTabChange() {
    // Xóa kết quả cũ khi đổi tab
    _locationController.clearResults();
    _userController.searchUser(''); // Hàm searchUser cũ của bạn tự reset khi chuỗi rỗng
    _textController.clear();

    setState(() {
      if (_tabController.index == 0) {
        _hintText = "Tìm kiếm địa điểm";
      } else {
        _hintText = "Tìm kiếm người dùng";
      }
    });
  }

  // Hàm thực hiện tìm kiếm dựa trên tab hiện tại
  void _performSearch(String query) {
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    if (_tabController.index == 0) {
      // Tab 'Địa điểm'
      _locationController.searchLocation(query);
    } else {
      // Tab 'Người dùng'
      _userController.searchUser(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dùng màu nền của theme (sáng/tối)
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: (widget.isPickerMode)
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Get.back())
            : null,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: context.theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              hintText: _hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.camera_alt_outlined, color: Colors.grey[400]),
                onPressed: () => _locationController.searchByImage(),
              ),
            ),
            onSubmitted: (value) => _performSearch(value),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _performSearch(_textController.text.trim()),
            child: Text(
              'Tìm kiếm',
              style: TextStyle(color: buttonColor, fontSize: 16),
            ),
          )
        ],
        // 2. Thanh Tabs (Tích hợp tìm kiếm người dùng)
        bottom: widget.isPickerMode ? null : TabBar(
          controller: _tabController,
          indicatorColor: buttonColor,
          labelColor: context.theme.brightness == Brightness.dark ? Colors.white : Colors.black,
          tabs: [
            Tab(text: 'Địa điểm'),
            Tab(text: 'Người dùng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.isPickerMode
            ? [ _buildLocationSearchTab() ]
            : [
          _buildLocationSearchTab(),
          _buildUserSearchTab(),
        ],
      ),
    );
  }

  Widget _buildLocationSearchTab() {
    return Obx(() {
      if (_locationController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (_locationController.searchResults.value.isNotEmpty) {
        return _buildLocationResultsList();
      }
      return _buildLocationDefaultView();
    });
  }

  Widget _buildLocationDefaultView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentSearches(),
          _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Obx(() {
      if (_locationController.recentSearches.isEmpty) return Container();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._locationController.recentSearches.map((query) {
            return ListTile(
              leading: Icon(Icons.history, color: Colors.grey[400]),
              title: Text(query),
              onTap: () {
                _textController.text = query;
                _locationController.searchLocation(query);
              },
            );
          }).toList(),
          Divider(),
        ],
      );
    });
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đề xuất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () { /* TODO: Logic làm mới */ },
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Làm mới'),
              )
            ],
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _locationController.suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _locationController.suggestions[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(suggestion['name']!, style: TextStyle(color: Colors.redAccent)),
                // Dòng 'trailing' (hiển thị ảnh) đã bị xóa
                onTap: () {
                  _textController.text = suggestion['name']!;
                  _locationController.searchLocation(suggestion['name']!);
                },
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildLocationResultsList() {
    return ListView.builder(
      itemCount: _locationController.searchResults.value.length,
      itemBuilder: (context, index) {
        OsmLocation result = _locationController.searchResults.value[index];
        return ListTile(
          leading: Icon(Icons.location_pin, color: buttonColor),
          title: Text(result.name),
          subtitle: Text(
            result.displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            if (widget.isPickerMode) {
              // Nếu là Picker, trả kết quả về AddPostScreen
              Get.back(result: result);
            } else {
              // Nếu là Tab Search, đi đến chi tiết
              Get.to(() => LocationScreen(locationName: result.name));
            }
          },
        );
      },
    );
  }

  Widget _buildUserSearchTab() {
    return Obx(() {
      // Chỉ hiển thị kết quả nếu người dùng đã gõ gì đó
      if (_userController.searchedUsers.isEmpty) {
        return Center(child: Text('Tìm kiếm người dùng theo tên'));
      }
      return ListView.builder(
        itemCount: _userController.searchedUsers.length,
        itemBuilder: (context, index) {
          UserModel.User user = _userController.searchedUsers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                  user.avatarUrl ?? 'https://via.placeholder.com/150' // Ảnh placeholder
              ),
              backgroundColor: Colors.grey[800],
            ),
            title: Text(user.username),
            subtitle: Text(user.displayName ?? ''),
            onTap: () => Get.to(() => ProfileScreen(uid: user.uid)),
          );
        },
      );
    });
  }
}