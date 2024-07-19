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

  late String _websocketKey;

  FavPage() {
    _controller.init();
    requestData();
  }

  void setupWebSocket() {
    final GlobalController _globalController = Get.find<GlobalController>();
    var isRushTest = _globalController.isRushTest.value;

    try {
      _globalController.favWebSocketChannel.value = WebSocketChannel.connect(
          Uri.parse('ws://203.109.30.207:10001/connect'));

      _globalController.favWebSocketChannel.value?.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);

            if (data['Data'] != null && data['Data']['websocketkey'] != null) {
              _websocketKey = data['Data']['websocketkey'];
              print('WebSocket Key: $_websocketKey');
              isRushTest
                  ? _requestRush(_websocketKey)
                  : _requestReal(_websocketKey);
            } else if (data['TrCode'] != null && data['TrCode'] == "H0STCNT0") {
              _controller.isRequest.value = true;

              String STCK_PRPR = data['Data']['STCK_PRPR'] ?? '';
              String PRDY_VRSS_SIGN = data['Data']['PRDY_VRSS_SIGN'] ?? '';
              String PRDY_VRSS = data['Data']['PRDY_VRSS'] ?? '';
              String PRDY_CTRT = data['Data']['PRDY_CTRT'] ?? '';

              String jmCodeToUpdate = data['Data']['MKSC_SHRN_ISCD'];
              String? jmNameToUpdate;

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
            }
            else {

              var outputString = data['output'];
              Map<String, dynamic> outputData = json.decode(outputString);

              // if (data["trKey"] != null) {
                String? trCode = outputData['TrCode']?.toString();

                if (trCode == "H0STCNT0") {
                  String trKey = data['trKey'];

                  for (int i = 0; i < _controller.jmCodes.length; i++) {
                    if (trKey == _controller.jmCodes[i]['jmCode']) {
                      _controller.siseList[i] = SiseData(
                        STCK_PRPR: outputData['Data']['STCK_PRPR'].toString(),
                        PRDY_VRSS_SIGN: outputData['Data']['PRDY_VRSS_SIGN'].toString(),
                        PRDY_VRSS:outputData['Data']['PRDY_VRSS'].toString(),
                        PRDY_CTRT: outputData['Data']['PRDY_CTRT'].toString(),
                      );
                      break;
                    }
                  }
                // }
              }
            }
          } catch (e) {
            print('Error processing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
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

      Future future = http
          .post(
        Uri.parse('http://203.109.30.207:10001/request'),
        headers: headers,
        body: body,
      )
          .then((response) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData['TrCode'] ==
              "/uapi/domestic-stock/v1/quotations/S0004") {
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
      _controller.siseList.assignAll(
          newDataList.where((element) => element != null).cast<SiseData>());
      setupWebSocket();
    });
  }

  void _requestRush(String websocketKey) {
    List<Future<void>> futures = [];

    final headers = {'Content-Type': 'application/json;charset=utf-8'};
    final rushUrl = 'http://203.109.30.207:10001/rushtest';
    final rushBody = jsonEncode({
      "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
      "rqName": "",
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"count": "1", "tr_id": "HOSTCNTO"}
    });

    futures.add(
      http
          .post(Uri.parse(rushUrl), headers: headers, body: rushBody)
          .then((response) {
        if (response.statusCode == 200) {
          print("러시테스트 성공");
        } else {
          print('RequestRush request failed : ${response.statusCode} ');
        }
      }).catchError((error) {
        print('Error RequestRush request: $error');
      }),
    );

    Future.wait(futures);
  }

  void _requestReal(String websocketKey) {
    final headers = {'Content-Type': 'application/json;charset=utf-8'};
    List<Future<void>> futures = [];

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

      futures.add(
        http
            .post(Uri.parse(url), headers: headers, body: body)
            .then((response) {
          if (response.statusCode == 200) {
          } else {
            print(
                'RequestReal request failed : ${response.statusCode}, ${_controller.jmCodes[i]["jmName"]}');
          }
        }).catchError((error) {
          print('Error RequestReal request: $error');
        }),
      );
    }

    Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return ListView.builder(
          itemCount: _controller.siseList.length,
          itemBuilder: (context, index) {
            final siseData = _controller.siseList[index];
            final jmCode = _controller.jmCodes[index]['jmCode']!;
            final jmName = _controller.jmCodes[index]['jmName']!;

            return GestureDetector(
              onTap: () {
                Get.find<GlobalController>().setCurrWidget(
                  PricePage(jmCode, jmName),
                );
                Get.find<GlobalController>().setSelectecJm(
                  jmCode,
                  jmName,
                  siseData,
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
                        jmName,
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
      }),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Obx(() {
  //       return GridView.builder(
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 1,
  //           childAspectRatio: MediaQuery.of(context).size.width / 72,
  //         ),
  //         itemCount: _controller.siseList.length,
  //         itemBuilder: (context, index) {
  //           final siseData = _controller.siseList[index];
  //           return InkWell(
  //             onTap: () {
  //               Get.find<GlobalController>().setCurrWidget(
  //                 PricePage(
  //                   _controller.jmCodes[index]['jmCode']!,
  //                   _controller.jmCodes[index]['jmName']!,
  //                 ),
  //               );
  //               Get.find<GlobalController>().setSelectecJm(
  //                 _controller.jmCodes[index]['jmCode']!,
  //                 _controller.jmCodes[index]['jmName']!,
  //                 siseData,
  //               );
  //               Get.find<GlobalController>().selectedIndex.value = 1;
  //             },
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 24),
  //               height: 72,
  //               child: Row(
  //                 children: [
  //                   Container(
  //                     width: 36,
  //                     height: 36,
  //                     margin: const EdgeInsets.only(right: 12),
  //                     decoration: const BoxDecoration(shape: BoxShape.circle),
  //                     child: ClipOval(
  //                       child: Image.asset('assets/images/mmini.png'),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: Text(
  //                       _controller.jmCodes[index]["jmName"]!,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.w700,
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                   ),
  //                   Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       Text(
  //                         '${formatNumber(int.parse(siseData.STCK_PRPR))}원',
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.w700,
  //                           fontSize: 16,
  //                         ),
  //                       ),
  //                       makePrice(
  //                         siseData.PRDY_VRSS,
  //                         siseData.PRDY_CTRT,
  //                         siseData.PRDY_VRSS_SIGN,
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     }),
  //   );
  // }
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
