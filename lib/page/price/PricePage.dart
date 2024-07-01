import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class PricePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 현재가
            Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('65,700', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                        Text('원', style: TextStyle(fontSize: 28,)),
                      ],
                    ),
                    Text('▲ 400원 (0.61%)', style: TextStyle(fontSize: 16, color: Color(0xFFF24430)))
                  ],
                )),

            Container(height: 16, color: const Color(0xFFF7F8FA)),

            //기업정보
            Container(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 76,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title('기업정보'),
                              const Text('KOSPI | 금융업 | 시가총액 870.98조원', style: TextStyle(fontSize: 12, color: Color(0xFF50505B))),
                            ]),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        tag('#갤럭시'),
                        tag('#갤럭시워치'),],)

                    ])),
            Container(height: 16, color: const Color(0xFFF7F8FA)),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 28.0),
                child: Column(
                  children: [
                    title('회사소식'),
                    news('배터리 열받아도 불나지 않도록', 'assets/images/image1.png'),
                    news('에어부산, 내달부터 부산발 일본 동남아노선 3개 운항 재개',
                        'assets/images/image2.png'),
                    news('서울버스 총파업 현실화되나', 'assets/images/image3.png')
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
Widget tag(String title){
  return Container(
      margin: EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 4.0),
      decoration: const BoxDecoration(
        color: Color(0xFF2F4F4B),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(50.0),
          right: Radius.circular(50.0),
        ),
      ),
      child: Text(title,
          style:
          TextStyle(fontSize: 14, color: Colors.white)));
}

Widget title(String title){
  return  Row(
    children: [
      Expanded(
          child: Text(title, style: TextStyle(fontSize: 20))),
      Container(
          width: 24,
          child: IconButton(
              onPressed: () {},
              iconSize: 24.0,
              icon: Icon(Icons.arrow_forward_ios))
      )
    ],
  );
}
Widget news(String title, String imagePath) {
  return Container(
      width: double.infinity,
      height: 112,
      child: Row(
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16)),
                const SizedBox(height: 8),
                const Text('연합뉴스 | 2022/04/29 15:32',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7D7E85))),
              ])),
          Container(
              margin: EdgeInsets.only(left: 15),
              width: 72,
              height: 72,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, fit: BoxFit.fitHeight)))
        ],
      ));
}
