import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoPricePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(

            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child :Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(child: Image.asset('assets/images/mmini.png')),
                  SizedBox(height: 20),
                  Text('찜 목록에서 종목 클릭 해주세요', style: TextStyle(fontSize: 20),)
                ],
              )
            )));
  }
}
