# AriMarket

**AriMarket** là ứng dụng di động kết nối nông dân và người mua, cho phép nông dân trực tiếp đăng bán nông sản xanh, sạch, an toàn và người mua dễ dàng tìm kiếm, đặt hàng, và tương tác với nông dân. Ứng dụng được xây dựng bằng **Flutter** cho giao diện đa nền tảng và **Firebase** cho backend, đảm bảo trải nghiệm mượt mà và dễ mở rộng.

## Mục tiêu
- Tạo nền tảng để nông dân bán nông sản trực tiếp, giảm trung gian.
- Giúp người mua tiếp cận nông sản xanh, chất lượng cao với giá cả minh bạch.
- Xây dựng cộng đồng nông nghiệp bền vững thông qua giao tiếp trực tiếp giữa nông dân và người mua.

## Tính năng chính
- **Đăng ký/Đăng nhập/Phân quyền**:
  - Người dùng chọn vai trò: **Người bán** (Seller) hoặc **Người mua** (Buyer).
  - Đăng nhập/đăng ký qua email, số điện thoại, hoặc Google.
- **Người bán**:
  - Đăng, chỉnh sửa, xóa sản phẩm (rau, củ, quả, v.v.).
  - Quản lý đơn hàng (chờ xác nhận, đang giao, hoàn thành).
  - Chat trực tiếp với người mua.
  - Thống kế doanh thu
- **Người mua**:
  - Tìm kiếm và lọc sản phẩm theo loại, giá, hoặc khu vực.
  - Xem chi tiết sản phẩm
  - Thêm sản phẩm vào giỏ hàng và thanh toán (hỗ trợ VNPay, Momo, ZaloPay).
  - Đánh giá shop và sản phẩm
- **Chat**: Kết nối nông dân và người mua qua tin nhắn thời gian thực.
- **Thông báo**: Gửi cập nhật đơn hàng, khuyến mãi qua Firebase Cloud Messaging.

## Công nghệ sử dụng
- **Frontend**: Flutter (Dart) - Phát triển ứng dụng đa nền tảng (iOS, Android).
- **Backend**: Firebase
  - **Firebase Authentication**: Xác thực người dùng.
  - **Cloud Firestore**: Lưu trữ thông tin người dùng, sản phẩm, đơn hàng, và chat.
  - **Firebase Storage**: Lưu trữ hình ảnh sản phẩm.
  - **Firebase Cloud Messaging**: Gửi thông báo đẩy.
- **Thanh toán**: Tích hợp VNPay, ZaloPay (hoặc các cổng thanh toán khác).
- **Quản lý trạng thái và điều hướng**: GetX - Quản lý giỏ hàng, vai trò người dùng, và điều hướng màn hình.
- **Bản đồ** : Flutter Map với OpenStreetMap và latlong2.

## Phương pháp phát triển
 **Agile**:
- Phát triển theo vòng lặp (sprint) 2-3 tuần.
- Thu thập phản hồi thường xuyên từ nông dân và người mua để cải thiện tính năng.
- Ưu tiên các user story và cung cấp các bản cập nhật thường xuyên (VD: MVP với các tính năng cốt lõi).

## Kiến trúc
**MVVM (Model-View-ViewModel)**:
- **Model**: Định nghĩa cấu trúc dữ liệu (VD: Product, User, Order) và tương tác với Firebase.
- **View**: Các màn hình và widget Flutter, hiển thị dữ liệu và xử lý tương tác người dùng.
- **ViewModel**: Các GetX controller (VD: AuthController, CartController) xử lý logic nghiệp vụ, cập nhật trạng thái, và kết nối Model với View.
**Lợi ích**: Tách biệt logic và giao diện, dễ kiểm thử, bảo trì mã nguồn.

