# Nihongo Tap

A calm, distraction-free Android app for learning everyday Japanese vocabulary with instant tap-to-hear pronunciation and simple verb conjugations.

## Features

- **Tap-to-hear audio:** Touch any word, conjugated form, or example sentence to hear its Japanese (`ja-JP`) pronunciation via Android TTS.
- **Everyday first:** Opens on the **Everyday** tab ordered by daily usefulness, with category filters for **Nouns**, **Verbs**, **Adjectives**, and **Other**.
- **Simple verb conjugations:** Tap **Forms** on any verb to view its verb group rule, 6 essential forms (*Polite*, *Polite Negative*, *Past*, *Te-form*, *Want to*, *Can do*) with highlighted endings, and short example sentences.
- **Clean controls:** Toggle Romaji (`Aa`), slow pronunciation (`0.7×`), or instant search across English, kana, kanji, and romaji.

## Automatic Android Updates

Signed release APKs are built and published automatically to [GitHub Releases](https://github.com/radicelle/nihongo_tap/releases) on every push to `main` and every `v*.*.*` tag, with monotonically increasing `versionCode` for seamless in-place updates.

To get automatic updates on Android using **[Obtainium](https://obtainium.imranr.dev/)**:
1. Open Obtainium and tap **Add App**.
2. Paste `https://github.com/radicelle/nihongo_tap`.
3. Obtainium will track new GitHub Releases and prompt/update the signed APK automatically.

## Local Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
