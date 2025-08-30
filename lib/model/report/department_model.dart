
class DepartmentModel {
  final String id;
  final String name;
  bool isSelected;

  DepartmentModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
}
