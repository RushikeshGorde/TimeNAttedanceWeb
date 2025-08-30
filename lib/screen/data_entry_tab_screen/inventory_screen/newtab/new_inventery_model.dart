class AssetModel {
  String assetCode;
  String assetName;
  String manufacturer;
  String modelNumber;
  String serialNumber;
  bool isRental;
  bool isPurchase;
  String vendorName;
  String contactPerson;
  String phone1;
  String phone2;
  String remark;
  DateTime? rentalPeriodStart;
  DateTime? rentalPeriodEnd;
  DateTime? warrantyPeriodStart;
  DateTime? warrantyPeriodEnd;

  AssetModel({
    this.assetCode = '',
    this.assetName = '',
    this.manufacturer = '',
    this.modelNumber = '',
    this.serialNumber = '',
    this.isRental = false,
    this.isPurchase = false,
    this.vendorName = '',
    this.contactPerson = '',
    this.phone1 = '',
    this.phone2 = '',
    this.remark = '',
    this.rentalPeriodStart,
    this.rentalPeriodEnd,
    this.warrantyPeriodStart,
    this.warrantyPeriodEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'assetCode': assetCode,
      'assetName': assetName,
      'manufacturer': manufacturer,
      'modelNumber': modelNumber,
      'serialNumber': serialNumber,
      'isRental': isRental,
      'isPurchase': isPurchase,
      'vendorName': vendorName,
      'contactPerson': contactPerson,
      'phone1': phone1,
      'phone2': phone2,
      'remark': remark,
      'rentalPeriodStart': rentalPeriodStart?.toIso8601String(),
      'rentalPeriodEnd': rentalPeriodEnd?.toIso8601String(),
      'warrantyPeriodStart': warrantyPeriodStart?.toIso8601String(),
      'warrantyPeriodEnd': warrantyPeriodEnd?.toIso8601String(),
    };
  }

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      assetCode: json['assetCode'] ?? '',
      assetName: json['assetName'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      modelNumber: json['modelNumber'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      isRental: json['isRental'] ?? false,
      isPurchase: json['isPurchase'] ?? false,
      vendorName: json['vendorName'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      phone1: json['phone1'] ?? '',
      phone2: json['phone2'] ?? '',
      remark: json['remark'] ?? '',
      rentalPeriodStart: json['rentalPeriodStart'] != null 
          ? DateTime.parse(json['rentalPeriodStart']) 
          : null,
      rentalPeriodEnd: json['rentalPeriodEnd'] != null 
          ? DateTime.parse(json['rentalPeriodEnd']) 
          : null,
      warrantyPeriodStart: json['warrantyPeriodStart'] != null 
          ? DateTime.parse(json['warrantyPeriodStart']) 
          : null,
      warrantyPeriodEnd: json['warrantyPeriodEnd'] != null 
          ? DateTime.parse(json['warrantyPeriodEnd']) 
          : null,
    );
  }

  AssetModel copyWith({
    String? assetCode,
    String? assetName,
    String? manufacturer,
    String? modelNumber,
    String? serialNumber,
    bool? isRental,
    bool? isPurchase,
    String? vendorName,
    String? contactPerson,
    String? phone1,
    String? phone2,
    String? remark,
    DateTime? rentalPeriodStart,
    DateTime? rentalPeriodEnd,
    DateTime? warrantyPeriodStart,
    DateTime? warrantyPeriodEnd,
  }) {
    return AssetModel(
      assetCode: assetCode ?? this.assetCode,
      assetName: assetName ?? this.assetName,
      manufacturer: manufacturer ?? this.manufacturer,
      modelNumber: modelNumber ?? this.modelNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      isRental: isRental ?? this.isRental,
      isPurchase: isPurchase ?? this.isPurchase,
      vendorName: vendorName ?? this.vendorName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      remark: remark ?? this.remark,
      rentalPeriodStart: rentalPeriodStart ?? this.rentalPeriodStart,
      rentalPeriodEnd: rentalPeriodEnd ?? this.rentalPeriodEnd,
      warrantyPeriodStart: warrantyPeriodStart ?? this.warrantyPeriodStart,
      warrantyPeriodEnd: warrantyPeriodEnd ?? this.warrantyPeriodEnd,
    );
  }
}