import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../model/TALogin/login.dart';
import '../../widgets/mtaToast.dart';

import 'AuthLogin.dart';
import 'DeviceInfo.dart';
import 'FileInteraction.dart';

class AuthLoginDetails {
  // NEW: Clear all stored authentication data
  Future<void> clearAllAuthData() async {
    try {
      // Clear file-based data for mobile
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        AuthLogin objLoginInfo = await InItAuthLogin();
        objLoginInfo.CompanyCode = "";
        objLoginInfo.LoginID = "";
        objLoginInfo.Password = "";
        objLoginInfo.CanGoForBiometricLogin = false;
        objLoginInfo.DoesBiometricUsedForLogin = false;
        objLoginInfo.Mode = LoginMode.Unknown;
        await SaveLoginInformationInTheFile(objLoginInfo);
      }
      print('All auth data cleared');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  //Intialise Login With Values
  Future<AuthLogin> InItAuthLogin() async {
    // one GUID will maintain from install to uninstall
    String strNewGuID = const Uuid().v4().toString(); // new GUID;

    //Init LoginInfo with values
    AuthLogin objLoginInfo = new AuthLogin(strNewGuID);
    try {
      //values which are needed during Passing
      if (kIsWeb) {
        objLoginInfo.AppType = ApplicationType.Web;
      } else if (Platform.isAndroid) {
        objLoginInfo.AppType = ApplicationType.Android;
      } else if (Platform.isIOS) {
        objLoginInfo.AppType = ApplicationType.IOS;
      } else if (Platform.isWindows) {
        objLoginInfo.AppType = ApplicationType.Window;
      }

      //Device Information
      String strDeviceInformation = await DeviceInfo().GetDeviceInformation();
      objLoginInfo.DeviceInfo = strDeviceInformation;

      objLoginInfo.Mode = LoginMode.Unknown;

      //Only for Mobile
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          //get Information from file
          final strFileData = await FileInteraction()
              .getDataFromFile(FileInteraction.MTAFileName);
          if (strFileData.toString().trim().length == 0) // file is not exists
          {
            // if file contains are null or file not exists
            // save LoginInfo in file with new GUID
            SaveLoginInformationInTheFile(objLoginInfo);
            print('Fresh auth data stored: $objLoginInfo');
          } else if (strFileData.toString().trim().length > 0) {
            Map<String, dynamic> valueMap = json.decode(strFileData);
            print("File Data: $strFileData");
            
            AuthLogin fileLoginInfo = AuthLogin.fromJson(valueMap);
            
            // IMPORTANT: Only use file data if it's still valid for biometric
            // Otherwise, create fresh login info to avoid stale credentials
            if (fileLoginInfo.CanGoForBiometricLogin && 
                fileLoginInfo.LoginID.isNotEmpty && 
                fileLoginInfo.Password.isNotEmpty) {
              objLoginInfo = fileLoginInfo;
              print("Using stored credentials for biometric login");
            } else {
              // File has incomplete/invalid data, use fresh login info
              print("File contains invalid/incomplete data, using fresh login info");
              objLoginInfo.UniqueID = fileLoginInfo.UniqueID; // Keep the GUID
            }
            
            objLoginInfo.DoesBiometricUsedForLogin = false;
            await InItAuthEncryptedString(objLoginInfo); // to get Encryption string
          }
        }
      }
    } on Exception catch (e) {
      objLoginInfo = new AuthLogin(strNewGuID); //with default values
      objLoginInfo.CanGoForBiometricLogin = false;
      print('error caught: $e');
    }
    return objLoginInfo;
  }

  Future<String> InItAuthEncryptedString(AuthLogin objLoginInfo) async {
    String strAuthEncryption = '';
    try {
      //TODo:Temporary Encryption Disabled , Undone it later
      String strAuthEncryption = jsonEncode(objLoginInfo);
      objLoginInfo.AuthEncryptedString = strAuthEncryption;
    } on Exception catch (e) {
      strAuthEncryption = "";
      MTAToast().ShowToast(e.toString());
    }
    return strAuthEncryption;
  }

  // ENHANCED: Clear loginInformation In file too (except GUID)
  Future<bool> ClearLoginInformationForLogOut() async {
    bool bResult = true;
    try {
      AuthLogin objLoginInfo = await InItAuthLogin(); // to retrieve old values
      
      // Keep the GUID but clear all login-related data
      String preservedGUID = objLoginInfo.UniqueID;
      String preservedDeviceInfo = objLoginInfo.DeviceInfo;
      ApplicationType preservedAppType = objLoginInfo.AppType;
      
      objLoginInfo.CompanyCode = "";
      objLoginInfo.LoginID = "";
      objLoginInfo.Password = "";
      objLoginInfo.CanGoForBiometricLogin = false;
      objLoginInfo.DoesBiometricUsedForLogin = false;
      objLoginInfo.Mode = LoginMode.Unknown;
      objLoginInfo.AuthEncryptedString = "";
      
      // Restore non-sensitive data
      objLoginInfo.UniqueID = preservedGUID;
      objLoginInfo.DeviceInfo = preservedDeviceInfo;
      objLoginInfo.AppType = preservedAppType;
      
      await SaveLoginInformationInTheFile(objLoginInfo); // to clear loginID and password
      print('Login information cleared for logout');
    } on Exception catch (e) {
      bResult = false;
      print('error caught during logout: $e');
    }
    return bResult;
  }

  // ENHANCED: Login Info after LogOut with fresh credential validation
  Future<AuthLogin> LoginInformationForFirstLogin(
      String strCompanyCode, String strLoginID, String strPassword) async {
    AuthLogin objLoginInfo = new AuthLogin(""); //GUID will not change
    bool bResult = true;

    try {
      print('Creating fresh login with - Company: $strCompanyCode, LoginID: $strLoginID');
      
      // IMPORTANT: Get fresh auth login to avoid any cached credentials
      objLoginInfo = await InItAuthLogin();
      
      // Clear any existing login data to ensure fresh start
      objLoginInfo.CompanyCode = "";
      objLoginInfo.LoginID = "";
      objLoginInfo.Password = "";
      objLoginInfo.CanGoForBiometricLogin = false;
      objLoginInfo.DoesBiometricUsedForLogin = false;
      objLoginInfo.Mode = LoginMode.Unknown;
      objLoginInfo.AuthEncryptedString = "";
      
      // Set new credentials
      objLoginInfo.CompanyCode = strCompanyCode;
      objLoginInfo.LoginID = strLoginID;
      objLoginInfo.Password = strPassword;
      objLoginInfo.Mode = LoginMode.Unknown;
      
      String strLoginInfoCombineString = objLoginInfo.LoginInfoCombineStringForAuth;
      await InItAuthEncryptedString(objLoginInfo); // to get Encryption string after value changed
      
      print('Fresh login info created with encrypted string length: ${objLoginInfo.AuthEncryptedString.length}');
    } on Exception catch (e) {
      bResult = false;
      print('error caught during first login: $e');
      MTAToast().ShowToast(e.toString());
    }
    return objLoginInfo;
  }

  // Login Info after LogOut for using Add new user
  // This function is used for adding employee via app , temporary out of development
  Future<AuthLogin> LoginInformationForFirstLoginViaApp() async {
    AuthLogin objLoginInfo = new AuthLogin(""); //GUID will not change
    bool bResult = true;
    try {
      /*objLoginInfo= await InItLoginInfo(); // to retreive old values along with GUID
      objLoginInfo.CompanyCode=objLoginInfo.AddNewLoginIDViaApp; // this logic will change in future
      objLoginInfo.LoginID=objLoginInfo.AddNewLoginIDViaApp; // this logic will change in future
      objLoginInfo.Password=objLoginInfo.AddNewPassIDViaApp;
      objLoginInfo.CanGoForBiometricLogin=false;
      objLoginInfo.DoesBiometricUsedForLogin=false;
      objLoginInfo.Mode=LoginMode.Employee;
      await InItAuthEncryptedString(objLoginInfo); // to get Encryption string
      */
    } on Exception catch (e) {
      bResult = false;
      print('error caught: $e');
    }
    return objLoginInfo;
  }

  //ENHANCED: Update File For successful attempt so next time logins info retrieve from file and go for biometric
  Future<AuthLogin> UpdateSuccessFullLoginInformation(String strCompanyCode,
      String strLoginID, String strPassword, LoginMode objLoginMode) async {
    AuthLogin objLoginInfo = new AuthLogin('');
    try {
      print('Updating successful login info for: $strCompanyCode - $strLoginID');
      
      objLoginInfo = await InItAuthLogin(); // to retrieve old values and other informations
      
      // Update with successful login credentials
      objLoginInfo.CompanyCode = strCompanyCode;
      objLoginInfo.LoginID = strLoginID;
      objLoginInfo.Password = strPassword;
      objLoginInfo.DoesBiometricUsedForLogin = false;
      objLoginInfo.CanGoForBiometricLogin = true; // Enable biometric for next time
      objLoginInfo.Mode = objLoginMode;
      
      // Update encryption string with new data
      await InItAuthEncryptedString(objLoginInfo);
      
      await SaveLoginInformationInTheFile(objLoginInfo);
      print('Successful login information saved');
    } on Exception catch (e) {
      print('error caught during successful login update: $e');
    }
    return objLoginInfo;
  }

  // ENHANCED: Validate stored credentials against current login attempt
  Future<bool> validateStoredCredentials(String strCompanyCode, String strLoginID) async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final strFileData = await FileInteraction().getDataFromFile(FileInteraction.MTAFileName);
        if (strFileData.toString().trim().length > 0) {
          Map<String, dynamic> valueMap = json.decode(strFileData);
          AuthLogin storedLoginInfo = AuthLogin.fromJson(valueMap);
          
          bool credentialsMatch = storedLoginInfo.CompanyCode == strCompanyCode && 
                                 storedLoginInfo.LoginID == strLoginID;
          
          print('Stored credentials validation:');
          print('- Stored Company: ${storedLoginInfo.CompanyCode}');
          print('- Current Company: $strCompanyCode');
          print('- Stored LoginID: ${storedLoginInfo.LoginID}');
          print('- Current LoginID: $strLoginID');
          print('- Match: $credentialsMatch');
          
          if (!credentialsMatch) {
            print('Credentials mismatch detected - clearing stored data');
            await ClearLoginInformationForLogOut();
          }
          
          return credentialsMatch;
        }
      }
      return true; // No stored data to validate against
    } catch (e) {
      print('Error validating stored credentials: $e');
      return false;
    }
  }

  /// ENHANCED: saving data in file with better error handling
  Future<bool> SaveLoginInformationInTheFile(AuthLogin objLoginInfo) async {
    bool bResult = true;
    try {
      // only for employee - mobile
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        String strJsonData = jsonEncode(objLoginInfo);
        await FileInteraction()
            .saveDataInFile(strJsonData, FileInteraction.MTAFileName);
        print('Login information saved to file: ${objLoginInfo.CompanyCode} - ${objLoginInfo.LoginID}');
      }
    } on Exception catch (e) {
      bResult = false;
      print('error caught while saving to file: $e');
    }
    return bResult;
  }
}