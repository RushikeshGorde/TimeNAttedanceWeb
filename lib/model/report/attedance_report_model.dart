// attendance_report_model.dart

class AttendanceReportModel {
  String? exportFormat;
  String? reportDuration;
  String? employeeStatus;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedMonth;
  String? selectedYear;
  List<String>? reportTypes;
  List<String>? selectedCompanies;
  List<String>? selectedEmployees;
  List<String>? selectedDepartments;
  List<String>? selectedDesignations;
  bool? selectAllCompanies;
  bool? selectAllEmployees;
  bool? selectAllDepartments;
  bool? selectAllDesignations;

  AttendanceReportModel({
    this.exportFormat = 'PDF',
    this.reportDuration = 'Daily',
    this.employeeStatus = 'Active',
    this.fromDate,
    this.toDate,
    this.selectedMonth,
    this.selectedYear,
    this.reportTypes,
    this.selectedCompanies,
    this.selectedEmployees,
    this.selectedDepartments,
    this.selectedDesignations,
    this.selectAllCompanies = true,
    this.selectAllEmployees = true,
    this.selectAllDepartments = true,
    this.selectAllDesignations = true,
  });

  AttendanceReportModel copyWith({
    String? exportFormat,
    String? reportDuration,
    String? employeeStatus,
    DateTime? fromDate,
    DateTime? toDate,
    String? selectedMonth,
    String? selectedYear,
    List<String>? reportTypes,
    List<String>? selectedCompanies,
    List<String>? selectedEmployees,
    List<String>? selectedDepartments,
    List<String>? selectedDesignations,
    bool? selectAllCompanies,
    bool? selectAllEmployees,
    bool? selectAllDepartments,
    bool? selectAllDesignations,
  }) {
    return AttendanceReportModel(
      exportFormat: exportFormat ?? this.exportFormat,
      reportDuration: reportDuration ?? this.reportDuration,
      employeeStatus: employeeStatus ?? this.employeeStatus,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      reportTypes: reportTypes ?? this.reportTypes,
      selectedCompanies: selectedCompanies ?? this.selectedCompanies,
      selectedEmployees: selectedEmployees ?? this.selectedEmployees,
      selectedDepartments: selectedDepartments ?? this.selectedDepartments,
      selectedDesignations: selectedDesignations ?? this.selectedDesignations,
      selectAllCompanies: selectAllCompanies ?? this.selectAllCompanies,
      selectAllEmployees: selectAllEmployees ?? this.selectAllEmployees,
      selectAllDepartments: selectAllDepartments ?? this.selectAllDepartments,
      selectAllDesignations: selectAllDesignations ?? this.selectAllDesignations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exportFormat': exportFormat,
      'reportDuration': reportDuration,
      'employeeStatus': employeeStatus,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'selectedMonth': selectedMonth,
      'selectedYear': selectedYear,
      'reportTypes': reportTypes,
      'selectedCompanies': selectedCompanies,
      'selectedEmployees': selectedEmployees,
      'selectedDepartments': selectedDepartments,
      'selectedDesignations': selectedDesignations,
      'selectAllCompanies': selectAllCompanies,
      'selectAllEmployees': selectAllEmployees,
      'selectAllDepartments': selectAllDepartments,
      'selectAllDesignations': selectAllDesignations,
    };
  }

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceReportModel(
      exportFormat: json['exportFormat'],
      reportDuration: json['reportDuration'],
      employeeStatus: json['employeeStatus'],
      fromDate: json['fromDate'] != null ? DateTime.parse(json['fromDate']) : null,
      toDate: json['toDate'] != null ? DateTime.parse(json['toDate']) : null,
      selectedMonth: json['selectedMonth'],
      selectedYear: json['selectedYear'],
      reportTypes: json['reportTypes'] != null ? List<String>.from(json['reportTypes']) : null,
      selectedCompanies: json['selectedCompanies'] != null ? List<String>.from(json['selectedCompanies']) : null,
      selectedEmployees: json['selectedEmployees'] != null ? List<String>.from(json['selectedEmployees']) : null,
      selectedDepartments: json['selectedDepartments'] != null ? List<String>.from(json['selectedDepartments']) : null,
      selectedDesignations: json['selectedDesignations'] != null ? List<String>.from(json['selectedDesignations']) : null,
      selectAllCompanies: json['selectAllCompanies'],
      selectAllEmployees: json['selectAllEmployees'],
      selectAllDepartments: json['selectAllDepartments'],
      selectAllDesignations: json['selectAllDesignations'],
    );
  }
}

class CompanyModel {
  String id;
  String name;
  bool isSelected;

  CompanyModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  CompanyModel copyWith({
    String? id,
    String? name,
    bool? isSelected,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class EmployeeModel {
  String id;
  String name;
  String companyId;
  bool isSelected;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.companyId,
    this.isSelected = false,
  });

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? companyId,
    bool? isSelected,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class DepartmentModel {
  String id;
  String name;
  bool isSelected;

  DepartmentModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  DepartmentModel copyWith({
    String? id,
    String? name,
    bool? isSelected,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class DesignationModel {
  String id;
  String name;
  bool isSelected;

  DesignationModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  DesignationModel copyWith({
    String? id,
    String? name,
    bool? isSelected,
  }) {
    return DesignationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}