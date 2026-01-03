import 'package:flutter/material.dart';
import '../features/oanboarding/onboarding_page.dart';
import '../features/onboarding/splash_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/auth/check_auth_page.dart';
import '../features/auth/email_verification_page.dart';
import '../features/explore/explore_page.dart';
import '../features/location/location_picker_page.dart';
import '../features/main/main_tab_page.dart';
import '../features/manager/manager_home_page.dart';
import '../features/manager/first_field_registration_page.dart';
import '../features/manager/pending_approval_page.dart';
import '../features/admin/admin_dashboard_page.dart';
import '../features/booking/pages/booking_page.dart';
import '../features/booking/pages/field_list_page.dart';
import '../features/booking/pages/payment_page.dart';
import '../features/booking/pages/payment_waiting_page.dart';
import '../features/booking/pages/field_detail_page_simple.dart';
import '../features/booking/pages/receipt_page.dart';
import '../features/booking/pages/review_order_page.dart';

class AppRouter {
  static const onboarding = '/onboarding';
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const emailVerification = '/email-verification';
  static const locationPicker = '/location-picker';
  static const booking = '/booking';
  static const fieldList = '/field-list';
  static const fieldDetail = '/field-detail';
  static const reviewOrder = '/review-order';
  static const payment = '/payment';
  static const receipt = '/receipt';
  static const paymentWaiting = '/payment-waiting';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case emailVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EmailVerificationPage(
            email: args?['email'] ?? '',
            role: args?['role'] ?? 'user',
            name: args?['name'] ?? '',
          ),
        );

      case "/check":
        return MaterialPageRoute(builder: (_) => const CheckAuthPage());

      case '/explore':
        return MaterialPageRoute(builder: (_) => const ExplorePage());

      case '/main':
        return MaterialPageRoute(builder: (_) => const MainTabPage());

      case '/home':
        // Backward-compat alias; route to main tabs
        return MaterialPageRoute(builder: (_) => const MainTabPage());

      case '/manager':
        return MaterialPageRoute(builder: (_) => const ManagerHomePage());

      case '/first-field-registration':
        return MaterialPageRoute(
          builder: (_) => const FirstFieldRegistrationPage(),
        );

      case '/pending-approval':
        return MaterialPageRoute(builder: (_) => const PendingApprovalPage());

      case booking:
        return MaterialPageRoute(
          builder: (_) => const BookingPage(),
          settings: settings,
        );

      case fieldList:
        return MaterialPageRoute(
          builder: (_) => const FieldListPage(),
          settings: settings,
        );

      case fieldDetail:
        return MaterialPageRoute(
          builder: (_) => const FieldDetailPageSimple(),
          settings: settings,
        );

      case reviewOrder:
        return MaterialPageRoute(
          builder: (_) => const ReviewOrderPage(),
          settings: settings,
        );

      case payment:
        return MaterialPageRoute(
          builder: (_) => const PaymentPage(),
          settings: settings,
        );

      case paymentWaiting:
        return MaterialPageRoute(
          builder: (_) => const PaymentWaitingPage(),
          settings: settings,
        );

      case receipt:
        return MaterialPageRoute(
          builder: (_) => const ReceiptPage(),
          settings: settings,
        );

      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      case locationPicker:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LocationPickerPage(
            initialLat: args?['lat'] as double?,
            initialLon: args?['lon'] as double?,
            initialAddress: args?['address'] as String?,
            viewOnly: args?['viewOnly'] == true,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('404'))),
        );
    }
  }
}
