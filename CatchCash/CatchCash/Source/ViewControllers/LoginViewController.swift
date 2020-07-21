//
//  LoginViewController.swift
//  CatchCash
//
//  Created by DaEun Kim on 2020/07/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit
import WebKit

import RxCocoa
import RxSwift

final class LoginViewController: UIViewController {

    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var webView: WKWebView!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self

        startButton.layer.cornerRadius = 4
        startButton.layer.shadowRadius = 4
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 0.16
        startButton.layer.shadowOffset = .init(width: 2, height: 4)

        startButton.rx.tap
            .flatMap { Service.shared.login() }
            .bind { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let url):
                    self.webView.isHidden = false
                    let request = URLRequest(url: URL(string: url)!)
                    self.webView.load(request)
                default:
                    self.showToast("오류가 발생했습니다")
                }
        }
        .disposed(by: disposeBag)
    }

}

extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString.contains("http://10.156.145.162:1212") == false { return }

        webView.evaluateJavaScript("document.body.innerHTML", completionHandler: { html, error in
            let stringData = (html as? String)?.components(separatedBy: ["<", ">"])
                .filter { $0.starts(with: "{") }
                .joined()
                .data(using: .utf8)

            guard let data = stringData else { return }

            if let tokens = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                TokenManager.accessToken = tokens.accessToken
                TokenManager.refreshToken = tokens.refreshToken
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.tabBarController) {
                    self.navigationController?.setViewControllers([vc], animated: false)
                }
            }
        })
    }
}
