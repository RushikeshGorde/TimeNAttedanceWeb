// designation_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_attendance/controller/master_tab_controller/designation_controller.dart';
import 'package:time_attendance/model/master_tab_model/designation_model.dart';
import 'package:time_attendance/widget/reusable/button/form_button.dart';
import 'package:flutter/services.dart';

class DesignationDialog extends StatefulWidget {
  final DesignationController controller;
  final DesignationModel designation;

  const DesignationDialog({
    super.key,
    required this.controller,
    required this.designation,
  });

  @override
  State<DesignationDialog> createState() => _DesignationDialogState();
}

class _DesignationDialogState extends State<DesignationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _searchController;
  String? _selectedMasterDesignationId;
  final _formKey = GlobalKey<FormState>();
  bool _isDropdownOpen = false;
  List<DesignationModel> _filteredDesignations = [];

  // This method runs when the dialog is first created
  // Used to: Set up the form fields with existing data if editing
  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.designation.designationName);
    _searchController = TextEditingController();
    _selectedMasterDesignationId =
        widget.designation.masterDesignationId.isNotEmpty
            ? widget.designation.masterDesignationId
            : null;

    // Initialize filtered designations
    _filterDesignations('');
  }

  // This method cleans up resources when the dialog is closed
  // Used to: Free up memory by disposing text controllers
  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter designations based on search text
  void _filterDesignations(String searchText) {
    setState(() {
      _filteredDesignations = widget.controller.designations
          .where((d) =>
              d.designationId !=
                  widget.designation
                      .designationId && // Exclude current designation
              d.designationName
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  // Get display text for selected designation
  String _getSelectedDesignationName() {
    if (_selectedMasterDesignationId == null) return 'None';

    final designation = widget.controller.designations.firstWhere(
      (d) => d.designationId == _selectedMasterDesignationId,
      orElse: () => DesignationModel(),
    );
    return designation.designationName;
  }

  // This method validates and saves the designation data
  // Used to: Process the form when user clicks save button
  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      // Find the selected designation to get its name
      String masterDesignationName = '';
      if (_selectedMasterDesignationId != null) {
        final masterDesignation = widget.controller.designations.firstWhere(
          (d) => d.designationId == _selectedMasterDesignationId,
          orElse: () => DesignationModel(),
        );
        masterDesignationName = masterDesignation.designationName;
      }

      final updatedDesignation = DesignationModel(
        designationId: widget.designation.designationId,
        designationName: _nameController.text,
        masterDesignationId: _selectedMasterDesignationId ?? '',
        masterDesignationName: masterDesignationName,
      );

      widget.controller.saveDesignation(updatedDesignation);
      Navigator.of(context).pop();
    }
  }

  // Build searchable dropdown widget
  Widget _buildSearchableDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dropdown button/field
        InkWell(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
              if (_isDropdownOpen) {
                _searchController.clear();
                _filterDesignations('');
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
                    _getSelectedDesignationName(),
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedMasterDesignationId == null
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

        // Dropdown overlay
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
                // Search field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search designations...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: _filterDesignations,
                  ),
                ),

                // Options list
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // None option
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMasterDesignationId = null;
                            _isDropdownOpen = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedMasterDesignationId == null
                                ? Colors.blue[50]
                                : null,
                          ),
                          child: const Text(
                            'None',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      // Filtered designations
                      ..._filteredDesignations.map((designation) {
                        final isSelected = _selectedMasterDesignationId ==
                            designation.designationId;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMasterDesignationId =
                                  designation.designationId;
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
                              designation.designationName,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }),

                      // No results message
                      if (_filteredDesignations.isEmpty &&
                          _searchController.text.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No designations found',
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

  // This method creates the visual layout of the dialog form
  // Used to: Display input fields and buttons for designation editing
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dialog Header
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
                  widget.designation.designationId.isEmpty
                      ? 'Add Designation'
                      : 'Edit Designation',
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

          // Dialog Content
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
                            text: 'Designation Name ',
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
                        // Remove labelText since we're using RichText above
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        helperStyle:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Designation Name';
                        }

                        // Check if it starts with a letter (a-z or A-Z)
                        if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                          return 'Name must start with a letter (not number or special character)';
                        }

                        // Check for invalid characters (only letters, numbers, spaces, and common punctuation allowed)
                        if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*$')
                            .hasMatch(value)) {
                          return 'Name can only contain letters, numbers, spaces, hyphens, underscores, and dots';
                        }

                        // Check length
                        if (value.length > 20) {
                          return 'Name cannot exceed 20 characters';
                        }

                        // Check for consecutive spaces
                        if (value.contains('  ')) {
                          return 'Consecutive spaces are not allowed';
                        }

                        // Check if it ends with space
                        if (value.endsWith(' ')) {
                          return 'Name cannot end with a space';
                        }

                        return null;
                      },
                      maxLength: 20,
                      inputFormatters: [
                        // Prevent starting with non-letters
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Label for the searchable dropdown
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Master Designation ',
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

                // Searchable dropdown
                _buildSearchableDropdown(),

                const SizedBox(height: 40),
                CustomButtons(
                  onSavePressed: _handleSave,
                  onCancelPressed: () {
                    _nameController.clear();
                    setState(() {
                      _selectedMasterDesignationId = null;
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
