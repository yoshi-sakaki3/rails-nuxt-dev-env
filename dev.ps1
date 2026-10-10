<#
  Rails（API）＋ Nuxt（画面）開発環境の操作コマンド（PowerShell）
  使い方:  .\dev.ps1 <コマンド> [引数]
  一覧:    .\dev.ps1 help
#>
# 引数は param() で受けず、そのまま読む。
# param() を使うと、-e や -m のようにハイフンで始まる指定を PowerShell がこのスクリプトあての指定と解釈して、
# 「.\dev.ps1 ruby -e ...」や「.\dev.ps1 rails generate model Item -f」がエラーになるため。
$Command = if ($args.Count -gt 0) { [string]$args[0] } else { 'help' }
$Rest = @(if ($args.Count -gt 1) { $args[1..($args.Count - 1)] })

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

function Invoke-Compose { docker compose @args; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }

function Test-Docker {
    docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'Docker が起動していません。Docker Desktop を起動してから、もう一度実行してください。' -ForegroundColor Yellow
        exit 1
    }
}

switch ($Command) {
    'setup' {
        if (-not (Test-Path .env)) { Copy-Item env.example .env; Write-Host '.env を作成しました。' }
        Test-Docker
        Invoke-Compose build
        # api フォルダの内容を、コンテナ内の速い領域にそろえる（以後は sync サービスが 2 秒おきにそろえ続ける）
        Invoke-Compose run --rm sync sync-app once
        Invoke-Compose run --rm --no-deps api bundle install
        Invoke-Compose run --rm --no-deps web pnpm install
        Invoke-Compose up -d db sync
        # DB の作成・テーブルの作成・見本データの投入（開発用とテスト用の DB を作る）
        Invoke-Compose run --rm api bundle exec rails db:prepare
        Invoke-Compose up -d
        Write-Host ''
        Write-Host '準備ができました。Nuxt の最初の起動には 1 分ほどかかります。' -ForegroundColor Green
        & $PSCommandPath urls
    }
    'up'      { Test-Docker; Invoke-Compose up -d; & $PSCommandPath urls }
    'down'    { Invoke-Compose down }
    'restart' { Invoke-Compose restart api web }
    'rebuild' { Test-Docker; Invoke-Compose build --no-cache; Invoke-Compose up -d }
    'status'  { Invoke-Compose ps }
    'logs'    { Invoke-Compose logs -f --tail 100 @Rest }
    'sync'    { Invoke-Compose ps sync; Invoke-Compose logs --tail 20 sync }
    'sh'      { Invoke-Compose exec api bash }
    'rails'   { Invoke-Compose exec api bundle exec rails @Rest }
    'bundle'  { Invoke-Compose exec api bundle @Rest }
    'ruby'    { Invoke-Compose exec api ruby @Rest }
    'irb'     { Invoke-Compose exec api irb }
    'console' { Invoke-Compose exec api bundle exec rails console }
    'migrate' { Invoke-Compose exec api bundle exec rails db:migrate }
    'seed'    { Invoke-Compose exec api bundle exec rails db:seed }
    'web'     { Invoke-Compose exec web pnpm @Rest }
    'test' {
        Invoke-Compose exec api bundle exec rails test @Rest
        Invoke-Compose exec web pnpm test
    }
    'format' {
        Invoke-Compose exec api bundle exec rubocop -a
        Invoke-Compose exec web pnpm format
    }
    'check' {
        Invoke-Compose exec api bundle exec rubocop
        Invoke-Compose exec api bundle exec brakeman -q --no-pager
        Invoke-Compose exec api bundle exec rails test
        Invoke-Compose exec web pnpm check
    }
    'build'   { Invoke-Compose exec web pnpm build }
    'db'      { Invoke-Compose exec db sh -c 'psql -U "$POSTGRES_USER" app_development' }
    'urls' {
        Write-Host '  公開ページ（Nuxt） http://localhost:3500'
        Write-Host '  管理画面           http://localhost:3500/admin（合言葉は .env の ADMIN_API_TOKEN）'
        Write-Host '  API（Rails）       http://localhost:3400/api/articles'
        Write-Host '  DB                 localhost:5439（ユーザー app / パスワード app）'
    }
    'clean' {
        $ans = Read-Host 'DB・gem・node_modules を含めて全部消します。よろしいですか？ (yes/no)'
        if ($ans -eq 'yes') { Invoke-Compose down -v --rmi local }
    }
    default {
        @'
使い方: .\dev.ps1 <コマンド>

  setup          初回の準備（.env 作成・ビルド・同期・bundle install・pnpm install・DB 作成・見本データ・起動）
  up / down      起動 / 停止
  restart        Rails と Nuxt を再起動
  rebuild        イメージを作り直して起動（Dockerfile を変えたとき）
  status         動いているサービスの一覧
  logs [名前]    ログを見る（例: .\dev.ps1 logs api）
  sync           api フォルダとコンテナの同期の状態を見る

  rails ...      rails コマンド（例: .\dev.ps1 rails generate model Item name:string）
  bundle ...     bundle コマンド（例: .\dev.ps1 bundle add kaminari）
  ruby ...       Ruby を実行（例: .\dev.ps1 ruby -e "puts RUBY_VERSION"）
  irb            Ruby の対話コンソール
  console        Rails コンソール
  migrate        テーブルの変更を DB に反映
  seed           見本データを入れ直す
  sh             Rails のコンテナの中に入る
  web ...        Nuxt 側の pnpm コマンド（例: .\dev.ps1 web add @vueuse/nuxt）

  test           テストを実行（Rails はテスト用の DB を使う）
  format         コードの書き方を自動でそろえる（RuboCop・Prettier）
  check          書き方のチェック・安全面の検査・型チェック・テストをまとめて実行
  build          Nuxt の本番用ビルドを試す
  db             PostgreSQL に接続
  urls           各画面の URL を表示
  clean          データごと全部消す（確認あり）
'@ | Write-Host
    }
}
