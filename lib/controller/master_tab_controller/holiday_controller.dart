import 'package:get/get.dart';
import 'package:time_attendance/Data/LoginInformation/AuthLogin.dart';
import 'package:time_attendance/Data/LoginInformation/AuthLoginInfoDetails.dart';
import 'package:time_attendance/General/MTAResult.dart';
import 'package:time_attendance/model/Masters/branch.dart';
import 'package:time_attendance/model/Masters/holiday.dart';
import 'package:time_attendance/model/Masters/holidayDetails.dart';
// import 'package:time_attendance/model/TALogin/session_manager.dart';
import 'package:time_attendance/model/master_tab_model/holiday_model.dart';
import 'package:time_attendance/widgets/mtaToast.dart';
import 'package:time_attendance/model/TALogin/session_manager.dart'
    if (dart.library.html) 'package:time_attendance/model/TALogin/session_manager_web.dart'
    if (dart.library.io) 'package:time_attendance/model/TALogin/session_manager_mobile.dart';

/// Controller class responsible for managing holiday-related operations
class HolidaysController extends GetxController {
  final isLoading = false.obs;
  final holiday = <HolidayModel>[].obs;
  final filterHolidays = <HolidayModel>[].obs;
  final searchQuery = ''.obs;
  final sortColumn = Rx<String?>(null);
  final isSortAscending = true.obs;

  AuthLogin? _authLogin;

  /// Initializes the controller and calls initializeAuthHoliday
  @override
  void onInit() {
    super.onInit();
    initializeAuthHoliday();
  }

  /// Initializes authentication by retrieving user information and setting up the auth login
  Future<void> initializeAuthHoliday() async {
    try {
      MTAResult objResult = MTAResult();
      final userInfo = await PlatformSessionManager.getUserInfo();
      if (userInfo != null) {
        String companyCode = userInfo['CompanyCode'];
        String loginID = userInfo['LoginID'];
        String password = userInfo['Password'];
        _authLogin = await AuthLoginDetails()
            .LoginInformationForFirstLogin(companyCode, loginID, password);
        fetchHolidays();
      }
    } catch (e) {
      MTAToast().ShowToast(e.toString());
    }
  }

