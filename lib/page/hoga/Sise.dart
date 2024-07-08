class Sise {
  int step=0;         // 스탭 (리스트 표시 단계)
  String? jmCode;    // 종목코드
  String? jmName;    // 종목명
  String? price;     // 현재가
  String? sign;      // 전일대비구분
  String? change;    // 전일대비
  String? diff;      // 등락률
  String? volume;    // 누적거래량
  String? open;      // 시가
  String? high;      // 고가
  String? low;       // 저가
  String? value;     // 거래대금(백만)
  bool isVertical=true;  // 가로세로 구분 (true:세로, false:가로)

  Sise({this.jmCode, this.jmName, this.price, this.sign, this.change,
    this.diff, this.volume, this.open, this.high, this.low, this.value});

  /// json(Map) -> Master
  factory Sise.fromJson(Map<String, dynamic> json) {
    return Sise(
        jmCode: json['shcode'],
        jmName: (json['hname'] as String).trim(),
        price: json['price'],
        sign: json['sign'],
        change: json['change'],
        diff: json['diff'],
        volume: json['volume'],
        open: json['open'],
        high: json['high'],
        low: json['low'],
        value: json['value'],

    );
  }
}