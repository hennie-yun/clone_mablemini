import 'dart:convert';

import 'package:clone_mablemini/page/fav/FavPageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../comm/SiseData.dart';
import '../../manager/GlobalController.dart';
import '../fav/FavPage.dart';
import '../more/MorePage.dart';
import '../price/PricePage.dart';

import 'package:http/http.dart' as http;

class MainPage extends StatelessWidget {
  final GlobalController _globalCtrl = Get.find<GlobalController>();
  final FavPageController _controller = Get.put(FavPageController());

  final _scaffoldKey = GlobalKey<ScaffoldState>();

   WebSocketChannel? _webSocketChannel;
  // WebSocketChannel _webSocketChannel =
  //     WebSocketChannel.connect(Uri.parse('ws://203.109.30.207:10001/connect'));
  late String _websocketKey;

  void _setupWebSocket(String jmCode) async {

    if(_webSocketChannel != null){
      _webSocketChannel!.sink.close();
    }

    try {
      _webSocketChannel =
           WebSocketChannel.connect(Uri.parse('ws://203.109.30.207:10001/connect'));

      _webSocketChannel?.stream.listen((message) async {
        try {
          final data = jsonDecode(message);
          if (data['Data'] != null && data['Data']['websocketkey'] != null) {
            _websocketKey = data['Data']['websocketkey'];
            print('WebSocket Key: $_websocketKey');
            await _requestReal(_websocketKey, jmCode);
          } else {
            if (data['TrCode'] == "H0STCNT0") {
              String STCK_PRPR = data['Data']['STCK_PRPR'] ?? '';
              String PRDY_VRSS_SIGN = data['Data']['PRDY_VRSS_SIGN'] ?? '';
              String PRDY_VRSS = data['Data']['PRDY_VRSS'] ?? '';
              String PRDY_CTRT = data['Data']['PRDY_CTRT'] ?? '';

              _globalCtrl.selectedSiseList[0] = SiseData(
                STCK_PRPR: STCK_PRPR,
                PRDY_VRSS_SIGN: PRDY_VRSS_SIGN,
                PRDY_VRSS: PRDY_VRSS,
                PRDY_CTRT: PRDY_CTRT,
                JmName: _globalCtrl.selectedJmName.value,
              );
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

  Future<void> _requestReal(String websocketKey, String jmCode) async {
    final headers = {'Content-Type': 'application/json;charset=utf-8'};

    const url = 'http://203.109.30.207:10001/requestReal';
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

  Widget setBottom() {
    return Obx(() {
      return BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _globalCtrl.selectedIndex.value == 0
                ? Icon(Icons.star_rounded, color: Color(0XFFFFC700))
                : Icon(Icons.star_outline_rounded, color: Colors.black),
            label: '찜한주식',
          ),
          BottomNavigationBarItem(
            icon: _globalCtrl.selectedIndex.value == 1
                ? Icon(Icons.insert_chart_rounded, color: Color(0XFFFFC700))
                : Icon(Icons.insert_chart_outlined_rounded,
                    color: Colors.black),
            label: '현재가',
          ),
          BottomNavigationBarItem(
            icon: _globalCtrl.selectedIndex.value == 2
                ? Icon(Icons.more_horiz_rounded, color: Color(0XFFFFC700))
                : Icon(Icons.more_horiz_rounded, color: Colors.black),
            label: '더보기',
          ),
        ],
        currentIndex: _globalCtrl.selectedIndex.value,
        selectedItemColor: Color(0XFFFFC700),
        onTap: (value) {
          _globalCtrl.selectedIndex.value = value;
          switch (value) {
            case 0:
              _globalCtrl.setCurrWidget(FavPage()); // 찜하기 페이지
              if(_globalCtrl.hogaWebSocketChannel.value != null){ //-> 현재가에서 찜 클릭할 경우 호가 채널 닫아주기
                _globalCtrl.hogaWebSocketChannel.value?.sink.close();
              }
              break;

            case 1:
              if(_globalCtrl.hogaWebSocketChannel.value != null){
                _globalCtrl.hogaWebSocketChannel.value?.sink.close();
              }
              var siseData = _controller.siseList[0];
              _globalCtrl
                  .setCurrWidget(PricePage("000660", "SK 하이닉스")); //페이지 이동

              // 앱바 변경
              Get.find<GlobalController>()
                  .setSelectecJm('000660', 'SK 하이닉스', siseData);
              Get.find<GlobalController>().selectedIndex.value = 1;

              if(_globalCtrl.favWebSocketChannel.value != null){ //-> 찜에서 호가로 이동할 경우 찜에서 필요한 채널 닫아주기
                _globalCtrl.favWebSocketChannel.value?.sink.close();
              }
              break;

            case 2:
              _globalCtrl.setCurrWidget(MorePage());
              _globalCtrl.favWebSocketChannel.value ?? _globalCtrl.favWebSocketChannel.value?.sink.close();
              _globalCtrl.hogaWebSocketChannel.value ?? _globalCtrl.hogaWebSocketChannel.value?.sink.close();

              break;
          }
        },
        type: BottomNavigationBarType.fixed,
      );
    });
  }

  Widget setAppBar() {
    return Obx(() {
      String titleWidget = '';
      String jmCode = '';

      List<Widget>? actions = [];

      switch (_globalCtrl.selectedIndex.value) {
        case 0:

          titleWidget = '찜한주식';
          actions = [
            TextButton(

              onPressed: () {
                print ('${_globalCtrl.isRushTest.value} -> ${!_globalCtrl.isRushTest.value}');

                if(_globalCtrl.favWebSocketChannel.value != null){
                  _globalCtrl.favWebSocketChannel.value?.sink.close();
                }

                _globalCtrl.isRushTest.value = !_globalCtrl.isRushTest.value;
                FavPage();
              }, child: _globalCtrl.isRushTest.value == true ?  Text("러쉬테스트 ON ") : Text("러쉬테스트 OFF"),
            ),
            IconButton(
              icon: Icon(Icons.create_outlined),
              onPressed: () {},
            ),
          ];
          break;
        case 1:
          titleWidget = _globalCtrl.selectedJmName.value;
          jmCode = _globalCtrl.selectedJmCode.value;
          _setupWebSocket(jmCode);
          actions = [
            TextButton(
              child: _globalCtrl.isRushTest.value == true ?  Text("러쉬테스트 ON ") : Text("러쉬테스트 OFF"),
              onPressed: () {
                _globalCtrl.isRushTest.value = !_globalCtrl.isRushTest.value;
                if(_globalCtrl.hogaWebSocketChannel.value != null){
                  _globalCtrl.hogaWebSocketChannel.value?.sink.close();
                }



                Get.find<GlobalController>().setCurrWidget(PricePage(
                    _globalCtrl.selectedJmCode.value,
                    _globalCtrl.selectedJmName.value));
              },
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ];

          break;
        case 2:
          titleWidget = '더보기';
          actions = [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ];
          break;
      }

      return AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0.0,
        title: jmCode.isNotEmpty
            ? currentPriceAppbar(titleWidget)
            : Text('$titleWidget'),
        actions: actions,
      );
    });
  }

  Widget currentPriceAppbar(String titleWidget) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(titleWidget,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(width: 5),
            Icon(Icons.search, size: 16)
          ],
        ),
        Row(
          children: [
            Text(
                '${formatNumber(int.parse(_globalCtrl.selectedSiseList[0].STCK_PRPR.toString()))}원',
                style: TextStyle(fontSize: 16)),
            makePrice(
              _globalCtrl.selectedSiseList[0].PRDY_VRSS,
              _globalCtrl.selectedSiseList[0].PRDY_CTRT,
              _globalCtrl.selectedSiseList[0].PRDY_VRSS_SIGN,
            ),
          ],
        ),
        SizedBox(height: 10)
      ],
    ));
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

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(width: 8),
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
      sign = "-";
      return const Color(0xFF50505B);
    } else {
      sign = '▼ ';
      return const Color(0xFF4881FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 56),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: setAppBar(),
          )),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Obx(() {
          return _globalCtrl.currentWidget.value;
        }),
      ),
      bottomNavigationBar: setBottom(),
    );
  }
}