  /// Retrieves all holidays from the API and updates the local holiday list
  Future<void> fetchHolidays() async {
    try {
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      isLoading.value = true;

      MTAResult result = MTAResult();
      List<Holiday> apiHoliday =
          await HolidayDetails().GetAllHolidayes(_authLogin!, result);
      print('apiHoliday: $apiHoliday');
      holiday.value = apiHoliday
          .map((b) => HolidayModel(
                holidayID: b.HolidayID,
                holidayName: b.HolidayName,
                holidayDate: b.HolidayDate,
                holidayYear: b.HolidayYear,
                listOfCompany: b.ListOfBranch.map(
                        (xyz) => ListOfCompany.fromJson(xyz.toJson()))
                    .toList(),
              ))
          .toList();

      updateSearchQuery(searchQuery.value);
    } catch (e) {
      MTAToast().ShowToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Filters the holiday list based on the provided search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filterHolidays.assignAll(holiday);
    } else {
      filterHolidays.assignAll(
        holiday.where((branch) =>
            (branch.holidayName?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (branch.holidayDate
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ??
                false) ||
            (branch.holidayYear
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ??
                false) ||
            (branch.listOfCompany
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ??
                false)),
      );
    }
  }

  /// Creates or updates a holiday record in the system
  Future<void> saveHoliday(HolidayModel holiday) async {
    try {
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      // Validate required fields
      if (holiday.holidayName?.isEmpty ?? true) {
        throw Exception('Holiday name is required');
      }
      if (holiday.holidayDate?.isEmpty ?? true) {
        throw Exception('Holiday date is required');
      }
      if (holiday.listOfCompany?.isEmpty ?? true) {
        throw Exception('At least one company must be selected');
      }

      String holidayYear;
      try {
        if (holiday.holidayDate!.contains('-')) {
          final parts = holiday.holidayDate!.split('-');
          if (parts.length == 3) {
            holidayYear = parts[2];
          } else {
            holidayYear = DateTime.now().year.toString();
          }
        } else {
          DateTime holidayDateTime = DateTime.parse(holiday.holidayDate!);
          holidayYear = holidayDateTime.year.toString();
        }
      } catch (e) {
        final dateRegex = RegExp(r'(\d{4})');
        final match = dateRegex.firstMatch(holiday.holidayDate!);
        holidayYear = match?.group(1) ?? DateTime.now().year.toString();
      }

      isLoading.value = true;
      MTAResult result = MTAResult();

      Holiday apiHoliday = Holiday()
        ..HolidayID = holiday.holidayID ?? ''
        ..HolidayName = holiday.holidayName ?? ''
        ..HolidayDate = holiday.holidayDate ?? ''
        ..HolidayYear = holidayYear
        ..BranchIDs = holiday.listOfCompany
                ?.map((company) => company.companyID ?? '')
                .where((id) => id.isNotEmpty)
                .join(',') ??
            ''
        ..ListOfBranch = holiday.listOfCompany
                ?.map((company) => Branch()
                  ..BranchID = company.companyID ?? ''
                  ..BranchName = company.companyName ?? ''
                  ..Address = company.address ?? ''
                  ..ContactNo = company.contactNo ?? ''
                  ..Website = company.website ?? '')
                .toList() ??
            [];

      bool success;
      if (holiday.holidayID == null || holiday.holidayID!.isEmpty) {
        success = await HolidayDetails().Save(_authLogin!, apiHoliday, result);
      } else {
        success = await HolidayDetails().Update(_authLogin!, apiHoliday, result);
      }

      if (success) {
        MTAToast().ShowToast(result.ResultMessage);
        await fetchHolidays();
      } else {
        throw Exception(result.ErrorMessage.isNotEmpty
            ? result.ErrorMessage
            : 'Failed to save holiday');
      }
    } catch (e) {
      MTAToast().ShowToast(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Removes a holiday record from the system using its ID
  Future<void> deleteHoliday(String holidayID) async {
    try {
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      isLoading.value = true;
      MTAResult result = MTAResult();

      bool success =
          await HolidayDetails().Delete(_authLogin!, holidayID, result);

      if (success) {
        MTAToast().ShowToast(result.ResultMessage);
        await fetchHolidays();
      } else {
        MTAToast().ShowToast(result.ResultMessage);
        throw Exception(result.ErrorMessage);
      }
    } catch (e) {
      MTAToast().ShowToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Sorts the holiday list based on the specified column and direction
  void sortHolidays(String columnName, bool? ascending) {
    if (ascending != null) {
      isSortAscending.value = ascending;
    } else if (sortColumn.value == columnName) {
      isSortAscending.value = !isSortAscending.value;
    } else {
      isSortAscending.value = true;
    }

    sortColumn.value = columnName;

    filterHolidays.sort((a, b) {
      int comparison;
      switch (columnName) {
        case 'Holiday Name':
          comparison = (a.holidayName ?? '').compareTo(b.holidayName ?? '');
          break;
        case 'Holiday Date':
          comparison = (a.holidayDate ?? '').compareTo(b.holidayDate ?? '');
          break;
        case 'Holiday Year':
          comparison = (a.holidayYear ?? '').compareTo(b.holidayYear ?? '');
          break;
        case 'Branch Name':
          comparison = (a.holidayName ?? '')
              .toString()
              .compareTo((b.holidayName ?? '').toString());
          break;
        case 'Address':
          comparison = (a.holidayDate ?? '')
              .toString()
              .compareTo((b.holidayDate ?? '').toString());
          break;
        case 'Contact':
          comparison = (a.holidayYear ?? '')
              .toString()
              .compareTo((b.holidayYear ?? '').toString());
          break;
        case 'Website':
          comparison = (a.listOfCompany ?? '')
              .toString()
              .compareTo((b.listOfCompany ?? '').toString());
          break;

        default:
          comparison = 0;
      }
      return isSortAscending.value ? comparison : -comparison;
    });
  }

  /// Retrieves holidays for a specific year from the API
  Future<void> fetchHolidaysByYear(String year) async {
    try {
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      isLoading.value = true;
      MTAResult result = MTAResult();

      List<Holiday> apiHoliday = await HolidayDetails()
          .GetHolidayByHolidayYear(_authLogin!, year, result);

      holiday.value = apiHoliday
          .map((b) => HolidayModel(
                holidayID: b.HolidayID,
                holidayName: b.HolidayName,
                holidayDate: b.HolidayDate,
                holidayYear: b.HolidayYear,
                listOfCompany: b.ListOfBranch.map(
                        (branch) => ListOfCompany.fromJson(branch.toJson()))
                    .toList(),
              ))
          .toList();

      updateSearchQuery(searchQuery.value);
    } catch (e) {
      MTAToast().ShowToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Retrieves holidays for a specific branch and year from the API
  Future<void> fetchHolidaysByBranchIDAndYear(
      String branchID, String year) async {
    try {
      if (_authLogin == null) {
        throw Exception('Authentication not initialized');
      }

      isLoading.value = true;
      MTAResult result = MTAResult();

      List<Holiday> apiHoliday = await HolidayDetails()
          .GetHolidayByBranchIDNYear(_authLogin!, branchID, year, result);

      if (result.ErrorMessage.isNotEmpty) {
        MTAToast().ShowToast(result.ErrorMessage);
        return;
      }

      holiday.value = apiHoliday
          .map((b) => HolidayModel(
                holidayID: b.HolidayID,
                holidayName: b.HolidayName,
                holidayDate: b.HolidayDate,
                holidayYear: b.HolidayYear,
                listOfCompany: b.ListOfBranch.map(
                        (branch) => ListOfCompany.fromJson(branch.toJson()))
                    .toList(),
              ))
          .toList();

      updateSearchQuery(searchQuery.value);
    } catch (e) {
      MTAToast().ShowToast('Error fetching holidays: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
