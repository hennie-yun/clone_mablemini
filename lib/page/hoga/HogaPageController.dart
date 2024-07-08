import 'dart:convert';

import 'package:get/get.dart';


import 'HogaData.dart';
import 'HogaData2.dart';
import 'Sise.dart';
import 'T1101.dart';
import 'CheData.dart';
import 'package:http/http.dart' as http;

class HogaPageController extends GetxController {
  /// 종목 코드
  var jmCode = ''.obs; //2024.02 벌고해 프로젝트_개편관련_김진겸 : 실시간 연결 전 통신 초기값 넣기, 원래는 공백
  var jmName = ''.obs; //2024.02 벌고해 프로젝트_개편관련_김진겸 : 실시간 연결 전 통신 초기값 넣기, 원래는 이 코드 없음
  var isFavorite = false.obs;

  /// 키보드
  var password = ''.obs;

  /// 통신
  Rx<Sise> sise = Sise().obs;
  //2024.02 벌고해 프로젝트_개편관련_김진겸 start
  //Rxsign = "5"<FHKST01010200Output> hoga = FHKST01010200Output().obs;
  ///Rx<T1101Output> hoga = T1101Output().obs;

  // 호가 실시간 데이터
  Rx<HogaData> hoga = HogaData().obs;

  // 호가 데이터
  Rx<HogaData2> hoga2 = HogaData2().obs;

  //2024.02 벌고해 프로젝트_개편관련_김진겸 end
  // Rx<TR1102> hogaInfo = TR1102().obs;
  //Rx<FHKST01010100Output> hogaInfo = FHKST01010100Output().obs;
  // Rx<TR1301> contract = TR1301(ctsTime: '', array: []).obs;
  //2024.02 김현중 벌고해 개편 st
  //Rx<FHPST01060000Output> contract = FHPST01060000Output(array: []).obs;
  Rx<CheData> contract = CheData(array: []).obs;
  //2024.02 김현중 벌고해 개편 en
  /// 현재가
  var currentPrice = ''.obs;

  /// 탭뷰
  var currentIndex = 0.obs;



