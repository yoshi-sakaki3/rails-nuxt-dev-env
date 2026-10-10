require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  def build(attrs = {})
    Article.new({ title: "テスト", slug: "test-article", body: "本文" }.merge(attrs))
  end

  test "公開側に出るのは、公開済みで公開日時を過ぎた記事だけ" do
    assert_equal %w[newer-news older-news], Article.visible.newest_first.pluck(:slug)
    assert articles(:newer).visible?
    assert_not articles(:scheduled).visible?
    assert articles(:scheduled).scheduled?
    assert_not articles(:draft).visible?
  end

  test "公開日時を入れずに公開すると、今すぐ公開になる" do
    freeze_time do
      article = build(status: "published")
      assert article.save
      assert_equal Time.current, article.published_at
      assert article.visible?
    end
  end

  test "下書きは公開日時が空のままでよい" do
    article = build
    assert article.save
    assert article.draft?
    assert_nil article.published_at
  end

  test "タイトルと本文は必須で、エラーは日本語で返る" do
    article = build(title: " ", body: "")
    assert_not article.valid?
    assert_includes article.errors.full_messages, "タイトルを入力してください"
    assert_includes article.errors.full_messages, "本文を入力してください"
  end

  test "URL 用の名前は英小文字・数字・ハイフンだけ" do
    assert build(slug: "autumn-campaign-2026").valid?
    [ "autumn_campaign", "秋のお知らせ", "-start", "end-", "double--hyphen", "has space" ].each do |slug|
      article = build(slug:)
      assert_not article.valid?, "#{slug} は通してはいけない"
      assert_match "半角の英小文字・数字・ハイフン", article.errors.full_messages_for(:slug).first
    end
  end

  test "URL 用の名前は、前後の空白を取り、小文字にそろえる" do
    article = build(slug: "  New-Article  ")
    assert article.valid?
    assert_equal "new-article", article.slug
  end

  test "URL 用の名前は重複できない" do
    article = build(slug: articles(:newer).slug)
    assert_not article.valid?
    assert_includes article.errors.full_messages, "URL 用の名前はすでに存在します"
  end

  test "決まっていない状態は受け付けない" do
    assert_not build(status: "archived").valid?
  end
end
