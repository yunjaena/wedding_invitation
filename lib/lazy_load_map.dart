import 'package:flutter/material.dart';
import 'package:flutter_naver_map_web/flutter_naver_map_web.dart';

import 'wedding_constants.dart';

class LazyLoadMap extends StatefulWidget {
  final String apiKey;

  const LazyLoadMap({super.key, required this.apiKey});

  @override
  State<LazyLoadMap> createState() => _LazyLoadMapState();
}

class _LazyLoadMapState extends State<LazyLoadMap> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: WeddingConfig.primaryPink),
      );
    }

    return NaverMapWeb(
      key: UniqueKey(),
      clientId: widget.apiKey,
      initialLatitude: WeddingConfig.lat,
      initialLongitude: WeddingConfig.lng,
      initialZoom: 16,
      zoomControl: true,
      mapDataControl: true,
      places: const [
        Place(
          id: 'wedding_hall',
          name: WeddingConfig.weddingLocation,
          latitude: WeddingConfig.lat,
          longitude: WeddingConfig.lng,
          description: WeddingConfig.address,
        ),
      ],
    );
  }
}
