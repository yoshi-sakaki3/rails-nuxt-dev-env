require "test_helper"

class AdminArticlesTest < ActionDispatch::IntegrationTest
  test "合言葉がない・違うときは 401 で、何も変えない" do
    get "/api/admin/articles"
    assert_response :unauthorized

    get "/api/admin/articles", headers: admin_headers("wrong-token")
    assert_response :unauthorized

    assert_no_difference "Article.count" do
      delete "/api/admin/articles/#{articles(:newer).id}", headers: admin_headers("wrong-token")
    end
    assert_response :unauthorized
  end

  test "合言葉が設定されていないサーバーでは、誰も通さない" do
    original = ENV["ADMIN_API_TOKEN"]
    ENV["ADMIN_API_TOKEN"] = ""

    get "/api/admin/session", headers: { "Authorization" => "Bearer " }
    assert_response :unauthorized
    get "/api/admin/session", headers: admin_headers
    assert_response :unauthorized
  ensure
    ENV["ADMIN_API_TOKEN"] = original
  end

  test "正しい合言葉なら通る" do
    get "/api/admin/session", headers: admin_headers
    assert_response :no_content
  end

  test "一覧には、下書きと予約中も含まれる" do
    get "/api/admin/articles", headers: admin_headers

    assert_response :success
    by_slug = response.parsed_body["articles"].index_by { |a| a["slug"] }
    assert_equal 4, by_slug.size
    assert by_slug["newer-news"]["visible"]
    assert by_slug["scheduled-news"]["scheduled"]
    assert_equal "draft", by_slug["draft-news"]["status"]
  end

  test "記事を追加できる" do
    assert_difference "Article.count", 1 do
      post "/api/admin/articles", headers: admin_headers, as: :json,
           params: { article: { title: "新着", slug: "brand-new", body: "本文", status: "draft" } }
    end

    assert_response :created
    assert_equal "brand-new", response.parsed_body["slug"]
    assert_not response.parsed_body["visible"]
  end

  test "誤った入力は 422 で、項目ごとの理由を日本語で返す" do
    assert_no_difference "Article.count" do
      post "/api/admin/articles", headers: admin_headers, as: :json,
           params: { article: { title: "", slug: "newer-news", body: "本文" } }
    end

    assert_response :unprocessable_content
    assert_equal(
      { "title" => "タイトルを入力してください", "slug" => "URL 用の名前はすでに存在します" },
      response.parsed_body["errors"]
    )
  end

  test "下書きを公開すると、公開側に出るようになる" do
    draft = articles(:draft)
    get "/api/articles/#{draft.slug}"
    assert_response :not_found

    patch "/api/admin/articles/#{draft.id}", headers: admin_headers, as: :json,
          params: { article: { status: "published" } }
    assert_response :success
    assert response.parsed_body["visible"]

    get "/api/articles/#{draft.slug}"
    assert_response :success
  end

  test "公開日時を未来にすると、予約公開になる（日時は日本時間として受け取る）" do
    travel_to Time.zone.local(2026, 10, 10, 12, 0) do
      patch "/api/admin/articles/#{articles(:draft).id}", headers: admin_headers, as: :json,
            params: { article: { status: "published", publishedAt: "2026-10-20T09:00" } }

      assert_response :success
      assert response.parsed_body["scheduled"]
      assert_equal Time.zone.local(2026, 10, 20, 9, 0), articles(:draft).reload.published_at
    end
  end

  test "記事を削除できる" do
    assert_difference "Article.count", -1 do
      delete "/api/admin/articles/#{articles(:older).id}", headers: admin_headers
    end
    assert_response :no_content
  end

  test "ない記事は 404" do
    get "/api/admin/articles/999999", headers: admin_headers
    assert_response :not_found
  end
end
