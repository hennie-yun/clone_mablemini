import 'dart:convert';

import 'package:clone_mablemini/comm/SiseData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http/http.dart' as http;

import 'package:web_socket_channel/web_socket_channel.dart';

import 'PricePageController.dart';


class PricePage extends StatelessWidget {

  //컨트롤러
  PricePageController _controller = PricePageController();

  // 전역으로 사용할 WebSocket key
  String websocketKey = "";

  //웹소켓 채널 생성
  WebSocketChannel? channel;

  //웹소켓 연결
  void connectWebSocket() {
    print('웹소켓 연결');
    if (channel != null) {
      channel!.sink.close(); // 기존 채널이 열려 있다면 닫기
    }
    channel = WebSocketChannel.connect(
      Uri.parse('ws://203.109.30.207:10001/connect'),
    );

    channel!.stream.listen(
          (message) {
        print('Received message: $message');
        final data = jsonDecode(message);
        if (data['Data'] != null) {
          websocketKey = data['Data']['websocketkey'];
          print('WebSocket Key: $websocketKey');
          if (websocketKey.isNotEmpty) {
            getSiseData(websocketKey);
          }
          if (data['Trcode'] == "H0STCNT0") {
          SiseData siseData = SiseData.fromJson(data);
          _controller.siseList.add(siseData);
          }
        } else {
          print('No Data in message');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
        Future.delayed(Duration(seconds: 1), () => connectWebSocket());
      },
    );
  }

  //시세데이터 얻기
  void getSiseData(String websocketKey) async {
    const baseUrl = "http://203.109.30.207:10001/requestReal";

    print('WebSocket Key: $websocketKey');

    if (websocketKey.isEmpty) {
      throw Exception('WebSocket Key is empty');
    }

    var jsonData = jsonEncode({
      "header": {
        "sessionKey": websocketKey,
        "tr_type": "1",
      },
      "objCommInput": {"tr_id": "H0STCNT0", "tr_key": "005930"},
      "trCode": "/uapi/domestic-stock/v1/quotations/requestReal",
      "rqName": "",
    });

    Uri uri = Uri.parse('$baseUrl');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json;charset=UTF-8"},
      body: jsonData,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  PricePage() {
    connectWebSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:  Obx(() => Column(
          children: [
            // 현재가
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
                          Text("삼성증권", style: TextStyle(fontSize: 22)),
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

                   Row(
                      children: [
                        // todo) 실시간현재가 값
                        Text( _controller.siseList[0].value.STCK_PRPR,
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w700)),
                        Text('원',
                            style: TextStyle(
                              fontSize: 28,
                            )),
                      ],
                    ),

                    // todo) 실시간현재가 값
                    Text('▲ 400원 (0.61%)',
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFFF24430)))
                  ],
                )),
          ],
        )),
      ),
    );
  }
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

