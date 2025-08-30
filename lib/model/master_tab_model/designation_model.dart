// designation_model.dart
class DesignationModel {
  String designationId;
  String designationName;
  String masterDesignationId;
  String masterDesignationName;
  bool isDataRetrieved;

  // This is the main constructor that creates a new DesignationModel object
  // Used to: Create designation objects with default empty values
  DesignationModel({
    this.designationId = '',
    this.designationName = '',
    this.masterDesignationId = '',
    this.masterDesignationName = '',
    this.isDataRetrieved = false,
  });

  // This method converts JSON data from API into a DesignationModel object
  // Used to: Transform server response data into our app's designation format
  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      designationId: json['DesignationID'] ?? '',
      designationName: json['DesignationName'] ?? '',
      masterDesignationId: json['MastDesignationID'] ?? '',
      masterDesignationName: json['MastDesignationName'] ?? '',
      isDataRetrieved: true,
    );
  }

  // This method converts a DesignationModel object into JSON format
  // Used to: Send designation data to the server in the correct format
  Map<String, dynamic> toJson() {
    return {
      'DesignationID': designationId,
      'DesignationName': designationName,
      'MastDesignationID': masterDesignationId,
      'MastDesignationName': masterDesignationName,
    };
  }
}