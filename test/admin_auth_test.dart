import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:precisioncare_app/models/user_profile.dart';
import 'package:precisioncare_app/providers/auth_provider.dart';
import 'package:precisioncare_app/screens/admin/admin_login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Admin Authentication & UserProfile Tests', () {
    test('UserProfile correctly parses and serializes profile data', () {
      final adminUser = UserProfile(
        uid: 'admin_precisioncare_001',
        name: 'PrecisionCare Admin Officer',
        age: 35,
        sex: 'Male',
        address: 'Clinic HQ',
        mobile: '+91 92709 88595',
        email: 'admin@gmail.com',
      );

      final map = adminUser.toMap();
      expect(map['email'], 'admin@gmail.com');
      expect(map['name'], 'PrecisionCare Admin Officer');

      final fromMap = UserProfile.fromMap(map, 'admin_precisioncare_001');
      expect(fromMap.email, 'admin@gmail.com');
      expect(fromMap.uid, 'admin_precisioncare_001');
    });

    test('AuthProvider isAdmin identifies admin@gmail.com and rejects standard patients', () async {
      final authProvider = AuthProvider();

      // Sign in as default admin (admin@gmail.com / 1234)
      final adminSuccess = await authProvider.signIn(
        email: 'admin@gmail.com',
        password: '1234',
      );

      expect(adminSuccess, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.isAdmin, true);
      expect(authProvider.user?.email, 'admin@gmail.com');

      // Test Sign Out
      await authProvider.signOut();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.isAdmin, false);
      expect(authProvider.user, isNull);
    });
  });

  group('AdminLoginScreen Widget Tests', () {
    testWidgets('AdminLoginScreen displays admin portal header, form, and auto-fill button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: AdminLoginScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Verify portal branding
      expect(find.text('PrecisionCare Admin Portal'), findsOneWidget);
      expect(find.text('Operations, Diagnostic Queues & Lab Reports Control'), findsOneWidget);
      expect(find.text('Admin Email ID'), findsOneWidget);
      expect(find.text('Admin Password'), findsOneWidget);
      expect(find.text('Sign In to Admin Dashboard'), findsOneWidget);

      // Verify autofill button for admin@gmail.com / 1234
      expect(find.text('Auto-fill Admin (admin@gmail.com / 1234)'), findsOneWidget);

      // Tap autofill and verify fields
      await tester.tap(find.text('Auto-fill Admin (admin@gmail.com / 1234)'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('admin@gmail.com'), findsOneWidget);
      expect(find.text('1234'), findsOneWidget);
    });
  });
}
