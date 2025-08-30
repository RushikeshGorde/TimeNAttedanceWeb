// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:time_attendance/controller/master_tab_controller/company_controller.dart';
import 'package:time_attendance/controller/master_tab_controller/holiday_controller.dart';
import 'package:time_attendance/model/master_tab_model/holiday_model.dart';
import 'package:time_attendance/widget/reusable/button/form_button.dart';

class HolidayDialog extends StatefulWidget {
  final HolidaysController holidayController;
  final HolidayModel holiday;

  const HolidayDialog({
    super.key,
    required this.holidayController,
    required this.holiday,
  });

  @override
  State<HolidayDialog> createState() => _HolidayDialogState();
}

class _HolidayDialogState extends State<HolidayDialog> {
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _yearController;
  late TextEditingController _searchController;
  final _formKey = GlobalKey<FormState>();
  final BranchController branchController = Get.find<BranchController>();
  List<ListOfCompany> selectedCompanies = [];
  String searchQuery = '';
  bool _dropdownOpen = false;
  List<ListOfCompany> _filteredCompanies = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.holiday.holidayName);
    _dateController = TextEditingController(text: widget.holiday.holidayDate);
    _yearController = TextEditingController(text: widget.holiday.holidayYear);
    _searchController = TextEditingController();
    selectedCompanies = widget.holiday.listOfCompany ?? [];
    _initializeBranchController();
  }

  Future<void> _initializeBranchController() async {
    await branchController.initializeAuthBranch();
    await branchController.fetchBranches();
    _filterCompanies('');
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _yearController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCompanies(String searchText) {
    setState(() {
      final branches = branchController.branches;
      final companies = branches.map((branch) => ListOfCompany(
            companyID: branch.branchId,
            companyName: branch.branchName,
            address: branch.address,
            contactNo: branch.contact,
            website: branch.website,
            mastCompanyID: branch.masterBranchId,
            mastCompanyName: branch.masterBranch,
          )).toList();

      if (searchText.isEmpty) {
        _filteredCompanies = companies;
      } else {
        _filteredCompanies = companies.where((company) =>
            company.companyName?.toLowerCase().contains(searchText.toLowerCase()) ??
            false ||
            (company.mastCompanyName != null &&
                company.mastCompanyName!
                    .toLowerCase()
                    .contains(searchText.toLowerCase()))).toList();
      }
    });
  }

  Widget _buildCompanyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _dropdownOpen = !_dropdownOpen;
              if (_dropdownOpen) {
                _searchController.clear();
                _filterCompanies('');
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
              children: [
                Expanded(
                  child: Text(
                    selectedCompanies.isEmpty
                        ? 'Select Companies'
                        : selectedCompanies
                            .map((company) => company.companyName)
                            .join(', '),
                    style: TextStyle(
                      color: selectedCompanies.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _dropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        if (_dropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search companies...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: _filterCompanies,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectedCompanies.length == _filteredCompanies.length,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value ?? false) {
                              selectedCompanies = List.from(_filteredCompanies);
                            } else {
                              selectedCompanies.clear();
                            }
                          });
                        },
                      ),
                      const Text('Select All'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Obx(
                    () => branchController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredCompanies.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No companies found',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredCompanies.length,
                                itemBuilder: (context, index) {
                                  final company = _filteredCompanies[index];
                                  final isSelected = selectedCompanies.any(
                                      (c) => c.companyID == company.companyID);

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedCompanies.removeWhere(
                                              (c) =>
                                                  c.companyID == company.companyID,
                                            );
                                          } else {
                                            selectedCompanies.add(company);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value ?? false) {
                                                    if (!isSelected) {
                                                      selectedCompanies
                                                          .add(company);
                                                    }
                                                  } else {
                                                    selectedCompanies.removeWhere(
                                                      (c) =>
                                                          c.companyID ==
                                                          company.companyID,
                                                    );
                                                  }
                                                });
                                              },
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    company.companyName ??
                                                        'Unnamed Company',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  if (company.mastCompanyName !=
                                                      null)
                                                    Text(
                                                      company.mastCompanyName!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedHoliday = HolidayModel(
        holidayID: widget.holiday.holidayID,
        holidayName: _nameController.text.trim(),
        holidayDate: _dateController.text,
        holidayYear: _yearController.text,
        listOfCompany: selectedCompanies,
      );

      widget.holidayController.saveHoliday(updatedHoliday);
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
                  widget.holiday.holidayID == null ||
                          widget.holiday.holidayID!.isEmpty
                      ? 'Add Holiday'
                      : 'Edit Holiday',
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Holiday Name ',
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Holiday name';
                        }
                        if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                          return 'Name must start with a letter';
                        }
                        if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*$')
                            .hasMatch(value)) {
                          return 'Name can only contain letters, numbers, spaces, hyphens, underscores, and dots';
                        }
                        if (value.length > 50) {
                          return 'Name cannot exceed 50 characters';
                        }
                        if (value.contains('  ')) {
                          return 'Consecutive spaces are not allowed';
                        }
                        if (value.endsWith(' ')) {
                          return 'Name cannot end with a space';
                        }
                        return null;
                      },
                      maxLength: 50,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*')),
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
                            text: 'Holiday Date ',
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
                      enabled: widget.holiday.holidayID == null ||
                          widget.holiday.holidayID!.isEmpty,
                      controller: _dateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              _dateController.text =
                                  "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                              _yearController.text = date.year.toString();
                            }
                          },
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please select Holiday date' : null,
                      readOnly: true,
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
                            text: 'Companies ',
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
                    _buildCompanyDropdown(),
                  ],
                ),
                const SizedBox(height: 40),
                CustomButtons(
                  onSavePressed: _handleSave,
                  onCancelPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
