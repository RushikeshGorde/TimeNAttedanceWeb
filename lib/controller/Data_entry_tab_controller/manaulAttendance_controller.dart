import 'package:get/get.dart';
import 'package:time_attendance/Data/LoginInformation/AuthLogin.dart';
import 'package:time_attendance/Data/LoginInformation/AuthLoginInfoDetails.dart';
import 'package:time_attendance/General/MTAResult.dart';
import 'package:time_attendance/model/Data_entry_tab_model/manualAttendance_model.dart';
import 'package:time_attendance/model/Data_entry_tab_model/manualAttendance_details.dart';
import 'package:time_attendance/widgets/mtaToast.dart';
import 'package:time_attendance/model/TALogin/session_manager.dart'
    if (dart.library.html) 'package:time_attendance/model/TALogin/session_manager_web.dart'
    if (dart.library.io) 'package:time_attendance/model/TALogin/session_manager_mobile.dart';

class ManualAttendanceController extends GetxController {
  // Lists for manual attendance
  final manualAttendances = <ManualAttendanceModel>[].obs;
  final filteredManualAttendances = <ManualAttendanceModel>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  // Selected attendance regularization
  final selectedAttendanceRegularization = Rxn<ManualAttendanceModel>();

  // Filter variables
  final selectedMonth = RxString('');
  final selectedYear = RxString('');
  final selectedStatus = RxString('');
  final selectedEmployeeId = RxString('');
  
  // Sorting variables
  final sortColumn = RxString('ShiftDate');
  final isSortAscending = RxBool(true);

  // Authentication instance
  AuthLogin? _authLogin;

  // Initialize the controller and reset state
  @override
  void onInit() {
    super.onInit();
    resetState();
    initializeAuthProfile();
  }

  // Clean up resources when controller is closed
  @override
  void onClose() {
    resetState();
    super.onClose();
  }

  // Reset all state variables to their default values
  void resetState() {
    // Clear the existing data
    manualAttendances.clear();
    filteredManualAttendances.clear();
    searchQuery.value = '';
    selectedMonth.value = '';
    selectedYear.value = '';
    selectedStatus.value = '';
    selectedEmployeeId.value = '';
    sortColumn.value = 'ShiftDate';
    isLoading.value = false;
  }

  // Initialize authentication profile from session
  Future<void> initializeAuthProfile() async {
    try {
      final userInfo = await PlatformSessionManager.getUserInfo();
      if (userInfo != null) {
        String companyCode = userInfo['CompanyCode'];
        String loginID = userInfo['LoginID'];
        String password = userInfo['Password'];
        _authLogin = await AuthLoginDetails().LoginInformationForFirstLogin(companyCode, loginID, password);
      }
    } catch (e) {
      MTAToast().ShowToast(e.toString());
    }
  }

  // Fetch manual attendance records based on selected filters
  Future<void> fetchManualAttendances() async {
    try {
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }
      
      isLoading.value = true;
      
      MTAResult result = MTAResult();
      List<ManualAttendanceModel> apiManualAttendances = await ManualAttendanceDetails().GetMonthlyAttendance(
        _authLogin!,
        selectedEmployeeId.value,
        selectedMonth.value,
        selectedYear.value,
        selectedStatus.value,
        result
      );
      
      manualAttendances.assignAll(apiManualAttendances);
      updateSearchQuery('');
      if( apiManualAttendances.isEmpty) {
        MTAToast().ShowToast('No manual attendance records found for the selected filters.');
      }
      
    } catch (e) {
      MTAToast().ShowToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Update search results based on query string
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredManualAttendances.assignAll(manualAttendances);
    } else {
      filteredManualAttendances.assignAll(
        manualAttendances.where((attendance) => 
          attendance.employeeName.toLowerCase().contains(query.toLowerCase()) ||
          attendance.shiftName.toLowerCase().contains(query.toLowerCase()) ||
          attendance.reason.toLowerCase().contains(query.toLowerCase())
        )
      );
    }
    _applySort();
  }

  // Update filter values and fetch new data
  void updateFilters({
    String? month,
    String? year,
    String? status,
    String? employeeId,
  }) {
    if (month != null) selectedMonth.value = month;
    if (year != null) selectedYear.value = year;
    if (status != null) selectedStatus.value = status;
    if (employeeId != null) selectedEmployeeId.value = employeeId;
    
    fetchManualAttendances();
  }

  // Sort manual attendance records based on column and direction
  void sortManualAttendances(String columnName, bool? ascending) {
    if (ascending != null) {
      isSortAscending.value = ascending;
    } else if (sortColumn.value == columnName) {
      isSortAscending.value = !isSortAscending.value;
    } else {
      isSortAscending.value = true;
    }
    
    sortColumn.value = columnName;
    _applySort();
  }

  // Apply sorting to filtered attendance records
  void _applySort() {
    filteredManualAttendances.sort((a, b) {
      int comparison;
      switch (sortColumn.value) {
        case 'ShiftDate':
          comparison = a.shiftDateTime.compareTo(b.shiftDateTime);
          break;
        case 'EmployeeName':
          comparison = a.employeeName.compareTo(b.employeeName);
          break;
        case 'Status':
          comparison = a.status.toString().compareTo(b.status.toString());
          break;
        case 'ShiftName':
          comparison = a.shiftName.compareTo(b.shiftName);
          break;
        default:
          comparison = 0;
      }
      return isSortAscending.value ? comparison : -comparison;
    });
  }

  // Get current user's login ID
  String get currentLoginId => _authLogin?.LoginID ?? '';

  // Delete attendance record for specified employee and date
  Future<bool> deleteAttendance(String employeeId, DateTime shiftDate) async {
    try {
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      isLoading.value = true;
      MTAResult result = MTAResult();

      bool success = await ManualAttendanceDetails().DeleteAttendance(
        _authLogin!,
        employeeId,
        shiftDate,
        result
      );

      if (success) {
        MTAToast().ShowToast(result.ResultMessage.isNotEmpty 
          ? result.ResultMessage 
          : "Manual attendance deleted successfully");
        return true;
      } else {
        MTAToast().ShowToast(result.ResultMessage.isNotEmpty 
          ? result.ResultMessage 
          : "Failed to delete manual attendance");
        if (result.ErrorMessage.isNotEmpty) {
          throw Exception(result.ErrorMessage);
        }
        return false;
      }
    } catch (e) {
      MTAToast().ShowToast("Error deleting manual attendance: ${e.toString()}");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get attendance regularization details for specified employee and date
  Future<ManualAttendanceModel?> getAttendanceRegularization(String employeeId, DateTime shiftDate) async {
    try {
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      isLoading.value = true;
      MTAResult result = MTAResult();

      ManualAttendanceModel? attendanceDetails = await ManualAttendanceDetails().GetAttendanceRegularization(
        _authLogin!,
        employeeId,
        shiftDate,
        result
      );

      if (result.IsResultPass) {
        selectedAttendanceRegularization.value = attendanceDetails;
        if (attendanceDetails == null) {
          MTAToast().ShowToast('No attendance regularization found for the selected date.');
        }
      } else {
        MTAToast().ShowToast(result.ResultMessage.isNotEmpty 
          ? result.ResultMessage 
          : "Failed to fetch attendance regularization details");
        if (result.ErrorMessage.isNotEmpty) {
          throw Exception(result.ErrorMessage);
        }
      }

      return attendanceDetails;
    } catch (e) {
      MTAToast().ShowToast("Error fetching attendance regularization: ${e.toString()}");
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}