//
// Copyright (c) 2023 - present, LLC “V Kontakte”
//
// 1. Permission is hereby granted to any person obtaining a copy of this Software to
// use the Software without charge.
//
// 2. Restrictions
// You may not modify, merge, publish, distribute, sublicense, and/or sell copies,
// create derivative works based upon the Software or any part thereof.
//
// 3. Termination
// This License is effective until terminated. LLC “V Kontakte” may terminate this
// License at any time without any negative consequences to our rights.
// You may terminate this License at any time by deleting the Software and all copies
// thereof. Upon termination of this license for any reason, you shall continue to be
// bound by the provisions of Section 2 above.
// Termination will be without prejudice to any rights LLC “V Kontakte” may have as
// a result of this agreement.
//
// 4. Disclaimer of warranty and liability
// THE SOFTWARE IS MADE AVAILABLE ON THE “AS IS” BASIS. LLC “V KONTAKTE” DISCLAIMS
// ALL WARRANTIES THAT THE SOFTWARE MAY BE SUITABLE OR UNSUITABLE FOR ANY SPECIFIC
// PURPOSES OF USE. LLC “V KONTAKTE” CAN NOT GUARANTEE AND DOES NOT PROMISE ANY
// SPECIFIC RESULTS OF USE OF THE SOFTWARE.
// UNDER NO CIRCUMSTANCES LLC “V KONTAKTE” BEAR LIABILITY TO THE LICENSEE OR ANY
// THIRD PARTIES FOR ANY DAMAGE IN CONNECTION WITH USE OF THE SOFTWARE.
//

import UIKit
import VKIDCore
// Only for debug purposes. Do not use in your projects.
import VKID

final class AuthViewController: VKIDDemoViewController {
    private enum Constants {
        static let authButtonSize = CGSize(width: 220, height: 40)
    }

    private enum AuthUI: Int {
        case icon = 0
        case button = 1
        case widget = 2
        case sheet = 3
        case custom = 4
    }

    private var action: (() -> Void)? = nil
    private var oAuthProviders: [OAuthProvider] = [] {
        didSet {
            if oldValue != self.oAuthProviders {
                self.debugSettings.oAuthProviders = self.oAuthProviderSegmentControl.selectedSegmentIndex
                if self.authView != nil { self.addAuthButton() }
            }
        }
    }

    private lazy var authUI: AuthUI = .init(rawValue: self.debugSettings.authViewUI) ?? .button {
        didSet {
            if oldValue != self.authUI {
                self.debugSettings.authViewUI = self.authViewUISegmentControl.selectedSegmentIndex
                if self.authView != nil { self.addAuthButton() }
            }
        }
    }

