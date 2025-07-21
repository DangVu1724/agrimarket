class AppRoutes {
  // ===== PUBLIC ROUTES (Không cần authentication) =====
  static const String splash = '/splash';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerify = '/email-verify';
  static const String roleSelection = '/role-selection';
  static const String resetPassword = '/reset-password';

  // ===== AUTHENTICATION ROUTES (Cần authentication) =====
  static const String addAddress = '/add-address';
  static const String createStoreInfo = '/create-store-info';
  static const String createStoreAddress = '/create-store-address';

  // ===== BUYER ROUTES =====
  // Home & Navigation
  static const String buyerHome = '/buyer/home';
  static const String buyerHomeScreen = '/buyer/home-screen';

  // Shopping
  static const String store = '/buyer/store';
  static const String storeDetail = '/buyer/store-detail';
  static const String buyerProductDetail = '/buyer/product-detail';
  static const String buyerSearch = '/buyer/search';
  static const String categoryStoreScreen = '/buyer/category-store';
  static const String storePromotionList = '/buyer/store-promotion-list';
  static const String favourite = '/buyer/favourite';

  // Cart & Checkout
  static const String cart = '/buyer/cart';
  static const String checkOut = '/buyer/checkout';
  static const String discountCode = '/buyer/discount-code';
  static const String paymentMethod = '/buyer/payment-method';

  // Orders
  static const String buyerOrders = '/buyer/orders';
  static const String buyerOrderDetail = '/buyer/order-detail';

  // Profile & Settings
  static const String buyerProfile = '/buyer/profile';
  static const String buyerAccount = '/buyer/account';
  static const String buyerAddress = '/buyer/address';
  static const String buyerChatList = '/buyer/chatList';


  // Common (có thể dùng cho cả buyer và seller)
  static const String aboutApp = '/common/about-app';
  static const String help = '/common/help';
  static const String security = '/common/security';
  static const String privacyPolicy = '/common/privacy-policy';
  static const String settings = '/common/settings';

  // ===== SELLER ROUTES =====
  // Home & Navigation
  static const String sellerHome = '/seller/home';
  static const String sellerHomeScreen = '/seller/home-screen';

  // Store Management
  static const String storeInfo = '/seller/store-info';
  static const String sellerMenu = '/seller/menu';

  // Product Management
  static const String sellerProduct = '/seller/products';
  static const String sellerCreateProduct = '/seller/products/create';
  static const String sellerProductDetail = '/seller/products/detail';
  static const String sellerUpdateProduct = '/seller/products/update';

  // Profile Management
  static const String sellerProfile = '/seller/profile';

  // Order Management
  static const String sellerOrderList = '/seller/orders';

  // Financial & Revenue
  static const String sellerFinance = '/seller/finance';
  static const String sellerFinancial = '/seller/financial';
  static const String revenue = '/seller/revenue';

  // Promotions
  static const String sellerPromotions = '/seller/promotions';
  static const String sellerCreatePromotion = '/seller/promotions/create';
  static const String sellerCreateDiscountCode = '/seller/promotions/discount-code';
  static const String adminPromotion = '/seller/promotions/admin';

  // Communication
  static const String sellerChat = '/seller/chat';

  // Staff Management (future feature)
  static const String sellerStaff = '/seller/staff';

  // ===== HELPER METHODS =====

  /// Kiểm tra xem route có phải là public route không
  static bool isPublicRoute(String route) {
    final publicRoutes = [splash, dashboard, login, register, emailVerify, roleSelection, resetPassword];
    return publicRoutes.contains(route);
  }

  /// Kiểm tra xem route có phải là buyer route không
  static bool isBuyerRoute(String route) {
    return route.startsWith('/buyer/') ||
        route == cart ||
        route == checkOut ||
        route == discountCode ||
        route == paymentMethod ||
        route == buyerOrders ||
        route == buyerOrderDetail ||
        route == buyerProfile ||
        route == buyerAccount ||
        route == buyerAddress ||
        route == store ||
        route == buyerProductDetail ||
        route == buyerSearch ||
        route == categoryStoreScreen ||
        route == storePromotionList ||
        route == favourite ||
        route == addAddress;
  }

  /// Kiểm tra xem route có phải là seller route không
  static bool isSellerRoute(String route) {
    return route.startsWith('/seller/') ||
        route == createStoreInfo ||
        route == createStoreAddress ||
        route == storeInfo ||
        route == sellerMenu ||
        route == sellerProduct ||
        route == sellerCreateProduct ||
        route == sellerProductDetail ||
        route == sellerUpdateProduct ||
        route == sellerOrderList ||
        route == sellerFinance ||
        route == sellerFinancial ||
        route == revenue ||
        route == sellerPromotions ||
        route == sellerCreatePromotion ||
        route == sellerCreateDiscountCode ||
        route == adminPromotion ||
        route == sellerChat ||
        route == sellerStaff;
  }

  /// Lấy default route theo role
  static String getDefaultRouteByRole(String? role) {
    switch (role) {
      case 'buyer':
        return buyerHome;
      case 'seller':
        return sellerHome;
      default:
        return roleSelection;
    }
  }
}
