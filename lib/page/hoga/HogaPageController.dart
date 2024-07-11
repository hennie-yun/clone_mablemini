import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../comm/SiseData.dart';
import '../fav/FavPageController.dart';
import 'HogaData.dart';
import 'HogaData2.dart';
import 'CheData.dart';
import 'package:http/http.dart' as http;

class HogaPageController extends GetxController {

  // /// 종목 코드
  // var jmCode = ''.obs;
  // var jmName = ''.obs;
  // var isFavorite = false.obs;
  //
  // /// 키보드
  // var password = ''.obs;

  // /// 통신
  // Rx<Sise> sise = Sise().obs;
  final FavPageController _fevController = Get.find<FavPageController>();

  // 종목 코드
  RxList selectedJm = [].obs;

  // 호가 데이터
  Rx<HogaData> hoga = HogaData().obs;

  // 현재가 데이터
  Rx<HogaData2> hoga2 = HogaData2().obs;

  // 체결 데이터
  Rx<CheData> contract = CheData(array: []).obs;

  // 현재가
  // var siseList = [].obs;

  /// 현재가
  var currentPrice = ''.obs;
  var websocketKey = ''.obs;

//Rx<WebSocketChannel?> webSocketChannel = null.obs;
//   var webSocketChannel = Rxn<WebSocketChannel>();

  // /// 탭뷰
  // var currentIndex = 0.obs;




  void init() {
    // /// 종목 코드
    // jmCode.value = '';
    // isFavorite.value = false;
    //
    // /// 키보드
    // password.value = '';


    hoga.value = HogaData();

    /// 현재가
    currentPrice.value = '';

  }
// 호가
  Future<HogaData> requestHoga(String jmCode) async {
    //체결 데이터를 다 받고 난 뒤
    //CheData t1301Output = await requestChe();

    //HogaData hogaData = HogaData();
    final url = 'http://203.109.30.207:10001/request';
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "header": {
        "tr_id" : ""
      },
      "objCommInput": {
        "SHCODE" : jmCode
      },
      "rqName": "",
      "trCode": "/uapi/domestic-stock/v1/quotations/S0003"
    });
    final response = await http.post(Uri.parse(url),headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      String decodedBody = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(decodedBody);
      hoga.value  = HogaData.fromJSON(decodedJson['Data']['output']);
      HogaData hogaData = HogaData.fromJSON(decodedJson['Data']['output']);
      return hogaData;
    }else {
      print('requestHoga failed with status: ${response.statusCode}');
      throw Exception('Request failed with status: ${response.statusCode}');
    }
//return hogaData;
  }

  // 체결
  Future<CheData> requestChe(String jmCode) async {
    final url = 'http://203.109.30.207:10001/request';
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "header": {
        "tr_id" : ""
      },
      "objCommInput": {
        "FID_COND_MRKT_DIV_CODE" : "J",
        "FID_INPUT_ISCD" : jmCode
      },
      "rqName": "",
      "trCode":"/uapi/domestic-stock/v1/quotations/inquire-ccnl"
    });
    final response = await http.post(Uri.parse(url),headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      String decodedBody = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(decodedBody);

     //contract.value.array.add(T1301Array.fromJson(decodedJson['Data']['output']));
      contract.value = CheData.fromJSON(decodedJson['Data']['output']);
      CheData t1301Output = CheData.fromJSON(decodedJson['Data']['output']);
      return t1301Output;


    }else {
      print('requestChe failed with status: ${response.statusCode}');
      throw Exception('Request failed with status: ${response.statusCode}');
    }

  }

  // 현재가
  void requestPRPR(String jmCode) async {
    final url = 'http://203.109.30.207:10001/request';
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'header': {"tr_id": ""},
      'objCommInput': {"SHCODE":jmCode},
      'rqName': '',
      'trCode': "/uapi/domestic-stock/v1/quotations/S0004"
    });
    final response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      String decodedBody = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(decodedBody);
      hoga2.value =
          HogaData2.fromJSON(decodedJson['Data']['output'], jmCode);
      currentPrice.value = hoga2.value.price ?? '0';
    } else {
      print('requestPRPR failed with status: ${response.statusCode}');
    }
  }

  void updateCheData(CheData newData) {
    contract.value = newData;
  }
