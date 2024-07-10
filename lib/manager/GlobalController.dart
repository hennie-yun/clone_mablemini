import 'package:clone_mablemini/comm/SiseData.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../page/fav/FavPage.dart';

class GlobalController extends GetxController {
  static GlobalController get instance => Get.find();

  var selectedIndex = 0.obs;
  var currentWidget = Rx<Widget>(FavPage()); // 초기화

  void setCurrWidget(Widget widget) {
    currentWidget.value = widget;
  }

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

  }
}
