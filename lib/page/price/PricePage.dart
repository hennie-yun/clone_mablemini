import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:clone_mablemini/comm/SiseData.dart';
import 'package:clone_mablemini/page/hoga/HogaPage.dart';
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


import '../hoga/CheData.dart';
import '../hoga/HogaData.dart';
import '../hoga/HogaData2.dart';
import '../hoga/HogaPageController.dart';
import 'PricePageController.dart';



class PricePage extends StatelessWidget {


  final PricePageController _controller = PricePageController();

 // final HogaPageController _hogaController = Get.put(HogaPageController());
  final HogaPageController _hogaController = HogaPageController();
  /// 포맷팅
  final NumberFormat priceFormat = new NumberFormat('###,###');
  final NumberFormat percentFormat = new NumberFormat('###,##0.00%');
  final DateFormat dateFormat = new DateFormat('yyyyMMdd');


  late WebSocketChannel _webSocketChannel;



  late String _websocketKey;
  List selectedJm = [];

  PricePage(String selectedJmCode, String selectedJmName) {
    selectedJm = [selectedJmCode, selectedJmName];

    _requestData(selectedJm[0]);
    _hogaController.requestPRPR(selectedJm[0]);
    _hogaController.requestChe(selectedJm[0]);
    _hogaController.requestHoga(selectedJm[0]);
  }

