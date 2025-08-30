import 'dart:convert';
import '../LoginInformation/AuthLogin.dart';
import '../LoginInformation/Constants.dart';
import 'Result.dart';
import 'ServerInteractionViaHttp.dart';
import '../../model/TALogin/session_manager.dart'
    if (dart.library.html) '../../model/TALogin/session_manager_web.dart'
    if (dart.library.io) '../../model/TALogin/session_manager_mobile.dart';

//ToDo: Add cryptography Later, code optimization pending
class APIInteraction {
  
  // NEW: Get fresh auth token from session
  Future<String?> _getFreshAuthToken() async {
    try {
      // Check if session is still valid
      if (!await PlatformSessionManager.isLoggedIn()) {
        print('Session invalid - cannot get auth token');
        return null;
      }
      
      return await PlatformSessionManager.getAuthLoginInfo();
    } catch (e) {
      print('Error getting fresh auth token: $e');
      return null;
    }
  }

  // NEW: Create auth login from current session
  Future<AuthLogin?> _getAuthLoginFromSession() async {
    try {
      final userInfo = await PlatformSessionManager.getUserInfo();
      if (userInfo != null) {
        return AuthLogin.fromJson(userInfo);
      }
      return null;
    } catch (e) {
      print('Error creating AuthLogin from session: $e');
      return null;
    }
  }

  // ENHANCED: Get all objects with session validation
  Future<Result> GetAllObjects(AuthLogin objLoginInfo, String strApiControllerName) async {
    Result objResult;
    final ApiInteraction objApiInteraction = ApiInteraction();
    try {
      // Get fresh auth token from session instead of using passed object
      String? freshToken = await _getFreshAuthToken();
      if (freshToken == null) {
        objResult = Result();
        objResult.ResultMessage = 'Authentication token not available. Please login again.';
        objResult.IsResultPass = false;
        return objResult;
      }

      print('Using fresh auth token for API call');
      String strAPIUrl = ApiConstants.baseUrl + strApiControllerName;
      print('API URL: $strAPIUrl');
      objResult = await objApiInteraction.GetCall(freshToken, strAPIUrl);
    }
    on Exception catch (e) {
      objResult = Result();
      objResult.ResultMessage = e.toString();
      objResult.IsResultPass = false;
      print('error caught: $e');
    }
    return objResult;
  }

  // ENHANCED: Get object by ID with session validation  
  Future<Result> GetObjectByObjectID(AuthLogin objLoginInfo, String strObjectID, String strApiControllerName) async {
    Result objResult;
    final ApiInteraction objApiInteraction = ApiInteraction();
    try {
      // Get fresh auth token from session
      String? freshToken = await _getFreshAuthToken();
      if (freshToken == null) {
        objResult = Result();
        objResult.ResultMessage = 'Authentication token not available. Please login again.';
        objResult.IsResultPass = false;
        return objResult;
      }

      print('Using fresh auth token for GetObjectByID');
      String strAPIUrl = ApiConstants.baseUrl + strApiControllerName;
      print('API URL: $strAPIUrl');
      objResult = await objApiInteraction.GetCallParameter(freshToken, strAPIUrl, strObjectID);
    }
    on Exception catch (e) {
      objResult = Result();
      objResult.ResultMessage = e.toString();
      objResult.IsResultPass = false;
      print('error caught: $e');
    }
    return objResult;
  }

  // ENHANCED: Save with session validation
  Future<Result> Save(AuthLogin objLoginInfo, String strJsonEncodedString, String strApiControllerName) async {
    Result objResult;
    final ApiInteraction objApiInteraction = ApiInteraction();
    try {
      // Get fresh auth token from session
      String? freshToken = await _getFreshAuthToken();
      if (freshToken == null) {
        objResult = Result();
        objResult.ResultMessage = 'Authentication token not available. Please login again.';
        objResult.IsResultPass = false;
        return objResult;
      }

      print('Using fresh auth token for Save operation');
      String strAPIUrl = ApiConstants.baseUrl + strApiControllerName;
      String strJsonData = strJsonEncodedString;
      objResult = await objApiInteraction.PostCall(freshToken, strJsonData, strAPIUrl);

    }
    on Exception catch (e) {
      objResult = Result();
      objResult.ResultMessage = e.toString();
      objResult.IsResultPass = false;
      print('error caught: $e');
    }
    return objResult;
  }