    private lazy var authViewUISegmentControlLabel: UILabel = {
        let label = UILabel()
        label.text = "UI авторизации"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var authViewUISegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.insertSegment(withTitle: "иконка", at: 0, animated: false)
        segmentControl.insertSegment(withTitle: "кнопка", at: 1, animated: false)
        segmentControl.insertSegment(withTitle: "виджет", at: 2, animated: false)
        segmentControl.insertSegment(withTitle: "шторка", at: 3, animated: false)
        segmentControl.insertSegment(withTitle: "кастом", at: 4, animated: false)

        segmentControl.addTarget(self, action: #selector(self.authUISegmentControlChanged), for: .valueChanged)
        segmentControl.selectedSegmentIndex = self.debugSettings.authViewUI
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()

    private lazy var oAuthProviderSegmentControlLabel: UILabel = {
        let label = UILabel()
        label.text = "Провайдеры авторизации"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var oAuthProviderSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.insertSegment(withTitle: "ничего", at: 0, animated: false)
        segmentControl.insertSegment(withTitle: "ок", at: 1, animated: false)
        segmentControl.insertSegment(withTitle: "почта", at: 2, animated: false)
        segmentControl.insertSegment(withTitle: "ок,почта", at: 3, animated: false)
        segmentControl.insertSegment(withTitle: "ок,почта,вк", at: 4, animated: false)

        segmentControl.addTarget(self, action: #selector(self.oAuthProviderSegmentControlChanged), for: .valueChanged)
        segmentControl.selectedSegmentIndex = self.debugSettings.oAuthProviders
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()

    private lazy var termsOfAgreementLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label
            .text =
            "Нажимая “Войти c VK ID”, вы принимаете пользовательское соглашение и политику конфиденциальности"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = label.textColor.withAlphaComponent(0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var authContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var authView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.authUISegmentControlChanged()
        self.oAuthProviderSegmentControlChanged()

        self.addDebugSettingsButton()
        self.addTermsOfAgreement()
        self.addAuthViewUI()
        self.addOAuthProvider()
        self.addAuthContainerView()
        self.addAuthButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.vkid?.add(observer: self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.vkid?.remove(observer: self)
    }

    private func addAuthViewUI() {
        self.view.addSubview(self.authViewUISegmentControlLabel)
        self.view.addSubview(self.authViewUISegmentControl)

        NSLayoutConstraint.activate([
            // MARK: - AuthViewUISegmentControlLabel
            self.authViewUISegmentControlLabel.topAnchor.constraint(
                equalTo: self.descriptionLabel.bottomAnchor,
                constant: 32
            ),
            self.authViewUISegmentControlLabel.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            self.authViewUISegmentControlLabel.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),

            // MARK: - AuthViewUISegmentControl
            self.authViewUISegmentControl.topAnchor.constraint(
                equalTo: self.authViewUISegmentControlLabel.bottomAnchor,
                constant: 16
            ),
            self.authViewUISegmentControl.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            self.authViewUISegmentControl.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
        ])
    }

    private func addOAuthProvider() {
        self.view.addSubview(self.oAuthProviderSegmentControlLabel)
        self.view.addSubview(self.oAuthProviderSegmentControl)

        NSLayoutConstraint.activate([
            // MARK: - OAuthProviderSegmentControlLabel
            self.oAuthProviderSegmentControlLabel.topAnchor.constraint(
                equalTo: self.authViewUISegmentControl.bottomAnchor,
                constant: 16
            ),
            self.oAuthProviderSegmentControlLabel.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            self.oAuthProviderSegmentControlLabel.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),

            // MARK: - OAuthProviderSegmentControl
            self.oAuthProviderSegmentControl.topAnchor.constraint(
                equalTo: self.oAuthProviderSegmentControlLabel.bottomAnchor,
                constant: 16
            ),
            self.oAuthProviderSegmentControl.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            self.oAuthProviderSegmentControl.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            self.oAuthProviderSegmentControl.bottomAnchor.constraint(
                lessThanOrEqualTo: self.termsOfAgreementLabel.topAnchor
            ),
        ])
    }

    private func addTermsOfAgreement() {
        self.view.addSubview(self.termsOfAgreementLabel)

        NSLayoutConstraint.activate([
            self.termsOfAgreementLabel.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            self.termsOfAgreementLabel.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            self.termsOfAgreementLabel.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
        ])
    }

    private func addAuthContainerView() {
        self.view.addSubview(self.authContainerView)

        NSLayoutConstraint.activate([
            self.authContainerView.topAnchor.constraint(
                equalTo: self.oAuthProviderSegmentControl.bottomAnchor
            ),
            self.authContainerView.bottomAnchor.constraint(
                equalTo: self.termsOfAgreementLabel.topAnchor,
                constant: -8
            ),
            self.authContainerView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            self.authContainerView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
        ])
    }

    private func addAuthButton() {
        self.authView?.removeFromSuperview()
        self.authView = self.makeAuthView()
        self.authContainerView.addSubview(self.authView)
        self.authView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.authView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            self.authView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            self.authView.bottomAnchor.constraint(equalTo: self.termsOfAgreementLabel.topAnchor, constant: -8),
            self.authView.topAnchor.constraint(greaterThanOrEqualTo: self.descriptionLabel.bottomAnchor),
        ])
    }

    private func addDebugSettingsButton() {
        let bt = UIBarButtonItem(
            title: "Debug",
            style: .plain,
            target: self,
            action: #selector(self.onOpenDebugSettings(sender:))
        )
        self.navigationItem.rightBarButtonItem = bt
    }

    @objc
    func oAuthProviderSegmentControlChanged() {
        switch self.oAuthProviderSegmentControl.selectedSegmentIndex {
        case 0:
            self.oAuthProviders = []
        case 1:
            self.oAuthProviders = [.ok]
        case 2:
            self.oAuthProviders = [.mail]
        case 3:
            self.oAuthProviders = [.ok, .mail]
        case 4:
            self.oAuthProviders = [.ok, .mail, .vkid]
        default:
            break
        }
    }

    @objc
    func authUISegmentControlChanged() {
        switch self.authViewUISegmentControl.selectedSegmentIndex {
        case 0:
            self.authUI = .icon
        case 1:
            self.authUI = .button
        case 2:
            self.authUI = .widget
        case 3:
            self.authUI = .sheet
        case 4:
            self.authUI = .custom
        default:
            break
        }
    }

    @objc
    private func onOpenDebugSettings(sender: AnyObject) {
        let tableStyle: UITableView.Style = {
            if #available(iOS 13.0, *) {
                return .insetGrouped
            } else {
                return .grouped
            }
        }()
        let settings = DebugSettingsViewController(style: tableStyle)
        let navigation = UINavigationController(rootViewController: settings)
        self.present(navigation, animated: true)
        settings.render(viewModel: self.buildDebugSettings())
        self.debugSettingsVC = settings
    }

