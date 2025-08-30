import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter
import 'package:get/get.dart';
import 'package:time_attendance/controller/shift_tab_controller/shift_details_controller.dart';
import 'package:time_attendance/controller/shift_tab_controller/shift_pattern_controller.dart';
import 'package:time_attendance/model/employee_tab_model/employee_complete_model.dart';
import 'package:time_attendance/model/employee_tab_model/settingprofile.dart';
import 'package:time_attendance/controller/employee_tab_controller/settingprofile_controller.dart';
import 'package:time_attendance/model/sfift_tab_model/shift_details_model.dart';
import 'package:time_attendance/widget/reusable/tooltip/help_tooltip_button.dart';
import 'package:time_attendance/model/Masters/shiftPattern.dart';

// --- Enums for Radio Button Groups ---
enum PresentOnWeeklyOffHolidayOptions { overTime, compensatoryOff, present }
enum LeaveContainsWeeklyOffOptions { leave, weeklyOff }
enum LeaveContainsHolidayOptions { leave, holiday }
enum WeeklyOffHolidaySameDayOptions { weeklyOff, holiday }
enum AbsentBeforeAfterHolidayOptions { holiday, absent }
enum PunchTypeOptions { doubleFL, multipleEO, single }
enum WorkMinutesCalculationOptions { byShiftwise, byEmployeewise }
enum OverTimeStartOptions { afterFullDay, atExactShiftEnd }
enum OverTimeCalculationOptions { afterHour, afterHalfHour, none }
enum ForcePunchOutOptions {
  defaultTime,
  byShiftOutTime,
  byAddingHalfDayInTime,
  none
}
enum LateComingActionOptions { cutFullDay, cutHalfDay, markAbsent, none }
enum ShiftStartDateOptions { employeeJoiningDate, startOfJoiningMonth }
enum ShiftTypeOptions { fix, rotation, autoAssign }
enum WeeklyOffTypeOptions { regular, rotating }
enum WeeklyOffAbsentMarkingOptions { prefix, postfix, aWoffA, none }

class AddEditSettingProfileScreen extends StatefulWidget {
  final SettingProfileModel? profile;

  const AddEditSettingProfileScreen({
    Key? key,
    this.profile,
  }) : super(key: key);

  @override
  State<AddEditSettingProfileScreen> createState() =>
      _AddEditSettingProfileScreenState();
}

