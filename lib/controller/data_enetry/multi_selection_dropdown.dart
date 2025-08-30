import 'package:get/get.dart';
import 'package:time_attendance/controller/master_tab_controller/company_controller.dart';
import 'package:time_attendance/controller/master_tab_controller/department_controller.dart';
import 'package:time_attendance/controller/master_tab_controller/designation_controller.dart';
import 'package:time_attendance/widgets/mtaToast.dart';

class TransferListController extends GetxController {
  // Inject required controllers
  final BranchController _branchController = Get.find<BranchController>();
  final DesignationController _designationController = Get.find<DesignationController>();
  final DepartmentController _departmentController = Get.find<DepartmentController>();
  
  // Company related lists
  RxList<String> availableCompanies = <String>[].obs;
  RxList<String> selectedCompanies = <String>[].obs;
  RxBool isAllCompaniesSelected = false.obs;

  // Department related lists
  RxList<String> availableDepartments = <String>[].obs;
  RxList<String> selectedDepartments = <String>[].obs;
  RxBool isAllDepartmentsSelected = false.obs;

  // Designation related lists
  RxList<String> availableDesignations = <String>[].obs;
  RxList<String> selectedDesignations = <String>[].obs;
  RxBool isAllDesignationsSelected = false.obs;

  // Location related lists
  RxList<String> availableLocations = <String>[].obs;
  RxList<String> selectedLocations = <String>[].obs;
  RxBool isAllLocationsSelected = false.obs;

  // Called when the controller is initialized
  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // Initializes data by fetching from controllers and populating lists with company, department, designation, and location names
  // Handles error cases and displays toast messages if data loading fails
  Future<void> _initializeData() async {
    try {
      // Wait for controllers to initialize data
      if (_branchController.branches.isEmpty) {
        await _branchController.fetchBranches();
      }
      
      if (_designationController.designations.isEmpty) {
        await _designationController.fetchDesignations();
      }
      
      // Ensure department data is loaded
      if (_departmentController.departments.isEmpty) {
        await _departmentController.initializeAuthDept();
      }

      // Extract company names from branch data
      final companyNames = _branchController.branches
          .map((branch) => '${branch.branchName}')
          .toSet()
          .toList();
      
      availableCompanies.value = companyNames;

      // Extract department names from department controller
      final departmentNames = _departmentController.departments
          .map((dept) => dept.departmentName)
          .toSet()
          .toList();
      
      if (departmentNames.isNotEmpty) {
        availableDepartments.value = departmentNames;
      }

      // Extract designation data from designation controller
      final designationNames = _designationController.designations
          .map((desig) => desig.designationName)
          .toSet()
          .toList();
          
      if (designationNames.isNotEmpty) {
        availableDesignations.value = designationNames;
      }

      // Extract location data
      final locationNames = _branchController.branches
          .map((branch) => branch.address ?? '')
          .where((address) => address.isNotEmpty)
          .toSet()
          .toList();
      
      if (locationNames.isNotEmpty) {
        availableLocations.value = locationNames;
      }

      // Sort all lists
      availableCompanies.sort();
      availableDepartments.sort();
      availableDesignations.sort();
      availableLocations.sort();
      
      print('Data initialized successfully:');
      print('Companies: ${availableCompanies.length}');
      print('Departments: ${availableDepartments.length}');
      print('Designations: ${availableDesignations.length}');
      print('Locations: ${availableLocations.length}');

    } catch (e, stackTrace) {
      print('Data initialization error: $e');
      print('Stack trace: $stackTrace');
      MTAToast().ShowToast('Failed to load data: ${e.toString()}');
    }
  }

  // Finds and returns the department ID for a given department name
  // Returns null if department is not found
  String? getDepartmentId(String departmentName) {
    final department = _departmentController.departments
        .firstWhereOrNull((dept) => dept.departmentName == departmentName);
    return department?.departmentId;
  }

  // Converts selected department names to their corresponding IDs
  // Returns a list of valid department IDs
  List<String> getSelectedDepartmentIds() {
    return selectedDepartments
        .map((departmentName) => getDepartmentId(departmentName))
        .where((id) => id != null)
        .map((id) => id!)
        .toList();
  }

  // Extracts company ID from a display string containing ID in parentheses
  // Returns null if no ID is found
  String? getCompanyId(String displayName) {
    final match = RegExp(r'\((.*?)\)').firstMatch(displayName);
    return match?.group(1);
  }

  // Converts selected company names to their corresponding IDs
  // Returns a list of valid company IDs
  List<String> getSelectedCompanyIds() {
    return selectedCompanies
        .map((company) => getCompanyId(company))
        .where((id) => id != null)
        .map((id) => id!)
        .toList();
  }

  // Moves highlighted companies from available list to selected list
  // Clears highlights after transfer
  void moveCompanyRight() {
    selectedCompanies.addAll(highlightedAvailableCompanies);
    availableCompanies.removeWhere(
        (company) => highlightedAvailableCompanies.contains(company));
    highlightedAvailableCompanies.clear();
    selectedCompanies.sort();
  }

  // Moves highlighted companies from selected list back to available list
  // Clears highlights after transfer
  void moveCompanyLeft() {
    availableCompanies.addAll(highlightedSelectedCompanies);
    selectedCompanies.removeWhere(
        (company) => highlightedSelectedCompanies.contains(company));
    highlightedSelectedCompanies.clear();
    availableCompanies.sort();
  }

