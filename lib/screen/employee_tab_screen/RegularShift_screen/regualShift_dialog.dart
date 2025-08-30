import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Mock models - replace with your actual models
class ShiftDetailsModel {
  final String? shiftID;
  final String? shiftName;
  final String? inTime;
  final String? outTime;
  final bool? isDefaultShift;

  ShiftDetailsModel({
    this.shiftID,
    this.shiftName,
    this.inTime,
    this.outTime,
    this.isDefaultShift,
  });
}

class ShiftPatternModel {
  final String? patternID;
  final String? patternName;

  ShiftPatternModel({this.patternID, this.patternName});
}

// Mock controller - replace with your actual controller
class ShiftController extends GetxController {
  final RxList<ShiftDetailsModel> shifts = <ShiftDetailsModel>[].obs;
  final RxList<ShiftPatternModel> shiftPatterns = <ShiftPatternModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  void loadInitialData() {
    // Mock data - replace with actual API calls
    shifts.value = [
      ShiftDetailsModel(
        shiftID: '1',
        shiftName: 'Morning Shift',
        inTime: '09:00',
        outTime: '17:00',
        isDefaultShift: true,
      ),
      ShiftDetailsModel(
        shiftID: '2',
        shiftName: 'Night Shift',
        inTime: '22:00',
        outTime: '06:00',
        isDefaultShift: false,
      ),
      ShiftDetailsModel(
        shiftID: '3',
        shiftName: 'Evening Shift',
        inTime: '14:00',
        outTime: '22:00',
        isDefaultShift: false,
      ),
    ];

    shiftPatterns.value = [
      ShiftPatternModel(patternID: '1', patternName: 'ShiftPatternName109'),
      ShiftPatternModel(patternID: '2', patternName: 'Weekly Rotation'),
      ShiftPatternModel(patternID: '3', patternName: 'Monthly Pattern'),
    ];
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    loadInitialData();
    isLoading.value = false;
  }
}

enum ShiftType { autoAssign, fix, rotation }

class IndependentShiftAssignmentForm extends StatefulWidget {
  const IndependentShiftAssignmentForm({super.key});

  @override
  State<IndependentShiftAssignmentForm> createState() => _IndependentShiftAssignmentFormState();
}

