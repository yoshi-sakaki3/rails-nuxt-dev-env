# Rails（API）＋ Nuxt（画面）開発環境（お知らせ・ブログの見本つき）

Docker Compose と VS Code Dev Containers で動く、**Rails を API にして、画面を Nuxt で作る**構成の開発環境です。
Ruby 単体のスクリプトも実行できます。Windows（PowerShell）向けの操作コマンド `dev.ps1` 付き。

動作確認済み（2026-10-10）：Windows 11 + Docker Desktop で、公開ページ（一覧・詳細・ページ送り・404）・検索エンジン向けの情報（タイトル・説明文・OGP）・管理画面（ログイン・一覧・追加・入力チェック・公開・削除）・保存時の反映（Rails・Nuxt）・双方向の同期・テスト（Rails はテスト用 DB）・書き方のチェック・安全面の検査・型チェック・Nuxt の本番ビルド・まっさらな状態からの準備。

| 画面 | URL | 内容 |
|---|---|---|
| 公開ページ | http://localhost:3500 | お知らせの一覧と詳細。サーバー側で HTML を作る（SSR）ので、検索エンジンに内容が読まれる |
| 管理画面 | http://localhost:3500/admin | 記事の追加・変更・公開・削除。合言葉は `.env` の `ADMIN_API_TOKEN`（ローカル開発専用） |
| API | http://localhost:3400/api/articles | Rails が返す JSON |

## 入っているもの

- API：Ruby 4.0 ＋ Rails 8.1（API 専用）、PostgreSQL 17、rails-i18n（エラーメッセージの日本語）
- 画面：Nuxt 4 ＋ Vue 3 ＋ TypeScript（公開ページは SSR、管理画面はブラウザ側だけで描画）
- 品質チェック
  - Rails：Minitest（テスト）、RuboCop（書き方）、Brakeman（安全面の自動検査）
  - Nuxt：Vitest（テスト）、vue-tsc（型チェック）、ESLint、Prettier
- テスト用の DB（`app_test`）を開発用（`app_development`）とは別に用意。テストで開発中のデータが消えない

### 見本（お知らせ・ブログ）で気を付けていること

- **予約公開**：公開側に出るのは「公開済み」かつ「公開日時を過ぎた」記事だけ。公開日時を未来にすると、その時刻から出る。下書き・予約中の記事は、URL を知っていても 404（下書きがあることも知らせない）
- **検索エンジン・SNS 向けの情報**：記事ごとに、タイトル・説明文（要約。無ければ本文の先頭）・OGP・公開日時を HTML に入れる
- **合言葉をブラウザに渡さない**：管理用の合言葉は、JavaScript から読めない Cookie（httpOnly・SameSite=Strict）に入れ、Rails を呼ぶのは Nuxt のサーバーだけにする。ブラウザは Nuxt だけを呼ぶので、CORS の設定もいらない
- 合言葉が未設定のサーバーでは、管理用 API は誰も通さない。合言葉の比較は、処理時間から中身が漏れない方法で行う
- 本文は文字として表示する（HTML として解釈しないので、`<script>` が入っていても実行されない）
- 日時は日本時間で入力・表示する（サーバーやブラウザの時計の設定に左右されない）
- 入力の誤りは、Rails が日本語で項目ごとに返し、画面の各欄の下に出す

> 見本の管理画面は、合言葉 1 つでのログインです。本番では、利用者ごとのアカウント・パスワードの保管・ログイン失敗の回数制限などを、案件に合わせて足してください。

## 初回だけの準備

1. Docker Desktop を起動する（初めての PC は、先に管理者の PowerShell で `wsl --install` と再起動が必要）
2. このフォルダで準備コマンドを実行する
   ```powershell
   cd rails-nuxt-dev-env
   .\dev.ps1 setup
   ```
   gem と npm パッケージの取得・DB の作成・見本の記事（8件）の投入まで自動で行います（初回は 5 分ほど）。
   終わってから 1 分ほど（Nuxt の最初の起動）待って、http://localhost:3500 を開いてください。

> PowerShell で「スクリプトの実行が無効」と出たら：`powershell -ExecutionPolicy Bypass -File .\dev.ps1 setup`

## 普段の使い方

