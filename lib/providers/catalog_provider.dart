import 'dart:async';
import 'package:flutter/material.dart';
import '../models/diagnostic_service.dart';
import '../models/promo_banner.dart';
import '../services/catalog_service.dart';
import '../services/banner_service.dart';

class CatalogProvider with ChangeNotifier {
  final CatalogService _catalogService = CatalogService();
  final BannerService _bannerService = BannerService();

  List<DiagnosticService> _allServices = [];
  List<PromoBanner> _banners = [];
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  final List<DiagnosticService> _cart = [];

  StreamSubscription<List<DiagnosticService>>? _servicesSub;
  StreamSubscription<List<PromoBanner>>? _bannersSub;

  CatalogProvider() {
    _loadServices();
    _startServicesSync();
    _startBannersSync();
  }

  @override
  void dispose() {
    _servicesSub?.cancel();
    _bannersSub?.cancel();
    super.dispose();
  }

  void _startServicesSync() {
    _servicesSub?.cancel();
    _servicesSub = _catalogService.streamServices().listen((services) {
      _allServices = services;
      notifyListeners();
    });
  }

  void _startBannersSync() {
    _bannersSub?.cancel();
    _bannersSub = _bannerService.streamBanners().listen((banners) {
      _banners = banners;
      notifyListeners();
    });
  }

  List<DiagnosticService> get allServices => _allServices.isNotEmpty ? _allServices : CatalogService.initialServices;
  List<PromoBanner> get banners => _banners.where((b) => b.isActive).toList();
  List<PromoBanner> get allBanners => _banners;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get searchQuery => _searchQuery;
  List<DiagnosticService> get cart => _cart;

  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.price);

  Future<void> _loadServices() async {
    _allServices = await _catalogService.getAllServices();
    notifyListeners();
  }

  Future<void> loadBanners() async {
    _banners = await _bannerService.getBanners();
    notifyListeners();
  }

  void refreshCatalog() {
    _loadServices();
    loadBanners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<DiagnosticService> get filteredServices {
    final list = _allServices.isNotEmpty ? _allServices : CatalogService.initialServices;
    return list.where((service) {
      final matchesSearch = _searchQuery.isEmpty ||
          service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.categoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      switch (_selectedCategoryFilter) {
        case 'Home Visits':
          return service.isHomeVisitAvailable;
        case 'In-House Tests':
          return service.isInHouseAvailable && service.category == ServiceCategory.inHouseDiagnostic;
        case 'Physiotherapy':
          return service.category == ServiceCategory.physiotherapy;
        case 'Health Packages':
          return service.category == ServiceCategory.healthPackage || service.includedTests.length > 4;
        default:
          return true;
      }
    }).toList();
  }

  void addToCart(DiagnosticService service) {
    if (!_cart.any((item) => item.id == service.id)) {
      _cart.add(service);
      notifyListeners();
    }
  }

  void removeFromCart(String serviceId) {
    _cart.removeWhere((item) => item.id == serviceId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  bool isInCart(String serviceId) {
    return _cart.any((item) => item.id == serviceId);
  }
}
