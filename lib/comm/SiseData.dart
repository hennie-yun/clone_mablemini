class SiseData {
  final String STCK_PRPR; //현재가
  final String PRDY_VRSS_SIGN; //전일 대비 부호 -> 1 : 상한 / 2 : 상승 / 3 : 보합 / 4 : 하한 / 5 : 하락
  final double PRDY_VRSS; //전일 대비
  final double PRDY_CTRT; //전일 대비율

  SiseData(
      {required this.STCK_PRPR,
      required this.PRDY_VRSS_SIGN,
      required this.PRDY_VRSS,
      required this.PRDY_CTRT});

  factory SiseData.fromJson(Map<String, dynamic> json) {
    return SiseData(
        STCK_PRPR: json["Data"]["STCK_PRPR"],
        PRDY_VRSS_SIGN: json["Data"]["PRDY_VRSS_SIGN"],
        PRDY_VRSS: json["Data"]["PRDY_VRSS"],
        PRDY_CTRT: json["Data"]["PRDY_CTRT"]);
  }
}
