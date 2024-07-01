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
      appBar: AppBar(
        title:const Row(
          children: [
            Expanded(child:
            Text('찜한주식')),

          ],

        )
      ),
     body:ListView.builder(
         itemCount: zzimDataList.length,
    itemBuilder: (context,  index) {
           return Container(
             height: 72,
             decoration: const BoxDecoration(
               border: Border(
                 bottom: BorderSide(
                   color:   Color(0xffEBEEF0),
                   width: 1.0,
                 ),
               ),
             ),
             child:Row(
               children: [
                 Text(zzimDataList[index]['jm_name']!,
                 //style:const TextStyle(fontWeight: 700)
                  ),
                 ]
             )
           );

    }
     )  );
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