class _AddEditSettingProfileScreenState
    extends State<AddEditSettingProfileScreen> {
  // --- Controllers ---
  final _formKey = GlobalKey<FormState>();
  final ShiftDetailsController shiftDetailsController = Get.put(ShiftDetailsController());
  final ShiftPatternController shiftPatternController = Get.put(ShiftPatternController());
  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isDefaultProfile = false;

  // --- Work Settings State ---
  PresentOnWeeklyOffHolidayOptions _presentOnWeeklyOffHoliday =
      PresentOnWeeklyOffHolidayOptions.present;
  LeaveContainsWeeklyOffOptions _leaveContainsWeeklyOff =
      LeaveContainsWeeklyOffOptions.leave;
  LeaveContainsHolidayOptions _leaveContainsHoliday =
      LeaveContainsHolidayOptions.leave;
  WeeklyOffHolidaySameDayOptions _weeklyOffHolidaySameDay =
      WeeklyOffHolidaySameDayOptions.holiday;
  AbsentBeforeAfterHolidayOptions _absentBeforeAfterHoliday =
      AbsentBeforeAfterHolidayOptions.holiday;
  final TextEditingController _absentDaysForWeeklyOffController =
      TextEditingController(text: "0");
  WeeklyOffAbsentMarkingOptions _weeklyOffAbsentMarking =
      WeeklyOffAbsentMarkingOptions.none;

  // --- Work Minutes State ---
  PunchTypeOptions _punchType = PunchTypeOptions.doubleFL;
  final TextEditingController _singlePunchOutTimeHHController =
      TextEditingController();
  final TextEditingController _singlePunchOutTimeMMController =
      TextEditingController();
  final TextEditingController _allowedLateComingMinutesController =
      TextEditingController(text: "15");
  final TextEditingController _allowedEarlyGoingMinutesController =
      TextEditingController(text: "15");
  WorkMinutesCalculationOptions _workMinutesCalculation =
      WorkMinutesCalculationOptions.byEmployeewise;

  // --- Work Details (By Employeewise) ---
  final TextEditingController _fullDayMinsController =
      TextEditingController(text: "480");
  final TextEditingController _halfDayMinsController =
      TextEditingController(text: "240");
  bool _isEmployeeAllowedToDoOverTime = true;
  final TextEditingController _otGraceMinsController =
      TextEditingController(text: "5");
  OverTimeStartOptions _overTimeCalculationStartsAt =
      OverTimeStartOptions.afterFullDay;
  final TextEditingController _otStartsMinsController =
      TextEditingController(text: "490");

  // --- Additional Settings State ---
  OverTimeCalculationOptions _additionalOverTimeCalcOption =
      OverTimeCalculationOptions.none;
  bool _isEmployeeAllowedToTakeBreak = false;
  bool _subtractLunchFromFullDay = false;
  bool _subtractLunchFromHalfDay = false;
  bool _calculateLateEarlyOnWeeklyOff = false;
  ForcePunchOutOptions _forcePunchOutOption =
      ForcePunchOutOptions.byAddingHalfDayInTime;
  final TextEditingController _defaultForcePunchOutHHController =
      TextEditingController();
  final TextEditingController _defaultForcePunchOutMMController =
      TextEditingController();
  bool _isLateComingDeductionAllowed = false;
  final TextEditingController _lateComingForDaysController =
      TextEditingController(text: "-1");
  LateComingActionOptions _lateComingAction = LateComingActionOptions.none;
  bool _isRepeatLateComingDeductionAllowed = false;

  // --- Regular Shift State ---
  ShiftStartDateOptions _shiftStartDateOption =
      ShiftStartDateOptions.employeeJoiningDate;
  ShiftTypeOptions _shiftTypeOption = ShiftTypeOptions.fix;
  String? _selectedFixShiftId;
  final TextEditingController _shiftConstantDaysController =
      TextEditingController();
  String? _selectedShiftPatternId;

  // --- WeeklyOff Details State ---
  WeeklyOffTypeOptions _weeklyOffTypeOption = WeeklyOffTypeOptions.regular;
  String _selectedFirstWeeklyOff = "Sunday";
  String _selectedSecondWeeklyOff = "None";
  String _selectedFullDayHalfDay = "FullDay";
  bool _isWeek1Selected = true;
  bool _isWeek2Selected = true;
  bool _isWeek3Selected = true;
  bool _isWeek4Selected = true;
  bool _isWeek5Selected = true;


  // --- Employee Login Details State ---
  bool _isLoginEnabled = false;
  bool _canPunchInGeoFence = false;
  bool _canPunchFromHome = false;
  bool _viewRights = true;
  bool _canApplyForLeave = false;
  bool _canApplyForTour = false;
  bool _canApplyForManualAttendance = false;
  bool _canApplyForOutDoorDuty = false;

  // Dropdown data lists
  final List<String> _daysOfWeek = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  final List<String> _daysOfWeekWithNone = [
    "None",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  final List<String> _dayTypes = ["FullDay", "HalfDay"];

  @override
  void initState() {
    super.initState();
    // Fetch data for dropdowns
    shiftDetailsController.fetchShifts();
    shiftPatternController.fetchShiftPatterns();

    if (widget.profile != null) {
      _prepopulateFormFields(widget.profile!);
    }
  }

  void _prepopulateFormFields(SettingProfileModel profile) {
    // Basic Profile Info
    _profileNameController.text = profile.profileName;
    _descriptionController.text = profile.description;
    _isDefaultProfile = profile.isDefaultProfile;
    _shiftStartDateOption = profile.isShiftStartFromJoiningDate
        ? ShiftStartDateOptions.employeeJoiningDate
        : ShiftStartDateOptions.startOfJoiningMonth;

    // Work Settings
    if (profile.employeeSetting != null) {
      final settings = profile.employeeSetting!;
      _presentOnWeeklyOffHoliday = _mapStringToPresentOption(settings.presentOnWOffOrHoliday);
      _leaveContainsWeeklyOff = settings.leaveNWOffConsider == EmployeeSettings.taLeave
          ? LeaveContainsWeeklyOffOptions.leave
          : LeaveContainsWeeklyOffOptions.weeklyOff;
      _leaveContainsHoliday = settings.leaveNHolidayConsider == EmployeeSettings.taLeave
          ? LeaveContainsHolidayOptions.leave
          : LeaveContainsHolidayOptions.holiday;
      _weeklyOffHolidaySameDay = settings.wOffNHolidayConsider == EmployeeSettings.taWOff
          ? WeeklyOffHolidaySameDayOptions.weeklyOff
          : WeeklyOffHolidaySameDayOptions.holiday;
      _absentBeforeAfterHoliday = settings.isAHolidayAMarkA
          ? AbsentBeforeAfterHolidayOptions.absent
          : AbsentBeforeAfterHolidayOptions.holiday;
      _absentDaysForWeeklyOffController.text = settings.awoffDaysConstant.toStringAsFixed(0);

      if (settings.isAWoffAMarkA) {
        _weeklyOffAbsentMarking = WeeklyOffAbsentMarkingOptions.aWoffA;
      } else if (settings.isAWOffMarkA) {
        _weeklyOffAbsentMarking = WeeklyOffAbsentMarkingOptions.prefix;
      } else if (settings.isWOffAMarkA) {
        _weeklyOffAbsentMarking = WeeklyOffAbsentMarkingOptions.postfix;
      } else {
        _weeklyOffAbsentMarking = WeeklyOffAbsentMarkingOptions.none;
      }

      // Work Minutes
      _punchType = _mapIntToPunchType(settings.type);
      if (_punchType == PunchTypeOptions.single && settings.singlePunchOutTime.contains(':')) {
        final timeParts = settings.singlePunchOutTime.split(':');
        _singlePunchOutTimeHHController.text = timeParts[0];
        _singlePunchOutTimeMMController.text = timeParts[1];
      }
      _allowedLateComingMinutesController.text = settings.allowedLateComingMinutes.toString();
      _allowedEarlyGoingMinutesController.text = settings.allowedEarlyGoingMinutes.toString();
      _workMinutesCalculation = settings.isWorkMinutesCalculationByShift
          ? WorkMinutesCalculationOptions.byShiftwise
          : WorkMinutesCalculationOptions.byEmployeewise;

      // Employeewise Details
      _fullDayMinsController.text = settings.fullDayMinutes.toString();
      _halfDayMinsController.text = settings.halfDayMinutes.toString();
      _isEmployeeAllowedToDoOverTime = settings.isOverTimeAllowed;
      _otGraceMinsController.text = settings.otGraceMins.toString();
      _overTimeCalculationStartsAt = settings.isOTStartsAtShiftEnd
          ? OverTimeStartOptions.atExactShiftEnd
          : OverTimeStartOptions.afterFullDay;
      _otStartsMinsController.text = settings.otStartMinutes.toString();
    }

    // Additional Settings
    if (profile.employeeGeneralSetting != null) {
      final genSettings = profile.employeeGeneralSetting!;
      _additionalOverTimeCalcOption = _mapIntToOverTimeCalc(genSettings.overTimeCalculations);
      _isEmployeeAllowedToTakeBreak = profile.employeeSetting?.isBreakAllowed ?? false;
      _subtractLunchFromFullDay = genSettings.isBreakMinutesSubtractFromFullDayWork;
      _subtractLunchFromHalfDay = genSettings.isBreakMinutesSubtractFromHalfDayWork;
      _calculateLateEarlyOnWeeklyOff = genSettings.isComingLateNEarlyGoingCalculateOnWOff;
      _forcePunchOutOption = _mapIntToForcePunchOut(genSettings.forcePunchOut);

      if (_forcePunchOutOption == ForcePunchOutOptions.defaultTime && genSettings.forcePunchDefaultOutTime.contains(':')) {
        final timeParts = genSettings.forcePunchDefaultOutTime.split(':');
        _defaultForcePunchOutHHController.text = timeParts[0];
        _defaultForcePunchOutMMController.text = timeParts[1];
      }
      
      _isLateComingDeductionAllowed = genSettings.isLateComingDeductionAllowed;
      _lateComingForDaysController.text = genSettings.lateComingDaysForCutOff.toString();
      _lateComingAction = _mapIntToLateComingAction(genSettings.actionForLateComing);
      _isRepeatLateComingDeductionAllowed = genSettings.isRepeatLateComingAllowed;
    }

    // Regular Shift
    if (profile.employeeRegularShift != null) {
      final regularShift = profile.employeeRegularShift!;
      _shiftTypeOption = _mapIntToShiftType(regularShift.type);
      _selectedFixShiftId = regularShift.shiftID;
      _selectedShiftPatternId = regularShift.patternID;
      _shiftConstantDaysController.text = regularShift.shiftConstantDays;
    }

    // Weekly Off
    if (profile.employeeWOFF != null) {
      final woff = profile.employeeWOFF!;
      _weeklyOffTypeOption = (profile.employeeGeneralSetting?.isRotationalWeeklyOff ?? false)
          ? WeeklyOffTypeOptions.rotating
          : WeeklyOffTypeOptions.regular;
      _selectedFirstWeeklyOff = woff.firstWOff;
      _selectedSecondWeeklyOff = woff.secondWOff;
      _selectedFullDayHalfDay = woff.isFullDay ? "FullDay" : "HalfDay";
      
      if (woff.wOffPattern.isNotEmpty) {
        final weeks = woff.wOffPattern.split('-');
        _isWeek1Selected = weeks.contains('1');
        _isWeek2Selected = weeks.contains('2');
        _isWeek3Selected = weeks.contains('3');
        _isWeek4Selected = weeks.contains('4');
        _isWeek5Selected = weeks.contains('5');
      }
    }

    // Employee Login
    if (profile.employeeLogin != null) {
      final login = profile.employeeLogin!;
      _isLoginEnabled = login.isEnabled;
      _canPunchInGeoFence = login.canPunchInGeoFence;
      _canPunchFromHome = login.canPunchFromHome;
      _viewRights = login.canView;
      _canApplyForManualAttendance = login.canApplyForManualAttendance;
      _canApplyForLeave = login.canApplyForLeave;
      _canApplyForTour = login.canApplyForTour;
      _canApplyForOutDoorDuty = login.canApplyForOutDoor ?? false;
    }
    
    // Use setState to ensure the UI updates with the prepopulated values.
    setState(() {});
  }


  @override
  void dispose() {
    _profileNameController.dispose();
    _descriptionController.dispose();
    _absentDaysForWeeklyOffController.dispose();
    _singlePunchOutTimeHHController.dispose();
    _singlePunchOutTimeMMController.dispose();
    _allowedLateComingMinutesController.dispose();
    _allowedEarlyGoingMinutesController.dispose();
    _fullDayMinsController.dispose();
    _halfDayMinsController.dispose();
    _otGraceMinsController.dispose();
    _otStartsMinsController.dispose();
    _defaultForcePunchOutHHController.dispose();
    _defaultForcePunchOutMMController.dispose();
    _lateComingForDaysController.dispose();
    _shiftConstantDaysController.dispose();
    super.dispose();
  }

  // region Helper Methods for Data Conversion (To Model)
  String _getPresentOnWOffHolidayStringValue() {
    switch (_presentOnWeeklyOffHoliday) {
      case PresentOnWeeklyOffHolidayOptions.overTime:
        return EmployeeSettings.taOverTime;
      case PresentOnWeeklyOffHolidayOptions.compensatoryOff:
        return EmployeeSettings.taCOff;
      case PresentOnWeeklyOffHolidayOptions.present:
        return EmployeeSettings.taPresent;
    }
  }

  int _getPunchTypeEnumValue() {
    switch (_punchType) {
      case PunchTypeOptions.single:
        return CsPunchType.Single.index + 1;
      case PunchTypeOptions.doubleFL:
        return CsPunchType.Double.index + 1;
      case PunchTypeOptions.multipleEO:
        return CsPunchType.Multiple.index + 1;
    }
  }

  int _getOverTimeCalcEnumValue() {
    switch (_additionalOverTimeCalcOption) {
      case OverTimeCalculationOptions.none:
        return CsOverTimeCalculation.None.index + 1;
      case OverTimeCalculationOptions.afterHalfHour:
        return CsOverTimeCalculation.HalfHourly.index + 1;
      case OverTimeCalculationOptions.afterHour:
        return CsOverTimeCalculation.Hourly.index + 1;
    }
  }

  int _getForcePunchOutEnumValue() {
    switch (_forcePunchOutOption) {
      case ForcePunchOutOptions.none:
        return CsForcePunchOutType.None.index + 1;
      case ForcePunchOutOptions.defaultTime:
        return CsForcePunchOutType.ByDefault.index + 1;
      case ForcePunchOutOptions.byShiftOutTime:
        return CsForcePunchOutType.ByShift.index + 1;
      case ForcePunchOutOptions.byAddingHalfDayInTime:
        return CsForcePunchOutType.ByHalfDayMinutes.index + 1;
    }
  }

  int _getLateComingActionEnumValue() {
    switch (_lateComingAction) {
      case LateComingActionOptions.none:
        return CsLateComingAction.None.index + 1;
      case LateComingActionOptions.cutFullDay:
        return CsLateComingAction.CutFullDayMinutes.index + 1;
      case LateComingActionOptions.cutHalfDay:
        return CsLateComingAction.CutHalfDayMinutes.index + 1;
      case LateComingActionOptions.markAbsent:
        return CsLateComingAction.MarkAbsent.index + 1;
    }
  }

  int _getShiftTypeEnumValue() {
    switch (_shiftTypeOption) {
      case ShiftTypeOptions.fix:
        return CsShiftType.Fix.index + 1;
      case ShiftTypeOptions.autoAssign:
        return CsShiftType.AutoShift.index + 1;
      case ShiftTypeOptions.rotation:
        return CsShiftType.Rotation.index + 1;
    }
  }
  // endregion

  // region Helper Methods for Data Mapping (From Model to UI Enums)
  PresentOnWeeklyOffHolidayOptions _mapStringToPresentOption(String value) {
    if (value == EmployeeSettings.taOverTime) return PresentOnWeeklyOffHolidayOptions.overTime;
    if (value == EmployeeSettings.taCOff) return PresentOnWeeklyOffHolidayOptions.compensatoryOff;
    return PresentOnWeeklyOffHolidayOptions.present;
  }

  PunchTypeOptions _mapIntToPunchType(int value) {
    if (value == CsPunchType.Single.index + 1) return PunchTypeOptions.single;
    if (value == CsPunchType.Multiple.index + 1) return PunchTypeOptions.multipleEO;
    return PunchTypeOptions.doubleFL;
  }

  OverTimeCalculationOptions _mapIntToOverTimeCalc(int value) {
    if (value == CsOverTimeCalculation.Hourly.index + 1) return OverTimeCalculationOptions.afterHour;
    if (value == CsOverTimeCalculation.HalfHourly.index + 1) return OverTimeCalculationOptions.afterHalfHour;
    return OverTimeCalculationOptions.none;
  }

  ForcePunchOutOptions _mapIntToForcePunchOut(int value) {
    if (value == CsForcePunchOutType.ByDefault.index + 1) return ForcePunchOutOptions.defaultTime;
    if (value == CsForcePunchOutType.ByShift.index + 1) return ForcePunchOutOptions.byShiftOutTime;
    if (value == CsForcePunchOutType.ByHalfDayMinutes.index + 1) return ForcePunchOutOptions.byAddingHalfDayInTime;
    return ForcePunchOutOptions.none;
  }

  LateComingActionOptions _mapIntToLateComingAction(int value) {
    if (value == CsLateComingAction.CutFullDayMinutes.index + 1) return LateComingActionOptions.cutFullDay;
    if (value == CsLateComingAction.CutHalfDayMinutes.index + 1) return LateComingActionOptions.cutHalfDay;
    if (value == CsLateComingAction.MarkAbsent.index + 1) return LateComingActionOptions.markAbsent;
    return LateComingActionOptions.none;
  }

  ShiftTypeOptions _mapIntToShiftType(int value) {
    if (value == CsShiftType.Rotation.index + 1) return ShiftTypeOptions.rotation;
    if (value == CsShiftType.AutoShift.index + 1) return ShiftTypeOptions.autoAssign;
    return ShiftTypeOptions.fix;
  }
  // endregion


  // region UI Builder Widgets
  Widget _buildRadioWidget<T>({
    required String label,
    required T groupValue,
    required List<MapEntry<String, T>> options,
    required ValueChanged<T?> onChanged,
    bool isDense = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Row(
          children: options.map((entry) {
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(entry.value),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Radio<T>(
                      value: entry.value,
                      groupValue: groupValue,
                      onChanged: onChanged,
                      materialTapTargetSize: isDense
                          ? MaterialTapTargetSize.shrinkWrap
                          : MaterialTapTargetSize.padded,
                      visualDensity: isDense
                          ? VisualDensity.compact
                          : VisualDensity.standard,
                    ),
                    Flexible(
                        child: Text(entry.key,
                            style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLabeledTextField(
      String label, TextEditingController controller, String hintText,
      {bool isNumeric = true, int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: false)
              : TextInputType.text,
          inputFormatters: isNumeric
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  if (maxLength != null)
                    LengthLimitingTextInputFormatter(maxLength)
                ]
              : (maxLength != null
                  ? [LengthLimitingTextInputFormatter(maxLength)]
                  : []),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: const TextStyle(fontSize: 14)),
        if (label.isNotEmpty) const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            hintText: hintText,
          ),
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkSettingsExpansionTile() {
    return ExpansionTile(
      title: const Text("Work Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      initiallyExpanded: true,
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildRadioWidget<PresentOnWeeklyOffHolidayOptions>(
          label: "If present on WeeklyOff or Holiday, calculate work as:",
          groupValue: _presentOnWeeklyOffHoliday,
          options: [
            MapEntry("Over Time", PresentOnWeeklyOffHolidayOptions.overTime),
            MapEntry("Compensatory Off",
                PresentOnWeeklyOffHolidayOptions.compensatoryOff),
            MapEntry("Present", PresentOnWeeklyOffHolidayOptions.present),
          ],
          onChanged: (val) => setState(() => _presentOnWeeklyOffHoliday = val!),
        ),
        _buildRadioWidget<LeaveContainsWeeklyOffOptions>(
          label:
              "If Leave application contains WeeklyOff, consider WeeklyOff as:",
          groupValue: _leaveContainsWeeklyOff,
          options: [
            MapEntry("Leave", LeaveContainsWeeklyOffOptions.leave),
            MapEntry("Weekly Off", LeaveContainsWeeklyOffOptions.weeklyOff),
          ],
          onChanged: (val) => setState(() => _leaveContainsWeeklyOff = val!),
        ),
        _buildRadioWidget<LeaveContainsHolidayOptions>(
          label: "If Leave application contains Holiday, consider Holiday as:",
          groupValue: _leaveContainsHoliday,
          options: [
            MapEntry("Leave", LeaveContainsHolidayOptions.leave),
            MapEntry("Holiday", LeaveContainsHolidayOptions.holiday),
          ],
          onChanged: (val) => setState(() => _leaveContainsHoliday = val!),
        ),
        _buildRadioWidget<WeeklyOffHolidaySameDayOptions>(
          label: "If WeeklyOff and Holiday on same day, consider it as:",
          groupValue: _weeklyOffHolidaySameDay,
          options: [
            MapEntry("Weekly Off", WeeklyOffHolidaySameDayOptions.weeklyOff),
            MapEntry("Holiday", WeeklyOffHolidaySameDayOptions.holiday),
          ],
          onChanged: (val) => setState(() => _weeklyOffHolidaySameDay = val!),
        ),
        _buildRadioWidget<AbsentBeforeAfterHolidayOptions>(
          label:
              "If Employee is Absent before and after Holiday, Mark Holiday as:",
          groupValue: _absentBeforeAfterHoliday,
          options: [
            MapEntry("Holiday", AbsentBeforeAfterHolidayOptions.holiday),
            MapEntry("Absent", AbsentBeforeAfterHolidayOptions.absent),
          ],
          onChanged: (val) => setState(() => _absentBeforeAfterHoliday = val!),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  "Number of absent days that are either to be prefixed or postfixed to WeeklyOff",
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: _absentDaysForWeeklyOffController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  ', to mark WeeklyOff as "Absent" :',
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 12.0),
          child: _buildRadioWidget<WeeklyOffAbsentMarkingOptions>(
            label: "",
            groupValue: _weeklyOffAbsentMarking,
            isDense: true,
            options: [
              MapEntry("Prefix", WeeklyOffAbsentMarkingOptions.prefix),
              MapEntry("Postfix", WeeklyOffAbsentMarkingOptions.postfix),
              MapEntry("A-Woff-A", WeeklyOffAbsentMarkingOptions.aWoffA),
              MapEntry("None", WeeklyOffAbsentMarkingOptions.none),
            ],
            onChanged: (val) => setState(() => _weeklyOffAbsentMarking = val!),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWorkMinutesExpansionTile() {
    return ExpansionTile(
      title: const Text("Work Minutes",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      initiallyExpanded: false,
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildRadioWidget<PunchTypeOptions>(
          label: "Punch Type:",
          groupValue: _punchType,
          isDense: true,
          options: [
            MapEntry("Double (First In Last Out)", PunchTypeOptions.doubleFL),
            MapEntry("Multiple (Even In Odd Out)", PunchTypeOptions.multipleEO),
            MapEntry("Single", PunchTypeOptions.single),
          ],
          onChanged: (val) => setState(() => _punchType = val!),
        ),
        if (_punchType == PunchTypeOptions.single)
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Out Time:* ", style: TextStyle(fontSize: 14)),
                SizedBox(
                  width: 55,
                  child: _buildLabeledTextField(
                      "", _singlePunchOutTimeHHController, "HH",
                      maxLength: 2),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(":",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 55,
                  child: _buildLabeledTextField(
                      "", _singlePunchOutTimeMMController, "MM",
                      maxLength: 2),
                ),
                const SizedBox(width: 8),
                const Flexible(
                    child: Text("[in 24 Hour Format]",
                        style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
        const SizedBox(height: 8),
        const Text("Allowed Late Coming Minutes and Early Going Minutes:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _buildLabeledTextField("Late Coming Minutes:*",
                    _allowedLateComingMinutesController, "15")),
            const SizedBox(width: 16),
            Expanded(
                child: _buildLabeledTextField("Early Going Minutes:*",
                    _allowedEarlyGoingMinutesController, "15")),
          ],
        ),
        const SizedBox(height: 16),
        _buildRadioWidget<WorkMinutesCalculationOptions>(
          label:
              "Work Minutes Calculation by Minutes assign to Shift or Employee :",
          groupValue: _workMinutesCalculation,
          options: [
            MapEntry("By Shiftwise", WorkMinutesCalculationOptions.byShiftwise),
            MapEntry("By Employeewise",
                WorkMinutesCalculationOptions.byEmployeewise),
          ],
          onChanged: (val) => setState(() => _workMinutesCalculation = val!),
        ),
        if (_workMinutesCalculation ==
            WorkMinutesCalculationOptions.byEmployeewise)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Work Details (By Employeewise):",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87)),
                  const SizedBox(height: 12),
                  _buildLabeledTextField(
                      "Full Day Mins:*", _fullDayMinsController, "480"),
                  const SizedBox(height: 12),
                  _buildLabeledTextField(
                      "Half Day Mins:*", _halfDayMinsController, "240"),
                  const SizedBox(height: 4),
                  _buildCheckboxRow(
                    "Is Employee Allowed to do OverTime.",
                    _isEmployeeAllowedToDoOverTime,
                    (val) =>
                        setState(() => _isEmployeeAllowedToDoOverTime = val!),
                  ),
                  if (_isEmployeeAllowedToDoOverTime)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabeledTextField(
                              "OT Grace Mins:", _otGraceMinsController, "5"),
                          const SizedBox(height: 12),
                          _buildRadioWidget<OverTimeStartOptions>(
                            label: "Over time calculation starts at:",
                            groupValue: _overTimeCalculationStartsAt,
                            isDense: true,
                            options: [
                              MapEntry("OT starts after FullDay minutes work",
                                  OverTimeStartOptions.afterFullDay),
                              MapEntry("OT starts at exact shift end time",
                                  OverTimeStartOptions.atExactShiftEnd),
                            ],
                            onChanged: (val) => setState(
                                () => _overTimeCalculationStartsAt = val!),
                          ),
                          if (_overTimeCalculationStartsAt ==
                              OverTimeStartOptions.afterFullDay)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 24.0),
                              child: _buildLabeledTextField("OTStarts Mins:",
                                  _otStartsMinsController, "490"),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAdditionalSettingsExpansionTile() {
    return ExpansionTile(
      title: const Text("Additional Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      initiallyExpanded: false,
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildRadioWidget<OverTimeCalculationOptions>(
          label: "Over Time Calculations:",
          groupValue: _additionalOverTimeCalcOption,
          isDense: true,
          options: [
            MapEntry("After Every Hour including Grace Minutes",
                OverTimeCalculationOptions.afterHour),
            MapEntry("After Every Half An Hour including Grace Minutes",
                OverTimeCalculationOptions.afterHalfHour),
            MapEntry("None", OverTimeCalculationOptions.none),
          ],
          onChanged: (val) =>
              setState(() => _additionalOverTimeCalcOption = val!),
        ),
        const SizedBox(height: 12),
        _buildCheckboxRow(
          "Is Employee Allowed to take break.",
          _isEmployeeAllowedToTakeBreak,
          (val) => setState(() => _isEmployeeAllowedToTakeBreak = val!),
        ),
        if (_isEmployeeAllowedToTakeBreak)
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Text("Break Minutes:",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                _buildCheckboxRow(
                    "Subtract Lunch Minutes from Fullday Hours work.",
                    _subtractLunchFromFullDay,
                    (val) => setState(() => _subtractLunchFromFullDay = val!)),
                _buildCheckboxRow(
                    "Subtract Lunch Minutes from Halfday Hours work.",
                    _subtractLunchFromHalfDay,
                    (val) => setState(() => _subtractLunchFromHalfDay = val!)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        _buildCheckboxRow(
          "Calculate Late Coming Minutes and Early Going Minutes, If Employee present on Weekly Off",
          _calculateLateEarlyOnWeeklyOff,
          (val) => setState(() => _calculateLateEarlyOnWeeklyOff = val!),
        ),
        const SizedBox(height: 12),
        _buildRadioWidget<ForcePunchOutOptions>(
          label: 'Force Punch Out, if "No-Out" occurs (No out log found) :',
          groupValue: _forcePunchOutOption,
          isDense: true,
          options: [
            MapEntry(
                "Default(Specific Time)", ForcePunchOutOptions.defaultTime),
            MapEntry("By Shift OutTime", ForcePunchOutOptions.byShiftOutTime),
            MapEntry("By Adding Half Day minutes in InTime",
                ForcePunchOutOptions.byAddingHalfDayInTime),
            MapEntry("None", ForcePunchOutOptions.none),
          ],
          onChanged: (val) => setState(() => _forcePunchOutOption = val!),
        ),
        if (_forcePunchOutOption == ForcePunchOutOptions.defaultTime)
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Default Out Time:* ",
                    style: TextStyle(fontSize: 14)),
                SizedBox(
                  width: 55,
                  child: _buildLabeledTextField(
                      "", _defaultForcePunchOutHHController, "HH",
                      maxLength: 2),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(":",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 55,
                  child: _buildLabeledTextField(
                      "", _defaultForcePunchOutMMController, "MM",
                      maxLength: 2),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text("Late Coming CutOff:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        _buildCheckboxRow(
          "Is Coming Late Deduction Allowed",
          _isLateComingDeductionAllowed,
          (val) => setState(() => _isLateComingDeductionAllowed = val!),
        ),
        if (_isLateComingDeductionAllowed)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("If coming late for",
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      height: 40,
                      child: _buildLabeledTextField(
                        "",
                        _lateComingForDaysController,
                        "",
                        maxLength: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("days:", style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRadioWidget<LateComingActionOptions>(
                  label: "Action Taken:",
                  groupValue: _lateComingAction,
                  isDense: true,
                  options: [
                    MapEntry("Cut Full Day Minutes",
                        LateComingActionOptions.cutFullDay),
                    MapEntry("Cut Half Day Minutes",
                        LateComingActionOptions.cutHalfDay),
                    MapEntry("Mark Absent", LateComingActionOptions.markAbsent),
                    MapEntry("None", LateComingActionOptions.none),
                  ],
                  onChanged: (val) => setState(() => _lateComingAction = val!),
                ),
                const SizedBox(height: 8),
                _buildCheckboxRow(
                  "Is Repeat Late Coming Deduction Allowed (After action taken and condition occurs again.)",
                  _isRepeatLateComingDeductionAllowed,
                  (val) =>
                      setState(() => _isRepeatLateComingDeductionAllowed = val!),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRegularShiftExpansionTile() {
    return ExpansionTile(
      title: const Text("Regular Shift",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      subtitle: const Text(
          "(Applicable only for New Employee at the time of enrollment)",
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
      initiallyExpanded: false,
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildRadioWidget<ShiftStartDateOptions>(
          label: "Shift Start Date :",
          groupValue: _shiftStartDateOption,
          isDense: true,
          options: [
            MapEntry("Employee's Joining Date",
                ShiftStartDateOptions.employeeJoiningDate),
            MapEntry("Start of the Joining month",
                ShiftStartDateOptions.startOfJoiningMonth),
          ],
          onChanged: (val) => setState(() => _shiftStartDateOption = val!),
        ),
        const SizedBox(height: 12),
        _buildRadioWidget<ShiftTypeOptions>(
          label: "Shift Type :",
          groupValue: _shiftTypeOption,
          isDense: true,
          options: [
            MapEntry("Fix", ShiftTypeOptions.fix),
            MapEntry("Rotation", ShiftTypeOptions.rotation),
            MapEntry("Auto Assign Shift", ShiftTypeOptions.autoAssign),
          ],
          onChanged: (val) => setState(() {
            _shiftTypeOption = val!;
            if (_shiftTypeOption != ShiftTypeOptions.fix) {
              _selectedFixShiftId = null;
            }
            if (_shiftTypeOption != ShiftTypeOptions.rotation) {
              _selectedShiftPatternId = null;
            }
          }),
        ),
        const SizedBox(height: 12),
        if (_shiftTypeOption == ShiftTypeOptions.fix)
          Obx(() {
            if (shiftDetailsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: _buildDropdownField<String>(
                label: "Shift :*",
                value: _selectedFixShiftId,
                items: shiftDetailsController.shifts.map((SiftDetailsModel shift) {
                  return DropdownMenuItem(
                      value: shift.shiftID,
                      child: Text(shift.shiftName ?? 'Unnamed Shift'));
                }).toList(),
                onChanged: (val) => setState(() => _selectedFixShiftId = val),
                hintText: "Select Shift",
              ),
            );
          }),
        if (_shiftTypeOption == ShiftTypeOptions.rotation)
          Obx(() {
            if (shiftPatternController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                children: [
                  _buildDropdownField<String>(
                    label: "Shift Pattern :*",
                    value: _selectedShiftPatternId,
                    items: shiftPatternController.shiftPatterns
                        .map((ShiftPatternModel pattern) => DropdownMenuItem(
                            value: pattern.patternId.toString(),
                            child: Text(pattern.patternName)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedShiftPatternId = val),
                    hintText: "Select Shift Pattern",
                  ),
                  const SizedBox(height: 12),
                  _buildLabeledTextField(
                    "Shift Constant Days :*",
                    _shiftConstantDaysController,
                    "",
                    isNumeric: true,
                    maxLength: 3,
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWeekSelectionCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Weeks for Second Half-Day Off:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Expanded(
              child: _buildCheckboxRow(
                '1st Week',
                _isWeek1Selected,
                (val) => setState(() => _isWeek1Selected = val!),
              ),
            ),
            Expanded(
              child: _buildCheckboxRow(
                '2nd Week',
                _isWeek2Selected,
                (val) => setState(() => _isWeek2Selected = val!),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildCheckboxRow(
                '3rd Week',
                _isWeek3Selected,
                (val) => setState(() => _isWeek3Selected = val!),
              ),
            ),
            Expanded(
              child: _buildCheckboxRow(
                '4th Week',
                _isWeek4Selected,
                (val) => setState(() => _isWeek4Selected = val!),
              ),
            ),
          ],
        ),
        _buildCheckboxRow(
          '5th Week',
          _isWeek5Selected,
          (val) => setState(() => _isWeek5Selected = val!),
        ),
      ],
    );
  }

  Widget _buildWeeklyOffDetailsExpansionTile() {
    final bool isSecondWeeklyOffDisabled = _selectedFirstWeeklyOff == 'None';
    final bool isDayTypeDisabled = _selectedSecondWeeklyOff == 'None' ||
        _selectedFirstWeeklyOff == _selectedSecondWeeklyOff;
    final bool showWeekSelection = !isDayTypeDisabled && _selectedFullDayHalfDay == 'HalfDay';

    return ExpansionTile(
      title: const Text("WeeklyOff Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      subtitle: const Text(
          "(Applicable only for New Employee at the time of enrollment)",
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
      initiallyExpanded: false,
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildRadioWidget<WeeklyOffTypeOptions>(
          label: "WeeklyOff Type :",
          groupValue: _weeklyOffTypeOption,
          isDense: true,
          options: [
            MapEntry("Regular", WeeklyOffTypeOptions.regular),
            MapEntry("Rotating", WeeklyOffTypeOptions.rotating),
          ],
          onChanged: (val) => setState(() {
            _weeklyOffTypeOption = val!;
            if (_weeklyOffTypeOption != WeeklyOffTypeOptions.regular) {
              _selectedFirstWeeklyOff = "Sunday";
              _selectedSecondWeeklyOff = "None";
              _selectedFullDayHalfDay = "FullDay";
            }
          }),
        ),
        const SizedBox(height: 12),
        if (_weeklyOffTypeOption == WeeklyOffTypeOptions.regular)
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Column(
              children: [
                _buildDropdownField<String>(
                  label: "First Weekly OFF :",
                  value: _selectedFirstWeeklyOff,
                  items: _daysOfWeek
                      .map((day) =>
                          DropdownMenuItem(value: day, child: Text(day)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedFirstWeeklyOff = val!;
                      // If first and second are same, reset second
                      if (_selectedFirstWeeklyOff == _selectedSecondWeeklyOff) {
                        _selectedSecondWeeklyOff = "None";
                      }
                    });
                  }
                ),
                const SizedBox(height: 12),
                AbsorbPointer(
                  absorbing: isSecondWeeklyOffDisabled,
                  child: Opacity(
                    opacity: isSecondWeeklyOffDisabled ? 0.5 : 1.0,
                    child: _buildDropdownField<String>(
                      label: "Secondly Weekly OFF :",
                      value: _selectedSecondWeeklyOff,
                      items: _daysOfWeekWithNone
                          .where((day) => day != _selectedFirstWeeklyOff) // Prevent selecting the same day
                          .map((day) =>
                              DropdownMenuItem(value: day, child: Text(day)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedSecondWeeklyOff = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AbsorbPointer(
                  absorbing: isDayTypeDisabled,
                  child: Opacity(
                    opacity: isDayTypeDisabled ? 0.5 : 1.0,
                    child: _buildDropdownField<String>(
                      label: "Full Day/Half Day :",
                      value: _selectedFullDayHalfDay,
                      items: _dayTypes
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedFullDayHalfDay = val!),
                    ),
                  ),
                ),
                if (showWeekSelection) ...[
                  const SizedBox(height: 16),
                  _buildWeekSelectionCheckboxes(),
                ]
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmployeeLoginDetailsExpansionTile() {
    return ExpansionTile(
      title: const Text("Employee Login Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      subtitle: const Text(
          "(Applicable only for New Employee at the time of enrollment)",
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
      initiallyExpanded: false,
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildCheckboxRow(
          "Employee can use non-biometric device(e.g. mobile/web).",
          _isLoginEnabled,
          (val) => setState(() => _isLoginEnabled = val ?? false),
        ),
        if (_isLoginEnabled)
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 8.0),
            child: Column(
              children: [
                _buildCheckboxRow(
                  "Can punch (In and out) from non-biometric device(e.g. mobile) from office's geo-fence.",
                  _canPunchInGeoFence,
                  (val) => setState(() => _canPunchInGeoFence = val!),
                ),
                const SizedBox(height: 4),
                _buildCheckboxRow(
                  "Can work from home i.e. punch (In and out) from non-biometric device(e.g. mobile) from any geo location.",
                  _canPunchFromHome,
                  (val) => setState(() => _canPunchFromHome = val!),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Set Rights:*",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildCheckboxRow("View Rights", _viewRights,
                  (val) => setState(() => _viewRights = val!)),
              const SizedBox(height: 4),
              _buildCheckboxRow(
                  "Can Apply for Regularization",
                  _canApplyForManualAttendance,
                  (val) => setState(() => _canApplyForManualAttendance = val!)),
              const SizedBox(height: 4),
              _buildCheckboxRow("Can Apply for Leave.", _canApplyForLeave,
                  (val) => setState(() => _canApplyForLeave = val!)),
              const SizedBox(height: 4),
              _buildCheckboxRow(
                  "Can Apply for Out Door Duty for a day",
                  _canApplyForOutDoorDuty,
                  (val) => setState(() => _canApplyForOutDoorDuty = val!)),
              const SizedBox(height: 4),
              _buildCheckboxRow("Can Apply for Tour/Travelling", _canApplyForTour,
                  (val) => setState(() => _canApplyForTour = val!)),
            ],
          ),
        ),
      ],
    );
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.profile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Setting Profile' : 'Add Setting Profile',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          HelpTooltipButton(
            tooltipMessage:
                'Configure employee settings including profile name, description, default status, weekly off adjustments, and shift start settings.',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _profileNameController,
                decoration: const InputDecoration(
                  labelText: 'Profile Name*',
                  border: OutlineInputBorder(),
                  counterText: '(Max. 50 characters)',
                ),
                maxLength: 50,
                // Add input formatter to prevent starting with non-letters
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a profile name';
                  }

                  // Check if it starts with a letter (a-z or A-Z)
                  if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
                    return 'Profile name must start with a letter (not number or special character)';
                  }

                  // Check for invalid characters (only letters, numbers, spaces, and common punctuation allowed)
                  if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9\s\-_\.]*$').hasMatch(value)) {
                    return 'Profile name can only contain letters, numbers, spaces, hyphens, underscores, and dots';
                  }

                  // Check length
                  if (value.length > 20) {
                    return 'Profile name cannot exceed 50 characters';
                  }

                  // Check for consecutive spaces
                  if (value.contains('  ')) {
                    return 'Consecutive spaces are not allowed';
                  }

                  // Check if it ends with space
                  if (value.endsWith(' ')) {
                    return 'Profile name cannot end with a space';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                  counterText: '(Max. 200 characters)',
                ),
                maxLength: 200,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length > 200) {
                    return 'Description cannot exceed 200 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCheckboxRow(
                'Set as Default Profile (Applicable only for New Employee at the time of enrollment)',
                _isDefaultProfile,
                (bool? value) {
                  setState(() {
                    _isDefaultProfile = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildWorkSettingsExpansionTile(),
              const SizedBox(height: 16),
              _buildWorkMinutesExpansionTile(),
              const SizedBox(height: 16),
              _buildAdditionalSettingsExpansionTile(),
              const SizedBox(height: 16),
              _buildRegularShiftExpansionTile(),
              const SizedBox(height: 16),
              _buildWeeklyOffDetailsExpansionTile(),
              const SizedBox(height: 16),
              _buildEmployeeLoginDetailsExpansionTile(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Clear all form fields
                      _profileNameController.clear();
                      _descriptionController.clear();
                      setState(() {
                        _isDefaultProfile = false;
                        
                        // Reset Work Settings
                        _presentOnWeeklyOffHoliday = PresentOnWeeklyOffHolidayOptions.present;
                        _leaveContainsWeeklyOff = LeaveContainsWeeklyOffOptions.leave;
                        _leaveContainsHoliday = LeaveContainsHolidayOptions.leave;
                        _weeklyOffHolidaySameDay = WeeklyOffHolidaySameDayOptions.holiday;
                        _absentBeforeAfterHoliday = AbsentBeforeAfterHolidayOptions.holiday;
                        _absentDaysForWeeklyOffController.text = "0";
                        _weeklyOffAbsentMarking = WeeklyOffAbsentMarkingOptions.prefix;

                        // Reset Work Minutes
                        _punchType = PunchTypeOptions.doubleFL;
                        _singlePunchOutTimeHHController.clear();
                        _singlePunchOutTimeMMController.clear();
                        _allowedLateComingMinutesController.text = "15";
                        _allowedEarlyGoingMinutesController.text = "15";
                        _workMinutesCalculation = WorkMinutesCalculationOptions.byShiftwise;
                        _fullDayMinsController.text = "480";
                        _halfDayMinsController.text = "240";
                        
                        // Reset Additional Settings
                        _isEmployeeAllowedToDoOverTime = true;
                        _otGraceMinsController.text = "5";
                        _overTimeCalculationStartsAt = OverTimeStartOptions.afterFullDay;
                        _additionalOverTimeCalcOption = OverTimeCalculationOptions.none;
                        _isEmployeeAllowedToTakeBreak = false;
                        _subtractLunchFromFullDay = false;
                        _subtractLunchFromHalfDay = false;
                        _calculateLateEarlyOnWeeklyOff = false;
                        _forcePunchOutOption = ForcePunchOutOptions.byAddingHalfDayInTime;
                        _defaultForcePunchOutHHController.clear();
                        _defaultForcePunchOutMMController.clear();
                        _isLateComingDeductionAllowed = false;
                        _lateComingForDaysController.text = "-1";
                        _lateComingAction = LateComingActionOptions.none;
                        _isRepeatLateComingDeductionAllowed = false;

                        // Reset Regular Shift
                        _shiftStartDateOption = ShiftStartDateOptions.employeeJoiningDate;
                        _shiftTypeOption = ShiftTypeOptions.fix;
                        _selectedFixShiftId = null;
                        _shiftConstantDaysController.clear();
                        _selectedShiftPatternId = null;

                        // Reset Weekly Off Details
                        _weeklyOffTypeOption = WeeklyOffTypeOptions.regular;
                        _selectedFirstWeeklyOff = "Sunday";
                        _selectedSecondWeeklyOff = "None";
                        _selectedFullDayHalfDay = "FullDay";
                        _isWeek1Selected = true;
                        _isWeek2Selected = true;
                        _isWeek3Selected = true;
                        _isWeek4Selected = true;
                        _isWeek5Selected = true;

                        // Reset Employee Login Details
                        _isLoginEnabled = false;
                        _canPunchInGeoFence = false;
                        _canPunchFromHome = false;
                        _viewRights = true;
                        _canApplyForLeave = false;
                        _canApplyForTour = false;
                        _canApplyForManualAttendance = false;
                        _canApplyForOutDoorDuty = false;
                      });
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text(isEditing ? 'Save Changes' : 'Create Profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<SettingProfileController>();
      final now = DateTime.now();
      final loginId = controller.currentLoginId;

      // --- 1. Build EmployeeSettings ---
      final employeeSetting = EmployeeSettings(
        employeeID: '',
        employeeName: '',
        type: _getPunchTypeEnumValue(),
        singlePunchOutTime: _punchType == PunchTypeOptions.single
            ? '${_singlePunchOutTimeHHController.text.padLeft(2, '0')}:${_singlePunchOutTimeMMController.text.padLeft(2, '0')}'
            : '00:00',
        isWorkMinutesCalculationByShift:
            _workMinutesCalculation == WorkMinutesCalculationOptions.byShiftwise,
        fullDayMinutes: int.tryParse(_fullDayMinsController.text) ?? 480,
        halfDayMinutes: int.tryParse(_halfDayMinsController.text) ?? 240,
        isOverTimeAllowed: _isEmployeeAllowedToDoOverTime,
        otStartMinutes: _isEmployeeAllowedToDoOverTime
            ? (int.tryParse(_otStartsMinsController.text) ?? 490)
            : 0,
        otGraceMins: _isEmployeeAllowedToDoOverTime
            ? (int.tryParse(_otGraceMinsController.text) ?? 5)
            : 0,
        isOTStartsAtShiftEnd:
            _overTimeCalculationStartsAt == OverTimeStartOptions.atExactShiftEnd,
        presentOnWOffOrHoliday: _getPresentOnWOffHolidayStringValue(),
        leaveNWOffConsider: _leaveContainsWeeklyOff ==
                LeaveContainsWeeklyOffOptions.leave
            ? EmployeeSettings.taLeave
            : EmployeeSettings.taWOff,
        leaveNHolidayConsider: _leaveContainsHoliday ==
                LeaveContainsHolidayOptions.leave
            ? EmployeeSettings.taLeave
            : EmployeeSettings.taHoliday,
        wOffNHolidayConsider: _weeklyOffHolidaySameDay ==
                WeeklyOffHolidaySameDayOptions.weeklyOff
            ? EmployeeSettings.taWOff
            : EmployeeSettings.taHoliday,
        allowedLateComingMinutes:
            int.tryParse(_allowedLateComingMinutesController.text) ?? 15,
        allowedEarlyGoingMinutes:
            int.tryParse(_allowedEarlyGoingMinutesController.text) ?? 15,
        isAHolidayAMarkA:
            _absentBeforeAfterHoliday == AbsentBeforeAfterHolidayOptions.absent,
        isBreakAllowed: _isEmployeeAllowedToTakeBreak,
        awoffDaysConstant:
            double.tryParse(_absentDaysForWeeklyOffController.text) ?? 0,
        isAWoffAMarkA:
            _weeklyOffAbsentMarking == WeeklyOffAbsentMarkingOptions.aWoffA,
        isAWOffMarkA:
            _weeklyOffAbsentMarking == WeeklyOffAbsentMarkingOptions.prefix,
        isWOffAMarkA:
            _weeklyOffAbsentMarking == WeeklyOffAbsentMarkingOptions.postfix,
      );

      // --- 2. Build EmployeeGeneralSettings ---
      final employeeGeneralSetting = EmployeeGeneralSettings(
        employeeID: '',
        employeeName: '',
        isComingLateNEarlyGoingCalculateOnWOff: _calculateLateEarlyOnWeeklyOff,
        isBreakMinutesSubtractFromFullDayWork: _subtractLunchFromFullDay,
        isBreakMinutesSubtractFromHalfDayWork: _subtractLunchFromHalfDay,
        overTimeCalculations: _getOverTimeCalcEnumValue(),
        forcePunchOut: _getForcePunchOutEnumValue(),
        forcePunchDefaultOutTime:
            _forcePunchOutOption == ForcePunchOutOptions.defaultTime
                ? '${_defaultForcePunchOutHHController.text.padLeft(2, '0')}:${_defaultForcePunchOutMMController.text.padLeft(2, '0')}'
                : '00:00',
        isLateComingDeductionAllowed: _isLateComingDeductionAllowed,
        lateComingDaysForCutOff:
            int.tryParse(_lateComingForDaysController.text) ?? -1,
        actionForLateComing: _getLateComingActionEnumValue(),
        isRepeatLateComingAllowed: _isRepeatLateComingDeductionAllowed,
        isRotationalWeeklyOff:
            _weeklyOffTypeOption == WeeklyOffTypeOptions.rotating,
      );

      // --- 3. Build EmployeeRegularShifts ---
      final employeeRegularShift = EmployeeRegularShifts(
        employeeID: '',
        employeeName: '',
        startDate: '',
        startDateTime: DateTime.now().toIso8601String(),
        type: _getShiftTypeEnumValue(),
        shiftID: _shiftTypeOption == ShiftTypeOptions.fix
            ? _selectedFixShiftId ?? ''
            : '',
        shiftName: '',
        patternID: _shiftTypeOption == ShiftTypeOptions.rotation
            ? _selectedShiftPatternId ?? ''
            : '',
        patternName: '',
        shiftConstantDays: _shiftTypeOption == ShiftTypeOptions.rotation
            ? _shiftConstantDaysController.text
            : '',
      );

      // --- 4. Build EmployeeWOff ---
      String woffPattern = '';
      final bool weekSelectionIsActive = _selectedSecondWeeklyOff != 'None' &&
          _selectedFirstWeeklyOff != _selectedSecondWeeklyOff &&
          _selectedFullDayHalfDay == 'HalfDay';

      if (weekSelectionIsActive) {
        final weeks = <String>[];
        if (_isWeek1Selected) weeks.add('1');
        if (_isWeek2Selected) weeks.add('2');
        if (_isWeek3Selected) weeks.add('3');
        if (_isWeek4Selected) weeks.add('4');
        if (_isWeek5Selected) weeks.add('5');
        woffPattern = weeks.join('-');
      }

      final employeeWOFF = EmployeeWOff(
        employeeID: '',
        employeeName: '',
        firstName: '',
        firstWOff: _selectedFirstWeeklyOff,
        secondWOff: _selectedSecondWeeklyOff,
        isFullDay: _selectedFullDayHalfDay == 'FullDay',
        wOffPattern: woffPattern,
      );

      // --- 5. Build EmpLogin ---
      final empLogin = EmpLogin(
        employeeID: '',
        employeeName: '',
        isPasswordSet: false,
        employeePassword: '',
        employeePasswordConfirm: '',
        roleType: '',
        isEnabled: _isLoginEnabled,
        canPunchInGeoFence: _canPunchInGeoFence,
        canPunchFromHome: _canPunchFromHome,
        empDeviceLogin: null,
        canView: _viewRights,
        canApplyForManualAttendance: _canApplyForManualAttendance,
        canApplyForLeave: _canApplyForLeave,
        canApplyForTour: _canApplyForTour,
        canApplyForOutDoor: _canApplyForOutDoorDuty,
        empLoginModeCreated:
            CsEmpLoginModeCreated.ViaTAWebOrUtility.index,
        hasSubordinate: false,
        listOfSubordinatesEmployeeID: '',
      );

      // --- 6. Build the final SettingProfileModel ---
      final profile = SettingProfileModel(
        profileId: widget.profile?.profileId ?? '',
        profileName: _profileNameController.text,
        description: _descriptionController.text,
        isDefaultProfile: _isDefaultProfile,
        isEmpWeeklyOffAdjustable: false,
        isShiftStartFromJoiningDate:
            _shiftStartDateOption == ShiftStartDateOptions.employeeJoiningDate,
        changesDoneOn: now.toIso8601String(),
        changesDoneOnDateTime: now,
        changesDoneBy: loginId,
        employeeSetting: employeeSetting,
        employeeGeneralSetting: employeeGeneralSetting,
        employeeRegularShift: employeeRegularShift,
        employeeWOFF: employeeWOFF,
        employeeLogin: empLogin,
      );

      bool success = false;
      if (widget.profile != null) {
        success = await controller.updateSettingProfile(profile);
      } else {
        success = await controller.createSettingProfile(profile);
      }

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }
}