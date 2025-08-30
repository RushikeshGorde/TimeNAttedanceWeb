
class DesignationModel {
  final String id;
  final String name;
  bool isSelected;

  DesignationModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
}
