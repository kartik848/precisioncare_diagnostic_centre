import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/diagnostic_service.dart';
import '../../models/promo_banner.dart';
import '../../models/staff_model.dart';
import '../../models/user_profile.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/app_image_view.dart';
import '../../widgets/empty_state.dart';
import 'widgets/add_staff_dialog.dart';
import 'widgets/add_test_dialog.dart';
import 'widgets/booking_action_dialog.dart';
import 'widgets/edit_banner_dialog.dart';
import 'widgets/upload_report_dialog.dart';
import 'widgets/send_patient_reminder_dialog.dart';
import '../../core/utils/field_order_pdf_generator.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedNavIndex = 0;

  final List<String> _navTitles = [
    'Incoming Booking Requests',
    'Active Home Visits & Dispatches',
    'Medical Staff & Technicians',
    'Diagnostic Test Catalog',
    'Promotional Banners & Offers',
    'Patient Users Directory',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().initAdminData();
    });
  }

  void _openAcceptDialog(BookingModel booking) {
    showDialog(context: context, builder: (_) => BookingActionDialog(booking: booking));
  }

  void _openUploadReportDialog(BookingModel booking) {
    showDialog(context: context, builder: (_) => UploadReportDialog(booking: booking));
  }

  void _openSendReminderDialog({String? patientId, String? patientName}) {
    showDialog(
      context: context,
      builder: (_) => SendPatientReminderDialog(
        initialUserId: patientId,
        initialPatientName: patientName,
      ),
    );
  }

  void _openAddStaffDialog([StaffMember? staff]) {
    showDialog(context: context, builder: (_) => AddStaffDialog(staffToEdit: staff));
  }

  void _openAddTestDialog([DiagnosticService? service]) {
    showDialog(context: context, builder: (_) => AddTestDialog(testToEdit: service));
  }

  void _openEditBannerDialog(PromoBanner banner) {
    showDialog(context: context, builder: (_) => EditBannerDialog(banner: banner));
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    final pending = admin.pendingRequests;
    final active = admin.activeVisits;
    final staff = admin.staffList;
    final catalog = admin.catalogServices;
    final banners = admin.banners;
    final users = admin.usersList;

    final isLargeScreen = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isLargeScreen
          ? null
          : Drawer(
              child: _buildSidebar(
                admin,
                pending.length,
                active.length,
                staff.length,
                catalog.length,
                banners.length,
                users.length,
                isDrawer: true,
              ),
            ),
      appBar: isLargeScreen
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset('assets/images/precisioncare_logo.jpeg', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _navTitles[_selectedNavIndex],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  tooltip: 'Refresh Data',
                  onPressed: () => admin.initAdminData(),
                ),
                IconButton(
                  icon: const Icon(Icons.notification_add_rounded, color: AppColors.accent, size: 20),
                  tooltip: 'Push Patient Reminder',
                  onPressed: () => _openSendReminderDialog(),
                ),
              ],
            ),
      body: Row(
        children: [
          // 1. LEFT SIDEBAR (On Large Screens)
          if (isLargeScreen)
            _buildSidebar(
              admin,
              pending.length,
              active.length,
              staff.length,
              catalog.length,
              banners.length,
              users.length,
            ),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // Top Header Bar (Desktop/Web only)
                if (isLargeScreen) _buildTopAppBar(admin),

                // Top Metrics Quick Strip
                _buildMetricsStrip(admin, isLargeScreen: isLargeScreen),
                const Divider(height: 1, color: AppColors.border),

                // Mobile Horizontal Navigation Tabs
                if (!isLargeScreen) _buildMobileNavBar(pending.length, active.length),

                // Active View Body
                Expanded(
                  child: admin.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildActiveContentView(
                          index: _selectedNavIndex,
                          pending: pending,
                          active: active,
                          staff: staff,
                          catalog: catalog,
                          banners: banners,
                          users: users,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // LEFT SIDEBAR WIDGET
  Widget _buildSidebar(
    AdminProvider admin,
    int pendingCount,
    int activeCount,
    int staffCount,
    int catalogCount,
    int bannersCount,
    int usersCount, {
    bool isDrawer = false,
  }) {
    return Container(
      width: isDrawer ? double.infinity : 260,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark Slate Theme
        border: Border(right: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Brand Header with Logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/precisioncare_logo.jpeg', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRECISIONCARE',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                        ),
                        Text(
                          'Admin Operations Panel',
                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  if (isDrawer)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),

            // Sidebar Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                children: [
                  _buildSidebarItem(
                    index: 0,
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending Requests',
                    badgeCount: pendingCount,
                    badgeColor: AppColors.accent,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    index: 1,
                    icon: Icons.run_circle_outlined,
                    label: 'Active Dispatches',
                    badgeCount: activeCount,
                    badgeColor: AppColors.info,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    index: 2,
                    icon: Icons.badge_outlined,
                    label: 'Staff Directory',
                    badgeCount: staffCount,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    index: 3,
                    icon: Icons.science_outlined,
                    label: 'Test Catalog & Prices',
                    badgeCount: catalogCount,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    index: 4,
                    icon: Icons.view_carousel_outlined,
                    label: 'Promotional Banners',
                    badgeCount: bannersCount,
                    isDrawer: isDrawer,
                  ),
                  _buildSidebarItem(
                    index: 5,
                    icon: Icons.people_alt_outlined,
                    label: 'Patient Users Directory',
                    badgeCount: usersCount,
                    isDrawer: isDrawer,
                  ),
                ],
              ),
            ),

            // Bottom Sidebar Actions
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.shield_rounded, size: 14, color: AppColors.primary),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Administrator (Active Session)',
                      style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
    Color badgeColor = const Color(0xFF334155),
    bool isDrawer = false,
  }) {
    final isSelected = _selectedNavIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          setState(() => _selectedNavIndex = index);
          if (isDrawer) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // MOBILE HORIZONTAL TAB SWITCHER
  Widget _buildMobileNavBar(int pendingCount, int activeCount) {
    final shortTabs = [
      {'title': 'Pending', 'badge': pendingCount, 'icon': Icons.pending_actions_rounded},
      {'title': 'Active', 'badge': activeCount, 'icon': Icons.run_circle_outlined},
      {'title': 'Staff', 'badge': null, 'icon': Icons.badge_outlined},
      {'title': 'Catalog', 'badge': null, 'icon': Icons.science_outlined},
      {'title': 'Banners', 'badge': null, 'icon': Icons.view_carousel_outlined},
      {'title': 'Users', 'badge': null, 'icon': Icons.people_alt_outlined},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(shortTabs.length, (idx) {
            final isSelected = _selectedNavIndex == idx;
            final item = shortTabs[idx];
            final badge = item['badge'] as int?;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    if (badge != null && badge > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badge',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? AppColors.primary : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                onSelected: (_) => setState(() => _selectedNavIndex = idx),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                showCheckmark: false,
              ),
            );
          }),
        ),
      ),
    );
  }

  // TOP APP BAR (Desktop / Web)
  Widget _buildTopAppBar(AdminProvider admin) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard_customize_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                _navTitles[_selectedNavIndex],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => admin.initAdminData(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh Data', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _openSendReminderDialog(),
                icon: const Icon(Icons.notification_add_rounded, size: 16, color: Colors.white),
                label: const Text('Push Reminder', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TOP METRICS STRIP (Responsive for Mobile & Desktop)
  Widget _buildMetricsStrip(AdminProvider admin, {required bool isLargeScreen}) {
    final statCards = [
      _buildStatCard('Pending Requests', '${admin.pendingRequests.length}', AppColors.accent, Icons.pending_actions_rounded),
      _buildStatCard('Active Dispatches', '${admin.activeVisits.length}', AppColors.info, Icons.run_circle_outlined),
      _buildStatCard('Active Staff', '${admin.activeStaffList.length}', AppColors.secondary, Icons.badge_outlined),
      _buildStatCard('Completed Reports', '${admin.completedBookings.length}', AppColors.success, Icons.task_alt_rounded),
      _buildStatCard('Total Revenue', '₹${admin.totalRevenue.toInt()}', AppColors.primary, Icons.account_balance_wallet_outlined),
    ];

    if (isLargeScreen) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: statCards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: card))).toList(),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statCards.map((card) => Container(width: 145, margin: const EdgeInsets.only(right: 8), child: card)).toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: color), maxLines: 1),
                Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContentView({
    required int index,
    required List<BookingModel> pending,
    required List<BookingModel> active,
    required List<StaffMember> staff,
    required List<DiagnosticService> catalog,
    required List<PromoBanner> banners,
    required List<UserProfile> users,
  }) {
    switch (index) {
      case 0:
        return _buildBookingsQueue(pending, isPendingQueue: true);
      case 1:
        return _buildBookingsQueue(active, isActiveQueue: true);
      case 2:
        return _buildStaffTab(staff);
      case 3:
        return _buildCatalogTab(catalog);
      case 4:
        return _buildBannersTab(banners);
      case 5:
        return _buildUsersTab(users);
      default:
        return _buildBookingsQueue(pending);
    }
  }

  Widget? _buildFab() {
    if (_selectedNavIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () => _openAddStaffDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Staff Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      );
    } else if (_selectedNavIndex == 3) {
      return FloatingActionButton.extended(
        onPressed: () => _openAddTestDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('Add Diagnostic Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      );
    }
    return null;
  }

  // 1 & 2. BOOKINGS QUEUE
  Widget _buildBookingsQueue(
    List<BookingModel> bookings, {
    bool isPendingQueue = false,
    bool isActiveQueue = false,
  }) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        title: isPendingQueue ? 'No Pending Booking Requests' : 'No Active Visits',
        description: isPendingQueue
            ? 'All incoming diagnostic requests have been accepted and dispatched to phlebotomists.'
            : 'New appointments scheduled in Patient App will appear here in real-time.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final isHomeVisit = booking.visitType == VisitType.homeVisit;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: booking.status == BookingStatus.pendingApproval ? AppColors.accent : AppColors.border,
              width: booking.status == BookingStatus.pendingApproval ? 1.5 : 1,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('BOOKING #${booking.id}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => FieldWorkOrderPdfGenerator.printOrShareWorkOrder(booking),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.print_rounded, size: 12, color: AppColors.primary),
                              SizedBox(width: 3),
                              Text('Print Slip', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHomeVisit ? AppColors.primaryLight : AppColors.infoLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isHomeVisit ? 'HOME VISIT' : 'IN-HOUSE CENTRE',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: isHomeVisit ? AppColors.primaryDark : AppColors.info),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: AppColors.background, child: Icon(Icons.person, color: AppColors.primary, size: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${booking.patientName} (${booking.patientAge}y, ${booking.patientSex})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Ph: ${booking.patientMobile}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('₹${booking.totalAmount.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...booking.services.map((s) => Text('• ${s.title}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    const SizedBox(height: 4),
                    Text('Slot: ${DateFormat("EEE, dd MMM").format(booking.scheduledDate)} (${booking.timeSlot})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    if (isHomeVisit && booking.patientAddress != null)
                      Text('Address: ${booking.patientAddress}', style: const TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // UTR Payment Verification Badge
              if (booking.utrNumber != null || booking.paymentStatus.contains('Online') || booking.paymentStatus.contains('Paid')) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 16, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'UPI Paid • UTR: ${booking.utrNumber ?? "Verified Online"}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                        ),
                      ),
                      if (booking.paymentScreenshotUrl != null)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('UPI Payment Proof', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(context)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: AppImageView(imageUrl: booking.paymentScreenshotUrl!),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('View Proof', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.payments_outlined, size: 14, color: Color(0xFFD97706)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text('Pay on Visit / Collection (Cash / UPI)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (booking.technicianName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.successLight.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Assigned Staff: ${booking.technicianName} (${booking.technicianPhone ?? ""})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Actions
              Row(
                children: [
                  if (booking.status == BookingStatus.pendingApproval) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openAcceptDialog(booking),
                        icon: const Icon(Icons.person_pin_rounded, size: 16),
                        label: const Text('Select Staff & Accept', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => context.read<AdminProvider>().cancelOrRejectBooking(booking.id, 'Slot unavailable'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                      child: const Text('Reject', style: TextStyle(fontSize: 12)),
                    ),
                  ] else if (booking.status != BookingStatus.completed && booking.status != BookingStatus.cancelled) ...[
                    if (booking.status == BookingStatus.technicianAssigned || booking.status == BookingStatus.confirmed)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.read<AdminProvider>().updateStatus(bookingId: booking.id, newStatus: BookingStatus.sampleCollected),
                          icon: const Icon(Icons.science_outlined, size: 16),
                          label: const Text('Sample Taken', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openUploadReportDialog(booking),
                        icon: const Icon(Icons.upload_file_rounded, size: 16),
                        label: const Text('Upload Report', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. STAFF DIRECTORY TAB
  Widget _buildStaffTab(List<StaffMember> staffList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: staffList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medical Staff & Technicians Directory', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    Text('Total certified field & lab personnel: ${staffList.length}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAddStaffDialog(),
                  icon: const Icon(Icons.person_add, size: 14, color: Colors.white),
                  label: const Text('Add Staff', style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ],
            ),
          );
        }

        final staff = staffList[index - 1];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: staff.isActive ? AppColors.successLight : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            staff.isActive ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: staff.isActive ? AppColors.success : AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(staff.role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text('Ph: ${staff.phone}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    Text(staff.specialization, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Text('Completed Field Visits: ${staff.completedVisits}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    onPressed: () => _openAddStaffDialog(staff),
                    tooltip: 'Edit Staff',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Staff Member?'),
                          content: Text('Remove ${staff.name} from directory?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                context.read<AdminProvider>().deleteStaff(staff.id);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    tooltip: 'Delete Staff',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. TEST CATALOG TAB
  Widget _buildCatalogTab(List<DiagnosticService> catalog) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: catalog.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diagnostic Tests & Packages Live Catalog', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    Text('Active investigation offerings: ${catalog.length}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAddTestDialog(),
                  icon: const Icon(Icons.add_circle_outline, size: 14, color: Colors.white),
                  label: const Text('Add Test', style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ],
            ),
          );
        }

        final test = catalog[index - 1];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.science_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(test.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(4)),
                          child: Text(test.categoryName, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(test.description, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('₹${test.price.toInt()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        if (test.originalPrice != null) ...[
                          const SizedBox(width: 6),
                          Text('₹${test.originalPrice!.toInt()}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, decoration: TextDecoration.lineThrough)),
                        ],
                        const SizedBox(width: 12),
                        if (test.isHomeVisitAvailable)
                          const Text('• Home Visit', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.success)),
                        if (test.isInHouseAvailable)
                          const Text(' • In-House', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    onPressed: () => _openAddTestDialog(test),
                    tooltip: 'Edit Test',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Test?'),
                          content: Text('Remove ${test.title} from catalog?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                context.read<AdminProvider>().deleteDiagnosticTest(test.id);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    tooltip: 'Delete Test',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 5. PROMOTIONAL BANNERS TAB
  Widget _buildBannersTab(List<PromoBanner> banners) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: banners.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top Home Carousel Banners & Offers', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    Text('Active promotional slides: ${banners.length}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openEditBannerDialog(
                    PromoBanner(
                      id: 'BANNER-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      title: 'Special Health Package',
                      subtitle: 'Flat 20% OFF on Full Body Tests',
                      badge: 'SPECIAL OFFER',
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                  label: const Text('New Banner', style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ],
            ),
          );
        }

        final banner = banners[index - 1];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.local_offer_rounded, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
                          child: Text(banner.badge, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(banner.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(banner.subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Action Button: "${banner.actionText}" • Target: ${banner.categoryTarget}', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    onPressed: () => _openEditBannerDialog(banner),
                    tooltip: 'Edit Banner',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    onPressed: () => context.read<AdminProvider>().deleteBanner(banner.id),
                    tooltip: 'Delete Banner',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 6. PATIENT USERS DIRECTORY TAB
  Widget _buildUsersTab(List<UserProfile> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registered Patient Users Directory', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    Text('Total registered patients: ${users.length}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openSendReminderDialog(),
                  icon: const Icon(Icons.campaign_rounded, size: 14, color: Colors.white),
                  label: const Text('Broadcast Alert', style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ],
            ),
          );
        }

        final user = users[index - 1];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: user.isBlocked ? AppColors.error : AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${user.name} (${user.age}y, ${user.sex})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                        if (user.isBlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(4)),
                            child: const Text('RESTRICTED', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.error)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Email: ${user.email}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    Text('Phone: ${user.mobile}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    Text('Address: ${user.address}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.alarm_add_rounded, size: 18, color: AppColors.accent),
                    tooltip: 'Send Test Due Reminder',
                    onPressed: () => _openSendReminderDialog(patientId: user.uid, patientName: user.name),
                  ),
                  IconButton(
                    icon: Icon(
                      user.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                      size: 18,
                      color: user.isBlocked ? AppColors.success : AppColors.error,
                    ),
                    tooltip: user.isBlocked ? 'Unblock Patient' : 'Restrict Patient Account',
                    onPressed: () {
                      context.read<AdminProvider>().toggleBlockUser(user.uid, !user.isBlocked);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
