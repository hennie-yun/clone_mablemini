
import 'dart:convert';
import 'package:http/http.dart' as http;

/// /////////////////////// ///
///Ebest [주식]시세>주식시간대별체결조회 API///
///확인함///
////// 리스트 형식 output ///
/// ////////////////////// ///

///FHPST01060000Output
class CheData {
  List<CheDataArray> array = [];

  CheData({required this.array});

  /// Json -> TR8434OutputItem
  // factory Che.fromJSON(Map<String, dynamic> jsonArray) {
  //   List<T1301Array> array = [];
  //   for (int i = 0; i < jsonArray.length; i++) {
  //     T1301Array item = T1301Array.fromJson(jsonArray[i]);
  //     array.add(item);
  //   }
  //
  //   return Che(array: array);
  // }
  factory CheData.fromJSON(List<dynamic> jsonArray) {
    List<CheDataArray> array = [];
    for (int i = 0; i < jsonArray.length; i++) {
      CheDataArray item = CheDataArray.fromJson(jsonArray[i]);
      array.add(item);
    }

    return CheData(array: array);
  }
}

class CheDataArray {
  String chetime; //시간 stck_cntg_hour
  String price; //현재가 stck_prpr
  String sign; //전일대비구분 prdy_vrss_sign
  String change; //전일대비 prdy_vrss
  String chdegree; //체결강도 tday_rltv
  String volume; //거래량 cntg_vol


  CheDataArray({
    required this.chetime,
    required this.price,
    required this.sign,
    required this.change,
    required this.chdegree,
    required this.volume,

  });

  /// json(Map) -> TR1301
  factory CheDataArray.fromJson(
      Map<String, dynamic> json,
      ) {
    //따로 매수매도의 체결수량 및 체결건수가 없음
    return CheDataArray(
      chetime: json['stck_cntg_hour'] ?? json['STCK_CNTG_HOUR'],
      price: json['stck_prpr'] ?? json['STCK_PRPR'].toString(),
      sign: json['prdy_vrss_sign'] ?? json['PRDY_VRSS_SIGN'] ,
      change: json['prdy_vrss'] ?? json['PRDY_VRSS'],
      chdegree: json['tday_rltv'] ?? json['CTTR'],// 실시간은 없음
      volume: json['cntg_vol'] ??json['CNTG_VOL'],

    );
  }




}


