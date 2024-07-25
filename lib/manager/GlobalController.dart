import 'package:clone_mablemini/comm/SiseData.dart';
import 'package:clone_mablemini/page/fav/FavPagePaint.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../comm/HogaData.dart';
import '../page/fav/FavPage.dart';
import '../page/price/PricePage.dart';

class GlobalController extends GetxController {
  static GlobalController get instance => Get.find();

  double pricePageHeight = 0;

  var selectedIndex = 0.obs;
  var currentWidget = Rx<Widget>(FavPagePaint()); // 초기화

  // var currentWidget = Rx<Widget>(FavPage()); // 초기화


  void setCurrWidget(Widget widget) {
    currentWidget.value = widget;
  }

  var hogaWebSocketChannel = Rxn<WebSocketChannel>();
  var favWebSocketChannel = Rxn<WebSocketChannel>();

  //호가 페이지 인스턴스
  PricePage? pricePage;

  HogaData hogaPreData = HogaData();

  var selectedJmCode = ''.obs;

  var  selectedJmName = ''.obs;

  RxList<SiseData> selectedSiseList = <SiseData>[].obs;

  void setSelectecJm(String jmCode, String jmName, SiseData siseData) {
    selectedJmCode.value = jmCode;
    selectedJmName.value = jmName;
    selectedSiseList.assignAll([siseData]);
  }

  var isRushTest = false.obs;

  void init () {
  isRushTest.value = false;
  }
}
