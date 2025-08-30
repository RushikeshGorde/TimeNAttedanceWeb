import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:time_attendance/controller/master_tab_controller/department_controller.dart';
import 'package:time_attendance/model/master_tab_model/department_model.dart';
import 'package:time_attendance/widget/reusable/button/form_button.dart';

class DepartmentDialog extends StatefulWidget {
  final DepartmentController controller;
  final DepartmentModel department;

  const DepartmentDialog({
    super.key, 
    required this.controller,
    required this.department,
  });

  @override
  State<DepartmentDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<DepartmentDialog> {
  late TextEditingController _nameController;
  late TextEditingController _searchController;
  String? _selectedMasterDepartmentId;
  final _formKey = GlobalKey<FormState>();
  bool _isDropdownOpen = false;
  List<DepartmentModel> _filteredDepartments = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.department.departmentName);
    _searchController = TextEditingController();
    _selectedMasterDepartmentId = widget.department.masterDepartmentId.isNotEmpty 
        ? widget.department.masterDepartmentId 
        : null;
    _filterDepartments('');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterDepartments(String searchText) {
    setState(() {
      _filteredDepartments = widget.controller.departments
          .where((d) =>
              d.departmentId != widget.department.departmentId &&
              d.departmentName.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  String _getSelectedDepartmentName() {
    if (_selectedMasterDepartmentId == null) return 'None';

    final department = widget.controller.departments.firstWhere(
      (d) => d.departmentId == _selectedMasterDepartmentId,
      orElse: () => DepartmentModel(),
    );
    return department.departmentName;
  }

  Widget _buildSearchableDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
              if (_isDropdownOpen) {
                _searchController.clear();
                _filterDepartments('');
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getSelectedDepartmentName(),
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedMasterDepartmentId == null
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),

        if (_isDropdownOpen) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search departments...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: _filterDepartments,
                  ),
                ),

                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMasterDepartmentId = null;
                            _isDropdownOpen = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedMasterDepartmentId == null
                                ? Colors.blue[50]
                                : null,
                          ),
                          child: const Text(
                            'None',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      ..._filteredDepartments.map((department) {
                        final isSelected = _selectedMasterDepartmentId ==
                            department.departmentId;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMasterDepartmentId = department.departmentId;
                              _isDropdownOpen = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue[50] : null,
                            ),
                            child: Text(
                              department.departmentName,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }),

                      if (_filteredDepartments.isEmpty &&
                          _searchController.text.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No departments found',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      String masterDepartmentName = '';
      if (_selectedMasterDepartmentId != null) {
        final masterDepartment = widget.controller.departments.firstWhere(
          (d) => d.departmentId == _selectedMasterDepartmentId,
          orElse: () => DepartmentModel(),
        );
        masterDepartmentName = masterDepartment.departmentName;
      }

      final updatedDepartment = DepartmentModel(
        departmentId: widget.department.departmentId,
        departmentName: _nameController.text.trim(),
        masterDepartmentId: _selectedMasterDepartmentId ?? '',
        masterDepartmentName: masterDepartmentName,
      );
      
      widget.controller.saveDepartment(updatedDepartment);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.department.departmentId.isEmpty 
                      ? 'Add Department'
                      : 'Edit Department',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Department Name ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Department Name';
                        }

                        if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                          return 'Name must start with a letter';
                        }

                        if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*$').hasMatch(value)) {
                          return 'Name can only contain letters, numbers, spaces, hyphens, underscores, and dots';
                        }

                        if (value.length > 20) {
                          return 'Name cannot exceed 20 characters';
                        }

                        if (value.contains('  ')) {
                          return 'Consecutive spaces are not allowed';
                        }

                        if (value.endsWith(' ')) {
                          return 'Name cannot end with a space';
                        }

                        return null;
                      },
                      maxLength: 20,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Master Department ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildSearchableDropdown(),
                const SizedBox(height: 40),
                CustomButtons(
                  onSavePressed: _handleSave,
                  onCancelPressed: () {
                    _nameController.clear();
                    setState(() {
                      _selectedMasterDepartmentId = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
