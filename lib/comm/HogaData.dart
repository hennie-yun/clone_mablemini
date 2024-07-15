import 'dart:convert';
import 'dart:ffi';

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

    this.TOTAL_ASKP_RSQN,
    this.TOTAL_BIDP_RSQN,
    // this.buyHogas,
    // this.buyRems,
    // this.sellHogas,
    // this.sellRems

    List<String>? buyHogas,
    List<String>?  buyRems,
    List<String>? sellHogas,
    List<String>? sellRems

  })
      : this.buyHogas = buyHogas ?? List<String>.filled(10, '0'),
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

  // receiveH0STASP0(data) {
  //   try {
  //     // 서버로부터 수신된 데이터 처리
  //     var receivedData = jsonDecode(data.toString());
  //     if (receivedData['header']['tr_id'] != "PINGPONG") {
  //       List<String> decodedMessage = receivedData.split('|');
  //
  //       // 필요에 따라 Map에 저장
  //       Map<String, dynamic> resultMap = {
  //         'success': decodedMessage[0],
  //         'tr_id': decodedMessage[1],
  //         'code': decodedMessage[2],
  //         'data': decodedMessage[3],
  //         // ... 추가 필드들을 필요에 따라 계속 추가
  //       };
  //       _controller.hoga.value;
  //       List<String> JmMg = resultMap['data'].split('^');
  //
  //       Map<String, String> jmData = {
  //         'jmCode': JmMg[0], //종목코드
  //         'askp1': JmMg[3], //매도호가
  //         'askp2': JmMg[4], //매도호가
  //         'askp3': JmMg[5], //매도호가
  //         'askp4': JmMg[6], //매도호가
  //         'askp5': JmMg[7], //매도호가
  //         'askp6': JmMg[8], //매도호가
  //         'askp7': JmMg[9], //매도호가
  //         'askp8': JmMg[10], //매도호가
  //         'askp9': JmMg[11], //매도호가
  //         'askp10': JmMg[12], //매도호가
  //         'bidp1': JmMg[13], //매수호가
  //         'bidp2': JmMg[14], //매수호가
  //         'bidp3': JmMg[15], //매수호가
  //         'bidp4': JmMg[16], //매수호가
  //         'bidp5': JmMg[17], //매수호가
  //         'bidp6': JmMg[18], //매수호가
  //         'bidp7': JmMg[19], //매수호가
  //         'bidp8': JmMg[20], //매수호가
  //         'bidp9': JmMg[21], //매수호가
  //         'bidp10': JmMg[22], //매수호가
  //         'askp_rsqn1': JmMg[23], //매도호가 잔량
  //         'askp_rsqn2': JmMg[24], //매도호가 잔량
  //         'askp_rsqn3': JmMg[25], //매도호가 잔량
  //         'askp_rsqn4': JmMg[26], //매도호가 잔량
  //         'askp_rsqn5': JmMg[27], //매도호가 잔량
  //         'askp_rsqn6': JmMg[28], //매도호가 잔량
  //         'askp_rsqn7': JmMg[29], //매도호가 잔량
  //         'askp_rsqn8': JmMg[30], //매도호가 잔량
  //         'askp_rsqn9': JmMg[31], //매도호가 잔량
  //         'askp_rsqn10': JmMg[32], //매도호가 잔량
  //         'bidp_rsqn1': JmMg[33], //매수호가 잔량
  //         'bidp_rsqn2': JmMg[34], //매수호가 잔량
  //         'bidp_rsqn3': JmMg[35], //매수호가 잔량
  //         'bidp_rsqn4': JmMg[36], //매수호가 잔량
  //         'bidp_rsqn5': JmMg[37], //매수호가 잔량
  //         'bidp_rsqn6': JmMg[38], //매수호가 잔량
  //         'bidp_rsqn7': JmMg[39], //매수호가 잔량
  //         'bidp_rsqn8': JmMg[40], //매수호가 잔량
  //         'bidp_rsqn9': JmMg[41], //매수호가 잔량
  //         'bidp_rsqn10': JmMg[42], //매수호가 잔량
  //         'TOTAL_ASKP_RSQN': JmMg[43], //총 매도호가 잔량
  //         'TOTAL_BIDP_RSQN': JmMg[44], //총 매수호가 잔량
  //         // ... 추가 필드들을 필요에 따라 계속 추가
  //       };
  //
  //       _controller.hoga.value; // 이 부분에서 hoga 데이터 처리 코드 추가 필요
  //     } else {}
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}