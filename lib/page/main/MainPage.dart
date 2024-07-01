import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../manager/GlobalController.dart';
import '../fav/fav.dart';
import '../more/MorePage.dart';
import '../price/PricePage.dart';
import '../zzim.dart';

class MainPage extends StatelessWidget {
  final GlobalController _globalCtrl = Get.find<GlobalController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
              _globalCtrl.setCurrWidget(fav()); // 찜하기 페이지
              break;
            case 1:
              _globalCtrl.setCurrWidget(PricePage());
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
          titleWidget = 'KB금융';
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
        titleSpacing: titleWidget == 'KB금융' ? -15 :
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: titleWidget == ''
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {},
              )
            : null,
        title: Text(titleWidget),
        actions: actions,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 64),
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
