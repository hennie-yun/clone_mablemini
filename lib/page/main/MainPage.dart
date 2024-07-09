import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../manager/GlobalController.dart';
import '../fav/FavPage.dart';
import '../more/MorePage.dart';
import '../price/PricePage.dart';
import '../price/PricePageController.dart';
import 'NoPricePage.dart';

class MainPage extends StatelessWidget {
  final GlobalController _globalCtrl = Get.find<GlobalController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();




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
              _globalCtrl.selectedSiseList.clear();
              _globalCtrl.selectedJmCode.value ='';
              _globalCtrl.selectedJmName.value = '';
              _globalCtrl.setCurrWidget(
                  NoPricePage()); //-> 걍 이동 할때는 현재가 X
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

      List<Widget>? actions = [];

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
          actions = _globalCtrl.selectedJmName.value.isNotEmpty ? [
            IconButton(
              icon: Icon(Icons.notification_add_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ] : null;
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
            SizedBox(height : 10)
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

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
