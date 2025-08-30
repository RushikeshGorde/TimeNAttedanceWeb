// import 'package:flutter/material.dart';
// import 'package:get/get.dart';



// // Model class representing inventory data
// class InventoryModel {
//   String? inventoryId;
//   String? assetCode;
//   String? assetName;
//   String? manufacture;
//   String? modelNumber;
//   String? serialNumber;
//   bool isRental;
//   bool isPurchase;
//   String? vendorName;
//   String? contactPerson;
//   String? phone1;
//   String? phone2;
//   String? remark;
//   DateTime? rentalStartDate;
//   DateTime? rentalEndDate;
//   DateTime? warrantyStartDate;
//   DateTime? warrantyEndDate;
//   String? recordUpdateOn;
//   String? bySenior;
//   String? byUserLogin;

//   // Constructor for creating a new InventoryModel instance
//   InventoryModel({
//     this.inventoryId,
//     this.assetCode,
//     this.assetName,
//     this.manufacture,
//     this.modelNumber,
//     this.serialNumber,
//     this.isRental = false,
//     this.isPurchase = false,
//     this.vendorName,
//     this.contactPerson,
//     this.phone1,
//     this.phone2,
//     this.remark,
//     this.rentalStartDate,
//     this.rentalEndDate,
//     this.warrantyStartDate,
//     this.warrantyEndDate,
//     this.recordUpdateOn,
//     this.bySenior,
//     this.byUserLogin,
//   });

//   // Factory constructor to create InventoryModel from JSON data
//   factory InventoryModel.fromJson(Map<String, dynamic> json) {
//     return InventoryModel(
//       inventoryId: json['inventoryId'],
//       assetCode: json['assetCode'],
//       assetName: json['assetName'],
//       manufacture: json['manufacture'],
//       modelNumber: json['modelNumber'],
//       serialNumber: json['serialNumber'],
//       isRental: json['isRental'] ?? false,
//       isPurchase: json['isPurchase'] ?? false,
//       vendorName: json['vendorName'],
//       contactPerson: json['contactPerson'],
//       phone1: json['phone1'],
//       phone2: json['phone2'],
//       remark: json['remark'],
//       rentalStartDate: json['rentalStartDate'] != null 
//           ? DateTime.parse(json['rentalStartDate']) 
//           : null,
//       rentalEndDate: json['rentalEndDate'] != null 
//           ? DateTime.parse(json['rentalEndDate']) 
//           : null,
//       warrantyStartDate: json['warrantyStartDate'] != null 
//           ? DateTime.parse(json['warrantyStartDate']) 
//           : null,
//       warrantyEndDate: json['warrantyEndDate'] != null 
//           ? DateTime.parse(json['warrantyEndDate']) 
//           : null,
//       recordUpdateOn: json['recordUpdateOn'],
//       bySenior: json['bySenior'],
//       byUserLogin: json['byUserLogin'],
//     );
//   }

//   // Convert InventoryModel to JSON format
//   Map<String, dynamic> toJson() {
//     return {
//       'inventoryId': inventoryId,
//       'assetCode': assetCode,
//       'assetName': assetName,
//       'manufacture': manufacture,
//       'modelNumber': modelNumber,
//       'serialNumber': serialNumber,
//       'isRental': isRental,
//       'isPurchase': isPurchase,
//       'vendorName': vendorName,
//       'contactPerson': contactPerson,
//       'phone1': phone1,
//       'phone2': phone2,
//       'remark': remark,
//       'rentalStartDate': rentalStartDate?.toIso8601String(),
//       'rentalEndDate': rentalEndDate?.toIso8601String(),
//       'warrantyStartDate': warrantyStartDate?.toIso8601String(),
//       'warrantyEndDate': warrantyEndDate?.toIso8601String(),
//       'recordUpdateOn': recordUpdateOn,
//       'bySenior': bySenior,
//       'byUserLogin': byUserLogin,
//     };
//   }
// }


// // Controller class for managing inventory dialog state and operations
// class InventoryDialogController extends GetxController {

//   // Form key for form validation
//   final formKey = GlobalKey<FormState>();
  

