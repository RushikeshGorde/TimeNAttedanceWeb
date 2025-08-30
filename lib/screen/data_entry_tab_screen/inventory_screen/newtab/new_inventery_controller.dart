import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:time_attendance/screen/data_entry_tab_screen/inventory_screen/newtab/new_inventery_model.dart';
// import 'asset_model.dart';

class AssetController extends GetxController {
  // Text editing controllers
  final assetCodeController = TextEditingController();
  final assetNameController = TextEditingController();
  final manufacturerController = TextEditingController();
  final modelNumberController = TextEditingController();
  final serialNumberController = TextEditingController();
  final vendorNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phone1Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final remarkController = TextEditingController();

  // Observable variables
  final _asset = AssetModel().obs;
  final _isRental = false.obs;
  final _isPurchase = false.obs;
  final _rentalPeriodStart = Rxn<DateTime>();
  final _rentalPeriodEnd = Rxn<DateTime>();
  final _warrantyPeriodStart = Rxn<DateTime>();
  final _warrantyPeriodEnd = Rxn<DateTime>();

  // Getters for accessing private variables
  AssetModel get asset => _asset.value;
  bool get isRental => _isRental.value;
  bool get isPurchase => _isPurchase.value;
  DateTime? get rentalPeriodStart => _rentalPeriodStart.value;
  DateTime? get rentalPeriodEnd => _rentalPeriodEnd.value;
  DateTime? get warrantyPeriodStart => _warrantyPeriodStart.value;
  DateTime? get warrantyPeriodEnd => _warrantyPeriodEnd.value;

  // Getter for vendor name controller
  TextEditingController get rightVendorNameController => vendorNameController;

  // Getter for contact person controller
  TextEditingController get rightContactPersonController => contactPersonController;

  // Getter for phone1 controller
  TextEditingController get rightPhone1Controller => phone1Controller;

  // Getter for remark controller
  TextEditingController get rightRemarkController => remarkController;

  // Initialize the controller and set up listeners
  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
  }

  // Set up listeners for all text controllers
  void _initializeListeners() {
    assetCodeController.addListener(() => _updateAsset());
    assetNameController.addListener(() => _updateAsset());
    manufacturerController.addListener(() => _updateAsset());
    modelNumberController.addListener(() => _updateAsset());
    serialNumberController.addListener(() => _updateAsset());
    vendorNameController.addListener(() => _updateAsset());
    contactPersonController.addListener(() => _updateAsset());
    phone1Controller.addListener(() => _updateAsset());
    phone2Controller.addListener(() => _updateAsset());
    remarkController.addListener(() => _updateAsset());
  }

  // Update the asset model with current values from all controllers
  void _updateAsset() {
    _asset.value = _asset.value.copyWith(
      assetCode: assetCodeController.text,
      assetName: assetNameController.text,
      manufacturer: manufacturerController.text,
      modelNumber: modelNumberController.text,
      serialNumber: serialNumberController.text,
      isRental: _isRental.value,
      isPurchase: _isPurchase.value,
      vendorName: vendorNameController.text,
      contactPerson: contactPersonController.text,
      phone1: phone1Controller.text,
      phone2: phone2Controller.text,
      remark: remarkController.text,
      rentalPeriodStart: _rentalPeriodStart.value,
      rentalPeriodEnd: _rentalPeriodEnd.value,
      warrantyPeriodStart: _warrantyPeriodStart.value,
      warrantyPeriodEnd: _warrantyPeriodEnd.value,
    );
  }

  // Toggle the rental status and update asset
  void toggleRental(bool value) {
    _isRental.value = value;
    if (value) {
      _isPurchase.value = false;
    }
    _updateAsset();
  }

  // Toggle the purchase status and update asset
  void togglePurchase(bool value) {
    _isPurchase.value = value;
    if (value) {
      _isRental.value = false;
    }
    _updateAsset();
  }

  // Show date picker for rental start date selection
  Future<void> selectRentalStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _rentalPeriodStart.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _rentalPeriodStart.value = picked;
      _updateAsset();
    }
  }

  // Show date picker for rental end date selection
  Future<void> selectRentalEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _rentalPeriodEnd.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _rentalPeriodEnd.value = picked;
      _updateAsset();
    }
  }

  // Show date picker for warranty start date selection
  Future<void> selectWarrantyStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _warrantyPeriodStart.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _warrantyPeriodStart.value = picked;
      _updateAsset();
    }
  }

  // Show date picker for warranty end date selection
  Future<void> selectWarrantyEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _warrantyPeriodEnd.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _warrantyPeriodEnd.value = picked;
      _updateAsset();
    }
  }

  // Validate form fields and show error messages if needed
  bool validateForm() {
    if (assetCodeController.text.isEmpty) {
      Get.snackbar('Error', 'Asset Code is required');
      return false;
    }
    if (assetNameController.text.isEmpty) {
      Get.snackbar('Error', 'Asset Name is required');
      return false;
    }
    if (!_isRental.value && !_isPurchase.value) {
      Get.snackbar('Error', 'Please select either Rental or Purchase');
      return false;
    }
    return true;
  }

  // Save asset data after validation
  void saveAsset() {
    if (validateForm()) {
      _updateAsset();
      Get.snackbar('Success', 'Asset saved successfully');
      print('Asset saved: ${asset.toJson()}');
    }
  }

  // Clear all form fields and reset to initial state
  void clearForm() {
    assetCodeController.clear();
    assetNameController.clear();
    manufacturerController.clear();
    modelNumberController.clear();
    serialNumberController.clear();
    vendorNameController.clear();
    contactPersonController.clear();
    phone1Controller.clear();
    phone2Controller.clear();
    remarkController.clear();
    
    _isRental.value = false;
    _isPurchase.value = false;
    _rentalPeriodStart.value = null;
    _rentalPeriodEnd.value = null;
    _warrantyPeriodStart.value = null;
    _warrantyPeriodEnd.value = null;
    
    _updateAsset();
  }

  // Format date to display in dd/mm/yyyy format
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Dispose all controllers when the widget is disposed
  @override
  void onClose() {
    assetCodeController.dispose();
    assetNameController.dispose();
    manufacturerController.dispose();
    modelNumberController.dispose();
    serialNumberController.dispose();
    vendorNameController.dispose();
    contactPersonController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    remarkController.dispose();
    super.onClose();
  }
}