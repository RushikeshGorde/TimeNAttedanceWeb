import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:time_attendance/Data/LoginInformation/AuthLogin.dart';
import 'package:time_attendance/Data/LoginInformation/AuthLoginInfoDetails.dart';
import 'package:time_attendance/Data/ServerInteration/Result.dart';
import 'package:time_attendance/General/MTAInternetConnectivity.dart';
import 'package:time_attendance/model/TALogin/LoginDetails.dart';
import 'package:time_attendance/model/TALogin/login.dart';
import 'package:time_attendance/widgets/mtaToast.dart';
import 'package:time_attendance/model/TALogin/session_manager.dart'
    if (dart.library.html) 'package:time_attendance/model/TALogin/session_manager_web.dart'
    if (dart.library.io) 'package:time_attendance/model/TALogin/session_manager_mobile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController txtCompanyCode = TextEditingController();
  final TextEditingController txtLoginID = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();

  // Password visibility toggle
  bool passwordVisible = true;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    // Clear any existing session when login page loads
    _clearExistingSession();
  }

  // NEW: Clear existing session data
  Future<void> _clearExistingSession() async {
    try {
      await PlatformSessionManager.clearSession();
      print('Previous session cleared');
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  // Validation function for company code
  String? _validateCompanyCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company Code is required';
    }

    // Check if company code is exactly 3 characters long
    if (value.length != 3) {
      return 'Company Code must be 3 characters long';
    }

    // Check if company code is alphanumeric
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Company Code must be alphanumeric';
    }

    return null;
  }

  // Validation function for login ID
  String? _validateLoginID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Login ID is required';
    }

    // You can add more specific validation if needed
    // For example, minimum length, allowed characters, etc.
    if (value.length < 3) {
      return 'Login ID must be at least 3 characters long';
    }

    return null;
  }

  // Validation function for password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Password strength validation
    if (value.length < 4) {
      return 'Password must be at least 4 characters long';
    }

    // Optional: Add more complex password validation
    // For example, require at least one uppercase, one lowercase, one number
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    //   return 'Password must include uppercase, lowercase, and number';
    // }

    return null;
  }

  // UPDATED: Login method with comprehensive validation and session clearing
  Future<void> _performLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // IMPORTANT: Clear any existing session before new login
      await PlatformSessionManager.clearSession();
      print('Session cleared before new login attempt');

      // Check internet connectivity
      if (!kIsWeb) {
        bool bConnectivity =
            await MTAInternetConnectivity().isConnectedToInternet();
        if (!bConnectivity) {
          MTAToast().ShowToast('No internet connectivity');
          return;
        }
      }

      // Perform login process
      String strCompanyCode = txtCompanyCode.text.trim().toUpperCase();
      String strLoginID = txtLoginID.text.trim();
      String strPassword = txtPassword.text;

      print('Attempting login with:');
      print('Company Code: $strCompanyCode');
      print('Login ID: $strLoginID');

      // First login information retrieval
      AuthLogin objLoginInfo = await AuthLoginDetails()
          .LoginInformationForFirstLogin(
              strCompanyCode, strLoginID, strPassword);

      print('Login Info Object >> ${objLoginInfo.toJson()}');
      
      // Get login details
      Result objResult = await LoginDetails().GetLogin(objLoginInfo); 
      print('Login Details >> ${objResult.toJson()}');
      
      if (objResult.IsResultPass) {
        // Save current user info immediately after successful login
        await PlatformSessionManager.saveUserInfo(objLoginInfo.toJson());
        
        print('Login successful, processing result...');
        print('Login Result Mode: ${objResult.Mode}');
        print('LoginMode.UserForAPI: ${LoginMode.UserForAPI}');
        print('Compare of modes: ${objResult.Mode == LoginMode.UserForAPI}');
        
        if (objResult.Mode == LoginMode.UserForAPI) {
          String strJson = objResult.ResultRecordJson;
          Map<String, dynamic> valueMap = json.decode(strJson);
          Login objLogin = Login.fromJson(valueMap);
          print('Login Object >> ${objLogin.toJson()}');
          
          // Save all session data in sequence
          await PlatformSessionManager.saveLoginInfo(
              valueMap['CurrentUserLoginForAPI']);  
          await PlatformSessionManager.saveAuthMode(objResult.Mode);
          await PlatformSessionManager.saveAuthLoginInfo(objLoginInfo);
          
          // Verify saved data
          final authStr = await PlatformSessionManager.getAuthLoginInfo();
          final loginInfo = await PlatformSessionManager.getLoginInfo();
          print('Saved Auth Login Info: $authStr');
          print('Saved Login Info: $loginInfo');
          
          MTAToast().ShowToast('Login Successful');
          
          // Navigate to home
          if (mounted) {
            context.go('/home');
          }
          
        } else if (objResult.Mode == LoginMode.Employee) {
          AuthLogin updatedLoginInfo = await AuthLoginDetails()
              .UpdateSuccessFullLoginInformation(
                  strCompanyCode, strLoginID, strPassword, objResult.Mode);
          
          // Save employee session data
          await PlatformSessionManager.saveAuthMode(objResult.Mode);
          await PlatformSessionManager.saveAuthLoginInfo(updatedLoginInfo);
          
          MTAToast().ShowToast('Login Successful');
          
          // Navigate to home
          if (mounted) {
            context.go('/home');
          }
        }
      } else {
        // Clear session on failed login
        await PlatformSessionManager.clearSession();
        MTAToast().ShowToast(objResult.ResultMessage.toString());
      }
    } catch (e) {
      // Clear session on error
      await PlatformSessionManager.clearSession();
      MTAToast().ShowToast('Login Error: ${e.toString()}');
      print('Login Error: $e');
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    txtCompanyCode.dispose();
    txtLoginID.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: SizedBox(
              width: screenWidth > 600
                  ? 400
                  : screenWidth * 0.8, // Adjust width based on screen size
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        height: screenHeight *
                            0.06), // Adjust height proportionally
                    Container(
                      width: screenWidth * 0.6, // Adjust width proportionally
                      height:
                          screenHeight * 0.2, // Adjust height proportionally
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/company_logo.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.09), // A
                    // Company Code TextField
                    TextFormField(
                      controller: txtCompanyCode,
                      validator: _validateCompanyCode,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3),
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                      ],
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        hintText: "Company Code",
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                        prefixIcon: Icon(Icons.business,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.03), // Adjust height proportionally

                    // Login ID TextField
                    TextFormField(
                      controller: txtLoginID,
                      validator: _validateLoginID,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      decoration: InputDecoration(
                        hintText: "Login ID",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                        prefixIcon: Icon(Icons.person,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.02), // Adjust height proportionally

                    // Password TextField
                    TextFormField(
                      controller: txtPassword,
                      validator: _validatePassword,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      obscureText: passwordVisible,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2)),
                          prefixIcon: Icon(Icons.lock_open,
                              color: Theme.of(context).colorScheme.primary),
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              }
                            },
                          )),
                    ),

                    SizedBox(
                        height: screenHeight *
                            0.05), // Adjust height proportionally

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.all(10)),
                          onPressed: _performLogin,
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          )),
                    ),

                    SizedBox(
                        height: screenHeight *
                            0.02), // Adjust height proportionally
                    Text(
                      'Powered By Insignia E Security Pvt Ltd',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}