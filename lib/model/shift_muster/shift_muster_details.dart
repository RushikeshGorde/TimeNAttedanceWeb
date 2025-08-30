import 'dart:convert';
import '../../Data/LoginInformation/AuthLogin.dart';
import '../../Data/LoginInformation/Constants.dart';
import '../../Data/ServerInteration/APIIntraction.dart';
import '../../Data/ServerInteration/Result.dart';
import '../../General/MTAResult.dart';
import 'shift_muster_model.dart';

class ShiftMusterDetails {
  Future<ShiftMusterResponse>
      getEmployeeShiftMusterByEmployeeViewStartNEndDate({
    required AuthLogin objAuthLogin,
    required ShiftMusterRequest request,
    required MTAResult objMTAResult,
  }) async {
    ShiftMusterResponse response = ShiftMusterResponse();
    List<EmployeeShiftMusterModel> musterList = [];
    try {
      String strSearchJson = jsonEncode(request.toJson());
      strSearchJson = '?strSearchJson=$strSearchJson';
      Result objResult = await APIInteraction().GetObjectByObjectID(
        objAuthLogin,
        strSearchJson,
        "${ApiConstants.endpoint_ShiftMuster}/GetEmployeeShiftByEmployeeViewStartNEndDateInRange",
      );
      objMTAResult.IsResultPass = objResult.IsResultPass;
      objMTAResult.ResultMessage = objResult.ResultMessage;
      if (objResult.IsResultPass) {
        if (objResult.IsMultipleRecordsInJson) {
          musterList = parseMusterList(objResult.ResultRecordJson);
          response.isMultipleRecordsInJson = objResult.IsMultipleRecordsInJson;
          response.isResultPass = objResult.IsResultPass;
          response.totalRecordCount = objResult.TotalRecordCount;
          response.resultMessage = objResult.ResultMessage;
          response.musterList = musterList;
        }
      }
    } catch (e) {
      musterList = [];
    }
    return response;
  }

  List<EmployeeShiftMusterModel> parseMusterList(String responseBody) {
    try {
      final parsed =
          (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();
      return parsed
          .map<EmployeeShiftMusterModel>(
              (json) => EmployeeShiftMusterModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<EmpTemporaryShiftBulkResponse> bulkTemporaryShift(
    AuthLogin objAuthLogin,
    List<EmpTemporaryShiftBulkRequest> requests,
  ) async {
    EmpTemporaryShiftBulkResponse response = EmpTemporaryShiftBulkResponse();
    try {
      String strJson = jsonEncode(requests.map((e) => e.toJson()).toList());
      Result objResult = await APIInteraction().Save(
        objAuthLogin,
        strJson,
        "${ApiConstants.endpoint_EmpTemporaryShift}/Bulk",
      );
      if (objResult.IsResultPass) {
        print(objResult.toJson());
        response = EmpTemporaryShiftBulkResponse.fromJson(objResult.toJson());
        print(response);
      } else {
        response.resultMessage = objResult.ResultMessage;
        response.isResultPass = false;
      }
    } catch (e) {
      response.isResultPass = false;
      response.resultMessage = e.toString();
    }
    return response;
  }
}
