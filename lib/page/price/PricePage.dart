import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class PricePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 현재가
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('65,700', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      Text('원', style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  Text('▲ 400원 (0.61%)', style: TextStyle(fontSize: 16, color: Colors.red))
                ],
              )),

          Container(height: 16, color: const Color(0xFFF7F8FA)),

          //기업정보
          Container(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      //padding:EdgeInsets.symmetric(vertical:12) ,
                      height: 76,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                    child: Text('기업정보',
                                        style: TextStyle(fontSize: 20))),
                                IconButton(
                                    onPressed: () {},
                                    iconSize: 24.0,
                                    icon: Icon(Icons.chevron_right))
                              ],
                            ),
                            const Text('KOSPI | 금융업 | 시가총액 870.98조원',
                                style: TextStyle(fontSize: 12)),
                          ]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2F4F4B),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(50.0),
                            right: Radius.circular(50.0),
                          ),
                        ),
                        child: const Text('#갤럭시',
                            style:
                                TextStyle(fontSize: 14, color: Colors.white)))
                  ])),
          Container(height: 16, color: const Color(0xFFF7F8FA)),

          //회사소식

        ],
      ),
    );
  }
}
