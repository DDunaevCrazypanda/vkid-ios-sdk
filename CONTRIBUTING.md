# Contributing

## ⏳ Подготовка к разработке
Склонируйте репозиторий и перейдите в созданный каталог:

```bash
git clone git@github.com:VKCOM/vkid-ios-sdk.git
cd ios-sdk
```
Также можно сделать копию репозитория через Fork и работать в ней.

Для корректной работы автоформатирования выполните:  

```bash
sh scripts/install-git-hooks.sh
```
## 🐶 Базовые команды
Все команды запускаются из корня проекта:

```
 xcodebuild -scheme VKID -sdk iphonesimulator17.0 -destination "name=Any iOS Device" // полная сборка проекта
 xcodebuild test -scheme VKIDTests -sdk iphonesimulator17.0 -destination "name=iPhone 15" // прогон тестов
 swiftformat . // запуск форматирования кода
```

## 🪵 Создание ветки

Ветки создавайте от `develop`.

Для названия веток используйте шаблон:

```
{username}/{task_type}/{description}/{issue_number}
```

Где:
 - {username} – имя пользователя латиницей, например ivan.ivanov  
 - {task_type} – feature, если это крупное улучшение, или fix, если исправление бага  
 - {description} – краткое описание проделанной работы  
 - {issue_number} – VKIDSDK-XXX для разработчиков VK и ISSUE-XXXХ для внешних пользователей  

Пример:
```bash
git checkout develop
git pull
git checkout -b u.name/feature/some-feature/ISSUE-0000
```

В вебхуке `commit-msg` проверяется соответствие названия ветки шаблону.

## 📝 Создание коммита

Сообщение в коммите должно соответствовать шаблону:

```
{issue_number}: {commit_description} 
```

Где:
 - {issue_number} – VKIDSDK-XXX для разработчиков VK и ISSUE-XXX для внешних пользователей  
 - {commit_description} – краткое описание коммита на английском языке  

В вебхук `commit-msg` добавляется линтер, где проверяется соответствие сообщения в коммите шаблону.

Пример:
```bash
git checkout develop
git add -A
git commit -m "ISSUE-0000: some commit description"
```

## 😸 Подготовка Merge Request

Заголовок Merge Request (MR) пропишите по шаблону:
```
{issue_number}: {commit_description} 
```

Где:
 - {issue_number} – VKIDSDK-XXX для разработчиков VK и ISSUE-XXX для внешних пользователей  
 - {commit_description} – краткое описание коммита на английском языке  

Пример:
```
ISSUE-000: Some issue description
```

При подготовке MR проверьте себя по [чек-листу](.gitlab/merge_request_templates/Default.md)

## 🚅 Релизы версий
### <span style="color:green">TODO, добавить после публикации релизов</span>

## 🖊️ Документация
### <span style="color:green">TODO, добавить после поддержки генерации документации</span>

