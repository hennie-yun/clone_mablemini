import 'dart:convert';

import 'package:clone_mablemini/comm/SiseData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http/http.dart' as http;

import 'package:web_socket_channel/web_socket_channel.dart';


import 'PricePageController.dart';

class PricePage extends StatelessWidget {
  final PricePageController _controller = PricePageController();

  late WebSocketChannel _webSocketChannel;
  late String _websocketKey;
  List selectedJm = [];

  PricePage(String selectedJmCode, String selectedJmName) {
    selectedJm = [selectedJmCode, selectedJmName];
    _requestData(selectedJm[0]);
  }

  void _setupWebSocket() async {
    try {
      _webSocketChannel = WebSocketChannel.connect(
          Uri.parse('ws://203.109.30.207:10001/connect'));

      _webSocketChannel.stream.listen((message) async {
        try {
          final data = jsonDecode(message);
          if (data['Data'] != null && data['Data']['websocketkey'] != null) {
            _websocketKey = data['Data']['websocketkey'];
            print('WebSocket Key: $_websocketKey');
            await _requestReal(_websocketKey, selectedJm[0]);
          } else {
            if (data['TrCode'] == "H0STCNT0") {
              _controller.siseList.clear();
              String STCK_PRPR = data['Data']['STCK_PRPR'] ?? '';
              String PRDY_VRSS_SIGN = data['Data']['PRDY_VRSS_SIGN'] ?? '';
              String PRDY_VRSS = data['Data']['PRDY_VRSS'] ?? '';
              String PRDY_CTRT = data['Data']['PRDY_CTRT'] ?? '';

              SiseData newData = SiseData(
                STCK_PRPR: STCK_PRPR,
                PRDY_VRSS_SIGN: PRDY_VRSS_SIGN,
                PRDY_VRSS: PRDY_VRSS,
                PRDY_CTRT: PRDY_CTRT,
                JmName: selectedJm[1],
              );

              _controller.siseList.add(newData);
            }
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

  Future<void> _requestData(String value) async {
    print(value);
    final headers = {'Content-Type': 'application/json;charset=utf-8'};
    final body = jsonEncode({
      "trCode": "/uapi/domestic-stock/v1/quotations/S0004",
      "rqName": "",
      "header": {"tr_id": "1"},
      "objCommInput": {"SHCODE": value}
    });

    final response = await http.post(
      Uri.parse('http://203.109.30.207:10001/request'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['TrCode'] ==
          "/uapi/domestic-stock/v1/quotations/S0004") {
        SiseData siseData =
            SiseData.fromJson(responseData["Data"]["output"], value);
        print(siseData);
        _controller.siseList.add(siseData);
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }

    _setupWebSocket();
  }

  Future<void> _requestReal(String websocketKey, String jmCode) async {
    const url = 'http://203.109.30.207:10001/requestReal';

    final headers = {'Content-Type': 'application/json;charset=utf-8'};

    final body = jsonEncode({
      "trCode": "/uapi/domestic-stock/v1/quotations/requestReal",
      "rqName": "",
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"tr_key": jmCode, "tr_id": "H0STCNT0"}
    });
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: Obx(() {
        if (_controller.siseList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(selectedJm[1], style: TextStyle(fontSize: 22)),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withOpacity(0.1),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                                iconSize: 24.0,
                                icon: const Icon(Icons.push_pin_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${formatNumber(int.parse( _controller.siseList[0].STCK_PRPR))}원',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                      ),
                      makePrice(
                          _controller.siseList[0].PRDY_VRSS, // 전일 대비
                          _controller.siseList[0].PRDY_CTRT, // 전일 대비율
                          _controller.siseList[0].PRDY_VRSS_SIGN // 전일 대비 부호
                          ),
                      Container(height: 16, color: const Color(0xFFF7F8FA)),

                      //기업 정보
                      Container(
                          padding:
                              const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 76,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        title('기업정보'),
                                        const Text(
                                            'KOSPI | 금융업 | 시가총액 870.98조원',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF50505B))),
                                      ]),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    tag('#갤럭시'),
                                    tag('#갤럭시워치'),
                                  ],
                                )
                              ])),

                      Container(height: 16, color: const Color(0xFFF7F8FA)),

                      //뉴스
                      Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 28.0),
                          child: Column(
                            children: [
                              title('회사소식'),
                              news('배터리 열받아도 불나지 않도록',
                                  'assets/images/image1.png'),
                              news('에어부산, 내달부터 부산발 일본 동남아노선 3개 운항 재개',
                                  'assets/images/image2.png'),
                              news('서울버스 총파업 현실화되나', 'assets/images/image3.png')
                            ],
                          ))
                    ],
                  )),
            ],
          );
        }
      })),
    );
  }
}


String formatNumber(int number) {
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}

Widget tag(String title) {
  return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: const BoxDecoration(
        color: Color(0xFF2F4F4B),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(50.0),
          right: Radius.circular(50.0),
        ),
      ),
      child: Text(title,
          style: const TextStyle(fontSize: 14, color: Colors.white)));
}

Widget title(String title) {
  return Row(
    children: [
      Expanded(child: Text(title, style: const TextStyle(fontSize: 20))),
      SizedBox(
          width: 24,
          child: IconButton(
              onPressed: () {},
              iconSize: 24.0,
              icon: const Icon(Icons.arrow_forward_ios)))
    ],
  );
}

Widget news(String title, String imagePath) {
  return SizedBox(
      width: double.infinity,
      height: 112,
      child: Row(
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                const Text('연합뉴스 | 2022/04/29 15:32',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7D7E85))),
              ])),
          Container(
              margin: const EdgeInsets.only(left: 15),
              width: 72,
              height: 72,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, fit: BoxFit.fitHeight)))
        ],
      ));
}

Widget restof() {
  return Column(children: [
    Container(height: 16, color: const Color(0xFFF7F8FA)),

    //기업 정보
    Container(
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 76,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              title('기업정보'),
              const Text('KOSPI | 금융업 | 시가총액 870.98조원',
                  style: TextStyle(fontSize: 12, color: Color(0xFF50505B))),
            ]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              tag('#갤럭시'),
              tag('#갤럭시워치'),
            ],
          )
        ])),

    Container(height: 16, color: const Color(0xFFF7F8FA)),

    //뉴스
    Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 28.0),
        child: Column(
          children: [
            title('회사소식'),
            news('배터리 열받아도 불나지 않도록', 'assets/images/image1.png'),
            news(
                '에어부산, 내달부터 부산발 일본 동남아노선 3개 운항 재개', 'assets/images/image2.png'),
            news('서울버스 총파업 현실화되나', 'assets/images/image3.png')
          ],
        ))
  ]);
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
    sign = "";
    return const Color(0xFF50505B);
  } else {
    sign = '▼ ';
    return const Color(0xFF4881FF);
  }
}
