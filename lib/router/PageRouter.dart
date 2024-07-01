import 'package:get/get.dart';

import '../page/main/MainPage.dart';

/// PageRouter
/// 화면 ( page ) 및 이름 ( ex. /favpage ), 전환 효과 ( transition ) 등 정의
class PageRouter {
  static final route = [

    // 메인 화면 으로 이동
    GetPage(
        name: '/mainPage',
        page: () => MainPage(),
        transition: Transition.upToDown
    ),
  ];
}