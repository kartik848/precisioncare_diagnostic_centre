import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:precisioncare_app/models/diagnostic_category.dart';
import 'package:precisioncare_app/models/diagnostic_service.dart';
import 'package:precisioncare_app/providers/auth_provider.dart';
import 'package:precisioncare_app/providers/catalog_provider.dart';
import 'package:precisioncare_app/services/catalog_service.dart';
import 'package:precisioncare_app/screens/auth/precisioncarelogin.dart';
import 'package:precisioncare_app/widgets/motion_logo_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DiagnosticCategory & DiagnosticService Unit Tests', () {
    test('DiagnosticCategory maps correctly to and from map', () {
      final category = DiagnosticCategory(
        id: 'cat_xray_test',
        name: 'Digital X-Ray Test',
        description: 'Radiography diagnostics',
        iconType: 'xray',
        badge: 'Fast DR',
        isHomeVisitAvailable: true,
        isInHouseAvailable: true,
        sortOrder: 1,
      );

      final map = category.toMap();
      expect(map['name'], 'Digital X-Ray Test');
      expect(map['iconType'], 'xray');
      expect(map['badge'], 'Fast DR');

      final fromMap = DiagnosticCategory.fromMap(map, 'cat_xray_test');
      expect(fromMap.id, 'cat_xray_test');
      expect(fromMap.name, 'Digital X-Ray Test');
      expect(fromMap.iconData, Icons.medical_information_rounded);
    });

    test('DiagnosticService maps categoryId correctly', () {
      const service = DiagnosticService(
        id: 'test_xray_1',
        title: 'Digital Chest X-Ray PA View',
        categoryName: 'Digital X-Ray',
        categoryId: 'cat_xray',
        category: ServiceCategory.homeVisit,
        description: 'Portable chest x-ray',
        price: 999.0,
        preparation: 'Wear loose clothing',
        sampleType: 'DR Film',
        turnaroundTime: '2 Hours',
        iconType: 'xray',
      );

      final map = service.toMap();
      expect(map['categoryId'], 'cat_xray');
      expect(map['categoryName'], 'Digital X-Ray');

      final parsed = DiagnosticService.fromMap(map, 'test_xray_1');
      expect(parsed.categoryId, 'cat_xray');
      expect(parsed.categoryName, 'Digital X-Ray');
    });
  });

  group('CatalogProvider Strict Category Filtering Tests', () {
    test('X-Ray category filter returns ONLY X-Ray tests and NO blood/ECG tests', () {
      final provider = CatalogProvider();

      // Set filter to Digital X-Ray
      provider.setCategoryFilter('Digital X-Ray');
      final filtered = provider.filteredServices;

      expect(filtered.isNotEmpty, isTrue);

      // Verify EVERY test in the filtered list is strictly an X-Ray test
      for (final test in filtered) {
        final isXray = test.categoryId == 'cat_xray' ||
            test.iconType == 'xray' ||
            test.title.toLowerCase().contains('x-ray') ||
            test.title.toLowerCase().contains('xray') ||
            test.categoryName.toLowerCase().contains('x-ray') ||
            test.categoryName.toLowerCase().contains('xray');
        expect(isXray, isTrue, reason: '${test.title} should not appear under X-Ray filter');

        // Verify NO blood test or ECG appears
        expect(test.title.contains('Complete Blood Count'), isFalse);
        expect(test.title.contains('Thyroid'), isFalse);
        expect(test.title.contains('12-Lead Digital ECG'), isFalse);
      }
    });

    test('Blood Tests category filter returns ONLY Blood tests and NO X-Ray tests', () {
      final provider = CatalogProvider();

      // Set filter to Blood Tests
      provider.setCategoryFilter('Blood Tests');
      final filtered = provider.filteredServices;

      expect(filtered.isNotEmpty, isTrue);

      for (final test in filtered) {
        final isXray = test.iconType == 'xray' ||
            test.title.toLowerCase().contains('x-ray') ||
            test.title.toLowerCase().contains('xray');
        expect(isXray, isFalse, reason: 'X-Ray test ${test.title} should not appear under Blood Tests filter');

        final isPhysio = test.category == ServiceCategory.physiotherapy;
        expect(isPhysio, isFalse);
      }
    });

    test('ECG & Cardiology category filter returns ONLY ECG and Heart tests', () {
      final provider = CatalogProvider();

      provider.setCategoryFilter('ECG & Cardiology');
      final filtered = provider.filteredServices;

      expect(filtered.isNotEmpty, isTrue);
      for (final test in filtered) {
        final isEcgOrHeart = test.categoryId == 'cat_ecg' ||
            test.iconType == 'ecg' ||
            test.iconType == 'stress_test' ||
            test.title.toLowerCase().contains('ecg') ||
            test.title.toLowerCase().contains('stress') ||
            test.title.toLowerCase().contains('echocardiography');
        expect(isEcgOrHeart, isTrue, reason: '${test.title} should be ECG or heart related');
      }
    });
  });

  group('MotionLogo Widget Test', () {
    testWidgets('MotionLogo renders with animated properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MotionLogo(
                size: 64,
                showRipples: true,
                showShimmer: true,
                showFloating: true,
                showHeartbeat: true,
                badgeText: 'NABL',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MotionLogo), findsOneWidget);
      expect(find.text('NABL'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('PrecisionCareLoginScreen Widget Test', () {
    testWidgets('PrecisionCareLoginScreen displays inspired UI components with original email/password form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => CatalogProvider()),
          ],
          child: const MaterialApp(
            home: PrecisionCareLoginScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Verify Skip button
      expect(find.text('Skip'), findsOneWidget);

      // Verify PrecisionCare Brand & Tagline
      expect(find.text('PrecisionCare'), findsOneWidget);
      expect(find.text('Bringing care to health'), findsOneWidget);

      // Verify "Log in or sign up" section & header
      expect(find.text('Log in or sign up'), findsOneWidget);
      expect(find.text('Patient Portal Sign In'), findsOneWidget);

      // Verify original Email & Password fields
      expect(find.text('Registered Email Address'), findsOneWidget);
      expect(find.text('Account Password'), findsOneWidget);

      // Verify original Sign In button
      expect(find.text('Sign In to Health Portal'), findsOneWidget);

      // Verify original Register link
      expect(find.text('Create Patient Account'), findsOneWidget);

      // Verify SSL & HIPAA Guarantee
      expect(find.text('256-Bit SSL Encrypted & HIPAA Compliant Health Portal'), findsOneWidget);

      // Verify Terms and Privacy footer
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });
  });

  group('Admin Catalog Category Management & Isolation Tests', () {
    test('Newly added test is strictly isolated to its selected category', () {
      final customService = DiagnosticService(
        id: 'test_mri_101',
        title: 'Brain MRI 3.0 Tesla High Resolution',
        categoryName: 'MRI & Neuro Imaging',
        categoryId: 'cat_mri_scan',
        category: ServiceCategory.inHouseDiagnostic,
        description: 'Advanced neuro magnetic resonance scan',
        price: 3500.0,
        preparation: 'Remove all metal objects',
        sampleType: 'Scan',
        turnaroundTime: '12 Hours',
        iconType: 'body',
      );

      final catalog = [
        ...CatalogService.initialServices,
        customService,
      ];

      // 1. Digital X-Ray should NOT contain this MRI test
      final xrayTests = catalog.where((test) {
        final filterLower = 'digital x-ray';
        if (test.categoryId == 'cat_blood' || test.categoryId == 'cat_ecg' || test.categoryId == 'cat_usg' || test.categoryId == 'cat_pft' || test.categoryId == 'cat_physio' || test.categoryId == 'cat_packages') {
          return false;
        }
        return test.categoryId == 'cat_xray' ||
            test.iconType == 'xray' ||
            test.categoryName.toLowerCase().contains('x-ray') ||
            test.categoryName.toLowerCase().contains('xray') ||
            test.title.toLowerCase().contains('x-ray') ||
            test.title.toLowerCase().contains('xray');
      }).toList();

      expect(xrayTests.any((t) => t.id == 'test_mri_101'), isFalse);

      // 2. Blood Tests should NOT contain this MRI test
      final bloodTests = catalog.where((test) {
        final isXray = test.iconType == 'xray' ||
            test.title.toLowerCase().contains('x-ray') ||
            test.title.toLowerCase().contains('xray');
        if (isXray || test.categoryId == 'cat_packages' || test.category == ServiceCategory.healthPackage) return false;
        return test.categoryId == 'cat_blood' ||
            test.iconType == 'blood' ||
            test.categoryName.toLowerCase().contains('blood') ||
            test.title.toLowerCase().contains('blood') ||
            test.title.toLowerCase().contains('cbc') ||
            test.title.toLowerCase().contains('lipid') ||
            test.title.toLowerCase().contains('thyroid') ||
            test.title.toLowerCase().contains('diabetes');
      }).toList();

      expect(bloodTests.any((t) => t.id == 'test_mri_101'), isFalse);

      // 3. MRI & Neuro Category should ONLY match this MRI test
      final mriTests = catalog.where((test) {
        final filterLower = 'mri & neuro imaging';
        return (test.categoryId != null && test.categoryId!.toLowerCase() == 'cat_mri_scan') ||
            test.categoryName.trim().toLowerCase() == filterLower;
      }).toList();

      expect(mriTests.length, 1);
      expect(mriTests.first.id, 'test_mri_101');
      expect(mriTests.first.title, 'Brain MRI 3.0 Tesla High Resolution');
    });

    test('X-Ray test added with cat_xray appears strictly in Digital X-Ray and not in Blood Tests', () {
      final customXray = DiagnosticService(
        id: 'test_xray_lumbar',
        title: 'Lumbar Spine AP & LAT Digital X-Ray',
        categoryName: 'Digital X-Ray',
        categoryId: 'cat_xray',
        category: ServiceCategory.homeVisit,
        description: 'Two views digital radiography',
        price: 850.0,
        preparation: 'Wear comfortable clothing',
        sampleType: 'DR Film',
        turnaroundTime: '2 Hours',
        iconType: 'xray',
      );

      final catalog = [
        ...CatalogService.initialServices,
        customXray,
      ];

      // Digital X-Ray filter check
      final xrayTests = catalog.where((test) {
        if (test.categoryId == 'cat_blood' || test.categoryId == 'cat_ecg' || test.categoryId == 'cat_usg' || test.categoryId == 'cat_pft' || test.categoryId == 'cat_physio' || test.categoryId == 'cat_packages') {
          return false;
        }
        return test.categoryId == 'cat_xray' ||
            test.iconType == 'xray' ||
            test.categoryName.toLowerCase().contains('x-ray') ||
            test.categoryName.toLowerCase().contains('xray') ||
            test.title.toLowerCase().contains('x-ray') ||
            test.title.toLowerCase().contains('xray');
      }).toList();

      expect(xrayTests.any((t) => t.id == 'test_xray_lumbar'), isTrue);

      // Blood Tests filter check
      final bloodTests = catalog.where((test) {
        final isXray = test.iconType == 'xray' ||
            test.title.toLowerCase().contains('x-ray') ||
            test.title.toLowerCase().contains('xray');
        if (isXray || test.categoryId == 'cat_packages' || test.category == ServiceCategory.healthPackage) return false;
        return test.categoryId == 'cat_blood' ||
            test.iconType == 'blood' ||
            test.categoryName.toLowerCase().contains('blood') ||
            test.title.toLowerCase().contains('blood');
      }).toList();

      expect(bloodTests.any((t) => t.id == 'test_xray_lumbar'), isFalse);
    });
  });
}