//
//   void setupWebSocket(bool? boolValue) async {
//     try {
//       if(websocketKey.value != ''){
//        webSocketChannel.value!.sink.close();
//        webSocketChannel.value = null;
//       }
//
//
//       webSocketChannel.value = WebSocketChannel.connect(
//           Uri.parse('ws://203.109.30.207:10001/connect'));
//
//       webSocketChannel.value?.stream.listen((message) async {
//         try {
//           final data = jsonDecode(message);
//           if (data['Data'] != null && data['Data']['websocketkey'] != null) {
//             websocketKey.value = data['Data']['websocketkey'];
//             print('WebSocket Key: $websocketKey');
//             requestRealHoga(websocketKey.value, selectedJm[0], boolValue);
//             //requestRealChe(_websocketKey,selectedJm[0]);
//
//             await requestReal(websocketKey.value, selectedJm[0],boolValue);
//           } else {
//             if (data['TrCode'] == "H0STCNT0") {
//               siseList.clear();
//               String STCK_PRPR = data['Data']['STCK_PRPR'] ?? '';
//               String PRDY_VRSS_SIGN = data['Data']['PRDY_VRSS_SIGN'] ?? '';
//               String PRDY_VRSS = data['Data']['PRDY_VRSS'] ?? '';
//               String PRDY_CTRT = data['Data']['PRDY_CTRT'] ?? '';
//
//               SiseData newData = SiseData(
//                 STCK_PRPR: STCK_PRPR,
//                 PRDY_VRSS_SIGN: PRDY_VRSS_SIGN,
//                 PRDY_VRSS: PRDY_VRSS,
//                 PRDY_CTRT: PRDY_CTRT,
//                 JmName: selectedJm[1],
//               );
//
//               siseList.add(newData);
//
//
//               currentPrice.value =
//                   siseList[0].STCK_PRPR;
//               contract.value.array
//                   .insert(0, CheDataArray.fromJson(data['Data']));
//              ///
//              // cheFlag = true;
//
//               //realCtngVolColor(_hogaController.contract.value.array.first.volume);
//               if (contract.value.array.length >= 30) {
//                contract.value.array.removeLast();
//               }
//             }
//             if (data['TrCode'] == "H0STASP0") {
//               hoga.value = HogaData.fromJSON(data['Data']);
//             }
//
//             if (data['trKey'] == '031860') {
//               var rushData = jsonDecode(data['output']);
//
//               // 호가 러쉬테스트
//               if (rushData['TrCode'] == "H0STASP0") {
//                 if (rushData != null && rushData['Data'] != null) {
//                   print(data['num']);
//                   hoga.value =
//                       HogaData.fromJSON(rushData['Data']);
//
//                   print('호가 rushtest');
//                 }
//               }
//
//               // 체결 러쉬테스트
//               if (rushData['TrCode'] == "H0STCNT0") {
//                 if (rushData != null && rushData['Data'] != null) {
//                   print(data['num']);
//                   siseList.clear();
//                   String STCK_PRPR = rushData['Data']['STCK_PRPR'] ?? '';
//                   String PRDY_VRSS_SIGN =
//                       rushData['Data']['PRDY_VRSS_SIGN'] ?? '';
//                   String PRDY_VRSS = rushData['Data']['PRDY_VRSS'] ?? '';
//                   String PRDY_CTRT = rushData['Data']['PRDY_CTRT'] ?? '';
//
//                   SiseData newData = SiseData(
//                     STCK_PRPR: STCK_PRPR,
//                     PRDY_VRSS_SIGN: PRDY_VRSS_SIGN,
//                     PRDY_VRSS: PRDY_VRSS,
//                     PRDY_CTRT: PRDY_CTRT,
//                     JmName: selectedJm[1],
//                   );
//
//                   siseList.add(newData);
//
//                   currentPrice.value =
//                      siseList[0].STCK_PRPR;
//                  contract.value.array
//                       .insert(0, CheDataArray.fromJson(rushData['Data']));
//                   if (contract.value.array.length >= 30) {
//                     contract.value.array.removeLast();
//                   }
//
//                   print('체결 rushtest');
//                 }
//               }
//             }
//           }
//         } catch (e) {
//           print('Error processing WebSocket message: $e');
//         }
//       }, onError: (error) {
//         print('WebSocket error: $error');
//       }, onDone: () {
//         print('WebSocket connection closed');
//       });
//     } catch (e) {
//       print('WebSocket connection error: $e');
//     }
//   }
//
//   Future<void> requestData(String value, bool boolValue) async {
//     print(value);
//     final headers = {'Content-Type': 'application/json;charset=utf-8'};
//     final body = jsonEncode({
//       "trCode": "/uapi/domestic-stock/v1/quotations/S0004",
//       "rqName": "",
//       "header": {"tr_id": "1"},
//       "objCommInput": {"SHCODE": value}
//     });
//
//     final response = await http.post(
//       Uri.parse('http://203.109.30.207:10001/request'),
//       headers: headers,
//       body: body,
//     );
//
//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       if (responseData['TrCode'] ==
//           "/uapi/domestic-stock/v1/quotations/S0004") {
//         SiseData siseData =
//         SiseData.fromJson(responseData["Data"]["output"], value);
//         print(siseData);
//         siseList.add(siseData);
//       }
//     } else {
//       print('Request failed with status: ${response.statusCode}');
//     }
//
//     setupWebSocket(boolValue);
//   }
//
//   Future<void> requestReal(String websocketKey, String jmCode, boolValue) async {
//     final headers = {'Content-Type': 'application/json;charset=utf-8'};
//
//     var url;
//     var body;
//
//     if(boolValue == false) {
//        url = 'http://203.109.30.207:10001/requestReal';
//        body = jsonEncode({
//         "trCode": "/uapi/domestic-stock/v1/quotations/requestReal",
//         "rqName": "",
//         "header": {"sessionKey": websocketKey, "tr_type": "1"},
//         "objCommInput": {"tr_key": jmCode, "tr_id": "H0STCNT0"}
//       });
//     }else {
//       // 체결 러쉬테스트
//        url = 'http://203.109.30.207:10001/rushtest';
//        body = jsonEncode({
//         "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
//         "rqName": "",
//         "header": {"sessionKey": websocketKey, "tr_type": "1"},
//         "objCommInput": {"count": "2", "tr_id": "H0STCNT0"}
//       });
//     }
//     final response =
//     await http.post(Uri.parse(url), headers: headers, body: body);
//
//     if (response.statusCode == 200) {
//     } else {
//       print('Request failed with status: ${response.statusCode}');
//     }
//   }
// // 호가 실시간
//   Future<void> requestRealHoga(String websocketKey, String jmCode, boolValue) async {
//     final headers = {
//       'Content-Type': 'application/json',
//     };
//
//     var url;
//     var body;
//
//     if(boolValue == false) {
//       url = 'http://203.109.30.207:10001/requestReal';
//       body = jsonEncode({
//         'header': {'sessionKey': websocketKey, 'tr_type': '1'},
//         'objCommInput': {"tr_id": "H0STASP0", 'tr_key': jmCode},
//         'rqName': '',
//         'trCode': '/uapi/domestic-stock/v1/quotations/requestReal',
//       });
//     }else{
//       //러쉬테스트용
//       url = 'http://203.109.30.207:10001/rushtest';
//       body = jsonEncode({
//         "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
//         "rqName": "",
//         "header": {"sessionKey": websocketKey, "tr_type": "1"},
//         "objCommInput": {"count": "2", "tr_id": "H0STASP0"}
//       });
//     }
//
//
//     final response =
//     await http.post(Uri.parse(url), headers: headers, body: body);
//
//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       String decodedBody = utf8.decode(response.bodyBytes);
//       var decodedJson = jsonDecode(decodedBody);
//     } else {
//       print('Request failed with status: ${response.statusCode}');
//     }
//   }
//
//   // 체결 실시간
//   void requestRealChe(String websocketKey, String jmCode) async {
//     final headers = {
//       'Content-Type': 'application/json',
//     };
//
//     var url;
//     var body;
//
//     if(_fevController.isRushTest.value == false) {
//       url = 'http://203.109.30.207:10001/requestReal';
//       body = jsonEncode({
//         "header": {"sessionKey": websocketKey, "tr_type": "1"},
//         "objCommInput": {"tr_id": "H0STCNT0", "tr_key": jmCode},
//         "rqName": "",
//         "trCode": "/uapi/domestic-stock/v1/quotations/requestReal"
//       });
//     }else{
//       // 러쉬테스트
//       url = 'http://203.109.30.207:10001/rushtest';
//       body = jsonEncode({
//         "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
//         "rqName": "",
//         "header": {"sessionKey": websocketKey, "tr_type": "1"},
//         "objCommInput": {"count": "2", "tr_id": "H0STCNT0"}
//       });
//     }
//
//     final response =
//     await http.post(Uri.parse(url), headers: headers, body: body);
//
//     if (response.statusCode == 200) {
//       String decodedBody = utf8.decode(response.bodyBytes);
//       var decodedJson = jsonDecode(decodedBody);
//     } else {
//       print('Request failed with status: ${response.statusCode}');
//     }
//   }
}


