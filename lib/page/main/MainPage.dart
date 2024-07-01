import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


import '../../manager/GlobalController.dart';
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
              icon: _globalCtrl.selectedIndex.value == 0 ?
              Icon(Icons.star_rounded, color: Colors.yellow) :
              Icon(Icons.star_outline_rounded, color: Colors.black),
              label: 'fav'),
          BottomNavigationBarItem(
              icon: _globalCtrl.selectedIndex.value == 1 ? Icon(
                Icons.insert_chart_rounded, color: Colors.yellow,) : const Icon(
                Icons.insert_chart_outlined_rounded , color: Colors.black,),
              label: 'price'
          ),
          BottomNavigationBarItem(
              icon: _globalCtrl.selectedIndex.value == 2 ? Icon(
                Icons.more_horiz_rounded , color: Colors.yellow,) : Icon(
                  Icons.more_horiz_rounded , color: Colors.black),
              label: 'more'
          ),
        ],

        currentIndex: _globalCtrl.selectedIndex.value,
        selectedItemColor: Colors.black,

        onTap: (value) {
          _globalCtrl.selectedIndex.value = value;
          switch (value) {
            case 0:
               _globalCtrl.setCurrWidget(zzim()); // 찜하기 페이지
              break;
            case 1:
              _globalCtrl.setCurrWidget(PricePage());
              break;
            case 2:
              _globalCtrl.setCurrWidget(MorePage());
              break;
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Obx(() {
          return _globalCtrl.currentWidget.value;
        }),
      ),
      bottomNavigationBar: setBottom(),
    );
  }
}