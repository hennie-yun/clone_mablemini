class SiseData {
  final String STCK_PRPR; // 현재가
  final String PRDY_VRSS_SIGN; // 전일 대비 부호
  final String PRDY_VRSS; // 전일 대비
  final String PRDY_CTRT; // 전일 대비율
  final String? JmName; // 종목이름 (선택)

  SiseData({
    required this.STCK_PRPR,
    required this.PRDY_VRSS_SIGN,
    required this.PRDY_VRSS,
    required this.PRDY_CTRT,
    this.JmName,
  });

  factory SiseData.fromJson(Map<String, dynamic> json, String? jmName) {
    return SiseData(
      STCK_PRPR: json["PRICE"].toString(),
      PRDY_VRSS_SIGN: json["SIGN"].toString(),
      PRDY_VRSS: json["DIFF"].toString(),
      PRDY_CTRT: json["MARG_RATE"].toString(),
      JmName: jmName,
    );
  }
}

class RealSiseData {
  final String STCK_PRPR; // 현재가
  final String PRDY_VRSS_SIGN; // 전일 대비 부호
  final String PRDY_VRSS; // 전일 대비
  final String PRDY_CTRT; // 전일 대비율
  final String? JmName;

  RealSiseData({
    required this.STCK_PRPR,
    required this.PRDY_VRSS_SIGN,
    required this.PRDY_VRSS,
    required this.PRDY_CTRT,
    this.JmName,
  });

  factory RealSiseData.fromJson(Map<String, dynamic> json, String? jmName) {
    return RealSiseData(
      STCK_PRPR: json["STCK_PRPR"],
      PRDY_VRSS_SIGN: json["PRDY_VRSS_SIGN"],
      PRDY_VRSS: json["PRDY_VRSS"],
      PRDY_CTRT: json["PRDY_CTRT"],
      JmName: jmName,
    );
  }
}
