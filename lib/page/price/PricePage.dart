import 'dart:convert';

import 'package:clone_mablemini/comm/SiseData.dart';
import 'package:clone_mablemini/manager/GlobalController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../comm/CheData.dart';
import '../../comm/HogaData.dart';
import '../hoga/HogaPageController.dart';
import 'PricePageController.dart';

class PricePage extends StatelessWidget {
  //final PricePageController _controller = PricePageController();
  final HogaPageController _hogaController = HogaPageController();
  final GlobalController _globalController = Get.find<GlobalController>();

  /// 포맷팅
  final NumberFormat priceFormat = new NumberFormat('###,###');
  final NumberFormat percentFormat = new NumberFormat('###,##0.00%');
  final DateFormat dateFormat = new DateFormat('yyyyMMdd');

  /// 체결 실시간 현재가 color
  var cheFlag = false;
  var prePrice = '0';
  var priceColor = Colors.black;

  /// 웹소켓 키
  late String _websocketKey;

  /// 현재 종목 코드, 종목명
  List selectedJm = [];

  PricePage(String selectedJmCode, String selectedJmName) {
    selectedJm = [selectedJmCode, selectedJmName];

    _hogaController.requestPRPR(selectedJm[0]);
    _hogaController.requestChe(selectedJm[0]);
    _hogaController.requestHoga(selectedJm[0]);
    setupWebSocket();
  }

