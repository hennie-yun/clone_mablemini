import 'package:get/get.dart';

class FavPageController extends GetxController {

  var siseList = [].obs;
  var siseRealList = [].obs;
  var hasRealData = false.obs;


  final List<Map<String, String>> jmCodes = [
    {"jmCode": "000660", "jmName": "SK 하이닉스"},
    {"jmCode": "005380", "jmName": "현대차"},
    {"jmCode": "035420", "jmName": "네이버"},
    {"jmCode": "035720", "jmName": "카카오"}
  ];

  // 선택된 항목의 jmCode를 저장할 변수
  var selectedJmCode = ''.obs;

  String setSelectedJmCode(String jmCode) {
    return selectedJmCode.value = jmCode;
  }
}
