# TestFlight提出手順書(第1段階)

「あかし」をTestFlightの外部テストとして配布するまでの、あなた(澤井さん)ご自身がApple ID/Mac上で行う作業の手順です。
コード側の準備(SwiftUIアプリ本体)はリポジトリの`app/Akashi`にあります。

費用をかけずに動作確認したい場合は、まず**Stage 0(無料)**だけを行い、納得できてからStage 1(Apple Developer Program登録、$99/年)に進んでください。

## Stage 0(無料): 自分の端末でだけ動作確認する

Apple Developer Programに登録しなくても、無料のApple IDだけで自分のiPhoneにインストールして動作確認できます。詳しい手順は`app/Akashi/README.md`の「まずは無料の範囲で試す」セクションを参照してください。要点は以下の通りです。

- [ ] Mac + Xcode 15以降、無料のApple ID
- [ ] Xcodeの「Signing & Capabilities」で自分のApple ID(Personal Team)を選択し、実機にビルド・実行
- [ ] 初回は端末側で「設定 → 一般 → VPNとデバイス管理」からデベロッパを信頼する
- [ ] 無料プロビジョニングは7日で失効するため、都度Xcodeから再インストールが必要
- [ ] アプリ内課金は、同梱の`Products.storekit`をXcodeのスキーム設定(Run → Options → StoreKit Configuration)で指定すれば、課金なしでローカルにテストできる
- [ ] TestFlightは使えないため、自分以外の人には配布できない(友人にも試してもらいたくなったらStage 1へ)

## Stage 1(有料・$99/年): TestFlightで外部テストする

### 0. 事前に必要なもの

- [ ] Mac + Xcode 15以降
- [ ] Apple ID(個人のもので可)
- [ ] クレジットカード等、Apple Developer Program登録用の支払い手段($99/年)

## 1. Apple Developer Programに登録する

1. https://developer.apple.com/programs/enroll/ から「Individual(個人)」で登録
2. 本人確認(運転免許証等)が必要になる場合があります
3. 登録完了まで通常数時間〜数日かかります

## 2. リポジトリのコードをXcodeで開く

```bash
brew install xcodegen
git clone <このリポジトリのURL>
cd create_app/app/Akashi
xcodegen generate
open Akashi.xcodeproj
```

Xcode内で:
- 「Signing & Capabilities」で自分のTeamを選択
- Bundle Identifier (`com.akashi.app.Akashi`) を、次のApp Store Connectでの登録と一致させる

## 3. GitHub Pagesでプライバシーポリシーを公開する

1. GitHubのリポジトリ画面 → Settings → Pages
2. 「Source」を `Deploy from a branch` にし、ブランチは `main`(または最終的にマージするブランチ)、フォルダは `/docs` を選択して保存
3. 数分後、`https://yuu642.github.io/create_app/legal/privacy_policy.html` でプライバシーポリシーが閲覧できるようになります(アプリの「設定」からもリンクしています)

## 4. App Store Connectでアプリを登録する

1. https://appstoreconnect.apple.com にアクセス
2. 「マイApp」→「+」→「新規App」
3. プラットフォーム: iOS、名前: 「あかし」(またはApp Store掲載文言ドラフトの候補名)、Bundle ID: 手順2と同じもの、SKU: 任意の管理用文字列
4. 「App情報」で、プライバシーポリシーURLに手順3のURLを入力

## 5. アプリ内課金(In-App Purchase)商品を登録する

`Sources/Services/StoreService.swift` の `ProductID` と一致するProduct IDで、それぞれ「消費不可能(Non-Consumable)」として登録してください。

| Product ID | 内容 | 参考価格 |
|---|---|---|
| com.akashi.app.supporter.coffee | コーヒー1杯分サポーター | ¥120 |
| com.akashi.app.supporter.lunch | ランチ1食分サポーター | ¥490 |
| com.akashi.app.supporter.full | めいっぱい応援サポーター | ¥980 |
| com.akashi.app.theme.sakura | 着せ替え「さくら」 | 任意 |
| com.akashi.app.theme.night | 着せ替え「夜のしずく」 | 任意 |
| com.akashi.app.theme.dawn | 着せ替え「朝焼け」 | 任意 |

TestFlightでの動作確認時、これらはApple側のSandbox環境で疑似購入されるため、実際の課金は発生しません。

## 6. ビルドをアーカイブしてアップロードする

1. Xcodeで実機またはGeneric iOS Deviceを選択
2. メニュー「Product」→「Archive」
3. Organizerウィンドウが開いたら「Distribute App」→「App Store Connect」→「Upload」

## 7. TestFlightで外部テストを設定する

1. App Store Connectの対象アプリ →「TestFlight」タブ
2. アップロードしたビルドを選択
3. 輸出コンプライアンス等の質問に回答(暗号化: 標準的なHTTPS等のみ使用の場合は「いいえ」でよいことが多いですが、実際の実装内容に応じて回答してください)
4. 「External Testing」グループを新規作成し、テスト用の説明文(What to Test)を記入
5. 「Submit for Review」でBeta App Review(簡易審査)に提出
6. 承認後、公開リンクが発行されるので、任意の人に共有してテストしてもらう

## 8. 収益化・正式公開(第2段階)に進む際は

- 利用規約・特定商取引法に基づく表記を確定させ、`docs/legal`に追加してGitHub Pagesで公開する
- Apple Developer Programの登録形態(Individual継続か、法人化してOrganizationに切り替えるか)を確定させる
- 通常のApp Store提出(フル審査)を行う

---

**現時点でのTODO(コード内のTODOコメントと対応):**
- [ ] `Sources/Views/Guide/GuideView.swift` — 弁護士相談窓口の実際の電話番号
- [ ] アプリアイコン・スクリーンショットの用意(実装済みアプリからの撮影)
- [ ] 実機での録音・位置情報・カメラ・画面録画の動作確認
