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
    return ExpansionTile(
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      collapsedBackgroundColor: Colors.grey[100],
      backgroundColor: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      children: accounts
          .map((acc) =>
              _buildAccountRow(acc['bank']!, acc['number']!, acc['owner']!))
          .toList(),
    );
  }

  Widget _buildAccountRow(String bank, String accountNum, String name) {
    return Builder(builder: (context) {
      return ListTile(
        title: Text('$bank $accountNum', style: const TextStyle(fontSize: 14)),
        subtitle: Text('예금주 : $name', style: const TextStyle(fontSize: 12)),
        trailing: OutlinedButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: accountNum));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('계좌번호가 복사되었습니다.')),
            );
          },
          child: const Text('복사'),
        ),
      );
    });
  }
}
