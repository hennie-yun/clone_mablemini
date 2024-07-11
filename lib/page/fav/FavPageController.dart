import 'package:get/get.dart';

import '../../comm/SiseData.dart';

class FavPageController extends GetxController {
  var siseList = <SiseData>[].obs;
  var siseRealList = [].obs;

  // var hasRealData = false.obs;
  /// 통신 플래그
  var isRequest = false.obs;
  bool isFirst = true;

  var isRushTest = false.obs;

  final List<Map<String, String>> jmCodes = [
    {"jmCode": "000660", "jmName": "SK 하이닉스"},
    {"jmCode": "005380", "jmName": "현대차"},
    {"jmCode": "035420", "jmName": "네이버"},
    {"jmCode": "035720", "jmName": "카카오"},
    {"jmCode": "005490", "jmName": "POSCO홀딩스"},
    {"jmCode": "252670", "jmName": "KODEX 200 선물인버스"},
    {"jmCode": "055550", "jmName": "신한지주"},
    {"jmCode": "373220", "jmName": "LG에너지솔루션"},
    {"jmCode": "005930", "jmName": "삼성전자"},
    {"jmCode": "078150", "jmName": "HB테크놀로지"},
    {"jmCode": "001470", "jmName": "삼부토건"},
    {"jmCode": "032680", "jmName": "소프트센"},
    {"jmCode": "123410", "jmName": "코리아에프티"},
    {"jmCode": "000300", "jmName": "대유플러스"},
    {"jmCode": "084680", "jmName": "이월드"},
    {"jmCode": "039980", "jmName": "리노스"},
    {"jmCode": "008700", "jmName": "아남전자"},
    {"jmCode": "032620", "jmName": "유비케이"},
    {"jmCode": "900280", "jmName": "골든센츄리"},
    {"jmCode": "294630", "jmName": "서남"},
  ];

  // 선택된 항목의 jmCode를 저장할 변수
  var selectedJmCode = <String>[].obs;

  void setSelectedJmCode(List<String> jmCode) {
    selectedJmCode.value = jmCode;
  }

  void init() {
    isFirst = true;
    isRequest.value = false;
    siseList.clear();
    siseRealList.clear();
    // hasRealData.value = false;
    selectedJmCode.value = [];
  }
}
