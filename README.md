# Sketch Travel ✈️

**Sketch Travel** là một ứng dụng mạng xã hội di động, đa nền tảng (cross-platform) được xây dựng bằng **Flutter**. Ứng dụng này được thiết kế đặc biệt cho cộng đồng yêu thích du lịch, kết hợp trải nghiệm cuộn feed trực quan (tương tự TikTok) với một hệ thống cơ sở dữ liệu mạnh mẽ xoay quanh các địa điểm.

Người dùng có thể chia sẻ các khoảnh khắc (bài đăng có nhiều ảnh) từ chuyến đi của mình, gắn thẻ (tag) các địa điểm cụ thể. Sau đó, cộng đồng có thể khám phá các địa điểm đó để xem tất cả bài đăng, đọc và viết đánh giá, và kết nối với những người dùng khác.

## Member
- [Phạm Quang Minh - 23010489](https://github.com/miin000)

- [Nguyễn Văn Quang - 23011955](https://github.com/JCakaQuang)

## Link youtube demo: 
- [https://youtu.be/sloEyhPcLKA](https://youtu.be/sloEyhPcLKA)

## ✨ Tính năng chính

Dự án này bao gồm một bộ tính năng xã hội và khám phá phong phú:

* **🌍 Feed chính "TikTok-Style":** Giao diện cuộn dọc (`PostFeedScreen`) cho phép người dùng lướt qua các bài đăng một cách liền mạch.
* **📸 Bài đăng nhiều ảnh:** Người dùng có thể tải lên nhiều ảnh trong một bài đăng, được hiển thị dưới dạng một carousel cuộn ngang (`PageView`).
* **📍 Gắn thẻ & Khám phá Địa điểm:**
    * Gắn thẻ bài đăng với các địa điểm thực tế (sử dụng API OpenStreetMap) (`location_search_controller.dart`).
    * Nhấn vào một địa điểm sẽ mở màn hình chi tiết (`LocationScreen`) hiển thị thông tin, đánh giá, và tất cả các bài đăng khác được gắn thẻ tại đó.
* **⭐ Đánh giá cộng đồng:** Người dùng có thể xếp hạng (1-5 sao) và viết đánh giá (review) cho bất kỳ địa điểm nào (`location_controller.dart`).
* **🤝 Hệ thống Xã hội (Social Graph):**
    * Hệ thống Follow/Unfollow người dùng.
    * Logic **"Bạn bè"** tự động: Khi hai người dùng theo dõi lẫn nhau (mutual follow), họ sẽ tự động trở thành "bạn bè" (`profile_controller.dart`).
* **📥 Hòm thư (Mailbox) Real-time:**
    * **Thông báo:** Tab thông báo (`NotificationsScreen`) real-time cho các hoạt động: Likes, Comments, Follows, và Tin nhắn mới.
    * **Chat:** Hệ thống chat 1-1 (`ChatDetailScreen`) được mở khóa khi người dùng là "bạn bè".
* **🔍 Tìm kiếm kép:** Màn hình tìm kiếm (`SearchScreen`) có 2 tab:
    * Tìm kiếm Địa điểm (sử dụng API OSM).
    * Tìm kiếm Người dùng (sử dụng Firestore `searchKeywords`).
* **👤 Hồ sơ cá nhân:** Trang hồ sơ (`ProfileScreen`) hiển thị thông tin người dùng, thống kê, và 3 tab: Bài đã đăng, Bài đã thích, và Địa điểm đã lưu.
* **🎨 Chế độ Sáng/Tối:** Hỗ trợ chuyển đổi giao diện Light/Dark Mode (lưu trạng thái bằng `GetStorage`) (`theme_controller.dart`).

## 🛠️ Công nghệ & Kiến trúc

### Ngăn xếp Công nghệ (Tech Stack)

| Thành phần | Công nghệ | Mục đích |
| :--- | :--- | :--- |
| **Framework** | **Flutter** | Xây dựng giao diện người dùng (UI) đa nền tảng. |
| **Ngôn ngữ** | **Dart** | Ngôn ngữ lập trình chính. |
| **Kiến trúc** | **GetX** | Quản lý State, Dependency Injection, và Điều hướng (Routing). |
| **Database** | **Cloud Firestore** | Cơ sở dữ liệu NoSQL chính (lưu users, posts, locations, chats...). |
| **Xác thực** | **Firebase Auth** | Xử lý đăng ký, đăng nhập Email/Password. |
| **Lưu trữ Ảnh** | **Cloudinary** | Lưu trữ tất cả ảnh đại diện và ảnh bài đăng (thay vì Firebase Storage). |
| **API Địa điểm** | **OpenStreetMap (OSM)** | Tìm kiếm và lấy dữ liệu địa điểm (qua API Nominatim). |
| **Lưu trữ Cục bộ**| **GetStorage** | Lưu các cài đặt đơn giản (như trạng thái Dark Mode). |

### Kiến trúc Thư mục

Dự án tuân theo kiến trúc MVVM (Model-View-ViewModel) với GetX:

```
lib/
├── main.dart             # Điểm khởi đầu, khởi tạo Firebase & GetX
├── constants.dart        # Hằng số toàn cục (màu sắc, instance Firebase)
│
├── controllers/          # (ViewModel) Logic nghiệp vụ & Quản lý State
│   ├── auth_controller.dart
│   ├── post_controller.dart
│   ├── profile_controller.dart
│   ├── location_controller.dart
│   └── ...
│
├── models/               # (Model) Các lớp định nghĩa cấu trúc dữ liệu
│   ├── user.dart
│   ├── post.dart
│   ├── location.dart
│   ├── comment.dart
│   └── ...
│
└── views/                # (View) Giao diện người dùng (Widgets)
    ├── screens/          # Các màn hình chính (pages)
    │   ├── home_screen.dart
    │   ├── profile_screen.dart
    │   ├── add_post_screen.dart
    │   └── ...
    └── widgets/          # Các thành phần UI tái sử dụng
        ├── text_input_field.dart
        ├── post_grid_item.dart
        └── ...
```

## 🚀 Cài đặt và Chạy dự án

1.  **Clone Repository:**

    ```sh
    git clone https://github.com/miin000/sketch_travel_flutter
    cd sketch-travel-project
    ```

2.  **Lấy Dependencies:**

    ```sh
    flutter pub get
    ```

3.  **Thiết lập Firebase:**

    * Tạo một dự án mới trên [Bảng điều khiển Firebase](https://console.firebase.google.com/).
    * Thêm ứng dụng Android và/hoặc iOS vào dự án.
    * Tải file cấu hình `google-services.json` (cho Android) hoặc `GoogleService-Info.plist` (cho iOS) và đặt vào thư mục tương ứng (`android/app/` hoặc `ios/Runner/`).
    * Trong Bảng điều khiển Firebase, kích hoạt **Authentication** (phương thức Email/Password) và **Cloud Firestore**.
    * Trong Firestore Database chỉnh sửa rules như sau
     ```sh
    rules_version = '2';
    service cloud.firestore {
    match /databases/{database}/documents {
    
        match /{document=**} {
          allow read, write: if request.auth != null;
        }
      
        function isTestMode() {
          return request.time < timestamp.date(2026, 1, 1); 
        }
    
        match /users/{userId} {
          allow read, write: if isTestMode();
          match /followers/{docId} {
            allow read, write: if isTestMode();
          }
          match /following/{docId} {
             allow read, write: if isTestMode();
          }
        }
        
        // Rules cho Posts
        match /posts/{postId} {
          allow read, write: if isTestMode();
          match /comments/{commentId} {
             allow read, write: if isTestMode();
          }
        }
    
        // Rules cho Locations
        match /locations/{locationId} {
          allow read, write: if isTestMode();
          match /reviews/{reviewId} {
             allow read, write: if isTestMode();
          }
        }
        
        // Rules cho FavoriteLocations
         match /favoriteLocations/{favId} {
           allow read, write: if isTestMode();
        }
        
        match /notifications/{userId}/userNotifications/{notifId} {
          // Bất kỳ ai đăng nhập cũng có thể TẠO (create) thông báo
          allow create: if isTestMode() && request.auth != null;
          
          // Chỉ người nhận (chủ sở hữu) mới được ĐỌC, SỬA, XÓA
          allow read, update, delete: if isTestMode() && request.auth.uid == userId;
        }
        
        match /chatRooms/{roomId} {

          allow read, create, update, delete: if isTestMode() && 
                request.auth.uid in roomId.split('_');
                
          match /messages/{messageId} {
             allow read, create: if isTestMode() && 
                  request.auth.uid in get(/databases/$(database)/documents/chatRooms/$(roomId)).data.participants;
          }
        }
    }
    }
    ```

4.  **Thiết lập Cloudinary:**

    * Tạo tài khoản trên [Cloudinary](https://cloudinary.com/).
    * Tìm `Cloud Name`, `API Key` và tạo một `Upload Preset` (chế độ "Unsigned").
    * Mở file `lib/controllers/cloudinary_controller.dart` và điền các giá trị này vào:
      ```dart
      final String _cloudName = 'TEN_CLOUD_CUA_BAN';
      final String _uploadPreset = 'UPLOAD_PRESET_CUA_BAN';
      final String _apiKey = 'API_KEY_CUA_BAN';
      ```

5.  **Chạy ứng dụng:**

    ```sh
    flutter run
    ```