import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding_invitation/wedding_constants.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Text('마음 전하실 곳',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildAccountGroup('신랑측 계좌번호', WeddingConfig.groomAccounts),
          const SizedBox(height: 12),
          _buildAccountGroup('신부측 계좌번호', WeddingConfig.brideAccounts),
        ],
      ),
    );
  }

  Widget _buildAccountGroup(String title, List<Map<String, String>> accounts) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WeddingConfig.dividerColor),
      ),
      child: ExpansionTile(
          title: Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          leading: Icon(
            title.contains('신랑') ? Icons.favorite : Icons.favorite_border,
            // 하트 아이콘으로 변경 추천
            color: WeddingConfig.pointPink,
            size: 20,
          ),
          shape: const Border(),
          children: [
            ...accounts.map((acc) =>
                _buildAccountRow(acc['bank']!, acc['number']!, acc['owner']!)),
            const SizedBox(height: 12),
          ]),
    );
  }

  Widget _buildAccountRow(String bank, String accountNum, String name) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: WeddingConfig.accountBackground, // 연한 핑크 배경
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$bank $accountNum',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('예금주 : $name',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: accountNum));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('계좌번호가 복사되었습니다.'),
                        backgroundColor: WeddingConfig.pointPink, // 스낵바도 핑크색으로!
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    side: const BorderSide(color: WeddingConfig.pointPink),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    '복사',
                    style: TextStyle(
                        fontSize: 12,
                        color: WeddingConfig.pointPink,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
