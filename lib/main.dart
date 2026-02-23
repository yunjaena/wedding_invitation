import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map_web/flutter_naver_map_web.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding_invitation/lazy_load_map.dart';
import 'package:wedding_invitation/wedding_constants.dart';
import 'package:wedding_invitation/painter/parking_icon_painter.dart';
import 'package:wedding_invitation/painter/subway_icon_painter.dart';
import 'account_section.dart';
import 'count_down_timer.dart';
import 'fade_in_on_scroll.dart';
import 'firebase_options.dart';
import 'guestbook_section.dart';

void main() async {
  // 1. 플러터 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  await Future.delayed(const Duration(milliseconds: 100));

  try {
    // 2. Firebase 초기화 (설정값이 완벽해야 합니다)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false, // 웹에서는 캐시가 오히려 전송을 방해할 수 있음
      sslEnabled: true,
      host: 'firestore.googleapis.com',
    );

    print("Firebase 초기화 성공");
  } catch (e) {
    // 만약 여기서 에러가 나면 화면이 하얗게 멈춥니다.
    // 에러를 출력하고 일단 앱은 실행되도록 처리합니다.
    print("Firebase 초기화 실패: $e");
  }

  // 3. 앱 실행
  runApp(const WeddingApp());
}

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${WeddingConfig.groomName} & ${WeddingConfig.brideName} 청첩장',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: WeddingConfig.primaryPink,
        fontFamily: 'NotoSansKR',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WeddingScreen(),
    );
  }
}

class WeddingScreen extends StatelessWidget {
  const WeddingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 430, // 모바일 너비 고정
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 1. 커버 섹션
                FadeInOnScroll(
                  key: const ValueKey('cover'),
                  child: _buildCover(),
                ),
                const SizedBox(height: 30),

                // 2. 카운트다운 타이머
                const FadeInOnScroll(
                  key: ValueKey('countdown'),
                  delay: Duration(milliseconds: 200),
                  child: CountdownTimer(
                    targetDate: WeddingConfig.targetDateTime,
                  ),
                ),
                const Divider(height: 80, thickness: 1, color: Colors.black12),

                // 3. 양가 부모님 및 성함
                FadeInOnScroll(
                  key: const ValueKey('parents'),
                  child: _buildParentNames(),
                ),
                const Divider(height: 80, thickness: 1, color: Colors.black12),

                // 4. 인사말
                FadeInOnScroll(
                  key: const ValueKey('greeting'),
                  child: _buildGreeting(),
                ),
                const Divider(height: 80, thickness: 1, color: Colors.black12),

                // 5. 오시는 길 (주소 상단 배치 수정본)
                FadeInOnScroll(
                  key: const ValueKey('map'),
                  child: _buildMapSection(),
                ),
                const Divider(height: 80, thickness: 1, color: Colors.black12),

                // 6. 계좌 정보 (핑크 테마 적용 섹션)
                const FadeInOnScroll(
                  key: ValueKey('account'),
                  child: AccountSection(),
                ),

                const Divider(height: 80, thickness: 1, color: Colors.black12),
                const FadeInOnScroll(
                  key: ValueKey('guestbook'),
                  child: GuestbookSection(), // 새로 만든 방명록 위젯
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 위젯 빌더 함수들 ---

  Widget _buildCover() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Image.asset(
            WeddingConfig.introImage,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          '${WeddingConfig.groomName}  |  ${WeddingConfig.brideName}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '${WeddingConfig.weddingDateText}\n${WeddingConfig.weddingLocation}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildParentNames() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _parentRichText(
            father: WeddingConfig.groomFatherName,
            mother: WeddingConfig.groomMotherName,
            title: WeddingConfig.groomTitle,
            name: WeddingConfig.groomFirstName,
          ),
          const SizedBox(height: 8),
          _parentRichText(
            father: WeddingConfig.brideFatherName,
            mother: WeddingConfig.brideMotherName,
            title: WeddingConfig.brideTitle,
            name: WeddingConfig.brideFirstName,
          ),
        ],
      ),
    );
  }

  Widget _parentRichText(
      {required String father,
      required String mother,
      required String title,
      required String name}) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
            fontSize: 15,
            height: 1.8,
            color: Colors.black87,
            fontFamily: 'NotoSansKR'),
        children: [
          TextSpan(text: '$father · $mother'),
          TextSpan(text: '의 $title '),
          TextSpan(
              text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            WeddingConfig.greetingTitle,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: WeddingConfig.primaryPink),
          ),
          SizedBox(height: 24),
          Text(
            WeddingConfig.greetingBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 2.0, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    const String apiKey = String.fromEnvironment('NAVER_CLIENT_ID',
        defaultValue: WeddingConfig.naverClientId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Text('오시는 길',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 장소명과 주소 순서 변경 및 스타일 적용
          const Text(
            WeddingConfig.weddingLocation,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 6),
          const Text(
            WeddingConfig.address,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 24),
          Container(
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WeddingConfig.dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const LazyLoadMap(apiKey: apiKey),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMapButton(
                  label: '네이버',
                  url:
                      '${WeddingConfig.naverMapUrl}${Uri.encodeComponent(WeddingConfig.address)}',
                  color: const Color(0xFF03C75A)),
              const SizedBox(width: 8),
              _buildMapButton(
                  label: '카카오',
                  url:
                      '${WeddingConfig.kakaoMapUrl}${Uri.encodeComponent(WeddingConfig.weddingLocation)},${WeddingConfig.lat},${WeddingConfig.lng}',
                  color: const Color(0xFFFEE500),
                  textColor: Colors.black87),
              const SizedBox(width: 8),
              _buildMapButton(
                  label: '구글',
                  url:
                      'https://www.google.com/maps/search/?api=1&query=${WeddingConfig.lat},${WeddingConfig.lng}',
                  color: Colors.white,
                  textColor: Colors.black87,
                  isOutlined: true),
            ],
          ),
          const SizedBox(height: 32),
          _buildTransportInfo(
            painter: ParkingIconPainter(iconColor: Colors.blueAccent),
            title: '주차 안내',
            content: WeddingConfig.parkingInfo,
            iconColor: Colors.blueAccent,
          ),
          const SizedBox(height: 16),
          _buildTransportInfo(
            painter: SubwayIconPainter(iconColor: Colors.orangeAccent),
            title: '지하철 안내',
            content: WeddingConfig.subwayInfo,
            iconColor: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(
      {required String label,
      required String url,
      required Color color,
      Color textColor = Colors.white,
      bool isOutlined = false}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: isOutlined
              ? const BorderSide(color: Colors.black12)
              : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildTransportInfo(
      {required CustomPainter painter,
      required String title,
      required String content,
      required Color iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            size: const ui.Size(36, 36),
            painter: painter,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54)),
              const SizedBox(height: 4),
              Text(content,
                  style: const TextStyle(
                      fontSize: 15, color: Colors.black87, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
