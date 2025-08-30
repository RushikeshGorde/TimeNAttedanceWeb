
class EmployeeModel {
  final String id;
  final String name;
  final String companyId;
  bool isSelected;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.companyId,
    this.isSelected = false,
  });
}
