# User Management App - Flutter Midterm Project

Ứng dụng quản lý người dùng với đầy đủ chức năng CRUD (Create, Read, Update, Delete) và xác thực đăng nhập.

## Tính năng

### 1. Quản lý người dùng (8.0 điểm)
- Cơ sở dữ liệu MongoDB với chính xác 4 trường:
  - username: Tên người dùng (khóa chính - unique)
  - email: Email
  - password: Mật khẩu
  - imageUrl: Hình ảnh đại diện (không bắt buộc)
- MongoDB tự tạo _id nhưng không sử dụng trong logic ứng dụng

### 2. Nhập và hiển thị hình ảnh (0.5 điểm)
- Chọn hình ảnh từ thư viện
- Hiển thị hình ảnh trong danh sách và form
- Hỗ trợ cả file local và URL

### 3. Chức năng nâng cao (1.5 điểm)
- Đăng nhập: Xác thực người dùng bằng email và password
- Thêm người dùng mới: Form nhập đầy đủ thông tin
- Sửa thông tin: Cập nhật thông tin người dùng
- Xóa người dùng: Xác nhận trước khi xóa
- Validation: Kiểm tra dữ liệu đầu vào
- UI/UX: Giao diện thân thiện, responsive

## Công nghệ sử dụng

- **Framework**: Flutter SDK 3.9.0+
- **State Management**: flutter_bloc
- **Database**: MongoDB (mongo_dart)
- **Image Picker**: image_picker
- **Architecture**: Clean Architecture
  - Domain Layer (Entities, Use Cases, Repositories)
  - Data Layer (Models, Data Sources, Repository Implementation)
  - Presentation Layer (BLoC, Pages, Widgets)

## Yêu cầu hệ thống

- Flutter SDK >= 3.9.0
- Dart SDK >= 3.9.0
- MongoDB Atlas account (hoặc MongoDB local)
- Android Studio / VS Code
- Android Emulator / iOS Simulator / Physical Device

## Cài đặt và chạy

### 1. Clone repository
```bash
git clone https://github.com/phamngocpho/flutter-midterm.git
cd midterm
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Cấu hình MongoDB
Mở file `lib/core/constants/app_constants.dart` và cập nhật MongoDB connection string:
```dart
static const String mongoDbUrl = 'mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<database>?retryWrites=true&w=majority';
static const String usersCollection = 'users';
```

### 4. Chạy ứng dụng
```bash
flutter run
```

## Hướng dẫn sử dụng

### Đăng nhập
1. Mở ứng dụng, màn hình đăng nhập sẽ hiện ra
2. Nhập email và password của một user đã tồn tại
3. Nhấn "Login" để đăng nhập
4. Hoặc nhấn "Skip Login (Admin Mode)" để vào chế độ quản trị

### Thêm người dùng mới
1. Từ màn hình danh sách, nhấn nút "+" ở góc dưới bên phải
2. Nhập thông tin:
   - Username (tối thiểu 3 ký tự)
   - Email (định dạng email hợp lệ)
   - Password (tối thiểu 6 ký tự)
   - Hình ảnh (tùy chọn - nhấn vào vòng tròn để chọn)
3. Nhấn "Create User"

### Sửa thông tin người dùng
1. Trong danh sách, nhấn icon "Edit" bên cạnh người dùng
2. Cập nhật thông tin cần thiết (email, password, image)
3. **Lưu ý**: Username không thể thay đổi vì là khóa chính
4. Nhấn "Update User"

### Xóa người dùng
1. Trong danh sách, nhấn icon "Delete" bên cạnh người dùng
2. Xác nhận xóa trong dialog

## Cấu trúc dự án

```
lib/
├── core/
│   ├── constants/          # App constants (MongoDB config)
│   ├── error/             # Error handling
│   ├── usecases/          # Base use case
│   └── utils/             # Utilities
├── features/
│   └── user_management/
│       ├── data/
│       │   ├── datasources/    # MongoDB data source
│       │   ├── models/         # User model
│       │   └── repositories/   # Repository implementation
│       ├── domain/
│       │   ├── entities/       # User entity
│       │   ├── repositories/   # Repository interface
│       │   └── usecases/       # Business logic
│       └── presentation/
│           ├── bloc/           # State management
│           ├── pages/          # Screens (Login, List, Form)
│           └── widgets/        # Reusable widgets
├── injection_container.dart    # Dependency injection
└── main.dart                  # Entry point
```

## Testing

### Test MongoDB connection
```bash
flutter run lib/test_mongodb_connection.dart
```

## Screenshots

### Màn hình đăng nhập
- Form đăng nhập với email và password
- Validation đầu vào
- Nút skip login cho admin

### Màn hình danh sách người dùng
- Hiển thị danh sách user với avatar
- Nút Edit và Delete cho mỗi user
- Nút thêm user mới
- Pull to refresh

### Màn hình form (Thêm/Sửa)
- Upload hình ảnh
- Các trường: username, email, password
- Validation đầy đủ
- Preview hình ảnh

## Xử lý lỗi

### Lỗi kết nối MongoDB
- Kiểm tra internet connection
- Kiểm tra MongoDB connection string
- Kiểm tra whitelist IP trong MongoDB Atlas

### Lỗi trên Android Emulator
- Restart emulator
- Kiểm tra DNS settings
- Thử với physical device

## Ghi chú
- **Username là khóa chính**: Mỗi username phải là duy nhất, không trùng lặp
- **Username không thể thay đổi**: Khi sửa user, chỉ có thể thay đổi email, password và image

- Password được lưu dưới dạng plain text (chỉ dùng cho mục đích học tập)
- Trong production, nên hash password trước khi lưu
- MongoDB tự động tạo trường `_id` nhưng không sử dụng trong logic ứng dụng
- Image được lưu dưới dạng file path (local) hoặc URL

## Tác giả

- **Họ tên**: Phạm Ngọc Phổ
- **MSSV**: 23IT212
- **Lớp**: 23SE3

## License

This project is for educational purposes only.
