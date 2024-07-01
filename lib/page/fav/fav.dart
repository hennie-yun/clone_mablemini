import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class zzim extends StatefulWidget {
  const zzim({super.key});

  @override
  State<zzim> createState() => _zzimState();
}

class _zzimState extends State<zzim> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
            itemCount: zzimDataList.length,
            itemBuilder: (context, index) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  height: 72,
                  child: Row(children: [
                    Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                            child: Image.asset('assets/images/mmini.png'))),
                    Expanded(
                      child: Text(zzimDataList[index]['jm_name']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(zzimDataList[index]['nowprc']! + '원',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          makePrice(
                              zzimDataList[index]['prc2']!,
                              zzimDataList[index]['percent']!,
                              zzimDataList[index]['sign']!)
                        ])
                  ]));
            }));
  }
}

String sign = '';

Widget makePrice(String prc, String prct, String updwn) {
  Color updwnColor = updownColor(updwn);

  var price = prc ?? '0';
  var percent = prct ?? '0';
  return Row(children: [
    Text(sign, style: TextStyle(color: updwnColor, fontSize: 12)),
    Text('$price원', style: TextStyle(color: updwnColor, fontSize: 12)),
    Text(' ($percent%)', style: TextStyle(color: updwnColor, fontSize: 12)),
  ]);
}

Color updownColor(String updwn) {
  var updown = int.parse(updwn);

  if (updown < 3) {
    sign = '▲';
    return Colors.red;
  } else if (updown == 3) {
    return Colors.black;
  } else {
    sign = '▼';
    return Colors.blue;
  }
}

final List<Map<String, String>> zzimDataList = [
  {
    'jm_name': 'SK증권',
    'sign': '2',
    'nowprc': '562',
    'prc2': '0',
    'percent': '0'
  },
  {
    'jm_name': '삼성전자',
    'sign': '1',
    'nowprc': '81000',
    'prc2': '500',
    'percent': '0.62'
  },
  {
    'jm_name': 'LG화학',
    'sign': '2',
    'nowprc': '801000',
    'prc2': '2000',
    'percent': '0.25'
  },
  {
    'jm_name': '현대차',
    'sign': '1',
    'nowprc': '230000',
    'prc2': '1000',
    'percent': '0.44'
  },
  {
    'jm_name': 'NAVER',
    'sign': '4',
    'nowprc': '420000',
    'prc2': '3000',
    'percent': '0.72'
  },
  {
    'jm_name': '카카오',
    'sign': '2',
    'nowprc': '160000',
    'prc2': '200',
    'percent': '0.42'
  }
];
