# AriMarket

**AriMarket** là ứng dụng di động kết nối trực tiếp **nông dân** và **người tiêu dùng**, cho phép nông dân đăng bán nông sản xanh, sạch, an toàn và giúp người mua dễ dàng tìm kiếm, đặt hàng và trao đổi trực tiếp với người sản xuất.

Dự án được xây dựng với mục tiêu giảm thiểu trung gian, minh bạch hoá nguồn gốc nông sản và hình thành một hệ sinh thái nông nghiệp số bền vững.

🎥 **Video demo**: [https://youtu.be/_7xsqqWk_p4](https://youtu.be/_7xsqqWk_p4)

🎥 **Video demo (Thông báo)**: https://youtube.com/shorts/04MGTvRMbCw?feature=share

---

## 🎯 Mục tiêu dự án

* Kết nối trực tiếp nông dân và người mua, không qua trung gian
* Cung cấp nguồn nông sản rõ nguồn gốc, giá cả minh bạch
* Xây dựng nền tảng giao tiếp và giao dịch nông sản hiện đại
* Áp dụng Flutter, Firebase và kiến trúc MVVM vào bài toán thực tế

---

## 🛠️ Công nghệ sử dụng

### 📱 Mobile Application

* **Flutter (Dart)**
  Xây dựng ứng dụng đa nền tảng Android và iOS

### ☁️ Backend-as-a-Service

* **Firebase Authentication**
  Xác thực người dùng
* **Cloud Firestore**
  Cơ sở dữ liệu NoSQL thời gian thực
* **Firebase Cloud Messaging (FCM)**
  Gửi thông báo đẩy

### 🖥️ Backend Server riêng

* **Node.js + ExpressJS**
* **Firebase Admin SDK**
* **node-cron**
* **REST API**

### 🔄 State Management & Navigation

* **GetX**

### 💳 Thanh toán

* **VNPay**

### 🗺️ Bản đồ & vị trí

* **Flutter Map**
* **OpenStreetMap**

---

## ✨ Tính năng chính

### 🔐 Xác thực & phân quyền

* Đăng ký và đăng nhập bằng Email, số điện thoại hoặc Google
* Phân quyền người dùng:

  * **Seller (Người bán)**
  * **Buyer (Người mua)**

---

### 👨‍🌾 Chức năng cho Người bán

* Đăng, chỉnh sửa và xoá sản phẩm nông sản
* Quản lý menu cửa hàng
* Tạo mã giảm giá, flash sale
* Quản lý đơn hàng theo trạng thái
* Chat trực tiếp với người mua theo thời gian thực
* Thống kê doanh thu và số lượng đơn hàng
* Tính toán và thanh toán hoa hồng theo ngày

---

### 🛒 Chức năng cho Người mua

* Tìm kiếm và lọc sản phẩm
* Xem chi tiết sản phẩm và cửa hàng
* Quản lý giỏ hàng
* Thanh toán đơn hàng
* Đánh giá sản phẩm và cửa hàng
* Tích điểm đổi voucher
* Thăng hạng thành viên
* Mua sản phẩm flash sale

---

### 💬 Chat & Thông báo

* Chat realtime giữa người bán và người mua
* Nhận thông báo về:

  * Trạng thái đơn hàng
  * Khuyến mãi
  * Cập nhật thanh toán

---

## 🖥️ Backend Server riêng (ExpressJS)

Bên cạnh Firebase, AriMarket xây dựng **server backend riêng** bằng **ExpressJS** để xử lý các tác vụ nền và nghiệp vụ định kỳ.

### ⏰ Cron Job & Background Tasks

* Tự động kiểm tra và vô hiệu hoá:

  * Voucher hết hạn
  * Flash sale hết hạn
  * Mã giảm giá không còn hiệu lực
* Rà soát và cập nhật trạng thái đơn hàng quá hạn
* Gửi thông báo FCM tự động đến người dùng

### 🎯 Vai trò của server riêng

* Xử lý logic không phụ thuộc hành động người dùng
* Giảm tải nghiệp vụ cho mobile app
* Giúp hệ thống mở rộng và vận hành ổn định hơn

---

## 🧱 Kiến trúc hệ thống

### MVVM (Model – View – ViewModel)

* **Model**
  Định nghĩa dữ liệu và tương tác với Firebase
* **View**
  Màn hình và widget Flutter
* **ViewModel (GetX Controller)**
  Xử lý nghiệp vụ và quản lý trạng thái

---

## 📂 Cấu trúc thư mục

```text
lib/
├── app/
│   ├── routes/
│   └── theme/
├── core/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── buyer/
│   ├── seller/
│   └── order/
├── main.dart
```

---

## ⚙️ Yêu cầu môi trường

* Flutter >= 3.0.0
* Dart >= 2.12
* Firebase (Auth, Firestore, Storage, FCM)
* Android API 21+ hoặc iOS 12+
* VS Code hoặc Android Studio

---

## 🚀 Hướng dẫn cài đặt

```bash
git clone https://github.com/DangVu1724/agrimarket.git
cd agrimarket
flutter pub get
flutter run
```

Cấu hình Firebase:

* Android: `google-services.json`
* iOS: `GoogleService-Info.plist`

---

## 📈 Định hướng phát triển

* Gợi ý sản phẩm dựa trên hành vi mua sắm
* Hỗ trợ đa ngôn ngữ Việt và Anh
* Tích hợp nhiều phương thức thanh toán online

---

## 👤 Tác giả

**AriMarket** được phát triển như một dự án học tập và nghiên cứu, tập trung vào việc xây dựng ứng dụng Flutter kết hợp Firebase và ExpressJS trong lĩnh vực nông nghiệp số.

> *Kết nối nông dân – Lan toả nông sản sạch* 🌱
