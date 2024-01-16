<div align="center">
  <h1 align="center">
    <img src="logo.svg" width="150" alt="VK ID SDK Logo">
  </h1>
  <p align="center">
    VK ID SDK — библиотека для авторизации пользователей iOS приложений с помощью аккаунта VK ID.
  </p>
</div>

---

:information_source: VK ID SDK сейчас находится в бета-тестировании. О проблемах вы можете сообщить с помощью <a href="https://github.com/VKCOM/vkid-ios-sdk/issues">issues репозитория</a>.

---

## Предварительно

Общий план интеграции и в целом что такое VK ID можно прочитать [здесь](https://id.vk.com/business/go/docs/ru/vkid/latest/vk-id/intro/plan).

Чтобы подключить VK ID SDK, сначала получите ID приложения (app_id) и защищенный ключ (client_secret). Для этого создайте приложение в [кабинете подключения VK ID](https://id.vk.com/business/go).

## Требования к приложению
* iOS 12.0 и выше
* Swift 5.9 и выше

## Установка

### Swift Package Manager
Добавьте VKID как зависимость в ваш `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/VKCOM/vkid-ios-sdk.git", .upToNextMajor(from: "1.0.0"))
]
```

### CocoaPods
Добавьте в ваш `Podfile`:
```ruby
pod 'VKID', '~> 1.0'
```
Выполните следующие команды, чтобы установить зависимости:
```shell
pod install --repo-update
```

## Интеграция

### Настройка Info.plist
Для поддержки бесшовной авторизации через провайдер (клиент ВКонтакте или другое официальное приложение VK) внесите в ваш `Info.plist` следующие изменения:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>vkauthorize-silent</string>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>auth_callback</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>vk123456</string> // Вместо 123456 подставьте ID вашего приложения.
        </array>
    </dict>
</array>
```

### Поддержка Universal Links
VK ID SDK взаимодействует с провайдерами авторизации через [Universal Links](https://developer.apple.com/ios/universal-links/).
При [настройке VK ID](https://id.vk.com/business/go/docs/vkid/latest/plan#Podgotovka-k-integracii) в кабинете его подключения укажите Universal Link, по которой провайдер авторизации откроет ваше приложение. Добавьте [поддержку Universal Links](https://developer.apple.com/documentation/xcode/supporting-associated-domains?language=objc) в приложение.

### Инициализация VK ID SDK
Все взаимодействие с VK ID SDK происходит через объект `VKID`. SDK не предоставляет shared объект, его необходимо удерживать самостоятельно после инициализации, например, в `ApplicationDelegate` или `SceneDelegate`. Повторная инициализация будет приводить к ошибке.
```swift
import VKID

do {
    let vkid = try VKID(
        config: Configuration(
            appCredentials: AppCredentials(
                clientId: clientId,         // ID вашего приложения (app_id)
                clientSecret: clientSecret  // ваш защищенный ключ (client_secret)
            )
        )
    )
} catch {
    preconditionFailure("Failed to initialize VKID: \(error)")
}
```

### Базовая авторизация
Флоу авторизации запускается вызовом метода `authorize`:
```swift
vkid.authorize(
    using: .uiViewController(presentingController)
) { result in
    do {
        let session = try result.get()
        print("Auth succeeded with token: \(session.accessToken) and user info: \(session.user)")
    } catch AuthError.cancelled {
        print("Auth cancelled by user")
    } catch {
        print("Auth failed with error: \(error)")
    }
}
```

Так же необходимо поддержать открытие ссылки при возврате в ваше приложение из провайдера авторизации. Для этого в вашем `AppDelegate` сделайте следующие изменения:
```swift
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
) -> Bool {
    return self.vkid.open(url: url)
}
```

Если ваше приложение использует `UIScene`, то нужно реализовать следующий метод из `UISceneDelegate`:
```swift
func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
) {
    URLContexts.forEach { ctx in
        self.vkid.open(url: ctx.url)
    }
}
```

После авторизации пользователя в сервисе с помощью VK ID, получите его данные.

Данные [User](VKID/Sources/Core/User.swift) находятся в объекте [UserSession](VKID/Sources/Core/UserSession.swift), который приходит как результат авторизации.

```swift
    let session = try result.get()
    let token = session.token
    let user = session.user
