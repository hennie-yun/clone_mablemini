import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../comm/SiseData.dart';

import '../../manager/GlobalController.dart';
import '../price/PricePage.dart';
import 'FavPageController.dart';

class FavPage extends StatelessWidget {
  final FavPageController _controller = Get.put(FavPageController());

  // late WebSocketChannel _webSocketChannel;
  late String _websocketKey;

  FavPage() {
    _controller.init();
    requestData();
  }

  void setupWebSocket() async {
    final GlobalController _globalController = Get.find<GlobalController>();

    var isRushTest = _globalController.isRushTest.value;

    try {
      _globalController.favWebSocketChannel.value = WebSocketChannel.connect(
          Uri.parse('ws://203.109.30.207:10001/connect'));

      _globalController.favWebSocketChannel.value?.stream.listen(
          (message) async {
        try {
          final data = jsonDecode(message);
          if (data['Data'] != null && data['Data']['websocketkey'] != null) {
            _websocketKey = data['Data']['websocketkey'];
            print('WebSocket Key: $_websocketKey');
            isRushTest
                ? await _requestRush(_websocketKey)
                : await _requestReal(_websocketKey);
          } else {
            if (data['TrCode'] != null && data['TrCode'] == "H0STCNT0") {
              _controller.isRequest.value = true;

              String STCK_PRPR = data['Data']['STCK_PRPR'] ?? '';
              String PRDY_VRSS_SIGN = data['Data']['PRDY_VRSS_SIGN'] ?? '';
              String PRDY_VRSS = data['Data']['PRDY_VRSS'] ?? '';
              String PRDY_CTRT = data['Data']['PRDY_CTRT'] ?? '';

              String jmCodeToUpdate = data['Data']['MKSC_SHRN_ISCD']; //종목코드
              String? jmNameToUpdate; // 이름 삽입

              for (int i = 0; i < _controller.jmCodes.length; i++) {
                if (_controller.jmCodes[i]['jmCode'] == jmCodeToUpdate) {
                  jmNameToUpdate = _controller.jmCodes[i]['jmName'];
                  break;
                }
              }

              for (int i = 0; i < _controller.siseList.length; i++) {
                if (_controller.siseList[i].JmName == jmNameToUpdate) {
                  _controller.siseList[i] = SiseData(
                    STCK_PRPR: STCK_PRPR,
                    PRDY_VRSS_SIGN: PRDY_VRSS_SIGN,
                    PRDY_VRSS: PRDY_VRSS,
                    PRDY_CTRT: PRDY_CTRT,
                    JmName: _controller.siseList[i].JmName,
                  );
                  break;
                }
              }
            } else {
              // 러쉬테스트 용 -> 안에 데이터값 이름 뭔지 몰라서 데이터 정확하지 않음
              var outputString = data['output'];
              Map<String, dynamic> outputData = json.decode(outputString);

              // trKey 가 null 이 아니면 rush 테스트임
              if (data["trKey"] != null) {
                String? trCode;

                if (outputData.containsKey('TrCode')) {
                  trCode = outputData['TrCode'].toString();
                }

                if (trCode == "H0STCNT0") {
                  String STCK_PRPR =
                      outputData['Data']['STCK_PRPR'].toString(); // 현재가
                  String PRDY_VRSS_SIGN = outputData['Data']['PRDY_VRSS_SIGN']
                      .toString(); // 등락기호 표시용
                  String PRDY_VRSS = outputData['Data']['OPRC_VRSS_PRPR']
                      .toString(); // 전일대비 가격
                  String PRDY_CTRT = outputData['Data']
                          ['PRDY_VOL_VRSS_ACML_VOL_RATE']
                      .toString(); // 몇프로

                  for (int i = 0; i < _controller.siseList.length; i++) {
                    // 현재 종목코드와 러쉬테스트 데이터의 종목코드가 같을 경우만 업데이트.
                    if(data['trKey'] == _controller.jmCodes[i]['jmCode']) {
                      print ('%%%%%%%%%%%%% ${data['trKey']}  ${_controller.jmCodes[i]['jmCode']} -> ${_controller.jmCodes[i]['jmName']} ' );
                      _controller.siseList[i] = SiseData(
                        STCK_PRPR: STCK_PRPR,
                        PRDY_VRSS_SIGN: PRDY_VRSS_SIGN,
                        PRDY_VRSS: PRDY_VRSS,
                        PRDY_CTRT: PRDY_CTRT,
                      );
                    }
                  }
                }
              }
            }

            // <<<<<<<<<<<<<<<<<<<<<러쉬테스트용
          }
        } catch (e) {
          print('Error processing WebSocket message: $e');
        }
      }, onError: (error) {
        print('WebSocket error: $error');
      }, onDone: () {
        print('WebSocket connection closed');
      });
    } catch (e) {
      print('WebSocket connection error: $e');
    }
  }

