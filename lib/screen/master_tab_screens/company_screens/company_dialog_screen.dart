// company_dialog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:time_attendance/controller/master_tab_controller/company_controller.dart';
import 'package:time_attendance/model/master_tab_model/company_model.dart';
import 'package:time_attendance/widget/reusable/button/form_button.dart';

class BranchDialog extends StatefulWidget {
  final BranchController controller;
  final BranchModel branch;

  const BranchDialog({
    Key? key,
    required this.controller,
    required this.branch,
  }) : super(key: key);

  @override
  State<BranchDialog> createState() => _BranchDialogState();
}

class _BranchDialogState extends State<BranchDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _websiteController;
  String? _selectedMasterBranchId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch.branchName);
    _addressController = TextEditingController(text: widget.branch.address);
    _contactController = TextEditingController(text: widget.branch.contact);
    _websiteController = TextEditingController(text: widget.branch.website);
    _selectedMasterBranchId = widget.branch.masterBranchId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      String? masterBranchName;
      if (_selectedMasterBranchId != null && _selectedMasterBranchId!.isNotEmpty) {
        final masterBranch = widget.controller.branches.firstWhere(
          (b) => b.branchId == _selectedMasterBranchId,
          orElse: () => BranchModel(),
        );
        masterBranchName = masterBranch.branchName;
      }

      final updatedBranch = BranchModel(
        branchId: widget.branch.branchId,
        branchName: _nameController.text,
        address: _addressController.text,
        contact: _contactController.text,
        website: _websiteController.text,
        masterBranchId: _selectedMasterBranchId ?? '',
        masterBranch: masterBranchName ?? '',
      );

      widget.controller.saveBranch(updatedBranch);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width < 767
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width < 767
          ? MediaQuery.of(context).size.height * 0.45
          : MediaQuery.of(context).size.height * 0.67,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
                  widget.branch.branchId == null || widget.branch.branchId!.isEmpty
                      ? 'Add Branch'
                      : 'Edit Branch',
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
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
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
                                  text: 'Branch Name ',
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
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Branch name';
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
                              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Address ',
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
                            controller: _addressController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            maxLines: 3,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter Address' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Contact ',
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
                            controller: _contactController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Contact';
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                return 'Please enter valid 10 digit number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Website',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _websiteController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master Branch',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final availableBranches = widget.controller.branches
                                .where((b) => b.branchId != widget.branch.branchId)
                                .toList();
                            
                            return DropdownButtonFormField<String>(
                              value: _selectedMasterBranchId,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: '',
                                  child: Text('None'),
                                ),
                                ...availableBranches.map((branch) => DropdownMenuItem<String>(
                                  value: branch.branchId,
                                  child: Text(branch.branchName ?? 'Unnamed Branch'),
                                )),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedMasterBranchId = newValue;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 40),
                     CustomButtons(
                        onSavePressed: _handleSave,
                        onCancelPressed: () {
                          _nameController.clear();
                          _addressController.clear();
                          _contactController.clear();
                          _websiteController.clear();
                          setState(() {
                            _selectedMasterBranchId = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}