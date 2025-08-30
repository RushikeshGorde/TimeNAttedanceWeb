
class CompanyModel {
  final String id;
  final String name;
  bool isSelected;

  CompanyModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
}
