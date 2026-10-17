import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsView extends StatefulWidget {
  final Widget child;
  const AdsView({super.key, required this.child});

  @override
  State<AdsView> createState() => _AdsViewState();
}

class _AdsViewState extends State<AdsView> {
  BannerAd? _banner;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final adUnitId =
        dotenv.env['ADUNITID'] ?? 'ca-app-pub-4377454783493553/6982619129';
    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _banner = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint("Ad failed to load: $error");
        },
      ),
    );
    banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: widget.child),
            if (_isLoaded && _banner != null)
              SizedBox(
                width: _banner!.size.width.toDouble(),
                height: _banner!.size.height.toDouble(),
                child: AdWidget(ad: _banner!),
              )
            else
              SizedBox(
                height: AdSize.banner.height.toDouble(),
              ),
          ],
        ),
      ),
    );
  }
}