  void _setupWebSocket() async {
    try {

        _webSocketChannel = WebSocketChannel.connect(
            Uri.parse('ws://203.109.30.207:10001/connect'));

        _webSocketChannel.stream.listen((message) async {
        try {
          final data = jsonDecode(message);
          if (data['Data'] != null && data['Data']['websocketkey'] != null) {
            _websocketKey = data['Data']['websocketkey'];
            print('WebSocket Key: $_websocketKey');
            requestRealHoga(_websocketKey,selectedJm[0]);
            //requestRealChe(_websocketKey,selectedJm[0]);


            await _requestReal(_websocketKey, selectedJm[0]);
          } else {
            if (data['TrCode'] == "H0STCNT0") {
              _controller.siseList.clear();
              String STCK_PRPR = data['Data']['STCK_PRPR'] ?? '';
              String PRDY_VRSS_SIGN = data['Data']['PRDY_VRSS_SIGN'] ?? '';
              String PRDY_VRSS = data['Data']['PRDY_VRSS'] ?? '';
              String PRDY_CTRT = data['Data']['PRDY_CTRT'] ?? '';

              SiseData newData = SiseData(
                STCK_PRPR: STCK_PRPR,
                PRDY_VRSS_SIGN: PRDY_VRSS_SIGN,
                PRDY_VRSS: PRDY_VRSS,
                PRDY_CTRT: PRDY_CTRT,
                JmName: selectedJm[1],
              );

              _controller.siseList.add(newData);

              _hogaController.currentPrice.value = _controller.siseList[0].STCK_PRPR;
              _hogaController.contract.value.array.insert(0,CheDataArray.fromJson(data['Data']));
              if(_hogaController.contract.value.array.length >= 30){
                _hogaController. contract.value.array.removeLast();
              }
            }
            if (data['TrCode'] == "H0STASP0" ) {
              _hogaController.hoga.value = HogaData.fromJSON(data['Data']);
            }


            if(data['trKey'] == '031860' ){
              var rushData = jsonDecode(data['output']);

              // 호가 러쉬테스트
              if(rushData['TrCode'] == "H0STASP0" ) {
                if (rushData != null && rushData['Data'] != null) {
                  print(data['num']);
                  _hogaController.hoga.value =
                      HogaData.fromJSON(rushData['Data']);

                  print('호가 rushtest');
                }
              }

              // 체결 러쉬테스트
              if(rushData['TrCode'] == "H0STCNT0" ) {
                if (rushData != null && rushData['Data'] != null) {
                  print(data['num']);
                  _controller.siseList.clear();
                  String STCK_PRPR = rushData['Data']['STCK_PRPR'] ?? '';
                  String PRDY_VRSS_SIGN = rushData['Data']['PRDY_VRSS_SIGN'] ?? '';
                  String PRDY_VRSS = rushData['Data']['PRDY_VRSS'] ?? '';
                  String PRDY_CTRT = rushData['Data']['PRDY_CTRT'] ?? '';

                  SiseData newData = SiseData(
                    STCK_PRPR: STCK_PRPR,
                    PRDY_VRSS_SIGN: PRDY_VRSS_SIGN,
                    PRDY_VRSS: PRDY_VRSS,
                    PRDY_CTRT: PRDY_CTRT,
                    JmName: selectedJm[1],
                  );

                  _controller.siseList.add(newData);

                  _hogaController.currentPrice.value = _controller.siseList[0].STCK_PRPR;
                  _hogaController.contract.value.array.insert(0,CheDataArray.fromJson(rushData['Data']));
                  if(_hogaController.contract.value.array.length >= 30){
                    _hogaController. contract.value.array.removeLast();
                  }

                  print('체결 rushtest');
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

  Future<void> _requestData(String value) async {
    print(value);
    final headers = {'Content-Type': 'application/json;charset=utf-8'};
    final body = jsonEncode({
      "trCode": "/uapi/domestic-stock/v1/quotations/S0004",
      "rqName": "",
      "header": {"tr_id": "1"},
      "objCommInput": {"SHCODE": value}
    });

    final response = await http.post(
      Uri.parse('http://203.109.30.207:10001/request'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['TrCode'] ==
          "/uapi/domestic-stock/v1/quotations/S0004") {
        SiseData siseData =
            SiseData.fromJson(responseData["Data"]["output"], value);
        print(siseData);
        _controller.siseList.add(siseData);
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }

    _setupWebSocket();
  }

  Future<void> _requestReal(String websocketKey, String jmCode) async {


    final headers = {'Content-Type': 'application/json;charset=utf-8'};

    const url = 'http://203.109.30.207:10001/requestReal';
    final body = jsonEncode({
      "trCode": "/uapi/domestic-stock/v1/quotations/requestReal",
       "rqName": "",
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"tr_key": jmCode, "tr_id": "H0STCNT0"}
    });

    // 체결 러쉬테스트
    // const url = 'http://203.109.30.207:10001/rushtest';
    // final body = jsonEncode({
    //   "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
    //   "rqName": "",
    //   "header": {"sessionKey": websocketKey, "tr_type": "1"},
    //   "objCommInput": {"count": "2", "tr_id": "H0STCNT0"}
    // });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  Widget build(BuildContext context) {

    //final double hogaListHeight = MediaQuery.of(context).size.height ;
    final double hogaListHeight = 650;
    return  Scaffold(
      body: SingleChildScrollView(child: Obx(() {
        if (_controller.siseList.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(selectedJm[1], style: TextStyle(fontSize: 22)),
                            // Container(
                            //   height: 30,
                            //   width: 30,
                            //   decoration: BoxDecoration(
                            //     shape: BoxShape.circle,
                            //     color: Colors.grey.withOpacity(0.1),
                            //   ),
                            //   child: IconButton(
                            //     padding: EdgeInsets.zero,
                            //     onPressed: () {},
                            //     iconSize: 24.0,
                            //     icon: const Icon(Icons.push_pin_outlined),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Text(
                        '${formatNumber(int.parse( _controller.siseList[0].STCK_PRPR))}원',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                      ),
                      makePrice(
                          _controller.siseList[0].PRDY_VRSS, // 전일 대비
                          _controller.siseList[0].PRDY_CTRT, // 전일 대비율
                          _controller.siseList[0].PRDY_VRSS_SIGN // 전일 대비 부호
                          ),

                     Container(
                                  // height: hogaListHeight*1.3,
                                  //height: hogaListHeight,
                                  child: Obx(() {
                                    if (_hogaController.hoga.value == null) {
                                      // request1101();
                                      //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                                      //requestFHKST01010200(_hogaController.jmCode.value);

                                      print('_hogaController.hoga.value가 null');

                                      ///requestT1101(_hogaController.jmCode.value);
                                      //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                      return Container();
                                    }
                                    if (_hogaController.currentPrice.value == "") {
                                      //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                                      //requestFHKST01010200(_hogaController.jmCode.value);
                                      print('_hogaController.currentPrice.value 가 ""');

                                      ///requestT1101(_hogaController.jmCode.value);
                                      //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                      return Container();
                                    }
                                    // var itemWidth = isBigScreen ? deviceWidth / 10.8 : deviceWidth / 3;
                                    var itemWidth = MediaQuery.of(context).size.width / 3;

                                    var itemHeight = hogaListHeight / 2;
                                    var listItemCount = 10;
                                    var listItemHeight = (itemHeight / listItemCount)-1 ;

                                    // print('높이');
                                    // print('hogaListHeight');
                                    // print(hogaListHeight);
                                    // print('itemHeight');
                                    // print(itemHeight);
                                    // print('listItemHeight');
                                    // print(listItemHeight);

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

                                    //2024.02 벌고해 프로젝트_개편관련_김진겸 end

                                    var totalMaxRemArray = [];

                                    if (sellRemArray != null) {
                                      totalMaxRemArray.addAll(sellRemArray.getRange(
                                          0, listItemCount) as Iterable);
                                    }
                                    if (buyRemArray != null) {
                                      totalMaxRemArray.addAll(buyRemArray.getRange(
                                          0, listItemCount) as Iterable);
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
                                    buyMaxRemArray.addAll(
                                        buyRemArray ?? [].getRange(0, listItemCount));
                                    var buyMaxRem = buyMaxRemArray.reduce(
                                            (value, element) =>
                                        int.parse(value) > int.parse(element)
                                            ? value
                                            : element);

                                    return
                                      // ScrollConfiguration(
                                      // behavior: ScrollConfiguration.of(context)
                                      //     .copyWith(scrollbars: false),
                                      // child:
                                      GridView.count(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        childAspectRatio: itemWidth / itemHeight,
                                        crossAxisCount: 3,
                                        children: [
                                          Container(
                                           // height:hogaListHeight,
//height:hogaListHeight/2,
                                          //constraints: BoxConstraints( minHeight:325),

                                      height:325,

                                            child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listItemCount,
                        itemBuilder: (context, index) {

                          int sellRem = 0;
                          if (sellRemArray != null)
                            sellRem =
                                int.parse(sellRemArray[ index ]);
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
                                    padding: EdgeInsets.all(2),
                                    alignment:
                                    Alignment.centerRight,
                                    child: AutoSizeText(
                                      sellRem == 0
                                          ? ''
                                          : priceFormat
                                          .format(sellRem),
                                      maxLines: 1,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: sellWeight),
                                    ),
                                  ),
                                  Container(
                                    height: listItemHeight,
                                    padding: EdgeInsets.only(
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
                                                    .withAlpha(
                                                    50))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.transparent),
                            ],
                          );
                        },
                                            ),
                                          ),

                                          ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: listItemCount,
                                            itemBuilder: (context, index) {
                        int sellClose = int.parse(beforeClose!);
                        // int sellHoga =
                        //     int.parse(sellHogaArray![4 - index]);
                        int sellHoga =
                        int.parse(sellHogaArray![index]);

                        double sellRate =
                            (sellClose - sellHoga).abs() /
                                sellClose;

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
                              color: sellColor, width: 2);
                        }

                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: listItemHeight,
                                  padding: EdgeInsets.all(1),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          sellHoga == 0
                                              ? ''
                                              : priceFormat
                                              .format(sellHoga),
                                          textAlign:
                                          TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        child: AutoSizeText(
                                          percentFormat.format(
                                              sellRate) ==
                                              '100.00%'
                                              ? ''
                                              : percentFormat
                                              .format(sellRate),
                                          maxLines: 1,
                                          textAlign:
                                          TextAlign.right,
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
                                    /*OrderConfirmDialog.move(
                                            context,
                                            _hogaController.sise.value,
                                            sellHogaArray[4 - index],
                                            1,
                                            onConfirm: () {
                                              if (accountList[mainAccount].pwd != "") {
                                                _goSetCount(context,
                                                    price: sellHogaArray[4 - index]);
                                              } else {
                                                Future.delayed(
                                                    const Duration(seconds: 0),
                                                        () => showKeyBoard(context));
                                              }
                                            },
                                          )..show();*/
                                    bool asd = true;

                                    /// _goToTransPage(sellHogaArray[4 - index], asd);
                                  },
                                ),
                              ],
                            ),
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.transparent)
                          ],
                        );
                                            },
                                          ),

                                          Obx(() {
                                            // if (_hogaController.hogaInfo.value == null) {
                                            //   return Container();
                                            // }
                                            //전일 거래량
                                            //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                                            // double preDayVolume = double.parse(
                                            //     (master[_hogaController.jmCode.value]
                                            //             ?.preDayVolume) ??
                                            //         '0');
                                            double preDayVolume = double.parse(
                          _hogaController.hoga2.value.volume ?? '0');
                                            //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                            //정적 상한가 (시가의 +10%)
                                            double svi_uplmtprice = double.parse(
                          _hogaController.hoga2.value.open ?? '0') *
                          0.01;
                                            svi_uplmtprice =
                          (svi_uplmtprice + svi_uplmtprice * 0.1)
                              .roundToDouble() *
                              100;
                                            //svi_uplmtprice += svi_uplmtprice*0.10;

                                            //정적 하한가 (시가의 -10%)
                                            double svi_dnlmtprice = double.parse(
                          _hogaController.hoga2.value.open ?? '0') *
                          0.01;
                                            //svi_dnlmtprice -= svi_dnlmtprice*0.1;
                                            svi_dnlmtprice =
                          (svi_dnlmtprice - svi_dnlmtprice * 0.1)
                              .roundToDouble() *
                              100;

                                            //상한가
                                            double uplmtprice = double.parse(
                        //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                        //double uplmtprice = double.parse(_hogaController.hoga.value.upPrice ?? '0');
                          _hogaController.hoga2.value.upPrice ?? '0');
                                            //하한가
                                            //double dnlmtprice = double.parse(_hogaController.hoga.value.downPrice ??'0');
                                            double dnlmtprice = double.parse(
                          _hogaController.hoga2.value.downPrice ?? '0');
                                            //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                            //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                                            //기준가
                                            // double recprice = double.parse(
                                            //     master[_hogaController.hoga.value]
                                            //             ?.basePrice ??
                                            //         '0');
                                            double jnilclose =
                                            // double.parse(_hogaController.hoga2.value.jnilclose ?? '0');
                                            double.parse(
                          _hogaController.hoga2.value.basePrice ??
                              '0');
                                            //2024.02 벌고해 프로젝트_개편관련_김진겸 end
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
                        //padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                        alignment: Alignment.bottomCenter,
                        color: Color(0XFFF4F5F8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(height:hogaListHeight/8 -1,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    sise1('start','전일거래량'),
                                    sise1('end','1,530,900'),
                                    sise1('start','거래대금'),
                                    sise1('end','673억원'),
                                  ],
                                )
                            ),
                            Divider(height: 1, thickness: 1, color: Colors.grey),
                            Container(height:hogaListHeight/8 -1,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    sise2('기준가','${priceFormat.format(jnilclose)}'),
                                    sise2('상한가','${priceFormat.format(uplmtprice)}'),
                                    sise2('하한가','${priceFormat.format(dnlmtprice)}'),
                                  ],
                                )
                            ),
                            Divider(height: 1, thickness: 1, color: Colors.grey),
                            Expanded(child:Container(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    sise3('시',open,'test',jnilclose ),
                                    sise3('고',high,'test',jnilclose),
                                    sise3('저',low,'test',jnilclose)
                                  ],
                                ))),
                            Divider(height: 1, thickness: 1, color: Colors.grey),
                            Container(height:hogaListHeight/20 -1,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    sise2('외인비율','${_hogaController.hoga2.value.frgnEhrt}%'),
                                  ],
                                ))

                          ],
                        ),
                                            );
                                          }),
                                          Obx(() {
                                            // if (_hogaController.contract.value.array.isEmpty) {
                                            //   return Container();
                                            // }

                                            double degree =
                                            _hogaController.contract.value.array.isEmpty
                          ? 0
                          : double.parse(_hogaController.contract
                          .value.array.first.chdegree);

                                            return Container(
                        height: listItemHeight,
                        //padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                        child: Column(
                          children: [
                            //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                            Expanded(
                              // padding: EdgeInsets.only(bottom: 5),
                              child: Column(
                                children: [
                                  Container(
                                    //padding: EdgeInsets.symmetric(vertical: 5),
                                    padding: EdgeInsets.all(5),
                                    color: Color(0xFFedeff2),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          '체결강도',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                        ),
                                        AutoSizeText(
                                          '$degree%',
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: ListView.builder(
                                          physics: AlwaysScrollableScrollPhysics(),
                                          itemCount: _hogaController.contract.value.array.length,
                                          itemBuilder: (context, index) {
                                            return cheList(_hogaController.contract.value.array[index]);
                                          }))
                                ],
                              ),
                            ),
                          ],
                        ),
                                            );
                                          }),
                                          ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: listItemCount,
                                            itemBuilder: (context, index) {
                        int buyClose = int.parse(beforeClose!);
                        int buyHoga =
                        int.parse(buyHogaArray![index]);
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
                          buyBorder =
                              Border.all(color: buyColor, width: 2);
                        }

                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: listItemHeight,
                                  padding: EdgeInsets.all(1),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          buyHoga == 0
                                              ? ''
                                              : priceFormat
                                              .format(buyHoga),
                                          maxLines: 1,
                                          textAlign:
                                          TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        child: AutoSizeText(
                                          percentFormat.format(
                                              buyRate) ==
                                              '100.00%'
                                              ? ''
                                              : percentFormat
                                              .format(buyRate),
                                          maxLines: 1,
                                          textAlign:
                                          TextAlign.right,
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
                                    /*OrderConfirmDialog.move(
                                            context,
                                            _hogaController.sise.value,
                                            buyHogaArray[index],
                                            1,
                                            onConfirm: () {
                                              if (accountList[mainAccount].pwd !=
                                                  "") {
                                                _goSetCount(context,
                                                    price: buyHogaArray[index]);
                                              } else {
                                                Future.delayed(
                                                    const Duration(seconds: 0),
                                                        () => showKeyBoard(context));
                                              }
                                            },
                                          )..show();*/
                                    bool asd = true;
                                    //_goToTransPage(buyHogaArray[index], asd);
                                  },
                                ),
                              ],
                            ),
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.transparent),
                          ],
                        );
                                            },
                                          ),
                                          ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: listItemCount,
                                            itemBuilder: (context, index) {
                        int buyRem = int.parse(buyRemArray != null
                            ? buyRemArray[index]
                            : '');
                        int buyRatio = 0;

                        if (int.parse(totalMaxRem) != 0) {
                          buyRatio = (buyRem /
                              int.parse(totalMaxRem) *
                              1000)
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
                                  padding: EdgeInsets.all(1),
                                  alignment: Alignment.centerLeft,
                                  child: AutoSizeText(
                                    buyRem == 0
                                        ? ''
                                        : priceFormat
                                        .format(buyRem),
                                    maxLines: 1,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      // color: _hogaControllerMore.isDarkMode.value
                                      //     ? LightColors.basic
                                      //     : Colors.black,
                                        fontSize: 12,
                                        fontWeight: buyWeight),
                                  ),
                                ),
                                Container(
                                  height: listItemHeight,
                                  padding: EdgeInsets.only(
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
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.transparent),
                          ],
                        );
                                            },
                                          ),
                                        ],
                                      )
                                    ;
                                  }),
                                ),


                    ],
                  )),
            ],
          );
        }
      })),
    );
  }
  Widget sise1(String alignment, String? text,){
    MainAxisAlignment mainalignment = MainAxisAlignment.start;
    if(alignment == 'end'){
      mainalignment = MainAxisAlignment.end;
    }else{
      mainalignment = MainAxisAlignment.start;
    }
    return Row( mainAxisAlignment: mainalignment,children: [ Text(text ?? '',style:TextStyle(fontSize: 10))]);
  }

  Widget sise2(String text, String text2){
    var color;
    if(text == '상한가'){
      color = Colors.red;
    }else if(text == '하한가' ){
      color = Colors.blue;
    }else{
      color = Colors.black;
    }
    return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text(text,style:TextStyle(fontSize: 10,color:color)),Text(text2,style:TextStyle(fontSize: 10,color:color))]);
  }
  Widget sise3(String text, double price, String text3, double basePrice){

    double doublePercent = (basePrice - price)/basePrice*100;
    String percent = doublePercent.abs().toStringAsFixed(2);
    var formatPrice = priceFormat.format(price);

    var color;
    if(text == '시'){
      color = Colors.green;
    }else if(text == '고' ){
      color = Colors.red;
    }else{
      color = Colors.blue;
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
          width:16,
          height:16,

          decoration: BoxDecoration(
              color:color,
              shape: BoxShape.circle
          ),
          child:Center(child:Column(children:[Text(text,style:TextStyle(fontSize: 10, color:Colors.white, fontWeight: FontWeight.bold))]))),
      //Text(text),
      Column(children: [Text(formatPrice,style:TextStyle(fontSize: 10)),Text('$percent%',style:TextStyle(fontSize: 10, color: doublePercent < 0 ? Colors.red : doublePercent > 0 ? Colors.blue : Colors.black))],)],);

  }
  Widget cheList(CheDataArray? cheData) {
    if (cheData == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            priceFormat.format(double.parse(cheData.price)),
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
          AutoSizeText(
            formatNumber(int.parse(cheData.volume)),
            maxLines: 1,
            style: TextStyle(color: valueColor(cheData.sign), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color valueColor(String sign){
    if(sign == '1' ||sign == '2'){
      return Colors.red;
    }else if(sign == '4' || sign == '5'){
      return Colors.blue;
    }else{
      return  Colors.black;
    }

  }
  // 호가 실시간
  Future<void> requestRealHoga(String websocketKey, String jmCode) async {

    final headers = {
      'Content-Type': 'application/json',
    };
    final url = 'http://203.109.30.207:10001/requestReal';
    final body = jsonEncode({
      'header': {'sessionKey': websocketKey, 'tr_type': '1'},
      'objCommInput': {"tr_id": "H0STASP0", 'tr_key': jmCode},
      'rqName': '',
      'trCode': '/uapi/domestic-stock/v1/quotations/requestReal',
    });

    //러쉬테스트용
    // const url = 'http://203.109.30.207:10001/rushtest';
    // final body = jsonEncode({
    //   "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
    //   "rqName": "",
    //   "header": {"sessionKey": websocketKey, "tr_type": "1"},
    //   "objCommInput": {"count": "2", "tr_id": "H0STASP0"}
    // });

    final response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String decodedBody = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(decodedBody);

    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  // 체결 실시간
  void requestRealChe(String websocketKey, String jmCode) async {

    final headers = {
      'Content-Type': 'application/json',
    };
    final url = 'http://203.109.30.207:10001/requestReal';
    final body = jsonEncode({
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"tr_id": "H0STCNT0", "tr_key": jmCode},
      "rqName": "",
      "trCode": "/uapi/domestic-stock/v1/quotations/requestReal"
    });

    // const url = 'http://203.109.30.207:10001/rushtest';
    // final body = jsonEncode({
    //   "trCode": "/uapi/domestic-stock/v1/quotations/rushtest",
    //   "rqName": "",
    //   "header": {"sessionKey": websocketKey, "tr_type": "1"},
    //   "objCommInput": {"count": "2", "tr_id": "H0STCNT0"}
    // });

    final response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      String decodedBody = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(decodedBody);

    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }




}


String formatNumber(int number) {
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}

Widget tag(String title) {
  return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: const BoxDecoration(
        color: Color(0xFF2F4F4B),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(50.0),
          right: Radius.circular(50.0),
        ),
      ),
      child: Text(title,
          style: const TextStyle(fontSize: 14, color: Colors.white)));
}

Widget title(String title) {
  return Row(
    children: [
      Expanded(child: Text(title, style: const TextStyle(fontSize: 20))),
      SizedBox(
          width: 24,
          child: IconButton(
              onPressed: () {},
              iconSize: 24.0,
              icon: const Icon(Icons.arrow_forward_ios)))
    ],
  );
}

Widget news(String title, String imagePath) {
  return SizedBox(
      width: double.infinity,
      height: 112,
      child: Row(
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                const Text('연합뉴스 | 2022/04/29 15:32',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7D7E85))),
              ])),
          Container(
              margin: const EdgeInsets.only(left: 15),
              width: 72,
              height: 72,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, fit: BoxFit.fitHeight)))
        ],
      ));
}

Widget restof() {
  return Column(children: [
    Container(height: 16, color: const Color(0xFFF7F8FA)),

    //기업 정보
    Container(
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 76,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              title('기업정보'),
              const Text('KOSPI | 금융업 | 시가총액 870.98조원',
                  style: TextStyle(fontSize: 12, color: Color(0xFF50505B))),
            ]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              tag('#갤럭시'),
              tag('#갤럭시워치'),
            ],
          )
        ])),

    Container(height: 16, color: const Color(0xFFF7F8FA)),

    //뉴스
    Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 28.0),
        child: Column(
          children: [
            title('회사소식'),
            news('배터리 열받아도 불나지 않도록', 'assets/images/image1.png'),
            news(
                '에어부산, 내달부터 부산발 일본 동남아노선 3개 운항 재개', 'assets/images/image2.png'),
            news('서울버스 총파업 현실화되나', 'assets/images/image3.png')
          ],
        ))
  ]);
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
