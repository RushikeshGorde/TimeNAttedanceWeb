// main_department_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_attendance/controller/master_tab_controller/department_controller.dart';
import 'package:time_attendance/controller/shift_tab_controller/shift_details_controller.dart';
import 'package:time_attendance/model/master_tab_model/department_model.dart';
import 'package:time_attendance/screen/employee_tab_screen/temprorary_weeklyOff/tempWeeklyOff_dialog_screen.dart';
import 'package:time_attendance/widget/reusable/button/custom_action_button.dart';
import 'package:time_attendance/widget/reusable/dialog/dialogbox.dart';
import 'package:time_attendance/widget/reusable/list/reusable_list.dart';
import 'package:time_attendance/widget/reusable/pagination/pagination_widget.dart';
import 'package:time_attendance/widget/reusable/tooltip/help_tooltip_button.dart';
import 'package:time_attendance/widget/reusable/search/reusable_search_field.dart';

class TemporaryWeeklyOffScreen extends StatelessWidget {
  TemporaryWeeklyOffScreen({super.key});

  final DepartmentController controller = Get.put(DepartmentController());
  final TextEditingController _searchController = TextEditingController();
  final ShiftDetailsController shiftDetails = Get.put(ShiftDetailsController());
  int _currentPage = 1;
  int _itemsPerPage = 10;
  final int _totalPages = 1;
  
  @override
  Widget build(BuildContext context) {
    // controller.fetchDepartments();
    controller.initializeAuthDept();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temporary WeeklyOff Muster'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (MediaQuery.of(context).size.width > 600)
            ReusableSearchField(
              searchController: _searchController,
              onSearchChanged: controller.updateSearchQuery,
            ),
          const SizedBox(width: 20),
          CustomActionButton(
            label: 'Assign WeeklyOff',
            onPressed: () => _showTempShiftDialog(context),
          ),
                CustomActionButton(
              label: 'Dowload',
              onPressed: () => {},
              icon: Icons.download,),
              // upload
              CustomActionButton(
                label: 'Upload',
                onPressed: () => {},
                icon: Icons.upload,
              ),
          const SizedBox(width: 8),
          HelpTooltipButton(
            tooltipMessage: 'Manage departments and their hierarchies in this section.',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (MediaQuery.of(context).size.width <= 600)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ReusableSearchField(
                searchController: _searchController,
                onSearchChanged: controller.updateSearchQuery,
                responsiveWidth: false,
              ),
            ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return Column(
                children: [
                  Expanded(
                    child: ReusableTableAndCard(
                      data: List.generate(
                        controller.filteredDepartments.length,
                        (index) => {
                          'Department Name': controller.filteredDepartments[index].departmentName,
                          'Master Department': controller.filteredDepartments[index].masterDepartmentName,
                        },
                      ),
                      headers: ['Department Name', 'Master Department', 'Actions'],
                      visibleColumns: ['Department Name', 'Master Department', 'Actions'],
                      onEdit: (row) {
                        final department = controller.filteredDepartments.firstWhere(
                          (d) => d.departmentName == row['Department Name'],
                        );
                        _showTempShiftDialog(context, department);
                      },
                      onDelete: (row) {
                        final department = controller.filteredDepartments.firstWhere(
                          (d) => d.departmentName == row['Department Name'],
                        );
                        _showDeleteConfirmationDialog(context, department);
                      },
                      onSort: (columnName, ascending) => 
                        controller.sortDepartments(columnName, ascending),
                    ),
                  ),
                  PaginationWidget(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onFirstPage: () => _handlePageChange(1),
                    onPreviousPage: () => _handlePageChange(_currentPage - 1),
                    onNextPage: () => _handlePageChange(_currentPage + 1),
                    onLastPage: () => _handlePageChange(_totalPages),
                    onItemsPerPageChange: _handleItemsPerPageChange,
                    itemsPerPage: _itemsPerPage,
                    itemsPerPageOptions: [10, 25, 50, 100],
                    totalItems: controller.filteredDepartments.length,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showTempShiftDialog(BuildContext context, [DepartmentModel? department]) {
    showCustomDialog(
      context: context,
      dialogContent: [
        TempWeeklyOffDialog(
    
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DepartmentModel department) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the department "${department.departmentName}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                controller.deleteDepartment(department.departmentId);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _handlePageChange(int page) {
    _currentPage = page;
    controller.update();
  }

  void _handleItemsPerPageChange(int itemsPerPage) {
    _itemsPerPage = itemsPerPage;
    _currentPage = 1;
    controller.update();
  }
}