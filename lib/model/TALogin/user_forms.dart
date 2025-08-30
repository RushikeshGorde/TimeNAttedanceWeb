// lib/model/TALogin/user_forms.dart
enum UserInsigniaForms {
  TA_Masters, //0 menu
  TA_Masters_Company, //1 form // Branch ToDo:
  TA_Masters_Department, //2 form
  TA_Masters_Designation, //3 form
  TA_Masters_Location, //4 form
  TA_Masters_Holiday, //5 form
  TA_Additional, //6 menu
  TA_EmployeeType, //7 form // Employee Type -- Interns , Full-time,Casual,Leased employees,Apprentices  etc, add  edit delete // currently implementation pending
  TA_Inventory, //8 form //Company Resources items (add update delete)  which will assigned to employees // currently implementation pending
  TA_Shift, //9 menu
  TA_Shift_Shift, //10 form
  TA_Shift_ShiftPattern, //11 form
  TA_Leave, //12 menu
  TA_Leave_LeaveType, //13 form
  TA_Leave_LeavePolicy, //14 form
  TA_Employee, //15 menu
  TA_Employee_Details, //16 form
  TA_Employee_Setting, //17 form // this should be small group of settings assigned to selected employees (now entire setting updated -need to divide in small groups)
  TA_EmployeeShift_RegularTemporaryOrCSV, //18 form //regular or Temporary and Temporary CSV will be merged together later
  TA_EmployeeWeeklyOff_RegularRotationalOrCSV, //19 form//regular or Rotational and Rotational CSV will be merged together later
  TA_EmployeeAdditionalSetting, //20 menu
  TA_Employee_BulkAddEditDelete, //21 form // upload, edit and delete will marge in One form later
  TA_Employee_EmployeeLogin, //22 form //edit password, rights geo Locations etc
  TA_Employee_EmployeeNonBiometricSettings, //23 form //mobile phone users approval etc
  TA_Employee_Inventory, //24 form //Cpmoany Resources allocated to Employee
  TA_DataEntry, //25 menu
  TA_Leave_EmpLeavePolicy, //26 sub menu
  TA_Leave_EmpLeavePolicyBulk, //27 form
  TA_Leave_EmpLeavePolicyIndividual, //28 form
  TA_Leave_LeaveApplication, //29 sub menu
  TA_Leave_EmpLeaveApplication, //30 form // create approve or reject according to rights
  TA_Leave_EmpLeaveApplicationApproval, //31 form // quick approve or reject according to rights. here leave application can not be edited
  TA_Leave_EmpLeaveCarryforward, //32 form //leave carry forwards
  TA_EmployeeManual, //33 sub menu
  TA_EmployeeManual_Create, //34 form
  TA_EmployeeManual_Approval, //35 form
  TA_EmployeeManual_BulkAssignment, //36 form
  TA_EmployeeOutDoor, //37 sub menu
  TA_EmployeeOutDoor_Create, //38 form  // out door is actually punch record added in Log table for considering that punch in attendance calculation
  TA_EmployeeOutDoor_Approval, //39 form
  TA_EmployeeTour, //40 sub menu
  TA_EmployeeTour_Create, //41 form// pending,
  TA_EmployeeTour_Approval, //42 form// pending
  TA_HouseKeeping, //43 menu
  TA_HouseKeeping_Device, //44 form
  TA_HouseKeeping_DownloadLogsDeviceUsbOrCSV, //45 form
  TA_HouseKeeping_DataProcessing, //46 form
  TA_MenuAdmin, //47 menu
  TA_Admin_User, //48 form
  TA_Reports, //49 menu
  TA_Reports_Master, //50 form  // will include reports of inventory items and Employee Type
  TA_Reports_Shift, //51 form
  TA_Reports_Leave, //52 form //Leave policy , leave Balance , Leave Type details  not related to employee
  TA_Reports_Employee, //53 form // employee details personal, inventory,
  TA_Reports_Attendance, //54 form // will also include employees Leave application, rejected and OD and Tour reports etc
  TA_Reports_Miscellaneous, //55 form // Log each thing in Db, create , edit update by which login , every thing in detail, status -- working
  TA_About //56 menu  // insignia Details copy rights
}