//   // Text Controllers for form fields
//   final assetCodeController = TextEditingController();
//   final assetNameController = TextEditingController();
//   final manufactureController = TextEditingController();
//   final modelNumberController = TextEditingController();
//   final serialNumberController = TextEditingController();
//   final vendorNameController = TextEditingController();
//   final contactPersonController = TextEditingController();
//   final phone1Controller = TextEditingController();
//   final phone2Controller = TextEditingController();
//   final remarkController = TextEditingController();
//   final rentalStartDateController = TextEditingController();
//   final rentalEndDateController = TextEditingController();
//   final warrantyStartDateController = TextEditingController();
//   final warrantyEndDateController = TextEditingController();


//   // Observable variables for state management
//   var isRental = false.obs;
//   var isPurchase = false.obs;
//   var isLoading = false.obs;
  
//   // Current inventory being edited
//   InventoryModel? currentInventory;

//   // Initialize controller and set up listeners
//   @override
//   void onInit() {
//     super.onInit();
    
//     // Listen to rental/purchase changes
//     isRental.listen((value) {
//       if (value) isPurchase.value = false;
//     });
    
//     isPurchase.listen((value) {
//       if (value) isRental.value = false;
//     });
//   }


//   // Initialize form with existing inventory data
//   void initializeForm(InventoryModel? inventory) {
//     if (inventory != null) {
//       currentInventory = inventory;
//       assetCodeController.text = inventory.assetCode ?? '';
//       assetNameController.text = inventory.assetName ?? '';
//       manufactureController.text = inventory.manufacture ?? '';
//       modelNumberController.text = inventory.modelNumber ?? '';
//       serialNumberController.text = inventory.serialNumber ?? '';
//       vendorNameController.text = inventory.vendorName ?? '';
//       contactPersonController.text = inventory.contactPerson ?? '';
//       phone1Controller.text = inventory.phone1 ?? '';
//       phone2Controller.text = inventory.phone2 ?? '';
//       remarkController.text = inventory.remark ?? '';
      
//       isRental.value = inventory.isRental;
//       isPurchase.value = inventory.isPurchase;
      
//       // Set date fields
//       if (inventory.rentalStartDate != null) {
//         rentalStartDateController.text = formatDate(inventory.rentalStartDate!);
//       }
//       if (inventory.rentalEndDate != null) {
//         rentalEndDateController.text = formatDate(inventory.rentalEndDate!);
//       }
//       if (inventory.warrantyStartDate != null) {
//         warrantyStartDateController.text = formatDate(inventory.warrantyStartDate!);
//       }
//       if (inventory.warrantyEndDate != null) {
//         warrantyEndDateController.text = formatDate(inventory.warrantyEndDate!);
//       }
//     }
//   }


//   // Clear all form fields and reset state
//   void clearForm() {
//     assetCodeController.clear();
//     assetNameController.clear();
//     manufactureController.clear();
//     modelNumberController.clear();
//     serialNumberController.clear();
//     vendorNameController.clear();
//     contactPersonController.clear();
//     phone1Controller.clear();
//     phone2Controller.clear();
//     remarkController.clear();
//     rentalStartDateController.clear();
//     rentalEndDateController.clear();
//     warrantyStartDateController.clear();
//     warrantyEndDateController.clear();
    
//     isRental.value = false;
//     isPurchase.value = false;
//     currentInventory = null;
//   }


//   // Save inventory data to backend
//   Future<void> saveInventory() async {
//     if (formKey.currentState?.validate() ?? false) {
//       isLoading.value = true;
      
//       try {
//         final inventory = InventoryModel(
//           inventoryId: currentInventory?.inventoryId,
//           assetCode: assetCodeController.text,
//           assetName: assetNameController.text,
//           manufacture: manufactureController.text,
//           modelNumber: modelNumberController.text,
//           serialNumber: serialNumberController.text,
//           isRental: isRental.value,
//           isPurchase: isPurchase.value,
//           vendorName: vendorNameController.text,
//           contactPerson: contactPersonController.text,
//           phone1: phone1Controller.text,
//           phone2: phone2Controller.text,
//           remark: remarkController.text,
//           rentalStartDate: parseDate(rentalStartDateController.text),
//           rentalEndDate: parseDate(rentalEndDateController.text),
//           warrantyStartDate: parseDate(warrantyStartDateController.text),
//           warrantyEndDate: parseDate(warrantyEndDateController.text),
//           recordUpdateOn: DateTime.now().toIso8601String(),


