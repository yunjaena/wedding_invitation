import 'dart:ui';

import 'package:flutter/material.dart';

class WeddingConfig {
  static const String groomName = "나윤재";
  static const String brideName = "신세정";
  static const String groomFirstName = "윤재";
  static const String brideFirstName = "세정";
  static const String groomFatherName = "나일성";
  static const String groomMotherName = "정진희";
  static const String brideFatherName = "신세식";
  static const String brideMotherName = "이영자";
  static const String groomTitle = "장남";
  static const String brideTitle = "차녀";
  static const String weddingDateText = "2026년 4월 11일 토요일 오후 5시";
  static const String weddingLocation = "베스트웨스턴 프리미어 강남호텔";
  static const String targetDateTime = "2026-04-11 17:00:00";

  static const String address = "서울 강남구 봉은사로 139";

  // --- 구글 지도 링크 기준 정밀 좌표 ---
  static const double lat = 37.5063252;
  static const double lng = 127.0297763;

  static const String greetingTitle = "초대합니다";
  static const String greetingBody = """
<b>윤</b>슬보다 빛나는 서로의 진심을 택했습니다.
<b>재</b>촉하기보다 같은 보폭으로 함께 걷겠습니다.
<b>세</b>월 속에서도 이 손의 온기만은 잊지 않겠습니다.
<b>정</b>다운 두 사람의 시작을 따뜻하게 지켜봐 주세요.
""";

  static const Color primaryPink = Color(0xFFFFA4A4); // 메인 핑크
  static const Color pointPink = Color(0xFFEE8E8E); // 아이콘 및 버튼 (진한 핑크)
  static const Color accountBackground = Color(0xFFFFF5F5); // 계좌 박스 (매우 연한 핑크)
  static const Color dividerColor = Color(0xFFF0E0E0); // 연한 분홍빛 구분선
  static const String naverClientId = "YOUR_CLIENT_ID"; // 네이버 콘솔에서 발급받은 키 입력
  static const String introImage = 'assets/images/intro.webp';

  static const List<Map<String, String>> groomAccounts = [
    {'bank': 'IBK기업은행', 'number': '167-068634-01-018', 'owner': '나일성'},
    {'bank': '우리은행', 'number': '1002-311-005187', 'owner': '정진희'},
    {'bank': '신한은행', 'number': '110-437-161617', 'owner': '나윤재'}
  ];
  static const List<Map<String, String>> brideAccounts = [
    {'bank': '우리은행', 'number': '025-134060-02-001', 'owner': '신세식'},
    {'bank': '농협은행', 'number': '477-12-111140', 'owner': '이영자'},
    {'bank': '우리은행', 'number': '1002-756-119929', 'owner': '신세정'}
  ];

  static const String parkingInfo = "호텔 내 전용 주차장 (하객 3시간 무료)";

  // \n을 사용해 줄바꿈이 정상적으로 나오도록 수정했습니다.
  static const String subwayInfo = "9호선 신논현역 3번 출구 도보 5분\n9호선 언주역 1번 출구 도보 5분";

  static const String naverMapUrl = "https://map.naver.com/v5/search/";
  static const String kakaoMapUrl = "https://map.kakao.com/link/to/";
  static const String googleMapUrl =
      "https://www.google.com/maps/search/?api=1&query=";
}
