import 'package:google_mobile_ads/google_mobile_ads.dart';

class ReklamController {
  String _banner1 = "ca-app-pub-8572094845088375/6663827108";
  String _bannerGoogle = "ca-app-pub-3940256099942544/6300978111";
  String _gecisliGoogle = "ca-app-pub-3940256099942544/1033173712";
  String _gecisli1 = "ca-app-pub-8572094845088375/6079156138";

  final BannerAd myBanner = BannerAd(
    adUnitId: "ca-app-pub-3940256099942544/6300978111",
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    ),
  );

  final gecisliReklamim = InterstitialAd.load(
    adUnitId: "ca-app-pub-3940256099942544/1033173712",
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        ad.show();
        print("Geçişli reklam yüklendi: $ad");
      },
      onAdFailedToLoad: (LoadAdError error){
        print("Geçişli reklam yüklenirken hata: $error");
      },
    ),
  );
}
