// lib/widget/responsive_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_attendance/model/TALogin/permission_manager.dart';
import 'package:time_attendance/model/TALogin/user_forms.dart';
import 'package:time_attendance/model/TALogin/session_manager.dart'
    if (dart.library.html) 'package:time_attendance/model/TALogin/session_manager_web.dart'
    if (dart.library.io) 'package:time_attendance/model/TALogin/session_manager_mobile.dart';

@immutable
class DrawerItem {
  final String path;
  final String label;
  final IconData icon;

  const DrawerItem(this.path, this.label, this.icon);
}

@immutable
class DrawerItemGroup {
  final String label;
  final IconData icon;
  final List<DrawerItem> children;

  const DrawerItemGroup(this.label, this.icon, this.children);
}

class ResponsiveScaffold extends StatelessWidget {
  static const double _kDrawerPadding = 16.0;
  static const double _kMobileBreakpoint = 600.0;
  static const double _kIconSpacing = 8.0;
  static const double _kMenuOffset = 50.0;
  static const double _kHeaderFontSize = 24.0;

  final Widget child;

  const ResponsiveScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: FutureBuilder<void>(
        future: PermissionManager().initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildDrawer(context);
          }
          return const Drawer(child: Center(child: CircularProgressIndicator()));
        },
      ),
      body: child,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final bool isMobile =
        MediaQuery.of(context).size.width <= _kMobileBreakpoint;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      title: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Text('Time Attendance'),
        ),
      ),
      actions: [
        _buildSettingsButton(context),
        if (!isMobile) _buildNotificationButton(),
        _buildProfileAvatar(),
        const SizedBox(width: _kIconSpacing),
        _buildProfileMenu(context, isMobile),
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Settings',
      onPressed: () => context.go('/settingprofile'),
    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      icon: const Icon(Icons.notifications),
      tooltip: 'Notifications',
      onPressed: () {},
    );
  }

  Widget _buildProfileAvatar() {
    return const CircleAvatar(
      backgroundImage: AssetImage('assets/images/user_avatar.png'),
    );
  }

  Widget _buildProfileMenu(BuildContext context, bool isMobile) {
    return PopupMenuButton<String>(
      offset: const Offset(0, _kMenuOffset),
      onSelected: (value) => _handleProfileMenuSelection(context, value),
      itemBuilder: (context) => _buildProfileMenuItems(context, isMobile),
      child: _buildProfileMenuTrigger(),
    );
  }

  void _handleProfileMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'logout':
        _showLogoutDialog(context);
        break;
      case 'view_profile':
        // Handle view profile
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildProfileMenuItems(
      BuildContext context, bool isMobile) {
    return [
      if (isMobile) ...[
        _buildMenuItem('settings', 'Settings', Icons.settings),
        _buildMenuItem('notifications', 'Notifications', Icons.notifications),
      ],
      _buildMenuItem('view_profile', 'View Profile', Icons.person),
      _buildMenuItem('logout', 'Logout', Icons.logout),
    ];
  }

  PopupMenuItem<String> _buildMenuItem(
      String value, String text, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildProfileMenuTrigger() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: PlatformSessionManager.getLoginDetails(),
            builder: (context, snapshot) {
              return Text(snapshot.data?['UserName'] ?? 'User');
            },
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PlatformSessionManager.clearSession();
              PermissionManager().clear(); // Clear cached permissions
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Maps a navigation path to its corresponding [UserInsigniaForms] enum.
  UserInsigniaForms? _getFormEnumFromPath(String path) {
    const Map<String, UserInsigniaForms> pathMap = {
      // Master
      '/designation': UserInsigniaForms.TA_Masters_Designation,
      '/department': UserInsigniaForms.TA_Masters_Department,
      '/company': UserInsigniaForms.TA_Masters_Company,
      '/location': UserInsigniaForms.TA_Masters_Location,
      '/holiday': UserInsigniaForms.TA_Masters_Holiday,
      '/employeeType': UserInsigniaForms.TA_EmployeeType,
      // Shift
      '/shiftdetail': UserInsigniaForms.TA_Shift_Shift,
      '/shiftpattern': UserInsigniaForms.TA_Shift_ShiftPattern,
      // Employee
      '/settingprofile': UserInsigniaForms.TA_Employee_Setting,
      '/employeesettings': UserInsigniaForms.TA_Employee_Setting,
      '/employee': UserInsigniaForms.TA_Employee_Details,
      '/regularshift': UserInsigniaForms.TA_EmployeeShift_RegularTemporaryOrCSV,
      '/temporaryshift': UserInsigniaForms.TA_EmployeeShift_RegularTemporaryOrCSV,
      '/temporaryweeklyoff': UserInsigniaForms.TA_EmployeeWeeklyOff_RegularRotationalOrCSV,
      // Data Entry
      '/inventory': UserInsigniaForms.TA_Inventory,
      '/dataprocess': UserInsigniaForms.TA_HouseKeeping_DataProcessing,
      '/manual-attendance/create': UserInsigniaForms.TA_EmployeeManual_Create,
      '/manual-attendance/approve': UserInsigniaForms.TA_EmployeeManual_Approval,
      // Housekeeping
      '/device': UserInsigniaForms.TA_HouseKeeping_Device,
      '/downoaddevice': UserInsigniaForms.TA_HouseKeeping_DownloadLogsDeviceUsbOrCSV,
      '/deviceManagement': UserInsigniaForms.TA_HouseKeeping_Device,
      '/bulk-employee-actions': UserInsigniaForms.TA_Employee_BulkAddEditDelete,
      // Admin
      '/admin-user': UserInsigniaForms.TA_Admin_User,
      // Reports
      '/masterreport': UserInsigniaForms.TA_Reports_Master,
      '/shiftreport': UserInsigniaForms.TA_Reports_Shift,
      '/leavereport': UserInsigniaForms.TA_Reports_Leave,
      '/employeereport': UserInsigniaForms.TA_Reports_Employee,
      '/attendancereport': UserInsigniaForms.TA_Reports_Attendance,
      '/misc-report': UserInsigniaForms.TA_Reports_Miscellaneous,
    };
    return pathMap[path];
  }

  Widget _buildDrawer(BuildContext context) {
    final permissionManager = PermissionManager();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(context),
          _buildDrawerItem(context, '/home', 'Home', Icons.home),
          if (permissionManager.hasAnyPermission([
            UserInsigniaForms.TA_Masters_Company,
            UserInsigniaForms.TA_Masters_Department,
            UserInsigniaForms.TA_Masters_Designation,
            UserInsigniaForms.TA_Masters_Location,
            UserInsigniaForms.TA_Masters_Holiday,
            UserInsigniaForms.TA_EmployeeType,
          ]))
            _buildMasterSection(context),
          if (permissionManager.hasAnyPermission([
            UserInsigniaForms.TA_Shift_Shift,
            UserInsigniaForms.TA_Shift_ShiftPattern,
          ]))
            _buildShiftSection(context),
          if (permissionManager.hasAnyPermission([
            UserInsigniaForms.TA_Employee_Setting,
            UserInsigniaForms.TA_Employee_Details,
            UserInsigniaForms.TA_EmployeeShift_RegularTemporaryOrCSV,
            UserInsigniaForms.TA_EmployeeWeeklyOff_RegularRotationalOrCSV,
          ]))
            _buildEmployeeSection(context),
          if (permissionManager.hasAnyPermission([
            UserInsigniaForms.TA_Inventory,
            UserInsigniaForms.TA_HouseKeeping_DataProcessing,
            UserInsigniaForms.TA_EmployeeManual_Create,
            UserInsigniaForms.TA_EmployeeManual_Approval,
          ]))
            _buildDataEntrySection(context),
          if (permissionManager.hasAnyPermission([
            UserInsigniaForms.TA_HouseKeeping_Device,
            UserInsigniaForms.TA_HouseKeeping_DownloadLogsDeviceUsbOrCSV,
            UserInsigniaForms.TA_Employee_BulkAddEditDelete,
          ]))
            _buildHousekeepingSection(context),
          if (permissionManager.hasAnyPermission([UserInsigniaForms.TA_Admin_User]))
            _buildAdminSection(context),
          if (permissionManager.hasAnyPermission([
            UserInsigniaForms.TA_Reports_Master,
            UserInsigniaForms.TA_Reports_Shift,
            UserInsigniaForms.TA_Reports_Leave,
            UserInsigniaForms.TA_Reports_Employee,
            UserInsigniaForms.TA_Reports_Attendance,
            UserInsigniaForms.TA_Reports_Miscellaneous,
          ]))
            _buildReportsSection(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        'Time Attendance',
        style: TextStyle(
          color: Colors.white,
          fontSize: _kHeaderFontSize,
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<dynamic> items,
  }) {
    final permissionManager = PermissionManager();

    final List<Widget> permittedChildren = items.map((item) {
      if (item is DrawerItem) {
        UserInsigniaForms? formEnum = _getFormEnumFromPath(item.path);
        if (formEnum != null && permissionManager.hasPermission(formEnum)) {
          return _buildPaddedDrawerItem(context, item);
        }
      } else if (item is DrawerItemGroup) {
        final permittedSubItems = item.children.where((child) {
          UserInsigniaForms? formEnum = _getFormEnumFromPath(child.path);
          return formEnum != null && permissionManager.hasPermission(formEnum);
        }).toList();

        if (permittedSubItems.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(left: _kDrawerPadding),
            child: ExpansionTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              shape: Border.all(color: Colors.transparent),
              children: permittedSubItems
                  .map((child) => _buildPaddedDrawerItem(context, child))
                  .toList(),
            ),
          );
        }
      }
      return const SizedBox.shrink();
    }).toList();

    // Remove empty widgets before checking if the list is empty
    permittedChildren.removeWhere((widget) => widget is SizedBox);

    if (permittedChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      shape: Border.all(color: Colors.transparent),
      children: permittedChildren,
    );
  }

  Widget _buildPaddedDrawerItem(BuildContext context, DrawerItem item) {
    return Padding(
      padding: const EdgeInsets.only(left: _kDrawerPadding),
      child: _buildDrawerItem(context, item.path, item.label, item.icon),
    );
  }

  Widget _buildMasterSection(BuildContext context) {
    return _buildExpandableSection(
      context: context,
      title: 'Master',
      icon: Icons.settings,
      items: [
        DrawerItem('/designation', 'Designation', Icons.badge),
        DrawerItem('/department', 'Department', Icons.business),
        DrawerItem('/company', 'Branch', Icons.business),
        DrawerItem('/location', 'Location', Icons.location_on),
        DrawerItem('/holiday', 'Holiday', Icons.calendar_today),
        DrawerItem('/employeeType', 'Employee Type', Icons.work_history),
      ],
    );
  }

  Widget _buildShiftSection(BuildContext context) {
    return _buildExpandableSection(
      context: context,
      title: 'Shift',
      icon: Icons.punch_clock_rounded,
      items: [
        DrawerItem('/shiftdetail', 'Shift Details', Icons.lock_clock),
        DrawerItem('/shiftpattern', 'Shift Pattern', Icons.pattern),
      ],
    );
  }

  Widget _buildEmployeeSection(BuildContext context) {
    return _buildExpandableSection(
      context: context,
      title: 'Employee',
      icon: Icons.people,
      items: [
        DrawerItem('/settingprofile', 'Setting Profiles', Icons.settings_applications),
        DrawerItem(
            '/employeesettings', 'Employee Settings', Icons.manage_accounts),
        DrawerItem('/employee', 'Employee Details', Icons.account_box),
        DrawerItem('/regularshift', 'Employee Regular Shift', Icons.schedule),
        DrawerItem('/temporaryshift', 'Shift Roster', Icons.event_note),
        DrawerItem(
            '/temporaryweeklyoff', 'Temporary Weekly Off', Icons.calendar_view_week),
      ],
    );
  }

  Widget _buildDataEntrySection(BuildContext context) {
    return _buildExpandableSection(
      context: context,
      title: 'Data Entry',
      icon: Icons.data_usage,
      items: [
        DrawerItem('/inventory', 'Inventory', Icons.inventory_2),
        DrawerItem('/dataprocess', 'Data Process', Icons.sync),
        DrawerItemGroup(
          'Regularization',
          Icons.edit_calendar,
          [
            DrawerItem('/manual-attendance/create', 'Create', Icons.add_circle),
            DrawerItem(
                '/manual-attendance/approve', 'Approve/Reject', Icons.approval),
          ],
        ),
      ],
    );
  }
  
  Widget _buildHousekeepingSection(BuildContext context) {
    return _buildExpandableSection(
      context: context,
      title: 'Housekeeping',
      icon: Icons.house,
      items: [
        DrawerItem('/device', 'Device', Icons.devices),
        DrawerItem('/downoaddevice', 'Download Device', Icons.download_for_offline),
        DrawerItem('/deviceManagement', 'Device Management', Icons.phonelink_setup),
        DrawerItem('/bulk-employee-actions', 'Bulk Employee Actions', Icons.group_add),
      ],
    );
  }

  Widget _buildAdminSection(BuildContext context) {
    return _buildExpandableSection(
      context: context,
      title: 'Admin',
      icon: Icons.admin_panel_settings,
      items: [
        DrawerItem('/admin-user', 'User Management', Icons.manage_accounts),
      ],
    );
  }

  Widget _buildReportsSection(BuildContext context) {
    return _buildExpandableSection(
      context: context,
      title: 'Reports',
      icon: Icons.assignment,
      items: [
        DrawerItem('/masterreport', 'Master Report', Icons.analytics),
        DrawerItem('/shiftreport', 'Shift Report', Icons.bar_chart),
        DrawerItem('/leavereport', 'Leave Report', Icons.event_busy),
        DrawerItem('/employeereport', 'Employee Report', Icons.person_search),
        DrawerItem('/attendancereport', 'Attendance Report', Icons.co_present),
        DrawerItem('/misc-report', 'Miscellaneous Report', Icons.more_horiz),
      ],
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String path, String label, IconData icon) {
    final currentPath =
        GoRouter.of(context).routeInformationProvider.value.uri.path;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: currentPath == path,
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}