  void init() {
    /// 종목 코드
    jmCode.value = ''; //2024.02 벌고해 프로젝트_개편관련_김진겸 : 실시간 연결 전 통신 초기값 넣기, 원래는 공백
    isFavorite.value = false;

    /// 키보드
    password.value = '';

    /// 통신
    ///sise.value = Sise();
    //2024.02 벌고해 프로젝트_개편관련_김진겸 start
    //hoga.value = FHKST01010200Output();
    //hoga.value = T1101Output();

    hoga.value = HogaData();
    //2024.02 벌고해 프로젝트_개편관련_김진겸 end
    //hogaInfo.value = FHKST01010100Output();
    //2024.02 김현중 벌고해 개편 st
    //contract.value = FHPST01060000Output(array: []);
   /// contract.value = T1301Output(array: []);
    //2024.02 김현중 벌고해 개편 en
    /// 현재가
    currentPrice.value = '';

  }
// 호가
  Future<HogaData> requestHoga() async {
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
        "SHCODE" : "005930"
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
      print('Request failed with status: ${response.statusCode}');
      throw Exception('Request failed with status: ${response.statusCode}');
    }
//return hogaData;
  }

  // 체결
  Future<CheData> requestChe() async {
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
        "FID_INPUT_ISCD" : "000660"
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
      print('Request failed with status: ${response.statusCode}');
      throw Exception('Request failed with status: ${response.statusCode}');
    }

  }

  void updateCheData(CheData newData) {
    contract.value = newData;
  }

  // 체결 실시간
  // void requestRealChe(String websocketKey) async {
  //   final url = 'http://203.109.30.207:10001/requestReal';
  //   final headers = {
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final body = jsonEncode({
  //     "header": {"sessionKey": websocketKey, "tr_type": "1"},
  //     "objCommInput": {"tr_id": "H0STCNT0", "tr_key": "000660"},
  //     "rqName": "",
  //     "trCode": "/tryitout/H0STCNT0"
  //   });
  //   final response =
  //   await http.post(Uri.parse(url), headers: headers, body: body);
  //
  //   if (response.statusCode == 200) {
  //     String decodedBody = utf8.decode(response.bodyBytes);
  //     var decodedJson = jsonDecode(decodedBody);
  //
  //     //contract.value.array.add(T1301Array.fromJson(decodedJson['Data']['output']));
  //     if(contract.value.array.length>30){
  //       contract.value.array.removeLast();
  //       contract.value.array.insert(0,T1301Array.fromJson(decodedJson['Data']['output']));
  //
  //     }else{
  //       contract.value.array.insert(0,T1301Array.fromJson(decodedJson['Data']['output']));
  //     }
  //   } else {
  //     print('Request failed with status: ${response.statusCode}');
  //   }
  // }
  // receiveH0STASP0(data) {
  //   try {
  //     // 서버로부터 수신된 데이터 처리
  //     var receivedData = jsonDecode(data.toString());
  //     if (receivedData['header']['tr_id'] != "PINGPONG") {
  //       List<String> decodedMessage = receivedData.split('|');
  //
  //       // 필요에 따라 Map에 저장
  //       Map<String, dynamic> resultMap = {
  //         'success': decodedMessage[0],
  //         'tr_id': decodedMessage[1],
  //         'code': decodedMessage[2],
  //         'data': decodedMessage[3],
  //         // ... 추가 필드들을 필요에 따라 계속 추가
  //       };
  //       _controller.hoga.value;
  //       List<String> JmMg = resultMap['data'].split('^');
  //
  //       Map<String, String> jmData = {
  //         'jmCode': JmMg[0], //종목코드
  //         'askp1': JmMg[3], //매도호가
  //         'askp2': JmMg[4], //매도호가
  //         'askp3': JmMg[5], //매도호가
  //         'askp4': JmMg[6], //매도호가
  //         'askp5': JmMg[7], //매도호가
  //         'askp6': JmMg[8], //매도호가
  //         'askp7': JmMg[9], //매도호가
  //         'askp8': JmMg[10], //매도호가
  //         'askp9': JmMg[11], //매도호가
  //         'askp10': JmMg[12], //매도호가
  //         'bidp1': JmMg[13], //매수호가
  //         'bidp2': JmMg[14], //매수호가
  //         'bidp3': JmMg[15], //매수호가
  //         'bidp4': JmMg[16], //매수호가
  //         'bidp5': JmMg[17], //매수호가
  //         'bidp6': JmMg[18], //매수호가
  //         'bidp7': JmMg[19], //매수호가
  //         'bidp8': JmMg[20], //매수호가
  //         'bidp9': JmMg[21], //매수호가
  //         'bidp10': JmMg[22], //매수호가
  //         'askp_rsqn1': JmMg[23], //매도호가 잔량
  //         'askp_rsqn2': JmMg[24], //매도호가 잔량
  //         'askp_rsqn3': JmMg[25], //매도호가 잔량
  //         'askp_rsqn4': JmMg[26], //매도호가 잔량
  //         'askp_rsqn5': JmMg[27], //매도호가 잔량
  //         'askp_rsqn6': JmMg[28], //매도호가 잔량
  //         'askp_rsqn7': JmMg[29], //매도호가 잔량
  //         'askp_rsqn8': JmMg[30], //매도호가 잔량
  //         'askp_rsqn9': JmMg[31], //매도호가 잔량
  //         'askp_rsqn10': JmMg[32], //매도호가 잔량
  //         'bidp_rsqn1': JmMg[33], //매수호가 잔량
  //         'bidp_rsqn2': JmMg[34], //매수호가 잔량
  //         'bidp_rsqn3': JmMg[35], //매수호가 잔량
  //         'bidp_rsqn4': JmMg[36], //매수호가 잔량
  //         'bidp_rsqn5': JmMg[37], //매수호가 잔량
  //         'bidp_rsqn6': JmMg[38], //매수호가 잔량
  //         'bidp_rsqn7': JmMg[39], //매수호가 잔량
  //         'bidp_rsqn8': JmMg[40], //매수호가 잔량
  //         'bidp_rsqn9': JmMg[41], //매수호가 잔량
  //         'bidp_rsqn10': JmMg[42], //매수호가 잔량
  //         'TOTAL_ASKP_RSQN': JmMg[43], //총 매도호가 잔량
  //         'TOTAL_BIDP_RSQN': JmMg[44], //총 매수호가 잔량
  //         // ... 추가 필드들을 필요에 따라 계속 추가
  //       };
  //
  //       _controller.hoga.value; // 이 부분에서 hoga 데이터 처리 코드 추가 필요
  //     } else {}
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}