//           bySenior: 'Current User',
//           byUserLogin: 'Current User',
//         );




//         Get.back(result: inventory);
//         Get.snackbar('Success', 'Inventory saved successfully');
        
//       } catch (e) {
//         Get.snackbar('Error', 'Failed to save inventory: $e');
//       } finally {
//         isLoading.value = false;
//       }
//     }
//   }


//   // Show date picker and update controller value
//   Future<void> selectDate(TextEditingController controller) async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       controller.text = formatDate(picked);
//     }
//   }


//   // Format DateTime to string
//   String formatDate(DateTime date) {
//     return "${date.day}/${date.month}/${date.year}";
//   }


//   // Parse date string to DateTime
//   DateTime? parseDate(String dateString) {
//     if (dateString.isEmpty) return null;
//     try {
//       final parts = dateString.split('/');
//       if (parts.length == 3) {
//         return DateTime(
//           int.parse(parts[2]),
//           int.parse(parts[1]),
//           int.parse(parts[0]),
//         );
//       }
//     } catch (e) {
//       return null;
//     }
//     return null;
//   }

//   // Cleanup resources when controller is disposed
//   @override
//   void onClose() {

//     assetCodeController.dispose();
//     assetNameController.dispose();
//     manufactureController.dispose();
//     modelNumberController.dispose();
//     serialNumberController.dispose();
//     vendorNameController.dispose();
//     contactPersonController.dispose();
//     phone1Controller.dispose();
//     phone2Controller.dispose();
//     remarkController.dispose();
//     rentalStartDateController.dispose();
//     rentalEndDateController.dispose();
//     warrantyStartDateController.dispose();
//     warrantyEndDateController.dispose();
//     super.onClose();
//   }
// }


// // Dialog Widget for inventory form
// class InventoryDialog extends StatelessWidget {
//   final String title;
//   final InventoryModel? inventory;
  
//   const InventoryDialog({
//     Key? key, 
//     this.title = 'Add Inventory',
//     this.inventory,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(InventoryDialogController());
    

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.initializeForm(inventory);
//     });

//     double dialogWidth = MediaQuery.of(context).size.width < 767
//         ? MediaQuery.of(context).size.width * 0.95
//         : MediaQuery.of(context).size.width * 0.7;
//     double dialogHeight = MediaQuery.of(context).size.width < 767
//         ? MediaQuery.of(context).size.height * 0.8
//         : MediaQuery.of(context).size.height * 0.85;
    
//     bool isSmallScreen = MediaQuery.of(context).size.width < 720;

//     return Container(
//       width: dialogWidth,
//       height: dialogHeight,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [

//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.secondaryContainer,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.black87),
//                   onPressed: () => Get.back(),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),
          

//           Expanded(
//             child: SingleChildScrollView(
//               child: Form(
//                 key: controller.formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [

//                       if (!isSmallScreen)
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildTextField(
//                                 controller: controller.assetCodeController,
//                                 label: 'Asset Code*',
//                                 isRequired: true,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildTextField(
//                                 controller: controller.assetNameController,
//                                 label: 'Asset Name*',
//                                 isRequired: true,
//                               ),
//                             ),
//                           ],
//                         ),
//                       if (isSmallScreen) ...[
//                         _buildTextField(
//                           controller: controller.assetCodeController,
//                           label: 'Asset Code*',
//                           isRequired: true,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           controller: controller.assetNameController,
//                           label: 'Asset Name*',
//                           isRequired: true,
//                         ),
//                       ],
//                       const SizedBox(height: 16),


//                       if (!isSmallScreen)
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildTextField(
//                                 controller: controller.manufactureController,
//                                 label: 'Manufacture*',
//                                 isRequired: true,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildTextField(
//                                 controller: controller.modelNumberController,
//                                 label: 'Model Number*',
//                                 isRequired: true,
//                               ),
//                             ),
//                           ],
//                         ),
//                       if (isSmallScreen) ...[
//                         _buildTextField(
//                           controller: controller.manufactureController,
//                           label: 'Manufacture*',
//                           isRequired: true,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           controller: controller.modelNumberController,
//                           label: 'Model Number*',
//                           isRequired: true,


















































































































































































































































































































































































































//                         ),