  Widget build(BuildContext context) {

    /// 호가창 높이
    double hogaListHeight = (_globalController.pricePageHeight < 480)
        ? 480
        : _globalController.pricePageHeight;

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        children: [
          Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: hogaListHeight,
                    child: Obx(() {
                      if (_hogaController.hoga.value == null) {
                        return Container();
                      }
                      if (_hogaController.currentPrice.value == "") {
                        return Container();
                      }

                      var itemWidth = MediaQuery.of(context).size.width / 3;

                      var itemHeight = hogaListHeight / 2;
                      var listItemCount = 10;
                      var listItemHeight = (itemHeight / listItemCount) - 1;

                      var currentPrice = _hogaController.currentPrice.value;

                      var beforeClose =
                          _hogaController.hoga2.value.basePrice ?? '0';
                      var sellHogaArray =
                          _hogaController.hoga.value.sellHogas ?? [];
                      var sellRemArray =
                          _hogaController.hoga.value.sellRems ?? [];
                      var buyHogaArray =
                          _hogaController.hoga.value.buyHogas ?? [];
                      var buyRemArray =
                          _hogaController.hoga.value.buyRems ?? [];

                      var totalMaxRemArray = [];

                      if (sellRemArray != null) {
                        totalMaxRemArray.addAll(sellRemArray.getRange(
                            0, listItemCount) as Iterable);
                      }
                      if (buyRemArray != null) {
                        totalMaxRemArray.addAll(
                            buyRemArray.getRange(0, listItemCount) as Iterable);
                      }

                      var totalMaxRem = totalMaxRemArray.reduce(
                          (value, element) =>
                              int.parse(value) > int.parse(element)
                                  ? value
                                  : element);

                      var sellMaxRemArray = [];
                      sellMaxRemArray.addAll(
                          sellRemArray ?? [].getRange(0, listItemCount));
                      var sellMaxRem = sellMaxRemArray.reduce(
                          (value, element) =>
                              int.parse(value) > int.parse(element)
                                  ? value
                                  : element);

                      var buyMaxRemArray = [];
                      buyMaxRemArray
                          .addAll(buyRemArray ?? [].getRange(0, listItemCount));
                      var buyMaxRem = buyMaxRemArray.reduce((value, element) =>
                          int.parse(value) > int.parse(element)
                              ? value
                              : element);

                      return ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            childAspectRatio: itemWidth / itemHeight,
                            crossAxisCount: 3,
                            children: [
                              Container(
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: listItemCount,
                                  itemBuilder: (context, index) {
                                    int sellRem = 0;
                                    if (sellRemArray != null)
                                      sellRem = int.parse(sellRemArray[index]);
                                    int sellRatio = 0;

                                    if (int.parse(totalMaxRem) != 0) {
                                      sellRatio = (sellRem /
                                              int.parse(totalMaxRem) *
                                              1000)
                                          .toInt();
                                    }

                                    FontWeight sellWeight = FontWeight.normal;
                                    if (int.parse(sellMaxRem) == sellRem) {
                                      sellWeight = FontWeight.bold;
                                    }

                                    return Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: listItemHeight,
                                              padding: const EdgeInsets.all(2),
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                sellRem == 0
                                                    ? ''
                                                    : priceFormat
                                                        .format(sellRem),
                                                maxLines: 1,
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  //fontWeight: sellWeight
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: listItemHeight,
                                              padding: const EdgeInsets.only(
                                                  top: 3, bottom: 3),
                                              //color: Colors.blue.withAlpha(30),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1000 - sellRatio,
                                                      child: Container()),
                                                  Expanded(
                                                      flex: sellRatio,
                                                      child: Container(
                                                          color: Colors.blue
                                                              .withAlpha(50))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Colors.transparent),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: listItemCount,
                                itemBuilder: (context, index) {
                                  int sellClose = int.parse(beforeClose!);
                                  // int sellHoga =
                                  //     int.parse(sellHogaArray![4 - index]);
                                  int sellHoga =
                                      int.parse(sellHogaArray![index]);

                                  double sellRate =
                                      (sellClose - sellHoga).abs() / sellClose;

                                  Color sellColor = Colors.black;
                                  if (sellClose > sellHoga) {
                                    sellColor = Colors.blue;
                                  } else if (sellClose < sellHoga) {
                                    sellColor = Colors.red;
                                  } else {
                                    Colors.black;
                                    // sellColor = _hogaControllerMore.isDarkMode.value ? Colors.white : Colors.black;
                                  }

                                  Border sellBorder = Border.all(
                                      color: Colors.transparent, width: 0);
                                  if (int.parse(currentPrice == ''
                                          ? "0"
                                          : currentPrice) ==
                                      sellHoga) {
                                    sellBorder = Border.all(
                                        color:
                                            //sellColor
                                            Color(0xfffffcb2d),
                                        width: 2);
                                  }

                                  return Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: listItemHeight,
                                            padding: const EdgeInsets.all(1),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    sellHoga == 0
                                                        ? ''
                                                        : priceFormat
                                                            .format(sellHoga),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    percentFormat.format(
                                                                sellRate) ==
                                                            '100.00%'
                                                        ? ''
                                                        : percentFormat
                                                            .format(sellRate),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: sellColor,
                                                        // fontSize:
                                                        //     15
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            child: Container(
                                              height: listItemHeight,
                                              decoration: BoxDecoration(
                                                  border: sellBorder),
                                            ),
                                            onTap: () {
                                              bool asd = true;
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.transparent)
                                    ],
                                  );
                                },
                              ),
                              Obx(() {
                                double preDayVolume = double.parse(
                                    _hogaController.hoga2.value.volume ?? '0');

                                //정적 상한가 (시가의 +10%)
                                double svi_uplmtprice = double.parse(
                                        _hogaController.hoga2.value.open ??
                                            '0') *
                                    0.01;
                                svi_uplmtprice =
                                    (svi_uplmtprice + svi_uplmtprice * 0.1)
                                            .roundToDouble() *
                                        100;
                                //svi_uplmtprice += svi_uplmtprice*0.10;

                                //정적 하한가 (시가의 -10%)
                                double svi_dnlmtprice = double.parse(
                                        _hogaController.hoga2.value.open ??
                                            '0') *
                                    0.01;
                                //svi_dnlmtprice -= svi_dnlmtprice*0.1;
                                svi_dnlmtprice =
                                    (svi_dnlmtprice - svi_dnlmtprice * 0.1)
                                            .roundToDouble() *
                                        100;

                                //상한가
                                double uplmtprice = double.parse(

                                    //double uplmtprice = double.parse(_hogaController.hoga.value.upPrice ?? '0');
                                    _hogaController.hoga2.value.upPrice ?? '0');
                                //하한가
                                //double dnlmtprice = double.parse(_hogaController.hoga.value.downPrice ??'0');
                                double dnlmtprice = double.parse(
                                    _hogaController.hoga2.value.downPrice ??
                                        '0');

                                double jnilclose =
                                    // double.parse(_hogaController.hoga2.value.jnilclose ?? '0');
                                    double.parse(
                                        _hogaController.hoga2.value.basePrice ??
                                            '0');

                                //시가
                                double open = double.parse(
                                    _hogaController.hoga2.value.open ?? '0');
                                //고가
                                double high = double.parse(
                                    _hogaController.hoga2.value.high ?? '0');
                                //저가
                                double low = double.parse(
                                    _hogaController.hoga2.value.low ?? '0');

                                return Container(
                                  alignment: Alignment.bottomCenter,
                                  color: const Color(0XFFF4F5F8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          height: hogaListHeight / 8 - 1,
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              sise1('start', '전일거래량'),
                                              sise1('end', '1,530,900'),
                                              sise1('start', '거래대금'),
                                              sise1('end', '673억원'),
                                            ],
                                          )),
                                      const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Color(0xffdee0e3)),
                                      Container(
                                          height: hogaListHeight / 8 - 1,
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              sise2('기준가',
                                                  '${priceFormat.format(jnilclose)}'),
                                              sise2('상한가',
                                                  '${priceFormat.format(uplmtprice)}'),
                                              sise2('하한가',
                                                  '${priceFormat.format(dnlmtprice)}'),
                                            ],
                                          )),
                                      const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Color(0xffdee0e3)),
                                      Expanded(
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 0, 10, 0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  sise3('시', open, 'test',
                                                      jnilclose),
                                                  sise3('고', high, 'test',
                                                      jnilclose),
                                                  sise3('저', low, 'test',
                                                      jnilclose)
                                                ],
                                              ))),
                                      const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Color(0xffdee0e3)),
                                      Container(
                                          height: hogaListHeight / 20 - 1,
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              sise2('외인비율',
                                                  '${_hogaController.hoga2.value.frgnEhrt}%'),
                                            ],
                                          ))
                                    ],
                                  ),
                                );
                              }),
                              Obx(() {
                                double degree =
                                    _hogaController.contract.value.array.isEmpty
                                        ? 0
                                        : double.parse(_hogaController.contract
                                            .value.array.first.chdegree);

                                Color degreeColor;
                                if (degree > 100) {
                                  degreeColor = Colors.red;
                                } else if (degree < 100) {
                                  degreeColor = Colors.blue;
                                } else {
                                  degreeColor = Colors.black;
                                }
                                return Container(
                                  height: listItemHeight,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              color: const Color(0xFFedeff2),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    '체결강도',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    '$degree%',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color:
                                                            degreeColor,
                                                        // Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                child: ListView.builder(
                                                    physics:
                                                        const ClampingScrollPhysics(),
                                                    itemCount: _hogaController
                                                        .contract
                                                        .value
                                                        .array
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return cheList(
                                                          _hogaController
                                                              .contract
                                                              .value
                                                              .array[index]);
                                                    }))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: listItemCount,
                                itemBuilder: (context, index) {
                                  int buyClose = int.parse(beforeClose!);
                                  int buyHoga = int.parse(buyHogaArray![index]);
                                  double buyRate =
                                      (buyClose - buyHoga).abs() / buyClose;

                                  Color buyColor = Colors.black;
                                  if (buyClose > buyHoga) {
                                    buyColor = Colors.blue;
                                  } else if (buyClose < buyHoga) {
                                    buyColor = Colors.red;
                                  } else {
                                    Colors.black;
                                    //buyColor = _hogaControllerMore.isDarkMode.value ? LightColors.basic : Colors.black;
                                  }

                                  Border buyBorder = Border.all(
                                      color: Colors.transparent, width: 0);
                                  if (int.parse(currentPrice == ''
                                          ? "0"
                                          : currentPrice) ==
                                      buyHoga) {
                                    buyBorder = Border.all(
                                        color:
                                            //buyColor
                                            Color(0xfffffcb2d),
                                        width: 2);
                                  }

                                  return Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: listItemHeight,
                                            padding: const EdgeInsets.all(1),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    buyHoga == 0
                                                        ? ''
                                                        : priceFormat
                                                            .format(buyHoga),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    percentFormat.format(
                                                                buyRate) ==
                                                            '100.00%'
                                                        ? ''
                                                        : percentFormat
                                                            .format(buyRate),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: buyColor,
                                                        // fontSize:
                                                        //     15
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            child: Container(
                                              height: listItemHeight,
                                              decoration: BoxDecoration(
                                                  border: buyBorder),
                                            ),
                                            onTap: () {
                                              bool asd = true;
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.transparent),
                                    ],
                                  );
                                },
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: listItemCount,
                                itemBuilder: (context, index) {
                                  int buyRem = int.parse(buyRemArray != null
                                      ? buyRemArray[index]
                                      : '');
                                  int buyRatio = 0;

                                  if (int.parse(totalMaxRem) != 0) {
                                    buyRatio =
                                        (buyRem / int.parse(totalMaxRem) * 1000)
                                            .toInt();
                                  }

                                  FontWeight buyWeight = FontWeight.normal;
                                  if (int.parse(buyMaxRem) == buyRem) {
                                    buyWeight = FontWeight.bold;
                                  }

                                  return Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: listItemHeight,
                                            padding: const EdgeInsets.all(1),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              buyRem == 0
                                                  ? ''
                                                  : priceFormat.format(buyRem),
                                              maxLines: 1,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                // color: _hogaControllerMore.isDarkMode.value
                                                //     ? LightColors.basic
                                                //     : Colors.black,
                                                fontSize: 12,
                                                //fontWeight: buyWeight
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: listItemHeight,
                                            padding: const EdgeInsets.only(
                                                top: 3, bottom: 3),
                                            // color: Colors.red.withAlpha(30),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: buyRatio,
                                                    child: Container(
                                                        color: Colors.red
                                                            .withAlpha(50))),
                                                Expanded(
                                                    flex: 1000 - buyRatio,
                                                    child: Container()),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.transparent),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ));
                    }),
                  ),
                ],
              )),
        ],
      ))),
    );
  }

  Widget sise1(
    String alignment,
    String? text,
  ) {
    MainAxisAlignment mainalignment = MainAxisAlignment.start;
    if (alignment == 'end') {
      mainalignment = MainAxisAlignment.end;
    } else {
      mainalignment = MainAxisAlignment.start;
    }
    return Row(
        mainAxisAlignment: mainalignment,
        children: [Text(text ?? '', style: const TextStyle(fontSize: 10))]);
  }

  Widget sise2(String text, String text2) {
    Color color;
    if (text == '상한가') {
      color = Colors.red;
    } else if (text == '하한가') {
      color = Colors.blue;
    } else {
      color = Colors.black;
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(text, style: TextStyle(fontSize: 10, color: color)),
      Text(text2, style: TextStyle(fontSize: 10, color: color))
    ]);
  }

  Widget sise3(String text, double price, String text3, double basePrice) {
    double doublePercent = (price - basePrice) / basePrice * 100;
    String percent = doublePercent.abs().toStringAsFixed(2);
    // double doublePercent = 0;
    // String percent = '0';
    //
    // if(price != 0){
    //   doublePercent = (price-basePrice) / basePrice * 100;
    //   percent = doublePercent.abs().toStringAsFixed(2);
    // }
    var formatPrice = priceFormat.format(price);

    var sign = '';
    Color color;
    if (doublePercent < 0) {
      sign = '-';
    }

    if (text == '시') {
      color = Colors.grey;
    } else if (text == '고') {
      color = Colors.red;
    } else {
      color = Colors.blue;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
                child: Column(children: [
              Text(text,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold))
            ]))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatPrice, style: const TextStyle(fontSize: 10)),
            Text('$sign$percent%',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: doublePercent < 0
                        ? Colors.blue
                        : doublePercent > 0
                            ? Colors.red
                            : Colors.black))
          ],
        )
      ],
    );
  }

  Widget cheList(CheDataArray? cheData) {
    if (cheData == null) {
      return Container();
    }
    cheFlag == true ? realPriceColor(cheData.price) : null;

    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            priceFormat.format(double.parse(cheData.price)),
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          Text(
            formatNumber(int.parse(cheData.volume)),
            maxLines: 1,
            style: TextStyle(
                color: prePrice == '0' ? valueColor(cheData.sign) : priceColor,
                fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 체결 거래량 컬러(real)
  realPriceColor(String nowPrice) {
    int intPrePrice = int.parse(prePrice);
    int intNowPrice = int.parse(nowPrice);

    if (intPrePrice < intNowPrice) {
      priceColor = Colors.red;
    } else if (intPrePrice > intNowPrice) {
      priceColor = Colors.blue;
    }

    prePrice = nowPrice;
  }

  /// 체결 거래량 컬러(request)
  Color valueColor(String sign) {
    if (sign == '1' || sign == '2') {
      return Colors.red;
    } else if (sign == '4' || sign == '5') {
      return Colors.blue;
    } else {
      return Colors.black;
    }
  }

  /// 호가 실시간
  void requestRealHoga(String websocketKey, String jmCode) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    var url = 'http://203.109.30.207:10001/requestReal';
    var body = jsonEncode({
      'header': {'sessionKey': websocketKey, 'tr_type': '1'},
      'objCommInput': {"tr_id": "H0STASP0", 'tr_key': jmCode},
      'rqName': '',
      'trCode': '/uapi/domestic-stock/v1/quotations/requestReal',
    });


    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      // final responseData = jsonDecode(response.body);
      // String decodedBody = utf8.decode(response.bodyBytes);
      // var decodedJson = jsonDecode(decodedBody);
    } else {
      print('requestRealHoga failed with status: ${response.statusCode}');
    }
  }

  /// 체결 실시간
  void requestRealChe(String websocketKey, String jmCode) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    var url = 'http://203.109.30.207:10001/requestReal';
    var body = jsonEncode({
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"tr_id": "H0STCNT0", "tr_key": jmCode},
      "rqName": "",
      "trCode": "/uapi/domestic-stock/v1/quotations/requestReal"
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {

    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  /// 러쉬 테스트
  void requestRush(String websocketKey) async {
    final headers = {'Content-Type': 'application/json;charset=utf-8'};

    // 러쉬테스트
    print('러쉬테스트');
    var url = 'http://203.109.30.207:10001/rushtest';
    var body = jsonEncode({
      "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
      "rqName": "",
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"count": "2", "tr_id": "H0STCNT0"}
    });

    final response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
    } else {
      if (_globalController.isRushTest.value == true) {
        _hogaController.hoga.value = _globalController.hogaPreData;
      }

      print('requestRush failed with status: ${response.statusCode}');
    }
  }

  void setupWebSocket() {

    // 현재 호가 소켓채널이 연결되었는지 확인하고 연결되었으면 끊어주기
    if (_globalController.hogaWebSocketChannel.value != null) {
      _globalController.hogaWebSocketChannel.value?.sink.close();
    }

    try {
      _globalController.hogaWebSocketChannel.value = WebSocketChannel.connect(
          Uri.parse('ws://203.109.30.207:10001/connect'));

      if (_globalController.hogaWebSocketChannel.value != null) {
        print('WebSocket connection opened');
      }

      _globalController.hogaWebSocketChannel.value?.stream.listen((message) {
        try {
          final data = jsonDecode(message);
          if (data['Data'] != null && data['Data']['websocketkey'] != null) {
            _websocketKey = data['Data']['websocketkey'];
            print('WebSocket Key: $_websocketKey');

            if (_globalController.isRushTest.value == false) {
              //호가
              requestRealHoga(_websocketKey, selectedJm[0]);

              //체결
              requestRealChe(_websocketKey, selectedJm[0]);
            } else {
              // 러쉬테스트
              requestRush(_websocketKey);
            }
          } else {
            if (data['TrCode'] == "H0STCNT0") {
              cheFlag = true;

              _hogaController.currentPrice.value = data['Data']['STCK_PRPR'] ?? '';

              _hogaController.contract.value.array
                  .insert(0, CheDataArray.fromJson(data['Data']));

            }else if (data['TrCode'] == "H0STASP0") {
              _hogaController.hoga.value = HogaData.fromJSON(data['Data']);
              _globalController.hogaPreData = _hogaController.hoga.value;
            }

            // 러쉬테스트 데이터
            else if (data['num'] != null) {
              // 현재 종목코드와 러쉬테스트 데이터의 종목코드가 같을 경우만 업데이트.
              if (data['trKey'] == selectedJm[0]) {
                var rushData = jsonDecode(data['output']);

                var set = HogaData.isAllFieldsZero(_hogaController.hoga.value);

                if (set) {
                  _hogaController.hoga.value = _globalController.hogaPreData;
                }
                // 호가 러쉬테스트
                if (rushData['TrCode'] == "H0STASP0") {
                  if (rushData != null && rushData['Data'] != null) {
                    var tempdata = HogaData.fromJSON(rushData['Data']);

                    // 데이터가 모두 '0'이면 화면 업데이트 안함
                    if (!HogaData.isAllFieldsZero(tempdata)) {
                      _hogaController.hoga.value = tempdata;
                      _globalController.hogaPreData =
                          _hogaController.hoga.value;
                    } else {
                      _hogaController.hoga.value =
                          _globalController.hogaPreData;
                    }
                    // _hogaController.hoga.value =
                    //     HogaData.fromJSON(rushData['Data']);

                    //print('호가 rushtest');
                  }
                }

                // 체결 러쉬테스트
                else if (rushData['TrCode'] == "H0STCNT0") {
                  if (rushData != null && rushData['Data'] != null) {
                    // print(data['num']);

                    // String STCK_PRPR =
                    //     (rushData?['Data']?['STCK_PRPR'] ?? '') as String;
                    //
                    // _hogaController.currentPrice.value = STCK_PRPR;

                    _hogaController.contract.value.array
                        .insert(0, CheDataArray.fromJson(rushData['Data']));

                    // print('체결 rushtest');
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error processing WebSocket message: $e');
        }
      }, onError: (error) {
        print('WebSocket error: $error');
      }, onDone: () {
        print('WebSocket connection closed');
      });
    } catch (e) {
      print('WebSocket connection error: $e');
    }
  }


}

String formatNumber(int number) {
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}

String sign = '';

Widget makePrice(String prc, String prct, String updwn) {
  Color updwnColor = updownColor(updwn);

  return Row(children: [
    Text(sign, style: TextStyle(color: updwnColor, fontSize: 12)),
    Text('$prc원', style: TextStyle(color: updwnColor, fontSize: 12)),
    Text(' ($prct%)', style: TextStyle(color: updwnColor, fontSize: 12)),
  ]);
}

Color updownColor(String updwn) {
  var updown = int.parse(updwn);

  if (updown < 3) {
    sign = '▲ ';
    return const Color(0xFFF24430);
  } else if (updown == 3) {
    sign = "";
    return const Color(0xFF50505B);
  } else {
    sign = '▼ ';
    return const Color(0xFF4881FF);
  }
}
