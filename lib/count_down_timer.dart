import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final String targetDate; // WeddingConfig.targetDateTime을 전달받음
  const CountdownTimer({super.key, required this.targetDate});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft(); // 초기 시간 설정

    // 1초마다 화면을 갱신하도록 타이머 설정
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // 위젯이 화면에 있을 때만 업데이트
        _updateTimeLeft();
      }
    });
  }

  void _updateTimeLeft() {
    try {
      final DateTime target = DateTime.parse(widget.targetDate);
      final DateTime now = DateTime.now();

      setState(() {
        if (target.isAfter(now)) {
          _timeLeft = target.difference(now);
        } else {
          _timeLeft = Duration.zero; // 예식 시간이 지났을 때
          _timer?.cancel();
        }
      });
    } catch (e) {
      debugPrint("날짜 형식이 잘못되었습니다: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // 메모리 누수 방지를 위해 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft == Duration.zero) {
      return const Center(
        child: Text(
          '축하해 주세요! 결혼식이 시작되었습니다.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFA4A4),
          ),
        ),
      );
    }

    // 일, 시간, 분, 초 계산
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours.remainder(24);
    final minutes = _timeLeft.inMinutes.remainder(60);
    final seconds = _timeLeft.inSeconds.remainder(60);

    return Column(
      children: [
        const Text(
          '우리의 예식이 시작되기까지',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeBox(days.toString(), 'Days'),
            _buildSeparator(),
            _buildTimeBox(hours.toString().padLeft(2, '0'), 'Hour'),
            _buildSeparator(),
            _buildTimeBox(minutes.toString().padLeft(2, '0'), 'Min'),
            _buildSeparator(),
            _buildTimeBox(
              seconds.toString().padLeft(2, '0'),
              'Sec',
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  // 시간 숫자와 단위를 보여주는 박스
  Widget _buildTimeBox(String time, String label, {bool isLast = false}) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      // symmetric 대신 only를 사용하여 하단 여백(bottom)을 명시합니다.
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 15),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