```powershell
.\dev.ps1 up              # 起動
.\dev.ps1 down            # 停止
.\dev.ps1 rails generate model Item name:string   # rails コマンド
.\dev.ps1 ruby -e "puts RUBY_VERSION"             # Ruby 単体で実行
.\dev.ps1 irb             # Ruby の対話コンソール
.\dev.ps1 web add xxx     # Nuxt 側にライブラリを追加
.\dev.ps1 check           # 書き方のチェック・安全面の検査・型チェック・テストをまとめて実行
.\dev.ps1 help            # コマンド一覧
```

ソースを保存すると、Rails も Nuxt も 3 秒ほどで反映されます。
開発中は、管理画面を開き直すたびに表示まで数秒かかります（開発用に部品をばらばらに読み込むため。本番ビルドではまとまります）。

## つなぎ方を使い分けている理由（Rails は同期、Nuxt は直接）

Docker Desktop で Windows のフォルダをコンテナから直接読むと、ファイル1つの確認に数ミリ秒かかります。

- **Rails**：リクエストのたびに「ソースが変わっていないか」を多くのファイルで確かめるので、直接つなぐと遅くなります。そこで、Rails にはコンテナ内の速い領域を読ませ、`api` フォルダとは同期ツール（unison）が 2 秒おきに双方向でそろえます。
- **Nuxt**：重い部分（`node_modules` とビルド結果）を最初からコンテナ側に置いているので、直接つないでも速さは変わりません（別の環境で同期方式を試して、差がないことを確かめています）。

| 測ったもの（同じ PC での実測） | Rails を直接つないだ環境 | この環境（Rails は同期） |
|---|---|---|
| Rails の応答（1回） | 0.6〜2.8 秒 | 0.03〜0.05 秒 |
| Rails のテスト（コマンド全体） | 約 90 秒 | 約 13 秒（24 件。テストそのものは約 2 秒） |

- `api` で保存した内容は 2〜3 秒で Rails に届き、コンテナの中で作ったファイル（`rails generate` の結果、`db/schema.rb`、`Gemfile.lock`）は `api` に戻ります。
- `tmp`・`log`・`storage` と gem は同期しません（コンテナ側だけにあります）。ログは `.\dev.ps1 logs api` で見られます。
- 両方で同じファイルを同時に変えたときは、新しいほうを採用します。片方が丸ごと空に見えるときは、全消しを防ぐために同期が止まります（様子は `.\dev.ps1 sync`）。
- 同期役は、待機中も CPU を少し使います。使わないときは `.\dev.ps1 down` で止めてください。

## VS Code で開発する（おすすめ）

VS Code でこのフォルダを開き、「コンテナーで再度開く（Reopen in Container）」を選ぶと、コンテナの中で補完やテストがそのまま使えます（拡張機能「Dev Containers」が必要）。
「API」（Rails）と「画面」（Nuxt）の2つの設定があるので、作業する側を選んでください。

## お客さまのソースを扱うときの注意

- お客さまのソースや個人情報を AI（Claude など）に渡す前に、秘密保持契約で外部の AI サービスの利用が認められているかを確認する
- `.env` には本番のパスワードや合言葉を入れない（この環境はローカル専用の値で動く）
- Rails の `config/master.key` は Git に入れない（この見本でも除外している）

## フォルダ構成

```
rails-nuxt-dev-env/
├─ compose.yaml            … どのサービスを起動するか
├─ env.example             … 設定の見本（setup で .env にコピーされる）
├─ dev.ps1                 … 操作コマンド
├─ docker/                 … Ruby・Node.js のイメージ、同期役（unison）
├─ api/                    … Rails（API 専用）
│  ├─ app/models/article.rb          … 記事（公開・予約公開の判定）
│  ├─ app/controllers/api/           … 公開用の API と、管理用の API（admin/）
│  ├─ config/locales/ja.yml          … 項目名とエラーメッセージ
│  ├─ db/                            … テーブルの定義・見本データ
│  └─ test/                          … テスト
├─ web/                    … Nuxt（画面）
│  ├─ app/pages/           … 公開ページ（index・articles/[slug]）と管理画面（admin/）
│  ├─ app/components/      … 記事の入力フォーム
│  ├─ app/utils/           … 日付の表示・エラーの読み取り
│  ├─ server/api/          … Rails への取り次ぎ（ログイン・合言葉の付け足し）
│  └─ tests/               … テスト
└─ .devcontainer/          … VS Code Dev Containers の設定
```