```

Так же [UserSession](VKID/Sources/Core/UserSession.swift), можно получить воспользовавшись объектом VKID.

```swift
    let session = vkid.currentAuthorizedSession
```

Для того, чтобы в [User](VKID/Sources/Core/User.swift) была информация о почте, перейдите в сервис авторизации VK ID, выберите ваше приложение и в разделе **Доступы** укажите опцию с почтой.

### Авторизация по кнопке OneTap
`OneTapButton` - конфигурация стилизованной кнопки авторизации. Чтобы использовать кнопку OneTap на своих экранах, сконфигурируйте `OneTapButton` и получите `UIView` для нее:
```swift
let oneTap = OneTapButton { authResult in
    do {
        let session = try authResult.get()
        print("Auth succeeded with token: \(session.accessToken)")
    } catch AuthError.cancelled {
        print("Auth cancelled by user")
    } catch {
        print("Auth failed with error: \(error)")
    }
}
let oneTapView = vkid.ui(for: oneTap).uiView()
view.addSubview(oneTapView)
```

При необходимости вы можете настроить стиль кнопки:
```swift
let oneTap = OneTapButton(
    appearance: .init(
        style: .primary(),
        theme: .matchingColorScheme(.system)
    ),
    layout: .regular(
        height: .large(.h56),
        cornerRadius: 28
    ),
    presenter: .newUIWindow
) { authResult in
    // authResult handling
}
```
Детальная кастомизация `OneTapButton` доступна на экране [OneTapButtonCustomizationController](VKIDDemo/VKIDDemo/Sources/OneTapButtonCustomizationController.swift) в демо-приложении.

### Шторка авторизации
`OneTapBottomSheet` - конфигурация для модальной шторки авторизации. Этот компонент представляет собой модальную карточку, которая анимированно выезжает снизу экрана и скрывается свайпом или тапом вне области карточки. Шторка позволяет добавить контекст, в котором проходит авторизация, выбрав нужный текст для целевого действия.

Для показа шторки сконфигурируйте `OneTapBottomSheet`, получите `UIViewController` и покажите его модально:
```swift
let oneTapSheet = OneTapBottomSheet(
    serviceName: "Your service name",
    targetActionText: .signIn,
    oneTapButton: .init(
        height: .medium(.h44),
        cornerRadius: 8
    ),
    theme: .matchingColorScheme(.system),
    autoDismissOnSuccess: true
) { authResult in
    // authResult handling
}
let sheetViewController = vkid.ui(for: oneTapSheet).uiViewController()
present(sheetViewController, animated: true)
```
Детальная кастомизация `OneTapBottomSheet` доступна на экране [OneTapBottomSheetCustomizationController](VKIDDemo/VKIDDemo/Sources/OneTapBottomSheetCustomizationController.swift) в демо-приложении.

## Демонстрация

SDK поставляется с демо-приложением [VKIDDemo](VKIDDemo), где можно посмотреть работу авторизации и как кастомизируются предоставляемые визуальные компоненты. Для корректной работы демо-приложения укажите параметры `CLIENT_ID` и `CLIENT_SECRET` вашего приложения VKID в файле [Info.plist](VKIDDemo/VKIDDemo/Resources/Info.plist).

## Документация

- [Что такое VK ID](https://id.vk.com/business/go/docs/ru/vkid/latest/vk-id/intro/plan)
- [Создание приложения](https://id.vk.com/business/go/docs/ru/vkid/latest/vk-id/connection/create-application)
- [Требования к дизайну](https://id.vk.com/business/go/docs/ru/vkid/archive/1.60/vk-id/guidelines/design-rules )
