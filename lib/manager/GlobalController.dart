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


}
