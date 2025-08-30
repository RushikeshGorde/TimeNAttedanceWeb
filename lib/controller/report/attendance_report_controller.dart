// attendance_report_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:time_attendance/model/attendance_report_model.dart';
import 'package:time_attendance/Data/LoginInformation/AuthLogin.dart';
import 'package:time_attendance/Data/LoginInformation/AuthLoginInfoDetails.dart';
import 'package:time_attendance/General/MTAResult.dart';
import 'package:time_attendance/model/Masters/designation.dart';
import 'package:time_attendance/model/Masters/designationDetails.dart';
import 'package:time_attendance/model/report/attedance_report_model.dart';
import 'package:time_attendance/widgets/mtaToast.dart';
import 'package:time_attendance/model/TALogin/session_manager.dart'
    if (dart.library.html) 'package:time_attendance/model/TALogin/session_manager_web.dart'
    if (dart.library.io) 'package:time_attendance/model/TALogin/session_manager_mobile.dart';
import 'package:time_attendance/model/Masters/branch.dart';
import 'package:time_attendance/model/Masters/branchDetails.dart';
import 'package:time_attendance/model/Masters/department.dart';
import 'package:time_attendance/model/Masters/departmentDetails.dart';


class AttendanceReportController extends GetxController {
  final isLoading = false.obs;
  final reportModel = AttendanceReportModel().obs;
  
  // Data lists
  final companies = <CompanyModel>[].obs;
  final employees = <EmployeeModel>[].obs;
  final departments = <DepartmentModel>[].obs;
  final designations = <DesignationModel>[].obs;
  
  // Export format options
  final exportFormats = ['PDF', 'Excel', 'MS Word', 'RichText', 'None'].obs;
  
  // Report duration options
  final reportDurations = ['Daily', 'Monthly', 'Yearly'].obs;
  
  // Employee status options
  final employeeStatuses = ['Active', 'Inactive'].obs;
  
  // Report type options for daily reports
  final dailyReportTypes = [
    'Daily Attendance(Raw)',
    'Late Coming',
    'Defaulters',
    'Daily Attendance',
    'Early Going',
    'Attendance Muster',
    'Attendance Status',
    'Overtime Report',
    'Performance Muster',
    'Absent',
    'NoInOut Report',
    'Detailed Performance Muster CSV',
  ].obs;
  
  // Report type options for monthly reports
  final monthlyReportTypes = [
    'Input Muster',
    'Over Time Muster',
    'Performance Muster',
    'Goff Work',
    'Early Going Muster',
    'Late Coming Muster',
    'Shift Muster',
    'Absent Muster',
    'Raw Device Punches',
    'Detailed Performance Muster',
    'Detailed WOffs And Shifts Muster',
    'Monthly Attendance Muster CSV',
  ].obs;
  
  // Selected report types
  final selectedReportTypes = <String>[].obs;
  
