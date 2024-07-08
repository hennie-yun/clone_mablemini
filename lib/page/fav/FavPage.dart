import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../comm/SiseData.dart';
import '../../manager/GlobalController.dart';
import '../main/MainPage.dart';
import '../price/PricePage.dart';
import 'FavPageController.dart';

class FavPage extends StatelessWidget {
  final FavPageController _controller = FavPageController();
  late WebSocketChannel _webSocketChannel;
  late String _websocketKey;


  FavPage() {
    _webSocketChannel =
        WebSocketChannel.connect(Uri.parse('ws://203.109.30.207:10001/connect'));
    _setupWebSocket();
  }

  void _setupWebSocket() {
    _webSocketChannel.stream.listen((message) async {
      final data = jsonDecode(message);
      if (data['Data'] != null) {
        _websocketKey = data['Data']['websocketkey'];
        print('WebSocket Key: $_websocketKey');
        await _requestData();
      }
      if (data['TrCode'] == "H0STCNT0") {
        RealSiseData siseRealList = RealSiseData.fromJson(data["Data"]);
        _controller.siseRealList.add(siseRealList);
        _controller.hasRealData.value = true;
      }
      else {
        print('No Data in message');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }

  Future<void> _requestData() async {
    try {
      for (int i = 0; i < _controller.jmCodes.length; i++) {
        if (i < 50) {
          final headers = {'Content-Type': 'application/json;charset=utf-8'};
          final body = jsonEncode({
            "trCode": "/uapi/domestic-stock/v1/quotations/S0004",
            "rqName": "",
            "header": {"tr_id": "1"},
            "objCommInput": {"SHCODE": _controller.jmCodes[i]["jmCode"]}
          });

          final response = await http.post(
            Uri.parse('http://203.109.30.207:10001/request'),
            headers: headers,
            body: body,
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            if (responseData['TrCode'] == "/uapi/domestic-stock/v1/quotations/S0004") {
              SiseData siseData = SiseData.fromJson(responseData["Data"]["output"],_controller.jmCodes[i]["jmName"]);
              _controller.siseList.add(siseData);
            }
          } else {
            print('Request failed with status: ${response.statusCode}');
          }
          await requestReal(_websocketKey);
        } else {
          break;
        }
      }
      _controller.hasRealData.value = false;
    } catch (e) {
      print('Error during request: $e');
    }
  }

  Future<void>  requestReal(String websocketKey) async {
    const url = 'http://203.109.30.207:10001/requestReal';

    final headers = {'Content-Type': 'application/json;charset=utf-8'};

    final body = jsonEncode({
      "trCode": "/uapi/domestic-stock/v1/quotations/requestReal",
      "rqName": "",
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"tr_key": "000660", "tr_id": "H0STCNT0"}
    });
    final response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print (responseData);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return _controller.hasRealData.value ?
      ListView.builder(
          itemCount: _controller.siseRealList.length,
          itemBuilder: (context, index) {
            final siseData = _controller.siseRealList[index];
            return GestureDetector(
              onTap: (){
                // 해당 항목의 jmCode를 선택하고 다음 페이지로 이동
                _controller.setSelectedJmCode(_controller.jmCodes[index]['jmCode']!);
                Get.to(PricePage());
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
                        _controller.jmCodes[index]['jmName']!,
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
                          siseData.STCK_PRPR + '원',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        makePrice(
                          siseData.PRDY_VRSS, // 전일 대비
                          siseData.PRDY_CTRT, // 전일 대비율
                          siseData.PRDY_VRSS_SIGN, // 전일 대비 부호
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) :  ListView.builder(
          itemCount: _controller.siseList.length,
          itemBuilder: (context, index) {
            final siseData = _controller.siseList[index];
            return GestureDetector(
              onTap: (){
                // 해당 항목의 jmCode를 선택하고 다음 페이지로 이동
                _controller.setSelectedJmCode(_controller.jmCodes[index]['jmCode']!);
                Get.to(PricePage());
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
                        _controller.jmCodes[index]['jmName']!,
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
                          siseData.STCK_PRPR + '원',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        makePrice(
                          siseData.PRDY_VRSS, // 전일 대비
                          siseData.PRDY_CTRT, // 전일 대비율
                          siseData.PRDY_VRSS_SIGN, // 전일 대비 부호
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

String sign = '';

Widget makePrice(String prc, String prct, String updwn) {

  Color updwnColor = updownColor(updwn);

  return Row(children: [
    Text(sign, style: TextStyle(color: updwnColor, fontSize: 12)),
    Text('$prc원', style: TextStyle(color: updwnColor, fontSize: 12)),
    Text(' ($prct%)', style: TextStyle(color: updwnColor, fontSize: 12)),
  ]);
}

Color updownColor(String updwn) {
  var updown = int.parse(updwn);

  if (updown < 3) {
    sign = '▲ ';
    return const Color(0xFFF24430);
  } else if (updown == 3) {
    return const Color(0xFF50505B);
  } else {
    sign = '▼ ';
    return const Color(0xFF4881FF);
  }
}

