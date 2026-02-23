import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wedding_invitation/wedding_constants.dart';

class GuestbookSection extends StatefulWidget {
  const GuestbookSection({super.key});

  @override
  State<GuestbookSection> createState() => _GuestbookSectionState();
}

class _GuestbookSectionState extends State<GuestbookSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSending = false;

  String _hashPassword(String password) {
    if (password.isEmpty) return "";
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  final TextStyle _labelStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    letterSpacing: -0.5,
  );

  final TextStyle _hintStyle = TextStyle(
    fontSize: 13,
    color: Colors.grey.withValues(alpha: 0.5),
  );

  void _showStyledDialog(
      {required Widget title,
      required Widget content,
      required List<Widget> actions}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Text('방명록',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0)),
          const SizedBox(height: 24),
          _buildInputForm(),
          const SizedBox(height: 48),
          _buildMessageList(),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildTextField(_nameController, "성함", isDense: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(_passwordController, "비밀번호",
                      isDense: true, isPassword: true)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(_messageController, "따뜻한 축하의 말씀을 남겨주세요", maxLines: 3),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSending ? null : _submitMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: WeddingConfig.pointPink,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('축하 메시지 등록하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1, bool isPassword = false, bool isDense = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      obscureText: isPassword,
      cursorColor: WeddingConfig.pointPink,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _hintStyle,
        filled: true,
        fillColor: WeddingConfig.accountBackground.withValues(alpha: 0.3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: WeddingConfig.dividerColor.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: WeddingConfig.pointPink, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('guestbook')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: WeddingConfig.pointPink));
        }
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Text('전해주시는 따뜻한 마음을 소중히 간직하겠습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 13));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final storedPwHash = data['pw'] ?? '';

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: WeddingConfig.dividerColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data['name'] ?? '성함 미입력', style: _labelStyle),
                      _buildHeartMenu(docId, storedPwHash, data['message']),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(data['message'] ?? '',
                      style: const TextStyle(
                          fontSize: 14, height: 1.6, color: Colors.black87)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeartMenu(String docId, String storedHash, String currentMsg) {
    return PopupMenuButton<String>(
      icon:
          const Icon(Icons.favorite, color: WeddingConfig.pointPink, size: 20),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 30),
      onSelected: (val) =>
          _showAuthDialog(docId, storedHash, currentMsg, val == 'del'),
      itemBuilder: (ctx) => [
        const PopupMenuItem(
            value: 'edit',
            child: Center(child: Text('수정', style: TextStyle(fontSize: 14)))),
        const PopupMenuItem(
            value: 'del',
            child: Center(
                child: Text('삭제',
                    style: TextStyle(fontSize: 14, color: Colors.red)))),
      ],
    );
  }

  void _showAuthDialog(
      String docId, String storedHash, String currentMsg, bool isDelete) {
    final TextEditingController authController = TextEditingController();
    _showStyledDialog(
      title: Text(isDelete ? '메시지 삭제' : '메시지 수정',
          style: _labelStyle.copyWith(fontSize: 18)),
      content: TextField(
        controller: authController,
        obscureText: true,
        cursorColor: WeddingConfig.pointPink,
        decoration: InputDecoration(
          hintText: '설정하신 비밀번호를 입력해 주세요.',
          hintStyle: _hintStyle,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: WeddingConfig.pointPink.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: WeddingConfig.pointPink,
              width: 2.0,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          onPressed: () {
            if (_hashPassword(authController.text) == storedHash) {
              Navigator.pop(context);
              if (isDelete) {
                FirebaseFirestore.instance
                    .collection('guestbook')
                    .doc(docId)
                    .delete();
              } else {
                _showEditDialog(docId, currentMsg);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: WeddingConfig.pointPink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Text('확인', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showEditDialog(String docId, String currentMsg) {
    final TextEditingController editController =
        TextEditingController(text: currentMsg);
    _showStyledDialog(
      title: Text('메시지 수정', style: _labelStyle.copyWith(fontSize: 18)),
      content: TextField(
        controller: editController,
        maxLines: 4,
        cursorColor: WeddingConfig.pointPink,
        decoration: InputDecoration(
          hintText: '수정하실 내용을 입력해 주세요.',
          hintStyle: _hintStyle,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: WeddingConfig.pointPink.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: WeddingConfig.pointPink,
              width: 2.0,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('guestbook')
                .doc(docId)
                .update({'message': editController.text});
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: WeddingConfig.pointPink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: const Text('수정 완료', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _submitMessage() async {
    final name = _nameController.text.trim();
    final message = _messageController.text.trim();
    final password = _passwordController.text.trim();
    if (name.isEmpty || message.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('모든 항목을 작성해 주세요.')));
      return;
    }
    setState(() => _isSending = true);
    try {
      await FirebaseFirestore.instance.collection('guestbook').add({
        'name': name,
        'message': message,
        'pw': _hashPassword(password),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _nameController.clear();
      _messageController.clear();
      _passwordController.clear();

      if (!mounted) return;
      FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('소중한 축하의 말씀 감사드립니다.')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
