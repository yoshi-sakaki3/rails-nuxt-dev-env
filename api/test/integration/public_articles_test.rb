require "test_helper"

class PublicArticlesTest < ActionDispatch::IntegrationTest
  test "一覧は、公開中の記事だけを新しい順に返す（本文は含めない）" do
    get "/api/articles"

    assert_response :success
    json = response.parsed_body
    assert_equal %w[newer-news older-news], json["articles"].pluck("slug")
    assert_equal 2, json["total"]
    assert_equal 1, json["totalPages"]
    assert_not json["articles"].first.key?("body")
  end

  test "一覧は 5 件ごとにページを分ける" do
    6.times do |i|
      Article.create!(title: "追加 #{i}", slug: "extra-#{i}", body: "本文", status: "published",
                      published_at: (i + 10).days.ago)
    end

    get "/api/articles", params: { page: 2 }

    json = response.parsed_body
    assert_equal 8, json["total"]
    assert_equal 2, json["totalPages"]
    assert_equal 3, json["articles"].size
  end

  test "ページ番号がおかしいときは 1 ページ目を返す" do
    get "/api/articles", params: { page: "abc" }
    assert_response :success
    assert_equal 1, response.parsed_body["page"]
  end

  test "記事の詳細を URL 用の名前で取れる" do
    get "/api/articles/newer-news"

    assert_response :success
    assert_equal "新しいお知らせの本文", response.parsed_body["body"]
  end

  test "下書きと予約中の記事は、URL を知っていても 404" do
    get "/api/articles/draft-news"
    assert_response :not_found

    get "/api/articles/scheduled-news"
    assert_response :not_found
  end

  test "公開日時を過ぎると、予約中の記事が出るようになる" do
    travel_to 4.days.from_now do
      get "/api/articles/scheduled-news"
      assert_response :success

      get "/api/articles"
      assert_equal "scheduled-news", response.parsed_body["articles"].first["slug"]
    end
  end
end
