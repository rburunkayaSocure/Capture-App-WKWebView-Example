//
//  WebFlowViewController.swift
//  WebViewTest
//
//  Created by JC on 11/06/25
//

import UIKit
import WebKit

final class WebFlowViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // Your hosted session URL
    private let hostedURL = URL(string: "https://riskos.sandbox.socure.com/hosted/98d69ddd-f60c-45ac-851d-526771de61e7")!

    private var webView: WKWebView!
    private let closeButton = UIButton(type: .custom)

    // Hide status bar for immersive fullscreen (optional)
    override var prefersStatusBarHidden: Bool { true }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func loadView() {
        let config = WKWebViewConfiguration()

        let prefs = WKWebpagePreferences()
        prefs.preferredContentMode = .mobile
        config.defaultWebpagePreferences = prefs

        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }

        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self

        // Edge-to-edge with dark backdrop (prevents white bands)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        let container = UIView()
        container.backgroundColor = .black
        container.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: container.topAnchor),
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Floating circular X button (no nav bar space used)
        styleCloseButton()
        container.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])

        view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: hostedURL))
    }

    // MARK: - Close button styling (modern iOS 15+)
    private func styleCloseButton() {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = UIColor(white: 0.1, alpha: 0.85)
        config.image = UIImage(systemName: "xmark")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        config.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        closeButton.configuration = config
        closeButton.layer.cornerRadius = 22
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.accessibilityLabel = "Close"
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: - Handle target=_blank in same view
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    // MARK: - Optional: intercept custom callback schemes
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "bolt" {
            decisionHandler(.cancel)
            dismiss(animated: true)
            return
        }
        decisionHandler(.allow)
    }

    // MARK: - Media capture (camera/mic) if used by hosted flow
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView,
                 decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                 initiatedBy frame: WKFrameInfo,
                 type: WKMediaCaptureType) async -> WKPermissionDecision {
        return .grant
    }
}