  // ENHANCED: Update with session validation
  Future<Result> Update(AuthLogin objLoginInfo, String strJsonEncodedString, String strApiControllerName) async {
    Result objResult;
    final ApiInteraction objApiInteraction = ApiInteraction();
    try {
      // Get fresh auth token from session
      String? freshToken = await _getFreshAuthToken();
      if (freshToken == null) {
        objResult = Result();
        objResult.ResultMessage = 'Authentication token not available. Please login again.';
        objResult.IsResultPass = false;
        return objResult;
      }

      print('Using fresh auth token for Update operation');
      String strAPIUrl = ApiConstants.baseUrl + strApiControllerName;
      String strJsonData = strJsonEncodedString;
      objResult = await objApiInteraction.PutCall(freshToken, strJsonData, strAPIUrl);
    }
    on Exception catch (e) {
      objResult = Result();
      objResult.ResultMessage = e.toString();
      objResult.IsResultPass = false;
      print('error caught: $e');
    }
    return objResult;
  }

  // ENHANCED: Delete with session validation
  Future<Result> Delete(AuthLogin objLoginInfo, String strJsonEncodedString, String strApiControllerName) async {
    Result objResult;
    final ApiInteraction objApiInteraction = ApiInteraction();
    try {
      // Get fresh auth token from session
      String? freshToken = await _getFreshAuthToken();
      if (freshToken == null) {
        objResult = Result();
        objResult.ResultMessage = 'Authentication token not available. Please login again.';
        objResult.IsResultPass = false;
        return objResult;
      }

      print('Using fresh auth token for Delete operation');
      String strAPIUrl = ApiConstants.baseUrl + strApiControllerName;
      String strJsonData = strJsonEncodedString;
      objResult = await objApiInteraction.DeleteCall(freshToken, strJsonData, strAPIUrl);
    }
    on Exception catch (e) {
      objResult = Result();
      objResult.ResultMessage = e.toString();
      objResult.IsResultPass = false;
      print('error caught: $e');
    }
    return objResult;
  }

  // NEW: Convenience methods that don't require AuthLogin parameter
  Future<Result> GetAllObjectsFromSession(String strApiControllerName) async {
    final authLogin = await _getAuthLoginFromSession();
    if (authLogin == null) {
      Result objResult = Result();
      objResult.ResultMessage = 'No valid session found. Please login again.';
      objResult.IsResultPass = false;
      return objResult;
    }
    return await GetAllObjects(authLogin, strApiControllerName);
  }

  Future<Result> GetObjectByObjectIDFromSession(String strObjectID, String strApiControllerName) async {
    final authLogin = await _getAuthLoginFromSession();
    if (authLogin == null) {
      Result objResult = Result();
      objResult.ResultMessage = 'No valid session found. Please login again.';
      objResult.IsResultPass = false;
      return objResult;
    }
    return await GetObjectByObjectID(authLogin, strObjectID, strApiControllerName);
  }

  Future<Result> SaveFromSession(String strJsonEncodedString, String strApiControllerName) async {
    final authLogin = await _getAuthLoginFromSession();
    if (authLogin == null) {
      Result objResult = Result();
      objResult.ResultMessage = 'No valid session found. Please login again.';
      objResult.IsResultPass = false;
      return objResult;
    }
    return await Save(authLogin, strJsonEncodedString, strApiControllerName);
  }

  Future<Result> UpdateFromSession(String strJsonEncodedString, String strApiControllerName) async {
    final authLogin = await _getAuthLoginFromSession();
    if (authLogin == null) {
      Result objResult = Result();
      objResult.ResultMessage = 'No valid session found. Please login again.';
      objResult.IsResultPass = false;
      return objResult;
    }
    return await Update(authLogin, strJsonEncodedString, strApiControllerName);
  }

  Future<Result> DeleteFromSession(String strJsonEncodedString, String strApiControllerName) async {
    final authLogin = await _getAuthLoginFromSession();
    if (authLogin == null) {
      Result objResult = Result();
      objResult.ResultMessage = 'No valid session found. Please login again.';
      objResult.IsResultPass = false;
      return objResult;
    }
    return await Delete(authLogin, strJsonEncodedString, strApiControllerName);
  }
}