## Cấu trúc dự án
```
lib/
├── app/
│   ├── routes/
│   │   ├── app_routes.dart                    # Định nghĩa các route
│   │   └── my_app_routes.dart                 # Quản lý điều hướng
│   ├── theme/
│   │   ├── app_colors.dart                    # Màu sắc giao diện
│   │   └── app_text_styles.dart               # Kiểu chữ
├── core/
│   ├── widgets/
│   │   ├── custom_button.dart                 # Nút tùy chỉnh
│   │   └── custom_text_field.dart             # Trường nhập liệu tùy chỉnh
├── features/
│   ├── auth/
│   │   ├── view/
│   │   │   ├── login_screen.dart              # Màn hình đăng nhập
│   │   │   └── reset_password_screen.dart     # Màn hình đặt lại mật khẩu
│   │   ├── viewmodel/
│   │   │   ├── login_view_model.dart           # ViewModel đăng nhập
│   │   │   └── forgot_password_view_model.dart # ViewModel quên mật khẩu
│   ├── buyer/
│   │   ├── view/
│   │   │   └── add_address.dart                # Màn hình thêm địa chỉ
│   │   ├── viewmodel/
│   │   │   └── add_address_vm.dart             # ViewModel thêm địa chỉ
├── main.dart                                   # Điểm vào ứng dụng
```

## Yêu cầu cài đặt
- **Flutter**: Phiên bản 3.0.0 trở lên.
- **Dart**: Phiên bản 2.12 trở lên.
- **Firebase**: Tài khoản Firebase với các dịch vụ đã kích hoạt (Authentication, Firestore, Storage, Cloud Messaging).
- **IDE**: VS Code hoặc Android Studio.
- **Thiết bị thử nghiệm**: Android (API 21+) hoặc iOS (12.0+).

## Hướng dẫn cài đặt
1. **Clone repository**:
   ```bash
   git clone https://github.com/DangVu1724/agrimarket.git
   cd arimarket
   ```

2. **Cài đặt dependencies**:
   ```bash
   flutter pub get
   ```

3. **Cấu hình Firebase**:
   - Tạo dự án trên [Firebase Console](https://console.firebase.google.com).
   - Thêm ứng dụng Android và iOS:
     - Android: Tải file `google-services.json` và đặt vào `android/app`.
     - iOS: Tải file `GoogleService-Info.plist` và đặt vào `ios/Runner`.
   - Kích hoạt Authentication, Firestore, Storage, và Cloud Messaging trong Firebase Console.

4. **Cấu hình Security Rules** (Firestore):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'farmer';
       }
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

5. **Chạy ứng dụng**:
   ```bash
   flutter run
   ```

## Cách sử dụng
1. **Đăng ký/Đăng nhập**:
   - Mở ứng dụng.
   - Đăng ký bằng email/mật khẩu hoặc Google.
   - Chọn vai trò (Nông dân hoặc Người mua)
2. **Nông dân**:
   - Thêm sản phẩm: Nhập tên, giá, mô tả, và tải ảnh lên.
   - Quản lý đơn hàng: Xem và cập nhật trạng thái đơn hàng.
   - Chat: Trả lời tin nhắn từ người mua.
   - Thống kế doanh thu hàng tháng
3. **Người mua**:
   - Tìm kiếm sản phẩm: Sử dụng thanh tìm kiếm hoặc bộ lọc.
   - Xem chi tiết sản phẩm
   - Thêm vào giỏ hàng và thanh toán qua VNPay/ZaloPay.
   - Đánh giá sản phẩm sau khi nhận hàng.
4. **Chat**: Gửi tin nhắn để trao đổi thông tin về sản phẩm.
5. **Thông báo**: Nhận cập nhật về đơn hàng hoặc khuyến mãi.

## Kế hoạch phát triển
- **MVP (Minimum Viable Product)**:
  - Đăng ký/đăng nhập với phân quyền.
  - Đăng/tìm kiếm sản phẩm, giỏ hàng, thanh toán.
  - Chat cơ bản giữa nông dân và người mua.
- **Tính năng tương lai**:
  - Phân tích dữ liệu mua sắm để gợi ý sản phẩm.
  - Hỗ trợ đa ngôn ngữ (tiếng Anh, tiếng Việt).
  - Tích hợp AI để kiểm tra chất lượng hình ảnh sản phẩm.

---
