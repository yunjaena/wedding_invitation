import 'dart:ui' as ui; // 추가: Size 충돌 해결을 위한 alias
import 'package:flutter/material.dart';
import 'package:flutter_naver_map_web/flutter_naver_map_web.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding_invitation/painter/parking_icon_painter.dart';
import 'package:wedding_invitation/painter/subway_icon_painter.dart';
import 'package:wedding_invitation/wedding_constants.dart';
import 'account_section.dart';
import 'count_down_timer.dart';

void main() {
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
          width: 430,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCover(),
                const SizedBox(height: 30),
                const CountdownTimer(targetDate: WeddingConfig.targetDateTime),
                const Divider(height: 80, thickness: 1, color: Colors.black12),
                _buildGreeting(),
                const Divider(height: 80, thickness: 1, color: Colors.black12),
                _buildMapSection(),
                const Divider(height: 80, thickness: 1, color: Colors.black12),
                const AccountSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Column(
      children: [
        Image.asset(
          WeddingConfig.introImage,
          height: 550,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 550,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            );
          },
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
          const SizedBox(height: 12),
          const Text(WeddingConfig.address,
              style: TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 20),

          Container(
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const NaverMapWeb(
                clientId: apiKey,
                initialLatitude: WeddingConfig.lat,
                initialLongitude: WeddingConfig.lng,
                initialZoom: 16,
                zoomControl: true,
                mapDataControl: true,
                places: [
                  Place(
                    id: 'wedding_hall',
                    name: WeddingConfig.weddingLocation,
                    latitude: WeddingConfig.lat,
                    longitude: WeddingConfig.lng,
                    description: WeddingConfig.address,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildMapButton(
                label: '네이버',
                url:
                    '${WeddingConfig.naverMapUrl}${Uri.encodeComponent(WeddingConfig.address)}',
                color: const Color(0xFF03C75A),
              ),
              const SizedBox(width: 8),
              _buildMapButton(
                label: '카카오',
                url:
                    '${WeddingConfig.kakaoMapUrl}${Uri.encodeComponent(WeddingConfig.weddingLocation)},${WeddingConfig.lat},${WeddingConfig.lng}',
                color: const Color(0xFFFEE500),
                textColor: Colors.black87,
              ),
              const SizedBox(width: 8),
              _buildMapButton(
                label: '구글',
                url:
                    'https://www.google.com/maps/search/?api=1&query=${WeddingConfig.lat},${WeddingConfig.lng}',
                color: Colors.white,
                textColor: Colors.black87,
                isOutlined: true,
              ),
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

  Widget _buildMapButton({
    required String label,
    required String url,
    required Color color,
    Color textColor = Colors.white,
    bool isOutlined = false,
  }) {
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

  Widget _buildTransportInfo({
    required CustomPainter painter,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          // 고정 크기 지정
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          // ui.Size를 사용하여 패키지 충돌 해결
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
