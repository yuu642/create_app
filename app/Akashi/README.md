# あかし (Akashi) — iOSアプリ

痴漢・盗撮を疑われた瞬間の自衛(記録・対処法ガイド・弁護士連絡)をサポートするアプリです。

このコードは **Linux上のリモート環境で作成されており、ビルド・実機確認は行っていません**。
XcodeがインストールされたmacOS環境で、以下の手順でプロジェクトを開いてビルドしてください。

## 必要環境

- macOS + Xcode 15以降
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)(`.xcodeproj`をこのリポジトリでは管理せず、`project.yml`から生成する方式にしています)

```bash
brew install xcodegen
```

## セットアップ手順

```bash
cd app/Akashi
xcodegen generate
open Akashi.xcodeproj
```

Xcodeが開いたら:

1. 「Signing & Capabilities」タブで、自分のApple Developerチームを選択する
2. Bundle Identifier (`com.akashi.app.Akashi`) を、実際にApp Store Connectで登録するIDに変更する(必要に応じて`project.yml`も更新して`xcodegen generate`を再実行)
3. シミュレーターまたは実機でビルド・実行して動作確認する

## まずは無料の範囲で試す

Apple Developer Program($99/年)に登録しなくても、無料のApple IDだけで、自分のiPhoneにアプリをインストールして動作確認できます。

1. Xcodeの「Signing & Capabilities」で、Teamに自分のApple ID(サインインしていなければ「Add Account...」から追加)を選ぶと、自動的に「〇〇 (Personal Team)」が選べるようになります
2. iPhoneをMacにケーブルで接続し、Xcode上部の実行先を自分の端末に切り替えて実行(▶ボタン)
3. 初回は端末側で「設定 → 一般 → VPNとデバイス管理」から、このApple IDのデベロッパApp設定を「信頼」する必要があります
4. **制約**: 無料のプロビジョニングプロファイルは7日で失効するため、7日ごとにXcodeから再インストールが必要です。TestFlightは使えず、あくまで自分の端末での動作確認用です

### アプリ内課金(IAP)も無料でテストできます

`Products.storekit` (Xcode StoreKit Testing用の設定ファイル)を同梱しています。Xcodeで以下を設定すると、App Store Connectに商品登録しなくても、purchaseフローをローカルでシミュレートできます。

1. Xcodeメニュー「Product」→「Scheme」→「Edit Scheme...」
2. 「Run」タブ →「Options」→「StoreKit Configuration」で `Products.storekit` を選択
3. 実行すると、応援課金・着せ替えの購入ボタンがローカルのテスト決済で動作します(実際の課金は発生しません)

## プロジェクト構成

```
Sources/
  App/            アプリのエントリーポイント、Info.plist設定
  Models/         IncidentRecordなどのデータモデル
  Services/       録音・位置情報・画面録画・ストア(IAP)・永続化サービス
  Views/          画面ごとのSwiftUI View(プロトタイプの画面構成に対応)
  Resources/      カラーパレット・フォントなどのデザイントークン
AkashiTests/      ユニットテスト
```

## 実装済み機能 / 未実装・要確認事項

- [x] オンボーディング、ホーム、記録(痴漢/盗撮モード)、提示画面、対処法ガイド、記録一覧、冤罪アラーム、男性向け情報、支援の輪、着せ替え、応援課金の画面
- [x] 録音(AVAudioRecorder)・位置情報(CoreLocation)・画面録画(ReplayKit)・端末内暗号化保存
- [x] StoreKit 2によるIn-App Purchase雛形(応援課金3ティア、着せ替えテーマ3種)
- [ ] **App Store Connect側でのApp内課金プロダクトの実際の登録**(`Sources/Services/StoreService.swift`の`ProductID`と一致するIDで登録してください)
- [ ] **弁護士相談窓口の実際の電話番号**(`Sources/Views/Guide/GuideView.swift`内のTODOコメントを参照)
- [ ] **プライバシーポリシー等のURL差し替え**(`Sources/Views/Settings/SettingsView.swift`内のTODOコメントを参照。`docs/legal`をGitHub Pagesで公開後のURLに差し替える)
- [ ] アプリアイコン・起動画面の画像アセット(現在はSF Symbolsで代替しているプレースホルダー箇所あり)
- [ ] 実機でのマイク・位置情報・カメラ・画面録画の動作確認、パーミッション文言の最終調整
- [ ] 目撃者連絡先の入力機能(提示画面のUIのみ実装済み、実際の連絡先保存・共有ロジックは未実装)

## 技術的な制約について

プロトタイプの「盗撮モード」で構想されていた、直前に使用していたアプリ名・カメラ起動履歴の自動取得は、
**iOSのプライバシー保護の仕様上、サードパーティアプリからは取得不可能**です。代わりに、ユーザー自身が
その場で画面録画(ReplayKit)を開始し、「カメラアプリを起動していないこと」を録画データそのもので
証明する形に置き換えています。