  // Month and year options
  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ].obs;
  
  final years = <String>[].obs;

  AuthLogin? _authLogin;

  @override
  void onInit() {
    super.onInit();
    initializeData();
    generateYears();
    // Set default values
    reportModel.value = reportModel.value.copyWith(
      fromDate: DateTime.now().subtract(Duration(days: 30)),
      toDate: DateTime.now(),
      selectedMonth: 'Aug-2025',
      selectedYear: DateTime.now().year.toString(),
    );
  }

  void generateYears() {
    final currentYear = DateTime.now().year;
    years.clear();
    for (int i = currentYear - 10; i <= currentYear + 5; i++) {
      years.add(i.toString());
    }
  }

  Future<void> initializeData() async {
    try {
      MTAResult objResult = MTAResult();
      final userInfo = await PlatformSessionManager.getUserInfo();
      if (userInfo != null) {
        String companyCode = userInfo['CompanyCode'];
        String loginID = userInfo['LoginID'];
        String password = userInfo['Password'];
        _authLogin = await AuthLoginDetails()
            .LoginInformationForFirstLogin(companyCode, loginID, password);
        
        await Future.wait([
          fetchCompanies(),
          fetchEmployees(),
          fetchDepartments(),
          fetchDesignations(),
        ]);
      }
    } catch (e) {
      MTAToast().ShowToast(e.toString());
    }
  }

  Future<void> fetchCompanies() async {
    try {
      isLoading.value = true;
      
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      MTAResult result = MTAResult();
      List<Branch> apiBranches = await BranchDetails().GetAllBranches(_authLogin!, result);

      // Convert Branch objects to CompanyModel objects
      companies.assignAll(apiBranches.map((branch) => CompanyModel(
        id: branch.BranchID ?? '',
        name: branch.BranchName ?? '',
        isSelected: false
      )).toList());

    } catch (e) {
      MTAToast().ShowToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEmployees() async {
    try {
      // Mock data - replace with actual API call
      employees.assignAll([
        EmployeeModel(id: '1', name: 'John Doe', companyId: '1'),
        EmployeeModel(id: '2', name: 'Jane Smith', companyId: '1'),
        EmployeeModel(id: '3', name: 'Mike Johnson', companyId: '2'),
      ]);
    } catch (e) {
      MTAToast().ShowToast(e.toString());
    }
  }

  Future<void> fetchDepartments() async {
    try {
      isLoading.value = true;
      
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      MTAResult result = MTAResult();
      List<Department> apiDepartments = await DepartmentDetails().GetAllDepartmentes(
        _authLogin!,
        result
      );

      // Convert API departments to the format needed for reports
      departments.assignAll(apiDepartments.map((d) => DepartmentModel(
        id: d.DepartmentID ?? '',
        name: d.DepartmentName ?? '',
        isSelected: false
      )).toList());

    } catch (e) {
      MTAToast().ShowToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDesignations() async {
    try {
      isLoading.value = true;
      
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      MTAResult result = MTAResult();
      List<Designation> apiDesignations = await DesignationDetails().GetAllDesignationes(
        _authLogin!,
        result
      );

      // Convert API designations to the format needed for reports
      designations.assignAll(apiDesignations.map((d) => DesignationModel(
        id: d.DesignationID ?? '',
        name: d.DesignationName ?? '',
        isSelected: false
      )).toList());

    } catch (e) {
      MTAToast().ShowToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Date selection methods with validation
  void selectFromDate(DateTime date) {
    final currentToDate = reportModel.value.toDate;
    
    if (currentToDate != null) {
      final daysDifference = currentToDate.difference(date).inDays;
      if (daysDifference > 31) {
        MTAToast().ShowToast('Date range cannot exceed 31 days. Please select a valid date range.');
        return;
      }
    }
    
    reportModel.value = reportModel.value.copyWith(fromDate: date);
  }

  void selectToDate(DateTime date) {
    final currentFromDate = reportModel.value.fromDate;
    
    if (currentFromDate != null) {
      final daysDifference = date.difference(currentFromDate).inDays;
      if (daysDifference > 31) {
        MTAToast().ShowToast('Date range cannot exceed 31 days. Please select a valid date range.');
        return;
      }
    }
    
    reportModel.value = reportModel.value.copyWith(toDate: date);
  }

  // Validate date range
  bool _validateDateRange() {
    final fromDate = reportModel.value.fromDate;
    final toDate = reportModel.value.toDate;
    
    if (fromDate != null && toDate != null) {
      final daysDifference = toDate.difference(fromDate).inDays;
      if (daysDifference > 31) {
        MTAToast().ShowToast('Date range cannot exceed 31 days. Please select a valid date range.');
        return false;
      }
      if (daysDifference < 0) {
        MTAToast().ShowToast('From date cannot be later than To date.');
        return false;
      }
    }
    return true;
  }

  // Export format selection
  void selectExportFormat(String format) {
    reportModel.value = reportModel.value.copyWith(exportFormat: format);
  }

  // Report duration selection
  void selectReportDuration(String duration) {
    reportModel.value = reportModel.value.copyWith(reportDuration: duration);
    // Clear selected report types when duration changes
    selectedReportTypes.clear();
  }

  // Employee status selection
  void selectEmployeeStatus(String status) {
    reportModel.value = reportModel.value.copyWith(employeeStatus: status);
  }

  // Month selection
  void selectMonth(String month) {
    reportModel.value = reportModel.value.copyWith(selectedMonth: month);
  }

  // Year selection
  void selectYear(String year) {
    reportModel.value = reportModel.value.copyWith(selectedYear: year);
  }

  // Report type selection
  void toggleReportType(String reportType) {
    if (selectedReportTypes.contains(reportType)) {
      selectedReportTypes.remove(reportType);
    } else {
      selectedReportTypes.add(reportType);
    }
  }

  // Get current report types based on duration
  List<String> get currentReportTypes {
    return reportModel.value.reportDuration == 'Monthly' 
        ? monthlyReportTypes 
        : dailyReportTypes;
  }

  // Company selection methods
  void toggleSelectAllCompanies(bool selectAll) {
    reportModel.value = reportModel.value.copyWith(selectAllCompanies: selectAll);
    for (var company in companies) {
      company.isSelected = selectAll;
    }
    companies.refresh();
  }

  void toggleCompanySelection(String companyId) {
    final company = companies.firstWhere((c) => c.id == companyId);
    company.isSelected = !company.isSelected;
    companies.refresh();
    
    // Update selectAllCompanies flag
    final allSelected = companies.every((c) => c.isSelected);
    reportModel.value = reportModel.value.copyWith(selectAllCompanies: allSelected);
  }

  // Employee selection methods
  void toggleSelectAllEmployees(bool selectAll) {
    reportModel.value = reportModel.value.copyWith(selectAllEmployees: selectAll);
    for (var employee in employees) {
      employee.isSelected = selectAll;
    }
    employees.refresh();
  }

  void toggleEmployeeSelection(String employeeId) {
    final employee = employees.firstWhere((e) => e.id == employeeId);
    employee.isSelected = !employee.isSelected;
    employees.refresh();
    
    // Update selectAllEmployees flag
    final allSelected = employees.every((e) => e.isSelected);
    reportModel.value = reportModel.value.copyWith(selectAllEmployees: allSelected);
  }

  // Department selection methods
  void toggleSelectAllDepartments(bool selectAll) {
    reportModel.value = reportModel.value.copyWith(selectAllDepartments: selectAll);
    for (var department in departments) {
      department.isSelected = selectAll;
    }
    departments.refresh();
  }

  void toggleDepartmentSelection(String departmentId) {
    final department = departments.firstWhere((d) => d.id == departmentId);
    department.isSelected = !department.isSelected;
    departments.refresh();
    
    // Update selectAllDepartments flag
    final allSelected = departments.every((d) => d.isSelected);
    reportModel.value = reportModel.value.copyWith(selectAllDepartments: allSelected);
  }

  // Designation selection methods
  void toggleSelectAllDesignations(bool selectAll) {
    reportModel.value = reportModel.value.copyWith(selectAllDesignations: selectAll);
    for (var designation in designations) {
      designation.isSelected = selectAll;
    }
    designations.refresh();
  }

  void toggleDesignationSelection(String designationId) {
    final designation = designations.firstWhere((d) => d.id == designationId);
    designation.isSelected = !designation.isSelected;
    designations.refresh();
    
    // Update selectAllDesignations flag
    final allSelected = designations.every((d) => d.isSelected);
    reportModel.value = reportModel.value.copyWith(selectAllDesignations: allSelected);
  }

  // Action methods
  Future<void> generateReport() async {
    try {
      // Validate date range for daily reports
      if (reportModel.value.reportDuration == 'Daily' && !_validateDateRange()) {
        return;
      }
      
      isLoading.value = true;
      
      // Validate required fields
      if (reportModel.value.reportDuration == 'Daily') {
        if (reportModel.value.fromDate == null || reportModel.value.toDate == null) {
          MTAToast().ShowToast('Please select both from and to dates.');
          return;
        }
      } else if (reportModel.value.reportDuration == 'Monthly') {
        if (reportModel.value.selectedMonth == null) {
          MTAToast().ShowToast('Please select a month.');
          return;
        }
      } else if (reportModel.value.reportDuration == 'Yearly') {
        if (reportModel.value.selectedYear == null) {
          MTAToast().ShowToast('Please select a year.');
          return;
        }
      }
      
      // Check if at least one report type is selected (for non-yearly reports)
      if (reportModel.value.reportDuration != 'Yearly' && selectedReportTypes.isEmpty) {
        MTAToast().ShowToast('Please select at least one report type.');
        return;
      }
      
      // TODO: Implement actual report generation logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      MTAToast().ShowToast('Report generated successfully!');
    } catch (e) {
      MTAToast().ShowToast('Error generating report: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await initializeData();
    MTAToast().ShowToast('Data refreshed successfully!');
  }

  void resetFilters() {
    reportModel.value = AttendanceReportModel(
      fromDate: DateTime.now().subtract(const Duration(days: 30)),
      toDate: DateTime.now(),
      selectedMonth: 'Aug-2025',
      selectedYear: DateTime.now().year.toString(),
    );
    selectedReportTypes.clear();
    
    // Reset all selections
    toggleSelectAllCompanies(true);
    toggleSelectAllEmployees(true);
    toggleSelectAllDepartments(true);
    toggleSelectAllDesignations(true);
    
    MTAToast().ShowToast('Filters reset successfully!');
  }
}