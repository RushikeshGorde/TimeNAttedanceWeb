import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:time_attendance/model/master_tab_model/department_model.dart';

class BulkEmployeedeleteController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedFileName = RxString('');
  final RxBool isLoading = false.obs;
  final RxList<String> uploadedEmployees = <String>[].obs;
  final searchQuery = ''.obs;
  final departments = <DepartmentModel>[].obs;
  final filteredDepartments = <DepartmentModel>[].obs;

  /// Opens a file picker dialog to select a CSV file
  /// Updates the selectedFileName when a file is picked
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      selectedFileName.value = result.files.single.name;
      // Store the file path for later use
      String filePath = result.files.single.path!;
      // You can process the CSV file here if needed
    }
  }

  /// Updates the selected date value
  /// @param date The new DateTime to set
  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  /// Generates a blank CSV template file with predefined headers
  /// Shows success/error message via snackbar
  Future<void> generateBlankCSV() async {
    // Implementation for generating blank CSV template
    try {
      // Generate CSV logic here
      String csvContent = "Employee ID,Name,Department,Position,Email\n";
      // Add logic to save the file
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate CSV template: ${e.toString()}');
    }
  }

  /// Uploads employee data from the selected CSV file
  /// Shows loading state and success/error messages
  /// Clears selection after successful upload
  Future<void> uploadEmployees() async {
    if (selectedFileName.isEmpty) {
      Get.snackbar('Error', 'Please select a file first');
      return;
    }

    try {
      isLoading.value = true;
      // Add your API call or database operation here
      await Future.delayed(Duration(seconds: 2)); // Simulated API call
      
      Get.snackbar('Success', 'Employees uploaded successfully');
      // Clear the selection after successful upload
      selectedFileName.value = '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload employees: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Resets all controller values to their initial state
  /// Clears filename, date and uploaded employees list
  void refresh() {
    selectedFileName.value = '';
    selectedDate.value = DateTime.now();
    uploadedEmployees.clear();
  }

  /// Filters departments based on search query
  /// Updates filteredDepartments list based on department name or master department name
  /// @param query The search string to filter by
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredDepartments.assignAll(departments);
    } else {
      filteredDepartments.assignAll(
        departments.where((d) => 
          d.departmentName.toLowerCase().contains(query.toLowerCase()) ||
          d.masterDepartmentName.toLowerCase().contains(query.toLowerCase())
        )
      );
    }
  }
}
