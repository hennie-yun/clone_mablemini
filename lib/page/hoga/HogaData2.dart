class HogaData2 {
  String? jmCode; // 종목코드
  String? price; // 현재가
  String? sign; // 전일대비구분
  String? change; // 전일대비
  String? diff; // 등락율
  String? volume; // 누적거래량
  String? close; // 전일종가
  String? upPrice; // 상한가
  String? downPrice; // 하한가
  String? open; // 시가
  String? high; // 고가
  String? low; // 저가
  String? basePrice; // 기준가
  String? frgnEhrt; // 외인비율

  HogaData2(
      { this.jmCode, this.price, this.sign, this.change,
        this.diff, this.volume, this.close, this.upPrice, this.downPrice,
        this.open, this.high, this.low, this.basePrice, this.frgnEhrt});

  factory HogaData2.fromJSON(Map<String, dynamic> json, jmCode){

      return HogaData2(
        jmCode: jmCode,
        price: (json['PRICE'] as String).trim(),
        sign: (json['SIGN'] as String).trim(),
        change: (json['CHANGE'] as String).trim(),
        diff: (json['DIFF'] as String).trim(),
        volume: (json['AVOLUME'] as String).trim(),
        close: (json['CLOSE'] as String).trim(),
        upPrice: (json['UPPER'] as String).trim(),
        downPrice: (json['LOWER'] as String).trim(),
        open: (json['OPEN'] as String).trim(),
        high: (json['HIGH'] as String).trim(),
        low: (json['LOW'] as String).trim(),
        basePrice: (json['REPRICE'] as String).trim(),
          frgnEhrt : json['FRGN_EHRT'] as String


      );

  }
}