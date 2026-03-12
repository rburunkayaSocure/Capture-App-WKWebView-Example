//
//  ViewController.swift
//  WebViewTest
//
//  Created by Recep Burunkaya on 5/14/23.
//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    var landingView: UIView!
    var verifyButton: UIButton!
    var closeButton: UIButton!
    
    let hostedFlowURL = "https://riskos.sandbox.socure.com/hosted/v2/56d03ea8-5504-4bac-a4ab-be994cfec2af"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        setupWebView()
        setupLandingScreen()
    }
    
    func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        
        let pref = WKWebpagePreferences()
        pref.preferredContentMode = .mobile
        webConfiguration.defaultWebpagePreferences = pref
        
        webConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isHidden = true
        webView.backgroundColor = .white
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        addCloseButton()
    }
    
    func addCloseButton() {
        closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 20
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeWebView), for: .touchUpInside)
        closeButton.isHidden = true
        self.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupLandingScreen() {
        landingView = UIView(frame: self.view.bounds)
        landingView.backgroundColor = .systemBackground
        landingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(landingView)
        
        NSLayoutConstraint.activate([
            landingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            landingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            landingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            landingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = "Your App"
        titleLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        landingView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your App is a great app for verifying your identity."
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        landingView.addSubview(subtitleLabel)
        
        verifyButton = UIButton(type: .system)
        verifyButton.setTitle("Verify Identity", for: .normal)
        verifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        verifyButton.backgroundColor = .systemBlue
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 25
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.addTarget(self, action: #selector(startVerification), for: .touchUpInside)
        landingView.addSubview(verifyButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: landingView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: landingView.centerYAnchor, constant: -120),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.centerXAnchor.constraint(equalTo: landingView.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: landingView.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: landingView.trailingAnchor, constant: -40),
            
            verifyButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            verifyButton.centerXAnchor.constraint(equalTo: landingView.centerXAnchor),
            verifyButton.widthAnchor.constraint(equalToConstant: 280),
            verifyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func startVerification() {
        landingView.isHidden = true
        webView.isHidden = false
        closeButton.isHidden = false
        
        self.view.bringSubviewToFront(closeButton)
        
        guard let url = URL(string: hostedFlowURL) else { return }
        webView.load(URLRequest(url: url))
    }
    
    @objc func closeWebView() {
        landingView.isHidden = false
        webView.isHidden = true
        closeButton.isHidden = true
        webView.stopLoading()
        self.view.bringSubviewToFront(landingView)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // Check if this should open in Safari
        if shouldOpenInSafari(url: url, navigationType: navigationAction.navigationType) {
            // Open in Safari
            let safariVC = SFSafariViewController(url: url)
            safariVC.modalPresentationStyle = .pageSheet
            present(safariVC, animated: true)
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    // MARK: - Link Detection Logic
    
    func shouldOpenInSafari(url: URL, navigationType: WKNavigationType) -> Bool {
        // Only open in Safari if user clicked a link
        guard navigationType == .linkActivated else {
            return false
        }
        
        // Check for external documentation keywords
        let urlString = url.absoluteString.lowercased()
        return urlString.contains("term") ||
               urlString.contains("privacy") ||
               urlString.contains("policy") ||
               urlString.contains("legal")
    }
    
    // MARK: - WKUIDelegate
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Handle links with target="_blank"
        if navigationAction.targetFrame == nil,
           let url = navigationAction.request.url {
            
            if shouldOpenInSafari(url: url, navigationType: navigationAction.navigationType) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true)
            } else {
                webView.load(navigationAction.request)
            }
        }
        return nil
    }
    
    // MARK: - Camera Permission
    
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView,
                 decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                 initiatedBy frame: WKFrameInfo,
                 type: WKMediaCaptureType) async -> WKPermissionDecision {
        return .grant
    }
}
