import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_attendance/controller/report/attendance_report_controller.dart';
import 'package:time_attendance/widget/reusable/button/custom_action_button.dart';
import 'package:time_attendance/model/report/attedance_report_model.dart';
import 'package:time_attendance/widget/reusable/multi_selection/reo_multi_selection_dropdown.dart';
// Import the multi-select dropdown widget
// import 'multi_select_dropdown.dart';

class AttendanceReportScreen extends StatefulWidget {
  AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final AttendanceReportController controller = Get.put(AttendanceReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Export Report Format Section - Show only for Daily reports
              if (controller.reportModel.value.reportDuration == 'Daily')
                _buildExportFormatSection(),
              if (controller.reportModel.value.reportDuration == 'Daily')
                const SizedBox(height: 16),
              
              // Report Duration and Employee Status Row
              Row(
                children: [
                  Expanded(child: _buildReportDurationSection()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEmployeeStatusSection()),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date/Month Selection Section
              _buildDateSelectionSection(),
              const SizedBox(height: 16),
              
              // Report Types Section
              if (controller.reportModel.value.reportDuration != 'Yearly')
                _buildReportTypesSection(),
              const SizedBox(height: 16),
              
              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 24),
              
              // Multi-Select Dropdown Sections
              _buildMultiSelectSections(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildExportFormatSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Report to :',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 16,
                runSpacing: 8,
                children: controller.exportFormats.map((format) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: format,
                        groupValue: controller.reportModel.value.exportFormat,
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectExportFormat(value);
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Text(format, style: const TextStyle(fontSize: 13)),
                    ],
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildReportDurationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Duration:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: controller.reportDurations.map((duration) {
                  return Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: duration,
                          groupValue: controller.reportModel.value.reportDuration,
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectReportDuration(value);
                            }
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: Text(
                            duration, 
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildEmployeeStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Employee Status:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: controller.employeeStatuses.map((status) {
                  return Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: status,
                          groupValue: controller.reportModel.value.employeeStatus,
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectEmployeeStatus(value);
                            }
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: Text(
                            status, 
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildDateSelectionSection() {
    return Obx(() {
      if (controller.reportModel.value.reportDuration == 'Daily') {
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From Date:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        controller.reportModel.value.fromDate?.toString().split(' ')[0] ?? 'Select Date',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('To Date:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        controller.reportModel.value.toDate?.toString().split(' ')[0] ?? 'Select Date',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      } else if (controller.reportModel.value.reportDuration == 'Monthly') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Month:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.reportModel.value.selectedMonth,
                  hint: const Text('Select Month'),
                  isExpanded: true,
                  items: _buildMonthItems(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectMonth(value);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Year:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.reportModel.value.selectedYear,
                  hint: const Text('Select Year'),
                  isExpanded: true,
                  items: controller.years.map((year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectYear(value);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      }
    });
  }

  List<DropdownMenuItem<String>> _buildMonthItems() {
    final currentYear = DateTime.now().year;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return months.map((month) {
      return DropdownMenuItem<String>(
        value: '$month-$currentYear',
        child: Text('$month-$currentYear'),
      );
    }).toList();
  }

  Widget _buildReportTypesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.reportModel.value.reportDuration == 'Monthly' 
                ? 'Monthly Report Types:' 
                : 'Daily Report Types:',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final reportTypes = controller.currentReportTypes;
            List<Widget> rows = [];
            for (int i = 0; i < reportTypes.length; i += 4) {
              final rowItems = reportTypes.skip(i).take(4).toList();
              rows.add(
                Row(
                  children: rowItems.map((type) {
                    return Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: type,
                            groupValue: controller.selectedReportTypes.contains(type) ? type : null,
                            onChanged: (value) {
                              controller.toggleReportType(type);
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Expanded(
                            child: Text(
                              type,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
              if (i + 4 < reportTypes.length) {
                rows.add(const SizedBox(height: 8));
              }
            }
            return Column(children: rows);
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomActionButton(
          label: 'Generate Report',
          onPressed: controller.generateReport,
          icon: Icons.description,
        ),
        const SizedBox(width: 16),
        CustomActionButton(
          label: 'Refresh',
          onPressed: controller.refreshData,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 16),
        CustomActionButton(
          label: 'Cancel',
          onPressed: controller.resetFilters,
          icon: Icons.cancel,
        ),
      ],
    );
  }

  Widget _buildMultiSelectSections() {
    return Column(
      children: [
        // Title
        const Text(
          'Selection Filters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Company and Employee Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => MultiSelectDropdown<CompanyModel>(
                        title: 'Companies',
                        items: controller.companies,
                        selectedItems: controller.companies
                            .where((company) => company.isSelected)
                            .toList(),
                        getDisplayName: (company) => company.name,
                        getItemId: (company) => company.id,
                        onSelectionChanged: (selectedCompanies) {
                          // Update selection state
                          for (var company in controller.companies) {
                            company.isSelected = selectedCompanies.any(
                              (selected) => selected.id == company.id,
                            );
                          }
                          controller.companies.refresh();
                          
                          // Update selectAll flag
                          final allSelected = controller.companies.every((c) => c.isSelected);
                          controller.reportModel.value = controller.reportModel.value
                              .copyWith(selectAllCompanies: allSelected);
                        },
                        selectAll: controller.reportModel.value.selectAllCompanies ?? false,
                        onSelectAllChanged: controller.toggleSelectAllCompanies,
                        hintText: 'Select Companies',
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => MultiSelectDropdown<EmployeeModel>(
                        title: 'Employees',
                        items: controller.employees,
                        selectedItems: controller.employees
                            .where((employee) => employee.isSelected)
                            .toList(),
                        getDisplayName: (employee) => employee.name,
                        getItemId: (employee) => employee.id,
                        onSelectionChanged: (selectedEmployees) {
                          // Update selection state
                          for (var employee in controller.employees) {
                            employee.isSelected = selectedEmployees.any(
                              (selected) => selected.id == employee.id,
                            );
                          }
                          controller.employees.refresh();
                          
                          // Update selectAll flag
                          final allSelected = controller.employees.every((e) => e.isSelected);
                          controller.reportModel.value = controller.reportModel.value
                              .copyWith(selectAllEmployees: allSelected);
                        },
                        selectAll: controller.reportModel.value.selectAllEmployees ?? false,
                        onSelectAllChanged: controller.toggleSelectAllEmployees,
                        hintText: 'Select Employees',
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Department and Designation Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Department:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => MultiSelectDropdown<DepartmentModel>(
                        title: 'Departments',
                        items: controller.departments,
                        selectedItems: controller.departments
                            .where((department) => department.isSelected)
                            .toList(),
                        getDisplayName: (department) => department.name,
                        getItemId: (department) => department.id,
                        onSelectionChanged: (selectedDepartments) {
                          // Update selection state
                          for (var department in controller.departments) {
                            department.isSelected = selectedDepartments.any(
                              (selected) => selected.id == department.id,
                            );
                          }
                          controller.departments.refresh();
                          
                          // Update selectAll flag
                          final allSelected = controller.departments.every((d) => d.isSelected);
                          controller.reportModel.value = controller.reportModel.value
                              .copyWith(selectAllDepartments: allSelected);
                        },
                        selectAll: controller.reportModel.value.selectAllDepartments ?? false,
                        onSelectAllChanged: controller.toggleSelectAllDepartments,
                        hintText: 'Select Departments',
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Designation:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => MultiSelectDropdown<DesignationModel>(
                        title: 'Designations',
                        items: controller.designations,
                        selectedItems: controller.designations
                            .where((designation) => designation.isSelected)
                            .toList(),
                        getDisplayName: (designation) => designation.name,
                        getItemId: (designation) => designation.id,
                        onSelectionChanged: (selectedDesignations) {
                          // Update selection state
                          for (var designation in controller.designations) {
                            designation.isSelected = selectedDesignations.any(
                              (selected) => selected.id == designation.id,
                            );
                          }
                          controller.designations.refresh();
                          
                          // Update selectAll flag
                          final allSelected = controller.designations.every((d) => d.isSelected);
                          controller.reportModel.value = controller.reportModel.value
                              .copyWith(selectAllDesignations: allSelected);
                        },
                        selectAll: controller.reportModel.value.selectAllDesignations ?? false,
                        onSelectAllChanged: controller.toggleSelectAllDesignations,
                        hintText: 'Select Designations',
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate 
          ? (controller.reportModel.value.fromDate ?? DateTime.now())
          : (controller.reportModel.value.toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null) {
      if (isFromDate) {
        controller.selectFromDate(picked);
      } else {
        controller.selectToDate(picked);
      }
    }
  }
}