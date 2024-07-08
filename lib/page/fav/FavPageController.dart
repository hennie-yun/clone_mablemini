import 'package:get/get.dart';

import '../../comm/SiseData.dart';

class FavPageController extends GetxController {

  var siseList = <SiseData>[].obs;
  var siseRealList = [].obs;
  var hasRealData = false.obs;


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
  ];

  // 선택된 항목의 jmCode를 저장할 변수
  var selectedJmCode = <String>[].obs;

  void setSelectedJmCode(List<String> jmCode) {
    selectedJmCode.value = jmCode;
  }

  void init() {
    siseList.clear();
    siseRealList.clear();
    hasRealData.value = false;
    selectedJmCode.value = [];
  }
}