  void requestData() {
    List<SiseData?> newDataList = List.filled(_controller.jmCodes.length, null);
    List<Future> futures = [];

    for (int i = 0; i < _controller.jmCodes.length; i++) {
      final headers = {'Content-Type': 'application/json;charset=utf-8'};
      final body = jsonEncode({
        "trCode": "/uapi/domestic-stock/v1/quotations/S0004",
        "rqName": "",
        "header": {"tr_id": "1"},
        "objCommInput": {"SHCODE": _controller.jmCodes[i]["jmCode"]}
      });

      Future future = http.post(
        Uri.parse('http://203.109.30.207:10001/request'),
        headers: headers,
        body: body,
      ).then((response) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['TrCode'] == "/uapi/domestic-stock/v1/quotations/S0004") {
            SiseData siseData = SiseData.fromJson(
              responseData["Data"]["output"],
              _controller.jmCodes[i]["jmName"]!,
            );
            newDataList[i] = siseData;
          }
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      });

      futures.add(future);
    }

    Future.wait(futures).then((_) {
      _controller.siseList.assignAll(newDataList.where((element) => element != null).cast<SiseData>());
      setupWebSocket();
    });
  }



  Future<void> _requestRush(String websocketKey) async {
    final headers = {'Content-Type': 'application/json;charset=utf-8'};
    final rushUrl = 'http://203.109.30.207:10001/rushtest';
    final rushBody = jsonEncode({
      "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
      "rqName": "",
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"count": "2", "tr_id": "HOSTCNTO"}
    });

    http.Response response;

    response =
        await http.post(Uri.parse(rushUrl), headers: headers, body: rushBody);
    if (response.statusCode == 200) {
    } else {
      print('Rush test request failed with status: ${response.statusCode}');
      Get.find<GlobalController>().isRushTest.value = false;
    }
  }

  // 실시간 요청
  Future<void> _requestReal(String websocketKey) async {
    final headers = {'Content-Type': 'application/json;charset=utf-8'};
    http.Response response;
    for (int i = 0; i < _controller.jmCodes.length; i++) {
      final url = 'http://203.109.30.207:10001/requestReal';
      final body = jsonEncode({
        "trCode": "/uapi/domestic-stock/v1/quotations/requestReal",
        "rqName": "",
        "header": {"sessionKey": websocketKey, "tr_type": "1"},
        "objCommInput": {
          "tr_key": _controller.jmCodes[i]["jmCode"],
          "tr_id": "H0STCNT0"
        }
      });

      response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
      } else {
        print('RequestReal request failed with status: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var isRushTest = Get.find<GlobalController>().isRushTest.value;

    return Scaffold(body: Obx(() {
      return ListView.builder(
        itemCount: _controller.siseList.length,
        itemBuilder: (context, index) {
          final siseData = _controller.siseList[index];
          return GestureDetector(
            onTap: () {
              Get.find<GlobalController>().setCurrWidget(
                PricePage(
                  _controller.jmCodes[index]['jmCode']!,
                  _controller.jmCodes[index]['jmName']!,
                ),
              );
              Get.find<GlobalController>().setSelectecJm(
                  _controller.jmCodes[index]['jmCode']!,
                  _controller.jmCodes[index]['jmName']!,
                  siseData
                // _controller.siseList[index]
              );

              Get.find<GlobalController>().selectedIndex.value = 1; // 인덱스 설정
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              height: 72,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.asset('assets/images/mmini.png'),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      isRushTest || siseData.JmName == null
                          ? _controller.jmCodes[index]["jmName"]!
                          : siseData.JmName!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${formatNumber(int.parse(siseData.STCK_PRPR))}원',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      makePrice(
                        siseData.PRDY_VRSS,
                        siseData.PRDY_CTRT,
                        siseData.PRDY_VRSS_SIGN,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

    }));
  }
}

String formatNumber(int number) {
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}

String sign = '';

Widget makePrice(String prc, String prct, String updwn) {
  Color updwnColor = updownColor(updwn);
  if (prc.contains("-") || prct.contains("-")) {
    prc = prc.replaceAll("-", ""); // '-' 기호 제거
    prct = prct.replaceAll("-", ""); // '-' 기호 제거
  }

  return Row(children: [
    Text(sign, style: TextStyle(color: updwnColor, fontSize: 12)),
    Text('${formatNumber(int.parse('$prc'))}원',
        style: TextStyle(color: updwnColor, fontSize: 12)),
    Text(' ($prct%)', style: TextStyle(color: updwnColor, fontSize: 12)),
  ]);
}

Color updownColor(String updwn) {
  var updown = int.parse(updwn);

  if (updown < 3) {
    sign = '▲ ';
    return const Color(0xFFF24430);
  } else if (updown == 3) {
    sign = "";
    return const Color(0xFF50505B);
  } else {
    sign = '▼ ';
    return const Color(0xFF4881FF);
  }
}
