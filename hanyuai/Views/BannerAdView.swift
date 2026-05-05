import SwiftUI
import GoogleMobileAds

/// AdMob のバナー広告を SwiftUI に橋渡しする UIViewRepresentable。
/// SDK v12+ では `GAD` プレフィックスが廃止された新 API を使う。
struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

enum AdUnitID {
    #if DEBUG
    static let banner = "ca-app-pub-3940256099942544/2934735716"
    #else
    static let banner = "ca-app-pub-7818121287671921/7913923306"
    #endif
}
