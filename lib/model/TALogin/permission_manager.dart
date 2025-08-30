// lib/model/TALogin/permission_manager.dart
import 'package:time_attendance/model/TALogin/session_manager.dart'
    if (dart.library.html) 'package:time_attendance/model/TALogin/session_manager_web.dart'
    if (dart.library.io) 'package:time_attendance/model/TALogin/session_manager_mobile.dart';
import 'package:time_attendance/model/TALogin/user_forms.dart';

/// A singleton class to manage user permissions based on the 'FormView' string.
class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  Set<int>? _allowedFormIds;

  /// Initializes the permission set from the session manager.
  /// Fetches the 'FormView' string and parses it into a set of integer IDs.
  Future<void> initialize() async {
    // Avoid re-initialization if permissions are already loaded
    if (_allowedFormIds != null) return;

    final loginDetails = await PlatformSessionManager.getLoginDetails();
    final formViewString = loginDetails?['FormView'] as String?;

    if (formViewString != null && formViewString.isNotEmpty) {
      _allowedFormIds = formViewString
          .split(',')
          .where((id) => id.isNotEmpty)
          .map((id) => int.tryParse(id))
          .where((id) => id != null)
          .cast<int>()
          .toSet();
    } else {
      // Default to an empty set if no permissions are found
      _allowedFormIds = <int>{};
    }
  }

  /// Checks if the current user has permission for a specific form.
  ///
  /// It is assumed that the integer values in the 'FormView' string correspond
  /// to the index of the [UserInsigniaForms] enum members.
  bool hasPermission(UserInsigniaForms form) {
    if (_allowedFormIds == null) {
      // If not initialized, default to no permission.
      return false;
    }
    return _allowedFormIds!.contains(form.index);
  }

  /// Checks if the user has permission for at least one of the given forms.
  /// Useful for determining if a parent menu should be visible.
  bool hasAnyPermission(List<UserInsigniaForms> forms) {
    if (_allowedFormIds == null) return false;
    return forms.any((form) => hasPermission(form));
  }

  /// Clears the cached permissions. Should be called on logout.
  void clear() {
    _allowedFormIds = null;
  }
}