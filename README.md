# AriMarket

**AriMarket** là ứng dụng di động kết nối trực tiếp **nông dân** và **người mua**, cho phép nông dân đăng bán nông sản xanh, sạch, an toàn và giúp người mua dễ dàng tìm kiếm, đặt hàng và trao đổi trực tiếp với người sản xuất.

Ứng dụng được phát triển bằng **Flutter** cho giao diện đa nền tảng và **Firebase** cho backend, hướng tới một hệ sinh thái nông nghiệp minh bạch, bền vững và dễ mở rộng.

---

## 🎯 Mục tiêu

* Giảm thiểu trung gian, giúp nông dân bán nông sản trực tiếp đến tay người tiêu dùng.
* Cung cấp cho người mua nguồn nông sản xanh, an toàn, rõ nguồn gốc với giá cả minh bạch.
* Xây dựng cộng đồng nông nghiệp bền vững thông qua giao tiếp và tương tác trực tiếp.

---

## Công nghệ sử dụng

### Mobile Application
- Flutter (Dart) – Xây dựng ứng dụng đa nền tảng Android & iOS

### Backend-as-a-Service (BaaS)
- Firebase Authentication – Xác thực người dùng
- Cloud Firestore – Cơ sở dữ liệu NoSQL
- Firebase Cloud Messaging – Thông báo đẩy

### State Management & Navigation
- GetX – Quản lý trạng thái và điều hướng

### Payment Integration
- VNPay
  
### Map & Location
- Flutter Map
- OpenStreetMap

---

## ✨ Tính năng chính

### 🔐 Xác thực & Phân quyền

* Đăng ký / đăng nhập bằng Email, số điện thoại hoặc Google.
* Phân quyền người dùng:

  * **Người bán (Seller)**
  * **Người mua (Buyer)**

---

### 👨‍🌾 Dành cho Người bán

* Đăng, chỉnh sửa và xoá sản phẩm (rau, củ, quả, nông sản).
* Tạo, cập nhật Menu cửa hàng
* Tạo các mã code giảm giá và các đợt giảm giá sản phẩm
* Quản lý đơn hàng theo trạng thái: chờ xác nhận, đang giao, hoàn thành.
* Chat trực tiếp với người mua theo thời gian thực.
* Thống kê doanh thu và số lượng đơn hàng.
* Thanh toán tiền hoa hồng định kỳ theo ngày

---

### 🛒 Dành cho Người mua

* Tìm kiếm và lọc sản phẩm.
* Xem chi tiết sản phẩm và thông tin cửa hàng.
* Quản lý giỏ hàng
* Thanh toán đơn hàng
* Đánh giá sản phẩm và cửa hàng sau khi mua.
* Tích điểm đổi voucher
* Tích điểm thăng hạng thành viên
* Mua các sản phẩm giá giá (Flash Sale)

---

### 💬 Chat & Thông báo

* Chat thời gian thực giữa nông dân và người mua.
* Nhận thông báo về trạng thái đơn hàng và khuyến mãi thông qua Firebase Cloud Messaging.

---

## 🧱 Kiến trúc hệ thống

### MVVM (Model – View – ViewModel)

* **Model**: Định nghĩa cấu trúc dữ liệu (Product, User, Order, Chat) và tương tác với Firebase.
* **View**: Các màn hình và widget Flutter, chịu trách nhiệm hiển thị UI.
* **ViewModel (GetX Controller)**: Xử lý logic nghiệp vụ, quản lý state và kết nối View với Model.

---

## 📂 Cấu trúc dự án

```text
lib/
├── app/
│   ├── routes/
│   │   ├── app_routes.dart
│   │   └── my_app_routes.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_text_styles.dart
├── core/
│   └── widgets/
│       ├── custom_button.dart
│       └── custom_text_field.dart
├── features/
│   ├── auth/
│   │   ├── view/
│   │   └── viewmodel/
│   ├── buyer/
│   │   ├── view/
│   │   └── viewmodel/
├── main.dart
```

---

## ⚙️ Yêu cầu cài đặt

* **Flutter** >= 3.0.0
* **Dart** >= 2.12
* **Firebase** (Authentication, Firestore, Storage, Cloud Messaging)
* **IDE**: VS Code hoặc Android Studio
* **Thiết bị test**: Android API 21+ hoặc iOS 12+

---

## 🚀 Hướng dẫn cài đặt

1. Clone repository:

```bash
git clone https://github.com/DangVu1724/agrimarket.git
cd arimarket
```

2. Cài đặt dependencies:

```bash
flutter pub get
```

3. Cấu hình Firebase:

* Android: thêm `google-services.json` vào `android/app`
* iOS: thêm `GoogleService-Info.plist` vào `ios/Runner`
* Kích hoạt Authentication, Firestore, Storage, Cloud Messaging

4. Chạy ứng dụng:

```bash
flutter run
```

---

## 🧪 Cách sử dụng

### Người bán

* Thêm và quản lý sản phẩm.
* Theo dõi và cập nhật trạng thái đơn hàng.
* Chat với người mua.
* Xem thống kê doanh thu.

### Người mua

* Tìm kiếm và xem chi tiết sản phẩm.
* Thêm sản phẩm vào giỏ hàng và thanh toán.
* Đánh giá sản phẩm và cửa hàng.

---

## 📈 Kế hoạch phát triển

### Tương lai

* Gợi ý sản phẩm dựa trên hành vi mua sắm.
* Hỗ trợ đa ngôn ngữ (Việt – Anh).
* Tích hợp AI đánh giá chất lượng hình ảnh sản phẩm.

---

## 👤 Tác giả

AriMarket được phát triển như một dự án học tập và nghiên cứu, tập trung vào việc áp dụng Flutter, Firebase và kiến trúc MVVM vào bài toán thực tế trong lĩnh vực nông nghiệp số.

> *Kết nối nông dân – Lan toả nông sản sạch* 🌱