  // Moves all companies from available list to selected list
  // Clears highlights after transfer
  void moveAllCompanyRight() {
    selectedCompanies.addAll(availableCompanies);
    availableCompanies.clear();
    highlightedAvailableCompanies.clear();
    selectedCompanies.sort();
  }

  // Moves all companies from selected list back to available list
  // Clears highlights after transfer
  void moveAllCompanyLeft() {
    availableCompanies.addAll(selectedCompanies);
    selectedCompanies.clear();
    highlightedSelectedCompanies.clear();
    availableCompanies.sort();
  }

  // Moves highlighted departments from available list to selected list
  // Clears highlights after transfer
  void moveDepartmentRight() {
    selectedDepartments.addAll(highlightedAvailableDepartments);
    availableDepartments
        .removeWhere((dept) => highlightedAvailableDepartments.contains(dept));
    highlightedAvailableDepartments.clear();
    selectedDepartments.sort();
  }

  // Moves highlighted departments from selected list back to available list
  // Clears highlights after transfer
  void moveDepartmentLeft() {
    availableDepartments.addAll(highlightedSelectedDepartments);
    selectedDepartments
        .removeWhere((dept) => highlightedSelectedDepartments.contains(dept));
    highlightedSelectedDepartments.clear();
    availableDepartments.sort();
  }

  // Moves all departments from available list to selected list
  // Clears highlights after transfer
  void moveAllDepartmentRight() {
    selectedDepartments.addAll(availableDepartments);
    availableDepartments.clear();
    highlightedAvailableDepartments.clear();
    selectedDepartments.sort();
  }

  // Moves all departments from selected list back to available list
  // Clears highlights after transfer
  void moveAllDepartmentLeft() {
    availableDepartments.addAll(selectedDepartments);
    selectedDepartments.clear();
    highlightedSelectedDepartments.clear();
    availableDepartments.sort();
  }

  // Lists for tracking highlighted items
  RxList<String> highlightedAvailableCompanies = <String>[].obs;
  RxList<String> highlightedSelectedCompanies = <String>[].obs;
  RxList<String> highlightedAvailableDepartments = <String>[].obs;
  RxList<String> highlightedSelectedDepartments = <String>[].obs;
  RxList<String> highlightedAvailableDesignations = <String>[].obs;
  RxList<String> highlightedSelectedDesignations = <String>[].obs;
  RxList<String> highlightedAvailableLocations = <String>[].obs;
  RxList<String> highlightedSelectedLocations = <String>[].obs;

  // Moves highlighted designations from available list to selected list
  // Clears highlights after transfer
  void moveDesignationRight() {
    selectedDesignations.addAll(highlightedAvailableDesignations);
    availableDesignations
        .removeWhere((designation) => highlightedAvailableDesignations.contains(designation));
    highlightedAvailableDesignations.clear();
    selectedDesignations.sort();
  }

  // Moves highlighted designations from selected list back to available list
  // Clears highlights after transfer
  void moveDesignationLeft() {
    availableDesignations.addAll(highlightedSelectedDesignations);
    selectedDesignations
        .removeWhere((designation) => highlightedSelectedDesignations.contains(designation));
    highlightedSelectedDesignations.clear();
    availableDesignations.sort();
  }

  // Moves all designations from available list to selected list
  // Clears highlights after transfer
  void moveAllDesignationRight() {
    selectedDesignations.addAll(availableDesignations);
    availableDesignations.clear();
    highlightedAvailableDesignations.clear();
    selectedDesignations.sort();
  }

  // Moves all designations from selected list back to available list
  // Clears highlights after transfer
  void moveAllDesignationLeft() {
    availableDesignations.addAll(selectedDesignations);
    selectedDesignations.clear();
    highlightedSelectedDesignations.clear();
    availableDesignations.sort();
  }

  // Moves highlighted locations from available list to selected list
  // Clears highlights after transfer
  void moveLocationRight() {
    selectedLocations.addAll(highlightedAvailableLocations);
    availableLocations
        .removeWhere((location) => highlightedAvailableLocations.contains(location));
    highlightedAvailableLocations.clear();
    selectedLocations.sort();
  }

  // Moves highlighted locations from selected list back to available list
  // Clears highlights after transfer
  void moveLocationLeft() {
    availableLocations.addAll(highlightedSelectedLocations);
    selectedLocations
        .removeWhere((location) => highlightedSelectedLocations.contains(location));
    highlightedSelectedLocations.clear();
    availableLocations.sort();
  }

  // Moves all locations from available list to selected list
  // Clears highlights after transfer
  void moveAllLocationRight() {
    selectedLocations.addAll(availableLocations);
    availableLocations.clear();
    highlightedAvailableLocations.clear();
    selectedLocations.sort();
  }

  // Moves all locations from selected list back to available list
  // Clears highlights after transfer
  void moveAllLocationLeft() {
    availableLocations.addAll(selectedLocations);
    selectedLocations.clear();
    highlightedSelectedLocations.clear();
    availableLocations.sort();
  }

  // Refreshes all data by fetching updated information from controllers
  // Handles errors and displays toast messages if refresh fails
  Future<void> refreshData() async {
    try {
      await _branchController.fetchBranches();
      await _departmentController.fetchDepartments();
      await _designationController.fetchDesignations();
      await _initializeData();
    } catch (e) {
      print('Error refreshing data: $e');
      MTAToast().ShowToast('Failed to refresh data: ${e.toString()}');
    }
  }
}