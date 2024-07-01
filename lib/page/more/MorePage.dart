import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoContainer(),
            SizedBox(height: 16),
            _buildSection(
              title: '배당 및 세금',
              items: [
                '해외주식 배당내역',
                '해외주식 배당옵션',
                '양도소득세 조회/신청',
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '뱅킹',
              items: [
                '이체하기',
                '이체내역',
                '거래내역',
                '충전하기',
                '환전하기',
                '환전신청내역',
                '충전계좌관리',
                '이체한도관리',
                '간편이체 등록/해지',
                '출고 신청/내역',
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '내 주식 관리',
              items: [
                '나의 정기구매',
                '정기구매 내역',
                '주식 선물하기',
                '온주전환',
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '프라임 클럽',
              items: [
                'MY 프라임',
                '증권방송 쪽지함',
                '프라임 상담톡',
              ],
            ),
            SizedBox(height: 16),
            _buildSection(
              title: '내 정보 관리',
              items: [
                '투자자정보 등록/조회',
                '개인(신용)정보동의서',
                '내 수수료 조회',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoContainer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: BoxDecoration(
        color: Color(0XFFF4F5F8),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 160,
      child : Column(
      children : [
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '김국민님',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0XFFB2B4BF),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1, color: Colors.grey.withOpacity(0.3)),
            ),
            child: Text('로그아웃'),
          ),
        ],
      ),
      SizedBox(height: 16),
      _buildIconWithDescriptions(),
      ]),
    );
  }

  Widget _buildIconWithDescriptions() {
    return Container(
      height: 66,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconWithDescription(Icons.lock, '인증/보안', Color(0XFFFB422E)),
          _buildIconWithDescription(Icons.card_giftcard, '선물함', Color(0XFF8C52EF)),
          _buildIconWithDescription(Icons.local_offer, '쿠폰함', Color(0XFF49D0C7)),
          _buildIconWithDescription(Icons.emoji_events, '이벤트', Color(0XFFFFDA80)),
          _buildIconWithDescription(Icons.headphones_outlined, '고객서비스', Color(0XFF3B60FF)),
        ],
      ),
    );
  }

  Widget _buildIconWithDescription(IconData icon, String text, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

Widget _buildSection({required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0XFFE58832),
            ),
          ),
        ),
        Column(
          children: items.map((item) => _buildDetailContent(item)).toList(),
        ),
        SizedBox(height: 16),
        Divider(
          height: 1,
          color: Colors.grey.withOpacity(0.3),
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildDetailContent(String content) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 52,
        padding: EdgeInsets.fromLTRB(24, 14, 24, 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0XFFB2B4BF),
            ),
          ],
        ),
      ),
    );
  }

