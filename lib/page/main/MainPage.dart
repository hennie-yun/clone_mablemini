import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../manager/GlobalController.dart';
import '../fav/FavPage.dart';
import '../more/MorePage.dart';
import '../price/PricePage.dart';
import '../price/PricePageController.dart';


class MainPage extends StatelessWidget {
  final GlobalController _globalCtrl = Get.find<GlobalController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final PricePageController _pricecontroller = PricePageController();


  MainPage({super.key});

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
              break;
            case 1:
              _globalCtrl.setCurrWidget(PricePage("000660", "SK 하이닉스")); //-> 걍 이동 시킬때는 하이닉스
              break;
            case 2:
              _globalCtrl.setCurrWidget(MorePage());
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

      List<Widget> actions = [];

      switch (_globalCtrl.selectedIndex.value) {
        case 0:
          titleWidget = '찜한주식';
          actions = [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {},
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
          actions = [
            IconButton(
              icon: Icon(Icons.notification_add_outlined),
              onPressed: () {},
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
        title: jmCode.isNotEmpty ?
        Container(
          child : Column(
            children: [
              Text('$titleWidget($jmCode)'),
            ],
          )
        ) : Text('$titleWidget') ,
        actions: actions,
      );
    });
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
