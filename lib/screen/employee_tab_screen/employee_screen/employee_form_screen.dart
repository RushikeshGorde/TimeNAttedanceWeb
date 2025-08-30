import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:time_attendance/controller/employee_tab_controller/employee_search_controller.dart';
import 'package:time_attendance/controller/employee_tab_controller/emplyoee_controller.dart';
import 'package:time_attendance/controller/employee_tab_controller/settingprofile_controller.dart';
import 'package:time_attendance/model/employee_tab_model/employee_complete_model.dart';
import 'package:time_attendance/widget/reusable/button/form_button.dart';
import 'package:time_attendance/widget/reusable/dialog/employee_selection_dialog.dart';

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class EmployeeForm extends StatelessWidget {
  final EmployeeController controller = Get.put(EmployeeController());
  final SettingProfileController settingProfileController =
      Get.put(SettingProfileController());
  final employeeSearchController = Get.put(EmployeeSearchController());

  // Add this RxString to persist the selected profile across rebuilds
  final RxString selectedProfileId = ''.obs;

  void clearAllFields() {
    // Clear all text fields
    controller.employeeIdController.clear();
    controller.enrollIdController.clear();
    controller.employeeNameController.clear();
    controller.designationFormController.clear();
    controller.employeeTypeFormController.clear();
    // Set current date as default joining date
    controller.dateOfJoiningController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    controller.dateOfLeavingController.clear();
    controller.seniorReportingController.clear();
    controller.seniorReportingNameController.clear();
    controller.officeEmailController.clear();
    controller.genderController.clear();
    controller.bloodGroupController.clear();
    controller.nationalityController.clear();
    controller.personalEmailController.clear();
    controller.mobileNoController.clear();
    controller.dateOfBirthController.clear();
    controller.localAddressController.clear();
    controller.permanentAddressController.clear();
    controller.contactNoController.clear();

    // Reset dropdowns
    controller.selectedCompany.value = '';
    controller.selectedDepartment.value = '';
    controller.selectedLocation.value = '';
    controller.selectedEmployeeStatus.value = 'Active';
    controller.selectedEmployeeType.value = '';
    controller.selectedSettingProfile.value = null;
    selectedProfileId.value = '';
  }

  final Employee? employee;
  EmployeeForm({Key? key, this.employee}) : super(key: key) {
    if (employee == null) {
      clearAllFields();
    }
    if (employee != null) {
      // Populate professional details
      final prof = employee!.employeeProfessional;
      if (prof != null) {
        controller.employeeIdController.text = prof.employeeID;
        controller.enrollIdController.text = prof.enrollID;
        controller.employeeNameController.text = prof.employeeName;
        controller.selectedCompany.value = prof.companyID;
        controller.selectedDepartment.value = prof.departmentID;
        controller.designationFormController.text = prof.designationID;
        controller.selectedLocation.value = prof.locationID;
        controller.selectedEmployeeType.value = prof.employeeTypeID;
        controller.employeeTypeFormController.text = prof.employeeType;
        controller.selectedEmployeeStatus.value =
            prof.empStatus == 1 ? 'Active' : 'Inactive';
        controller.dateOfJoiningController.text = prof.dateOfEmployment;
        controller.dateOfLeavingController.text = prof.dateOfLeaving ?? '';
        controller.seniorReportingController.text = prof.seniorEmployeeID;
        controller.officeEmailController.text = prof.emailID;
      }

      // Populate personal details
      final personal = employee!.employeePersonal;
      if (personal != null) {
        controller.genderController.text = personal.gender;
        controller.bloodGroupController.text = personal.bloodGroup;
        controller.nationalityController.text = personal.nationality;
        controller.personalEmailController.text = personal.emailID;
        controller.mobileNoController.text = personal.mobileNumber;
        controller.dateOfBirthController.text = personal.dateOfBirth;
        controller.localAddressController.text = personal.localAddress;
        controller.permanentAddressController.text = personal.permanentAddress;
        controller.contactNoController.text = personal.contactNo;
      }

      // Set work settings
      controller.selectedSettingProfile.value = null; // Reset first
      if (employee!.employeeWOFF != null &&
          employee!.employeeSetting != null &&
          employee!.employeeGeneralSetting != null &&
          employee!.employeeLogin != null) {
        // We have all required settings, create a SettingProfileModel and set it
        // This needs to be implemented based on how settings are handled
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Form')),
      body: DefaultTabController(
        length: 3, // Changed from 2 to 3
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Professional'),
                Tab(text: 'Personal'),
                Tab(text: 'Work Setting'), // Added third tab
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProfessionalTab(context),
                  _buildPersonalTab(context),
                  _buildWorkSettingTab(context), // Added third tab content
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEmployeeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EmployeeSelectionDialog(
        onEmployeeSelected: (selectedEmployee) {
          // Set the selected employee's ID as the senior person ID
          controller.seniorReportingController.text =
              selectedEmployee.employeeID ?? '';
          // Set the selected employee's name as the display in the field
          controller.seniorReportingNameController.text =
              selectedEmployee.employeeName ?? '';
        },
      ),
    );
  }

  Widget _buildProfessionalTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormRow(
            children: [
              _buildTextField(
                controller: controller.employeeIdController,
                label: 'Employee ID',
                isRequired: true,
                maxLength: 15,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              _buildTextField(
                controller: controller.enrollIdController,
                label: 'Device Enroll ID',
                isRequired: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              _buildTextField(
                controller: controller.employeeNameController,
                label: 'Employee Name',
                isRequired: true,
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  // Check if it starts with a letter (a-z or A-Z)
                  if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                    return 'Name must start with a letter';
                  }
                  // Check for invalid characters
                  if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*$').hasMatch(value)) {
                    return 'Only letters, numbers, spaces, hyphens, underscores, and dots allowed';
                  }
                  // Check for consecutive spaces
                  if (value.contains('  ')) {
                    return 'Consecutive spaces not allowed';
                  }
                  // Check if it ends with space
                  if (value.endsWith(' ')) {
                    return 'Name cannot end with a space';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Professional Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Obx(() => _buildFormRow(
                children: [
                  // Company Dropdown
                  _buildRequiredDropdown<String>(
                    value: controller.selectedCompany.value.isEmpty
                        ? null
                        : controller.selectedCompany.value,
                    label: 'Company',
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Select Company')),
                      ...controller.companies
                          .map((company) => DropdownMenuItem(
                                value: company.branchId ?? '',
                                child: Text(company.branchName ?? ''),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) =>
                        controller.selectedCompany.value = value ?? '',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  // Department Dropdown
                  _buildRequiredDropdown<String>(
                    value: controller.selectedDepartment.value.isEmpty
                        ? null
                        : controller.selectedDepartment.value,
                    label: 'Department',
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Select Department')),
                      ...controller.departments
                          .map((dept) => DropdownMenuItem(
                                value: dept.departmentId,
                                child: Text(dept.departmentName),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) =>
                        controller.selectedDepartment.value = value ?? '',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  // Employee Type Dropdown
                  _buildRequiredDropdown<String>(
                    value: controller.selectedEmployeeType.value.isEmpty
                        ? null
                        : controller.selectedEmployeeType.value,
                    label: 'Employee Type',
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Select Employee Type')),
                      ...controller.employeeTypes
                          .map((type) => DropdownMenuItem(
                                value: type.employeeTypeId,
                                child: Text(type.employeeTypeName),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      controller.selectedEmployeeType.value = value ?? '';
                      if (value != null) {
                        final selectedType = controller.employeeTypes
                            .firstWhere((type) => type.employeeTypeId == value);
                        controller.employeeTypeFormController.text =
                            selectedType.employeeTypeName;
                      }
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ],
              )),
          const SizedBox(height: 16),
          Obx(() => _buildFormRow(
                children: [
                  // Designation Dropdown
                  _buildRequiredDropdown<String>(
                    value: controller.designationFormController.text.isEmpty
                        ? null
                        : controller.designationFormController.text,
                    label: 'Designation',
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Select Designation')),
                      ...controller.designations
                          .map((designation) => DropdownMenuItem(
                                value: designation.designationId,
                                child: Text(designation.designationName),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) =>
                        controller.designationFormController.text = value ?? '',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  // Location Dropdown
                  _buildRequiredDropdown<String>(
                    value: controller.selectedLocation.value.isEmpty
                        ? null
                        : controller.selectedLocation.value,
                    label: 'Location',
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Select Location')),
                      ...controller.locations
                          .map((location) => DropdownMenuItem(
                                value: location.locationID,
                                child: Text(location.locationName ?? ''),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) =>
                        controller.selectedLocation.value = value ?? '',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  // Employee Status Dropdown
                  _buildRequiredDropdown<String>(
                    value: controller.selectedEmployeeStatus.value,
                    label: 'Employee Status',
                    items: controller.employeeStatuses
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) => controller
                        .selectedEmployeeStatus.value = value ?? 'Active',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ],
              )),
          const SizedBox(height: 16),
          _buildFormRow(
            children: [
              _buildDateField(
                context: context,
                controller: controller.dateOfJoiningController,
                label: 'Date Of Joining',
                isRequired: true,
                isJoiningDate: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              _buildDateField(
                context: context,
                controller: controller.dateOfLeavingController,
                label: 'Date Of Leaving',
                isLeavingDate: true,
                joiningDateController: controller.dateOfJoiningController,
              ),
              // Senior Reporting Person field with magnifying icon
              _buildTextField(
                controller: controller.seniorReportingNameController,
                label: 'Senior Reporting Person',
                readOnly: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => showEmployeeSelectionDialog(context),
                ),
                onTap: () => showEmployeeSelectionDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormRow(
            children: [
              _buildTextField(
                controller: controller.officeEmailController,
                label: 'Office Email ID',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Regular expression for email validation
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
                inputFormatters: [
                  // Allow only valid email characters
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.@_+-]')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSaveCancelButtons(context),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(BuildContext context) {
    // Set default value for nationality if empty
    if (controller.nationalityController.text.isEmpty) {
      controller.nationalityController.text = 'Indian';
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFormRow(
            children: [
              _buildRequiredDropdown<String>(
                items: ['-', 'Male', 'Female'].map((option) => 
                  DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  )
                ).toList(),
                label: 'Gender',
                onChanged: (value) => controller.genderController.text = value!,
                value: controller.genderController.text.isEmpty
                    ? '-'
                    : controller.genderController.text,
                validator: (value) =>
                    value == null || value == '-' || value.isEmpty
                        ? 'Required'
                        : null,
              ),
              _buildDropdown(
                options:
                    ['-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].obs,
                label: 'Blood Group',
                onChanged: (value) =>
                    controller.bloodGroupController.text = value!,
                value: controller.bloodGroupController.text.isEmpty
                    ? '-'
                    : controller.bloodGroupController.text,
              ),
              _buildTextField(
                controller: controller.nationalityController,
                label: 'Nationality',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormRow(
            children: [
              _buildTextField(
                controller: controller.personalEmailController,
                label: 'Personal Email ID',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Regular expression for email validation
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
                inputFormatters: [
                  // Allow only valid email characters
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.@_+-]')),
                ],
              ),
              _buildTextField(
                controller: controller.mobileNoController,
                label: 'Mobile No.',
                isRequired: true,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
              ),
              _buildDateField(
                context: context,
                controller: controller.dateOfBirthController,
                label: 'Date of Birth',
                isRequired: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormRow(
            children: [
              _buildTextField(
                controller: controller.localAddressController,
                label: 'Local Address',
                maxLines: 3,
              ),
              _buildTextField(
                controller: controller.permanentAddressController,
                label: 'Permanent Address',
                maxLines: 3,
              ),
              _buildTextField(
                controller: controller.contactNoController,
                label: 'Contact No',
                isRequired: true,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (value.length != 10) {
                    return 'Contact number must be 10 digits';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSaveCancelButtons(context),
        ],
      ),
    );
  }

  Widget _buildWorkSettingTab(BuildContext context) {
    return Obx(() {
      final profiles = settingProfileController.settingProfiles;
      if (profiles.isNotEmpty && selectedProfileId.value.isEmpty) {
        final defaultProfile =
            profiles.firstWhereOrNull((p) => p.isDefaultProfile);
        selectedProfileId.value =
            defaultProfile?.profileId ?? profiles.first.profileId;

        // Set the initial selected profile in the controller
        final selectedProfile = profiles
            .firstWhereOrNull((p) => p.profileId == selectedProfileId.value);
        if (selectedProfile != null) {
          controller.selectedSettingProfile.value = selectedProfile;
        }
      }
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Work Setting Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Reduce dropdown width
            Row(
              children: [
                SizedBox(
                  width: 320, // Set a reasonable width for the dropdown
                  child: _buildRequiredDropdown<String>(
                    value: selectedProfileId.value.isEmpty
                        ? null
                        : selectedProfileId.value,
                    label: 'Setting Profile',
                    items: profiles
                        .map((profile) => DropdownMenuItem(
                              value: profile.profileId,
                              child: Text(profile.profileName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedProfileId.value = value;
                        // Update the controller's selected profile
                        final selectedProfile = profiles
                            .firstWhereOrNull((p) => p.profileId == value);
                        if (selectedProfile != null) {
                          controller.selectedSettingProfile.value =
                              selectedProfile;
                        }
                      }
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final profile = profiles.firstWhereOrNull(
                  (p) => p.profileId == selectedProfileId.value);
              if (profile != null && profile.description.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(profile.description),
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
            const SizedBox(height: 24),
            _buildSaveCancelButtons(context),
          ],
        ),
      );
    });
  }

  Widget _buildFormRow({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile: width < 600 (1 item per row)
        // Laptop: width >= 600 && < 1200 (2 items per row)
        // PC: width >= 1200 (3 items per row)
        int itemsPerRow;
        if (constraints.maxWidth < 600) {
          itemsPerRow = 1;
        } else if (constraints.maxWidth < 1200) {
          itemsPerRow = 2;
        } else {
          itemsPerRow = 3;
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children.asMap().entries.map((entry) {
            return SizedBox(
              width:
                  (constraints.maxWidth - (itemsPerRow - 1) * 16) / itemsPerRow,
              child: entry.value,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
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
          )
        else
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: suffixIcon,
            counterText: maxLength != null ? '' : null, // Hide character counter
          ),
          onTap: onTap,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    FormFieldValidator<String>? validator,
    bool isJoiningDate = false,
    bool isLeavingDate = false,
    TextEditingController? joiningDateController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
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
          )
        else
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () => _selectDate(
            context, 
            controller, 
            isJoiningDate: isJoiningDate,
            isLeavingDate: isLeavingDate,
            joiningDateController: joiningDateController,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context, 
    TextEditingController controller, {
    bool isJoiningDate = false,
    bool isLeavingDate = false,
    TextEditingController? joiningDateController,
  }) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime(2100);

    // For Date of Joining: disable future dates (only today and past dates)
    if (isJoiningDate) {
      lastDate = DateTime.now(); // No future dates allowed
      if (controller.text.isNotEmpty) {
        try {
          initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
          if (initialDate.isAfter(DateTime.now())) {
            initialDate = DateTime.now();
          }
        } catch (e) {
          initialDate = DateTime.now();
        }
      }
    }

    // For Date of Leaving: disable dates before joining date
    if (isLeavingDate && joiningDateController != null && joiningDateController.text.isNotEmpty) {
      try {
        final joiningDate = DateFormat('yyyy-MM-dd').parse(joiningDateController.text);
        firstDate = joiningDate; // No dates before joining date allowed
        if (controller.text.isNotEmpty) {
          initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
          if (initialDate.isBefore(joiningDate)) {
            initialDate = joiningDate;
          }
        } else {
          initialDate = joiningDate;
        }
      } catch (e) {
        // If joining date is invalid, use default behavior
        firstDate = DateTime(1900);
        initialDate = DateTime.now();
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _buildDropdown({
    required RxList<String> options,
    required String label,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
    String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              value: value,
              items: options
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: validator,
            )),
      ],
    );
  }

  Widget _buildRequiredDropdown<T>({
    required String label,
    T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    FormFieldValidator<T>? validator,
    RxList<String>? options,
  }) {
    // Handle the case for simple string dropdowns with options
    if (options != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
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
          Obx(() => DropdownButtonFormField<String>(
                value: value as String?,
                items: options
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: onChanged as ValueChanged<String?>,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: validator as FormFieldValidator<String>?,
              )),
        ],
      );
    }

    // Handle the case for complex dropdowns with items
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$label ',
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
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSaveCancelButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButtons(
          onSavePressed: () async {
            final success = await controller.saveEmployee(isEdit: employee != null);
            if (success) {
              clearAllFields(); // Use the existing clearAllFields method
              Navigator.pop(context);
              await employeeSearchController.fetchEmployees(resetPage: true);
            }
          },
          onCancelPressed: () {
            clearAllFields(); // Clear fields but don't close popup
          },
        ),
      ],
    );
  }
}