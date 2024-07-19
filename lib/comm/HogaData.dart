

class HogaData{

  //매도호가
  // final int askp1;
  // final int askp2;
  // final int askp3;
  // final int askp4;
  // final int askp5;
  // final int askp6;
  // final int askp7;
  // final int askp8;
  // final int askp9;
  // final int askp10;
  //
  // //매수호가
  // final int bidp1;
  // final int bidp2;
  // final int bidp3;
  // final int bidp4;
  // final int bidp5;
  // final int bidp6;
  // final int bidp7;
  // final int bidp8;
  // final int bidp9;
  // final int bidp10;
  //
  // //매도호가 잔량
  // final int askp_rsqn1;
  // final int askp_rsqn2;
  // final int askp_rsqn3;
  // final int askp_rsqn4;
  // final int askp_rsqn5;
  // final int askp_rsqn6;
  // final int askp_rsqn7;
  // final int askp_rsqn8;
  // final int askp_rsqn9;
  // final int askp_rsqn10;
  //
  // //매수호가 잔량
  // final int bidp_rsqn1;
  // final int bidp_rsqn2;
  // final int bidp_rsqn3;
  // final int bidp_rsqn4;
  // final int bidp_rsqn5;
  // final int bidp_rsqn6;
  // final int bidp_rsqn7;
  // final int bidp_rsqn8;
  // final int bidp_rsqn9;
  // final int bidp_rsqn10;


  final String? TOTAL_ASKP_RSQN;
  final String? TOTAL_BIDP_RSQN;

  // List<String>? buyHogas = []; // 매수호가 1~10
  // List<String>? buyRems = []; // 매수호가수량 1~10
  // List<String>? sellHogas = []; // 매도호가 1~10
  // List<String>? sellRems = []; // 매도호가수량 1~10

  List<String>? buyHogas; // 매수호가 1~10
  List<String>? buyRems ; // 매수호가수량 1~10
  List<String>? sellHogas; // 매도호가 1~10
  List<String>? sellRems; // 매도호가수량 1~10

  HogaData({
    //매도호가
    // required this.askp1,
    // required this.askp2,
    // required this.askp3,
    // required this.askp4,
    // required this.askp5,
    // required this.askp6,
    // required this.askp7,
    // required this.askp8,
    // required this.askp9,
    // required this.askp10,
    //
    // //매수호가
    // required this.bidp1,
    // required this.bidp2,
    // required this.bidp3,
    // required this.bidp4,
    // required this.bidp5,
    // required this.bidp6,
    // required this.bidp7,
    // required this.bidp8,
    // required this.bidp9,
    // required this.bidp10,
    //
    // //매도호가 잔량
    // required this.askp_rsqn1,
    // required this.askp_rsqn2,
    // required this.askp_rsqn3,
    // required this.askp_rsqn4,
    // required this.askp_rsqn5,
    // required this.askp_rsqn6,
    // required this.askp_rsqn7,
    // required this.askp_rsqn8,
    // required this.askp_rsqn9,
    // required this.askp_rsqn10,
    //
    // //매수호가 잔량
    // required this.bidp_rsqn1,
    // required this.bidp_rsqn2,
    // required this.bidp_rsqn3,
    // required this.bidp_rsqn4,
    // required this.bidp_rsqn5,
    // required this.bidp_rsqn6,
    // required this.bidp_rsqn7,
    // required this.bidp_rsqn8,
    // required this.bidp_rsqn9,
    //required this.bidp_rsqn10,

    // this.TOTAL_ASKP_RSQN,
    // this.TOTAL_BIDP_RSQN,
    String? TOTAL_ASKP_RSQN,
    String? TOTAL_BIDP_RSQN,
    // this.buyHogas,
    // this.buyRems,
    // this.sellHogas,
    // this.sellRems

    List<String>? buyHogas,
    List<String>?  buyRems,
    List<String>? sellHogas,
    List<String>? sellRems

  })
      : this.TOTAL_ASKP_RSQN  = TOTAL_ASKP_RSQN ?? '0',
        this.TOTAL_BIDP_RSQN  = TOTAL_BIDP_RSQN ?? '0',
        this.buyHogas = buyHogas ?? List<String>.filled(10, '0'),
        this.buyRems = buyRems ?? List<String>.filled(10, '0'),
        this.sellHogas = sellHogas ?? List<String>.filled(10, '0'),
        this.sellRems = sellRems ?? List<String>.filled(10, '0');

  factory HogaData.fromJSON(Map<String, dynamic> json) {
    List<String> buyHogas = []; // 매수호가 1~10
    List<String> buyRems = []; // 매수호가수량 1~10
    List<String> sellHogas = []; // 매도호가 1~10
    List<String> sellRems = []; // 매도호가수량 1~10

    for (int i = 0; i <10; i++) {
      buyHogas.add((json['BIDP${i + 1}'] ?? '0' as String).trim());
      buyRems.add((json['BIDP_RSQN${i + 1}'] ?? '0' as String).trim());
      // sellHogas.add((json['ASKP${i + 1}'] as String).trim());
      // sellRems.add((json['ASKP_RSQN${i + 1}'] as String).trim());
    }

    for (int i = 9; i >= 0; i--) {
      sellHogas.add((json['ASKP${i + 1}'] ?? '0' as String).trim());
      sellRems.add((json['ASKP_RSQN${i + 1}'] ?? '0' as String).trim());
    }

    return HogaData(
      TOTAL_ASKP_RSQN : json['TOTAL_ASKP_RSQN'] ?? '0' as String,
      TOTAL_BIDP_RSQN: json['TOTAL_BIDP_RSQN']  ?? '0' as String,
      buyHogas: buyHogas,
      buyRems: buyRems,
      sellHogas: sellHogas,
      sellRems: sellRems,
    );
  }

  static bool isAllFieldsZero(HogaData hogaData) {

    if (hogaData.TOTAL_ASKP_RSQN?.trim() == '0' &&
        hogaData.TOTAL_BIDP_RSQN?.trim() == '0' &&
        hogaData.buyHogas!.every((hoga) => hoga.trim() == '0') &&
        hogaData.buyRems!.every((rem) => rem.trim() == '0') &&
        hogaData.sellHogas!.every((hoga) => hoga.trim() == '0') &&
        hogaData.sellRems!.every((rem) => rem.trim() == '0')) {
      return true;
    }
    return false;
  }
}