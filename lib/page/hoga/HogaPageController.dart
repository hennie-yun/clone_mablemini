import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../comm/SiseData.dart';
import '../fav/FavPageController.dart';
import '../../comm/HogaData.dart';
import '../../comm/HogaData2.dart';
import '../../comm/CheData.dart';
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
  void requestHoga(String jmCode) async {
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

      HogaData hogaData = HogaData();
      if(decodedJson['Data']['output'] != null) {
        hoga.value = HogaData.fromJSON(decodedJson['Data']['output']);
        // hogaData = HogaData.fromJSON(decodedJson['Data']['output']);
      }
      // return hogaData;
    }else {
      print('requestHoga failed with status: ${response.statusCode}');
      throw Exception('Request failed with status: ${response.statusCode}');
    }
//return hogaData;
  }

  // 체결
  void requestChe(String jmCode) async {
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
      // CheData t1301Output = CheData.fromJSON(decodedJson['Data']['output']);
      // return t1301Output;


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

}


