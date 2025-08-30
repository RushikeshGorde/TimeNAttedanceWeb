// inventory_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:time_attendance/model/dataEnetry/inventary_model.dart';
// import 'package:time_attendance/model/master_tab_model/inventory_model.dart';

class InventoryController extends GetxController {
  final isLoading = false.obs;
  final inventories = <InventoryModel>[].obs;
  final filteredInventories = <InventoryModel>[].obs;
  final searchQuery = ''.obs;
  final sortColumn = Rx<String?>(null);
  final isSortAscending = true.obs;

  // Initialize the controller and fetch initial inventory data
  @override
  void onInit() {
    super.onInit();
    fetchInventories();
  }

  // Fetches inventory data and populates the list with dummy data
  // This method simulates an API call and handles loading states
  Future<void> fetchInventories() async {
    try {
      isLoading.value = true;
      
      // Simulating API call or data fetching
      inventories.value = [
        InventoryModel(
          inventoryId: '1',
          name: 'John Doe',
          laptop: 'HP Pavilion',
          laptopCharger: 'Original HP Charger',
          mobile: 'iPhone 12',
          mobileCharger: 'Apple Charger',
          idCard: 'Available',
          accessCard: 'Granted',
          emailId: 'john.doe@company.com',
          recordUpdateOn: '2024-03-27',
          bySenior: 'Admin',
          byUserLogin: 'johndoe',
        ),
        // ... [rest of the dummy data remains the same]
      ];

      updateSearchQuery(searchQuery.value);
    } catch (e) {
      // Handle error
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Saves or updates an inventory item in the list
  // If inventoryId is empty, creates new entry, otherwise updates existing
  Future<void> saveInventory(InventoryModel inventory) async {
    try {
      isLoading.value = true;
      
      // Simulating save operation
      if (inventory.inventoryId == null || inventory.inventoryId!.isEmpty) {
        // Add new inventory
        inventory.inventoryId = DateTime.now().millisecondsSinceEpoch.toString();
        inventories.add(inventory);
      } else {
        // Update existing inventory
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

  // Removes an inventory item from the list based on inventoryId
  Future<void> deleteInventory(String inventoryId) async {
    try {
      isLoading.value = true;
      
      // Simulating delete operation
      inventories.removeWhere((i) => i.inventoryId == inventoryId);
      updateSearchQuery(searchQuery.value);
    } catch (e) {
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Filters the inventory list based on search query
  // Matches against name, laptop, mobile, and email fields
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

  // Sorts the inventory list based on selected column and sort direction
  // Supports sorting by Name, Laptop, Mobile, and Email ID
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