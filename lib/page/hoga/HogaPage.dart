import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'HogaData.dart';
import 'HogaData2.dart';
import 'HogaPageController.dart';
import 'CheData.dart';

class HogaPage extends StatelessWidget {
  HogaPage({super.key});

  // WebSocketChannel channel = WebSocketChannel.connect(
  //     Uri.parse('ws://203.109.30.207:10001/connect'));
  WebSocketChannel? channel;

  final HogaPageController _hogaController = Get.put(HogaPageController());

  /// 포맷팅
  final NumberFormat priceFormat = new NumberFormat('###,###');
  final NumberFormat percentFormat = new NumberFormat('###,##0.00%');
  final DateFormat dateFormat = new DateFormat('yyyyMMdd');


  @override
  Widget build(BuildContext context) {
    setupWebSocket('005930');
    //String jmCode = _hogaController.jmCode.value;

    // 현재가 단일종목
    requestPRPR();

    /// 호가 리스트
    //높이는 미더어쿼리 높이 - ([메인 탭 높이] + [상단바, 탭, 하단버튼 높이] + [마진패딩 등으로 밀리는 높이])
    //final double hogaListHeight = isBigScreen ? deviceHeight/1.31 : deviceHeight-(70+146+50);

    // 탭 높이, 앱바 높이 제외
    final double hogaListHeight = MediaQuery.of(context).size.height - 88 - 64;
    _hogaController.jmCode.value = '005930';


    // return Container(
    //   width: double.infinity,
    // );
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
             future: _hogaController.requestHoga(),
           // future:requestRealHoga(webSocketkey),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {

                return Column(
                  children: [
                    /// 호가 데이터
                    Expanded(
                      child: Container(
                        // height: hogaListHeight*1.3,
                        height: hogaListHeight,
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
                          var listItemHeight = (itemHeight / listItemCount) - 1;

                          var currentPrice = _hogaController.currentPrice.value;
                          //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                          /*
                                var beforeClose =
                                    _hogaController.hoga.value.close ?? '';
                                var sellHogaArray =
                                    _hogaController.hoga.value.sellHogas ?? [];
                                var sellRemArray =
                                    _hogaController.hoga.value.sellRems ?? [];
                                var buyHogaArray =
                                    _hogaController.hoga.value.buyHogas ?? [];
                                var buyRemArray =
                                    _hogaController.hoga.value.buyRems ?? [];
                                */
                          //var beforeClose = _hogaController.hoga.value.jnilclose ?? '';
                          // var sellHogaArray = _hogaController.hoga.value.offerho ?? [];
                          // var sellRemArray = _hogaController.hoga.value.offerrem ?? [];
                          // var buyHogaArray = _hogaController.hoga.value.bidho ?? [];
                          // var buyRemArray = _hogaController.hoga.value.bidrem ?? [];

                          var beforeClose =
                              _hogaController.hoga2.value.basePrice ?? '';
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

                          return ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: GridView.count(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              childAspectRatio: itemWidth / itemHeight,
                              crossAxisCount: 3,
                              children: [
                                Container(
                                  child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: listItemCount,
                                    itemBuilder: (context, index) {
                                      int sellRem = 0;
                                      if (sellRemArray != null)
                                        sellRem =
                                            int.parse(sellRemArray[index]);
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
                                // CustomScrollView(
                                //   reverse:true,
                                // slivers: [
                                //   SliverList(delegate: SliverChildBuilderDelegate((context,index){
                                //
                                //         int sellClose = int.parse(beforeClose!);
                                //         // int sellHoga =
                                //         //     int.parse(sellHogaArray![4 - index]);
                                //         int sellHoga =
                                //             int.parse(sellHogaArray![index]);
                                //
                                //         double sellRate =
                                //             (sellClose - sellHoga).abs() /
                                //                 sellClose;
                                //
                                //         Color sellColor = Colors.black;
                                //         if (sellClose > sellHoga) {
                                //           sellColor = Colors.blue;
                                //         } else if (sellClose < sellHoga) {
                                //           sellColor = Colors.red;
                                //         } else {
                                //           Colors.black;
                                //           // sellColor = _hogaControllerMore.isDarkMode.value ? Colors.white : Colors.black;
                                //         }
                                //
                                //         Border sellBorder = Border.all(
                                //             color: Colors.transparent, width: 0);
                                //         if (int.parse(currentPrice == ''
                                //                 ? "0"
                                //                 : currentPrice) ==
                                //             sellHoga) {
                                //           sellBorder = Border.all(
                                //               color: sellColor, width: 2);
                                //         }
                                //         return Column(
                                //           children: [
                                //             Stack(
                                //               children: [
                                //                 Container(
                                //                   height: listItemHeight,
                                //                   padding: EdgeInsets.all(1),
                                //                   child: Row(
                                //                     children: [
                                //                       Expanded(
                                //                         child: AutoSizeText(
                                //                           sellHoga == 0
                                //                               ? ''
                                //                               : priceFormat
                                //                                   .format(sellHoga),
                                //                           textAlign:
                                //                               TextAlign.center,
                                //                           maxLines: 1,
                                //                           style: TextStyle(
                                //                               color: Colors.black,
                                //                               fontWeight:
                                //                                   FontWeight.bold,
                                //                               fontSize: 15),
                                //                         ),
                                //                       ),
                                //                       Container(
                                //                         child: AutoSizeText(
                                //                           percentFormat.format(
                                //                                       sellRate) ==
                                //                                   '100.00%'
                                //                               ? ''
                                //                               : percentFormat
                                //                                   .format(sellRate),
                                //                           maxLines: 1,
                                //                           textAlign:
                                //                               TextAlign.right,
                                //                           style: TextStyle(
                                //                               color: sellColor,
                                //                               // fontSize:
                                //                               //     15
                                //                               fontSize: 12),
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   ),
                                //                 ),
                                //                 InkWell(
                                //                   child: Container(
                                //                     height: listItemHeight,
                                //                     decoration: BoxDecoration(
                                //                         border: sellBorder),
                                //                   ),
                                //                   onTap: () {
                                //                     /*OrderConfirmDialog.move(
                                //               context,
                                //               _hogaController.sise.value,
                                //               sellHogaArray[4 - index],
                                //               1,
                                //               onConfirm: () {
                                //                 if (accountList[mainAccount].pwd != "") {
                                //                   _goSetCount(context,
                                //                       price: sellHogaArray[4 - index]);
                                //                 } else {
                                //                   Future.delayed(
                                //                       const Duration(seconds: 0),
                                //                           () => showKeyBoard(context));
                                //                 }
                                //               },
                                //             )..show();*/
                                //                     bool asd = true;
                                //
                                //                     /// _goToTransPage(sellHogaArray[4 - index], asd);
                                //                   },
                                //                 ),
                                //               ],
                                //             ),
                                //             Divider(
                                //                 height: 1,
                                //                 thickness: 1,
                                //                 color: Colors.transparent)
                                //           ],
                                //         );
                                //
                                //   }))
                                // ],
                                // ),
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
                                        Container(height:hogaListHeight/8,
                                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                          child:Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              sise1('start','전일거래량'),
                                              sise1('end','test'),
                                              sise1('start','거래대금'),
                                              sise1('end','test'),
                                            ],
                                          )
                                        ),
                                        Divider(height: 1, thickness: 1, color: Colors.grey),
                                        Container(height:hogaListHeight/8,
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
                                        Container(height:hogaListHeight/20,
                                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                            child:Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                sise2('외인비율','${_hogaController.hoga2.value.frgnEhrt}%'),
                                              ],
                                            ))
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 5),
                                        //   child: Row(
                                        //     children: [
                                        //       InkWell(
                                        //         splashColor: Colors.transparent,
                                        //         highlightColor:
                                        //             Colors.transparent,
                                        //         child: Text(
                                        //           '누적',
                                        //           style: TextStyle(
                                        //
                                        //               ///color: Colors.black,
                                        //               fontSize: 12,
                                        //               decoration: TextDecoration
                                        //                   .underline),
                                        //         ),
                                        //         onTap: () {
                                        //           showDialog(
                                        //             context: context,
                                        //             builder: (context) {
                                        //               return AlertDialog(
                                        //                 shape: RoundedRectangleBorder(
                                        //                     borderRadius:
                                        //                         BorderRadius
                                        //                             .circular(
                                        //                                 10.0)),
                                        //                 title: Text(
                                        //                   '누적',
                                        //                   style: TextStyle(
                                        //                       fontWeight:
                                        //                           FontWeight
                                        //                               .bold,
                                        //                       fontSize: 152),
                                        //                 ),
                                        //                 content: Text(
                                        //                   '누적 거래량, 일정 기간 동안 거래된 주식 수의 총합',
                                        //                   style: TextStyle(
                                        //                       fontSize: 15),
                                        //                 ),
                                        //               );
                                        //             },
                                        //           );
                                        //         },
                                        //       ),
                                        //       Expanded(
                                        //         child: AutoSizeText(
                                        //           priceFormat
                                        //               .format(preDayVolume),
                                        //           maxLines: 1,
                                        //           textAlign: TextAlign.right,
                                        //           style: TextStyle(
                                        //               color: Colors.black,
                                        //               fontSize: 12),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 5),
                                        //   child: Row(
                                        //     children: [
                                        //       Text(
                                        //         '상Ⅵ',
                                        //         style: TextStyle(
                                        //             fontSize: 12,
                                        //             color: Colors.red),
                                        //       ),
                                        //       Expanded(
                                        //         child: AutoSizeText(
                                        //           priceFormat
                                        //               .format(svi_uplmtprice),
                                        //           maxLines: 1,
                                        //           textAlign: TextAlign.right,
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: Colors.red),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 5),
                                        //   child: Row(
                                        //     children: [
                                        //       Text('하Ⅵ',
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: Colors.blue)),
                                        //       Expanded(
                                        //         child: AutoSizeText(
                                        //           priceFormat
                                        //               .format(svi_dnlmtprice),
                                        //           textAlign: TextAlign.right,
                                        //           maxLines: 1,
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: Colors.blue),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 5),
                                        //   child: Row(
                                        //     children: [
                                        //       Text('상한',
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: Colors.red)),
                                        //       Expanded(
                                        //         child: AutoSizeText(
                                        //           priceFormat
                                        //               .format(uplmtprice),
                                        //           textAlign: TextAlign.right,
                                        //           maxLines: 1,
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: Colors.red),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 5),
                                        //   child: Row(
                                        //     children: [
                                        //       Text('하한',
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: Colors.blue)),
                                        //       Expanded(
                                        //         child: AutoSizeText(
                                        //           priceFormat
                                        //               .format(dnlmtprice),
                                        //           textAlign: TextAlign.right,
                                        //           maxLines: 1,
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: Colors.blue),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // Container(
                                        //     padding: EdgeInsets.all(10),
                                        //     child: Divider(
                                        //       height: 1,
                                        //       thickness: 1,
                                        //       // color: _hogaControllerMore.isDarkMode.value
                                        //       //     ? dDividerColor
                                        //       //     : mLightGray
                                        //     )),
                                        // Row(
                                        //   children: [
                                        //     Text('기준',
                                        //         style: TextStyle(
                                        //             color: Colors.black,
                                        //             fontSize: 12)),
                                        //     Expanded(
                                        //       child: AutoSizeText(
                                        //         //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                                        //         // priceFormat.format(recprice),
                                        //         priceFormat.format(jnilclose),
                                        //         //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                        //         maxLines: 1,
                                        //         textAlign: TextAlign.right,
                                        //         style: TextStyle(
                                        //             color: Colors.black,
                                        //             fontSize: 12),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 5),
                                        //   child: Row(
                                        //     children: [
                                        //       Text('시가',
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: jnilclose > open
                                        //                   ? Colors.blue
                                        //                   : Colors.red)),
                                        //       Expanded(
                                        //         child: AutoSizeText(
                                        //           priceFormat.format(open),
                                        //           textAlign: TextAlign.right,
                                        //           maxLines: 1,
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                                        //               // color: recprice > open
                                        //               color: jnilclose > open
                                        //                   //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                        //                   ? Colors.blue
                                        //                   : Colors.red),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 5),
                                        //   child: Row(
                                        //     children: [
                                        //       Text('고가',
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: jnilclose > high
                                        //                   //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                        //                   ? Colors.blue
                                        //                   : Colors.red)),
                                        //       Expanded(
                                        //         child: AutoSizeText(
                                        //           priceFormat.format(high),
                                        //           maxLines: 1,
                                        //           textAlign: TextAlign.right,
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                                        //               // color: recprice > high
                                        //               color: jnilclose > high
                                        //                   //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                        //                   ? Colors.blue
                                        //                   : Colors.red),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // Container(
                                        //   margin: EdgeInsets.only(top: 5),
                                        //   child: Row(
                                        //     children: [
                                        //       Text('저가',
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: jnilclose > low
                                        //                   //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                        //                   ? Colors.blue
                                        //                   : Colors.red)),
                                        //       Expanded(
                                        //         child: AutoSizeText(
                                        //           priceFormat.format(low),
                                        //           textAlign: TextAlign.right,
                                        //           maxLines: 1,
                                        //           style: TextStyle(
                                        //               fontSize: 12,
                                        //               //2024.02 벌고해 프로젝트_개편관련_김진겸 start
                                        //               // color: recprice > low
                                        //               color: jnilclose > low
                                        //                   //2024.02 벌고해 프로젝트_개편관련_김진겸 end
                                        //                   ? Colors.blue
                                        //                   : Colors.red),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
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
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }),
      ),
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
    if(cheData == null){
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
            cheData.volume,
            maxLines: 1,
            style: TextStyle(color:cheData.sign == '1' ||cheData.sign == '2' ? Colors.red :cheData.sign == '4' ||cheData.sign == '5'? Colors.blue : Colors.black , fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Future<T1101Output?> requestT1101(String jmCode) async {
  //   await T1101().fetchT1101(
  //       fetchComplete: (T1101Output item) {
  //         //2024.02 벌고해 프로젝트_개편관련_김진겸 end
  //         _hogaController.hoga.value = item;
  //
  //         _hogaController.currentPrice.value = item.price!;
  //         // Future.delayed(
  //         //     Duration(seconds: 1), () => _startRealFHKST01010200(jmCode));
  //         _hogaController.hoga.value;
  //         return _hogaController.hoga.value;
  //       },
  //       jmCode: jmCode);
  // }

  /// WebSocket 설정 및 데이터 요청
  void setupWebSocket(String jmCode) async {
    try {
      // 연결
      channel = WebSocketChannel.connect(
        Uri.parse('ws://203.109.30.207:10001/connect'),
      );

      channel!.stream.listen((message) {
       // print('Received message: $message');
        final data = jsonDecode(message);
        if (data['Data'] != null) {
          final websocketKey = data['Data']['websocketkey'];
          print('WebSocket Key: $websocketKey');
          if (websocketKey != null) {
            //호가 데이터
            requestRealHoga(websocketKey);
            requestRealChe(websocketKey);
          }
          if (data['TrCode'] == "H0STASP0") {
            _hogaController.hoga.value = HogaData.fromJSON(data['Data']);
          }else if(data['TrCode'] == "H0STCNT0"){
            _hogaController.contract.value.array.insert(0,CheDataArray.fromJson(data['Data']));
            if(_hogaController.contract.value.array.length >= 30){
              _hogaController. contract.value.array.removeLast();
            }
            //_hogaController.updateCheData(_hogaController.contract.value);
          }
        } else {
          print('No Data in message');
        }
      }, onError: (error) {
        print('WebSocket error: $error');
      }, onDone: () {
        print('WebSocket connection closed');
      });
    } catch (e) {
      print('WebSocket setup error: $e');
    }
  }



  // 호가 실시간
  void requestRealHoga(String websocketKey) async {
    final url = 'http://203.109.30.207:10001/requestReal';
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'header': {'sessionKey': websocketKey, 'tr_type': '1'},
      'objCommInput': {"tr_id": "H0STASP0", 'tr_key': '005930'},
      'rqName': '',
      'trCode': '/uapi/domestic-stock/v1/quotations/requestReal',
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  // 체결 실시간
  void requestRealChe(String websocketKey) async {
    final url = 'http://203.109.30.207:10001/requestReal';
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "header": {"sessionKey": websocketKey, "tr_type": "1"},
      "objCommInput": {"tr_id": "H0STCNT0", "tr_key": "000660"},
      "rqName": "",
      "trCode": "/uapi/domestic-stock/v1/quotations/requestReal"
    });
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      String decodedBody = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(decodedBody);

    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  // 호가
  //  void sendApiRequest3() async {
  //   final url = 'http://203.109.30.207:10001/request';
  //   final headers = {
  //     'Content-Type': 'application/json',
  //   };
  //
  //   final body = jsonEncode({
  //     "header": {
  //       "tr_id" : ""
  //     },
  //     "objCommInput": {
  //       "SHCODE" : "005930"
  //     },
  //     "rqName": "",
  //     "trCode": "/uapi/domestic-stock/v1/quotations/S0003"
  //   });
  //   final response = await http.post(Uri.parse(url),headers: headers, body: body);
  //
  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(response.body);
  //
  //     String decodedBody = utf8.decode(response.bodyBytes);
  //     var decodedJson = jsonDecode(decodedBody);
  //     _hogaController.hoga.value  = HogaData.fromJSON(decodedJson['Data']['output']);
  //
  //   }else {
  //     print('Request failed with status: ${response.statusCode}');
  //   }
  //
  // }
  // 현재가
  void requestPRPR() async {
    final url = 'http://203.109.30.207:10001/request';
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'header': {"tr_id": ""},
      'objCommInput': {"SHCODE": "005930"},
      'rqName': '',
      'trCode': "/uapi/domestic-stock/v1/quotations/S0004"
    });
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      String decodedBody = utf8.decode(response.bodyBytes);
      var decodedJson = jsonDecode(decodedBody);
      _hogaController.hoga2.value =
          HogaData2.fromJSON(decodedJson['Data']['output'], '005930');
      _hogaController.currentPrice.value = _hogaController.hoga2.value.price ?? '0';
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
}
