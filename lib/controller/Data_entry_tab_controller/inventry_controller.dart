// inventory_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:time_attendance/model/Data_entry_tab_model/inventry_model.dart';
// import 'package:time_attendance/model/dataEnetry/inventary_model.dart';
// import 'package:time_attendance/model/master_tab_model/inventory_model.dart';

class InventoryController extends GetxController {
  final isLoading = false.obs;
  final inventories = <InventoryModel>[].obs;
  final filteredInventories = <InventoryModel>[].obs;
  final searchQuery = ''.obs;
  final sortColumn = Rx<String?>(null);
  final isSortAscending = true.obs;

  /// Initializes the controller and fetches initial inventory data
  @override
  void onInit() {
    super.onInit();
    fetchInventories();
  }

  /// Fetches inventory data from the data source and populates the inventories list
  /// with dummy data for demonstration purposes
  Future<void> fetchInventories() async {
    try {
      isLoading.value = true;
      
      // Simulating API call or data fetching
      inventories.value = [
        // ... (same inventory data)
      ];

      updateSearchQuery(searchQuery.value);
    } catch (e) {
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Saves a new inventory item or updates an existing one
  /// Takes an InventoryModel as parameter and adds it to the inventories list
  Future<void> saveInventory(InventoryModel inventory) async {
    try {
      isLoading.value = true;
      
      if (inventory.inventoryId == null || inventory.inventoryId!.isEmpty) {
        inventory.inventoryId = DateTime.now().millisecondsSinceEpoch.toString();
        inventories.add(inventory);
      } else {
        final index = inventories.indexWhere((i) => i.inventoryId == inventory.inventoryId);
        if (index != -1) {
          inventories[index] = inventory;
        }
      }

      updateSearchQuery(searchQuery.value);
    } catch (e) {
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes an inventory item by its ID
  /// Takes inventoryId as parameter and removes the corresponding item from the list
  Future<void> deleteInventory(String inventoryId) async {
    try {
      isLoading.value = true;
      
      inventories.removeWhere((i) => i.inventoryId == inventoryId);
      updateSearchQuery(searchQuery.value);
    } catch (e) {
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates the search query and filters the inventory list based on the search term
  /// Filters by name, laptop, mobile, or email ID
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredInventories.assignAll(inventories);
    } else {
      filteredInventories.assignAll(
        inventories.where((inventory) =>
            (inventory.name?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (inventory.laptop?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (inventory.mobile?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (inventory.emailId?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ),
      );
    }
  }

  /// Sorts the inventory list based on the specified column and sort direction
  /// Takes columnName and optional ascending parameter to determine sort order
  void sortInventories(String columnName, bool? ascending) {
    if (ascending != null) {
      isSortAscending.value = ascending;
    } else if (sortColumn.value == columnName) {
      isSortAscending.value = !isSortAscending.value;
    } else {
      isSortAscending.value = true;
    }

    sortColumn.value = columnName;

    filteredInventories.sort((a, b) {
      int comparison;
      switch (columnName) {
        case 'Name':
          comparison = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'Laptop':
          comparison = (a.laptop ?? '').compareTo(b.laptop ?? '');
          break;
        case 'Mobile':
          comparison = (a.mobile ?? '').compareTo(b.mobile ?? '');
          break;
        case 'Email ID':
          comparison = (a.emailId ?? '').compareTo(b.emailId ?? '');
          break;
        default:
          comparison = 0;
      }
      return isSortAscending.value ? comparison : -comparison;
    });
  }
}