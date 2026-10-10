# 見本データ（内容はすべて架空）。同じ slug があれば上書きするので、何度実行しても同じ結果になる。
#   bin/rails db:seed
articles = [
  {
    slug: "site-renewal",
    title: "ホームページをリニューアルしました",
    summary: "スマートフォンでも読みやすいデザインに変わりました。",
    body: "いつもご利用ありがとうございます。\n\nこのたび、ホームページをリニューアルしました。\nスマートフォンでも読みやすく、知りたい情報にすぐたどり着けるようにしています。\n\nお気づきの点がありましたら、お問い合わせフォームからお知らせください。",
    status: "published", published_at: 20.days.ago
  },
  {
    slug: "autumn-campaign",
    title: "秋のキャンペーンのお知らせ",
    summary: "10月末まで、初回のご相談が無料になります。",
    body: "10月末までの期間限定で、初回のご相談を無料でお受けします。\n\n■ 対象\nはじめてご利用の方\n\n■ お申し込み\nお問い合わせフォーム、またはお電話でご連絡ください。",
    status: "published", published_at: 12.days.ago
  },
  {
    slug: "business-hours",
    title: "営業時間を変更します",
    summary: "11月から、平日の受付を19時まで延長します。",
    body: "11月1日から、平日の受付時間を19時まで延長します。\n\n変更前：9:00〜18:00\n変更後：9:00〜19:00\n\n土曜日はこれまでどおり 9:00〜13:00 です。",
    status: "published", published_at: 8.days.ago
  },
  {
    slug: "staff-blog-1",
    title: "スタッフブログをはじめました",
    summary: "日々の取り組みや、ちょっとしたお役立ち情報をお届けします。",
    body: "スタッフブログをはじめました。\n\n日々の取り組みや、知っておくと便利な情報を、月に2回ほどお届けする予定です。",
    status: "published", published_at: 5.days.ago
  },
  {
    slug: "faq-updated",
    title: "よくある質問を更新しました",
    summary: "お支払い方法とキャンセルについての質問を追加しました。",
    body: "お問い合わせの多い内容を、よくある質問に追加しました。\n\n・お支払い方法について\n・キャンセルの期限について",
    status: "published", published_at: 3.days.ago
  },
  {
    slug: "seminar-report",
    title: "無料セミナーを開催しました",
    summary: "先日のセミナーの様子と、当日いただいた質問をまとめました。",
    body: "先日、無料セミナーを開催しました。\nご参加いただいた皆さま、ありがとうございました。\n\n当日いただいた質問と回答を、後日あらためて掲載します。",
    status: "published", published_at: 1.day.ago
  },
  {
    slug: "year-end-holidays",
    title: "年末年始の休業日について",
    summary: "12月29日から1月3日まで休業します。",
    body: "年末年始は、次の期間を休業とさせていただきます。\n\n12月29日〜1月3日\n\n休業中にいただいたお問い合わせは、1月4日以降に順次お返事します。",
    # 公開済みだが、公開日時が未来（予約公開）
    status: "published", published_at: 7.days.from_now
  },
  {
    slug: "new-service-draft",
    title: "新しいサービスについて（下書き）",
    summary: nil,
    body: "（書きかけ）新しいサービスの内容をここに書く。",
    status: "draft", published_at: nil
  }
]

articles.each do |attrs|
  Article.find_or_initialize_by(slug: attrs[:slug]).update!(attrs)
end

puts "見本の記事を #{articles.size} 件入れました（公開 6・予約 1・下書き 1）"