class _IndependentShiftAssignmentFormState extends State<IndependentShiftAssignmentForm>
    with SingleTickerProviderStateMixin {
  final ShiftController controller = Get.put(ShiftController());
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _refreshController;

  // Form fields
  DateTime _startDate = DateTime.now();
  ShiftType _selectedShiftType = ShiftType.autoAssign;
  ShiftDetailsModel? _selectedShift;
  ShiftPatternModel? _selectedPattern;
  final TextEditingController _constantDaysController = TextEditingController(text: '2');

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Set default shift when shifts are loaded
    ever(controller.shifts, (List<ShiftDetailsModel> shifts) {
      if (shifts.isNotEmpty && _selectedShift == null) {
        _selectedShift = shifts.firstWhereOrNull(
          (shift) => shift.isDefaultShift == true,
        ) ?? shifts.first;
        setState(() {});
      }
    });

    // Set default pattern when patterns are loaded
    ever(controller.shiftPatterns, (List<ShiftPatternModel> patterns) {
      if (patterns.isNotEmpty && _selectedPattern == null) {
        _selectedPattern = patterns.first;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _constantDaysController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    _refreshController.forward().then((_) async {
      await controller.refreshData();
      _refreshController.reset();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _handleUpdate() {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Update'),
            content: Text(_getConfirmationMessage()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement update logic
                  _performUpdate();
                  Navigator.of(context).pop();
                  _showSuccessMessage();
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    }
  }

  String _getConfirmationMessage() {
    switch (_selectedShiftType) {
      case ShiftType.autoAssign:
        return 'Are you sure you want to apply auto-assign shift starting from ${DateFormat('d MMM yyyy').format(_startDate)}?';
      case ShiftType.fix:
        return 'Are you sure you want to apply fixed shift "${_selectedShift?.shiftName}" starting from ${DateFormat('d MMM yyyy').format(_startDate)}?';
      case ShiftType.rotation:
        return 'Are you sure you want to apply rotation pattern "${_selectedPattern?.patternName}" with ${_constantDaysController.text} constant days starting from ${DateFormat('d MMM yyyy').format(_startDate)}?';
    }
  }

  void _performUpdate() {
    // TODO: Implement actual update logic based on shift type
    print('Updating shift assignment:');
    print('Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}');
    print('Shift Type: ${_selectedShiftType.name}');
    
    switch (_selectedShiftType) {
      case ShiftType.autoAssign:
        print('Auto assign shift');
        break;
      case ShiftType.fix:
        print('Fixed shift: ${_selectedShift?.shiftName} (${_selectedShift?.inTime} - ${_selectedShift?.outTime})');
        break;
      case ShiftType.rotation:
        print('Rotation pattern: ${_selectedPattern?.patternName}');
        print('Constant days: ${_constantDaysController.text}');
        break;
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shift assignment updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildShiftTypeContent() {
    switch (_selectedShiftType) {
      case ShiftType.autoAssign:
        return const SizedBox.shrink();
      
      case ShiftType.fix:
        return Obx(() => Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedShift?.shiftID,
                    decoration: InputDecoration(
                      labelText: 'Shift *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: controller.shifts.map((shift) {
                      return DropdownMenuItem<String>(
                        value: shift.shiftID,
                        child: Text(shift.shiftName ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedShift = controller.shifts.firstWhere(
                          (shift) => shift.shiftID == value,
                        );
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a shift';
                      }
                      return null;
                    },
                  ),
                  if (_selectedShift != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'In-Time: ${_selectedShift?.inTime ?? ''} - Out-Time: ${_selectedShift?.outTime ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ));
      
      case ShiftType.rotation:
        return Obx(() => Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedPattern?.patternID,
                    decoration: InputDecoration(
                      labelText: 'Shift Pattern *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: controller.shiftPatterns.map((pattern) {
                      return DropdownMenuItem<String>(
                        value: pattern.patternID,
                        child: Text(pattern.patternName ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPattern = controller.shiftPatterns.firstWhere(
                          (pattern) => pattern.patternID == value,
                        );
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a shift pattern';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _constantDaysController,
                    decoration: InputDecoration(
                      labelText: 'Shift Constant Days *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter constant days';
                      }
                      final days = int.tryParse(value);
                      if (days == null || days <= 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MMM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Assignment'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        actions: [
          IconButton(
            icon: Obx(() => controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : RotationTransition(
                    turns: _refreshController,
                    child: const Icon(Icons.refresh),
                  )),
            onPressed: controller.isLoading.value ? null : _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Start Date Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shift Start Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        onTap: _selectDate,
                        decoration: InputDecoration(
                          labelText: 'Shift Start Date *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: dateFormat.format(_startDate),
                        ),
                        validator: (_) => null,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Regular Shift Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Regular Shift',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Shift Type Radio Buttons
                      const Text(
                        'Shift Type *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          RadioListTile<ShiftType>(
                            title: const Text('Auto Assign Shift'),
                            value: ShiftType.autoAssign,
                            groupValue: _selectedShiftType,
                            onChanged: (value) {
                              setState(() {
                                _selectedShiftType = value!;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<ShiftType>(
                            title: const Text('Fix'),
                            value: ShiftType.fix,
                            groupValue: _selectedShiftType,
                            onChanged: (value) {
                              setState(() {
                                _selectedShiftType = value!;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<ShiftType>(
                            title: const Text('Rotation'),
                            value: ShiftType.rotation,
                            groupValue: _selectedShiftType,
                            onChanged: (value) {
                              setState(() {
                                _selectedShiftType = value!;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      
                      // Dynamic content based on shift type
                      _buildShiftTypeContent(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Note Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: const Text(
                  'Note: Please Re-Process Attendance Data (if StartDate of shift is older than the Current Date)',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}