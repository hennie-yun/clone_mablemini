import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPage();
}

class _FavPage extends State<FavPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
            itemCount: DataList.length,
            itemBuilder: (context, index) {
              return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      child: Text(DataList[index]['jm_name']!,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(DataList[index]['nowprc']! + '원', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          makePrice(
                              DataList[index]['prc2']!,
                              DataList[index]['percent']!,
                              DataList[index]['sign']!)
                        ])
                  ]));
            }));
  }
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
    return const Color(0xFF50505B);
  } else {
    sign = '▼ ';
    return const Color(0xFF4881FF);
  }
}

final List<Map<String, String>> DataList = [
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
  },
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
  },
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
  },
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
  },
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
  },
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
  },
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
  },
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
  },
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