    @objc
    private func actionButtonOnTap() {
        self.action?()
    }

    private func makeAuthView() -> UIView {
        guard let vkid = self.vkid else {
            fatalError("No vkid provided")
        }

        switch self.authUI {
        case .custom:
            let button = UIButton()
            button.addTarget(self, action: #selector(self.actionButtonOnTap), for: .touchUpInside)
            button.setTitle(
                "Custom Authorize",
                for: .normal
            )
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            if #available(iOS 13.0, *) {
                button.setTitleColor(.label, for: .normal)
            } else {
                button.setTitleColor(.black, for: .normal)
            }

            self.action = {
                self.vkid?.authorize(
                    using: .uiViewController(self)
                ) { _ in }
            }
            return button
        case .icon, .button:
            return vkid.ui(for: self.makeButton()).uiView()
        case .widget:
            return vkid.ui(for: self.makeWidget()).uiView()
        case .sheet:
            let button = UIButton()
            button.addTarget(self, action: #selector(self.actionButtonOnTap), for: .touchUpInside)
            button.setTitle(
                "Present BottomSheet",
                for: .normal
            )
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            if #available(iOS 13.0, *) {
                button.setTitleColor(.label, for: .normal)
            } else {
                button.setTitleColor(.black, for: .normal)
            }

            self.action = {
                let controller = vkid.ui(for: self.makeSheet()).uiViewController()
                self.present(controller, animated: true)
            }
            return button
        }
    }

    private func makeButton(onTap: (()-> Void)? = nil) -> OneTapButton {
        if self.oAuthProviders.isEmpty {
            return .init(
                layout: self.authUI == .icon ?
                    .logoOnly(
                        size: .medium(.h44),
                        cornerRadius: 8
                    ) :
                    .regular(
                        height: .medium(.h44),
                        cornerRadius: 8
                    ),
                presenter: .uiViewController(self),
                authConfiguration: self.makeConfiguration(),
                onCompleteAuth: nil
            )
        } else {
            return .init(
                height: .medium(.h44),
                cornerRadius: 8,
                authConfiguration: self.makeConfiguration(),
                oAuthProviderConfiguration: self.makeOAuthProviderConfiguration(),
                presenter: .uiViewController(self),
                onCompleteAuth: nil
            )
        }
    }

    private func makeWidget() -> OAuthListWidget {
        .init(
            oAuthProviders: self.oAuthProviders,
            authConfiguration: self.makeConfiguration(),
            buttonConfiguration: .init(
                height: .medium(.h44),
                cornerRadius: 8
            ),
            onCompleteAuth: nil
        )
    }

    private func makeSheet() -> OneTapBottomSheet {
        .init(
            serviceName: "VKID Demo",
            targetActionText: .signIn,
            oneTapButton: .init(
                height: .medium(.h44),
                cornerRadius: 8
            ),
            authConfiguration: self.makeConfiguration(),
            oAuthProviderConfiguration: self.makeOAuthProviderConfiguration(),
            onCompleteAuth: nil
        )
    }

    private func makeOAuthProviderConfiguration() -> OAuthProviderConfiguration {
        .init(alternativeProviders: self.oAuthProviders)
    }

    private func makeConfiguration() -> AuthConfiguration {
        if self.debugSettings.providedPKCESecretsEnabled {
            guard let authSecrets = try? PKCESecrets() else {
                fatalError("PKCE secrets not generated")
            }
            self.providedAuthSecrets = authSecrets
            print("PKCE Secrets: \(authSecrets)")
        }

        // condition for interface testing
        if self.debugSettings.confidentialFlowEnabled {
            return .init(
                flow: .confidentialClientFlow(
                    codeExchanger: self,
                    pkce: self.providedAuthSecrets
                ),
                scope: Scope(self.debugSettings.scope)
            )
        } else {
            if self.debugSettings.providedPKCESecretsEnabled {
                return .init(
                    flow: .publicClientFlow(pkce: self.providedAuthSecrets),
                    scope: Scope(self.debugSettings.scope)
                )
            } else {
                return .init(
                    scope: Scope(self.debugSettings.scope)
                )
            }
        }
    }
}

extension AuthViewController: VKIDObserver {
    func vkid(_ vkid: VKID, didLogoutFrom session: UserSession, with result: LogoutResult) {}

    func vkid(_ vkid: VKID, didStartAuthUsing oAuth: OAuthProvider) {}

    func vkid(_ vkid: VKID, didCompleteAuthWith result: AuthResult, in oAuth: OAuthProvider) {
        do {
            let session = try result.get()
            print("Auth succeeded with\n\(session)")
            self.showAlert(message: session.debugDescription)
        } catch AuthError.cancelled {
            print("Auth cancelled by user")
        } catch {
            print("Auth failed with error: \(error)")
            self.showAlert(message: "Ошибка авторизации")
        }
    }
}
