class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "見つかりません" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: "#{e.param} がありません" }, status: :bad_request
  end

  private

  # 入力の誤りを「項目ごとに最初の1つ」で返す（画面の各欄の下に出す用）
  def render_errors(record)
    errors = record.errors.attribute_names.index_with { |name| record.errors.full_messages_for(name).first }
    render json: { errors: }, status: :unprocessable_content
  end

  def article_summary(article)
    {
      id: article.id,
      title: article.title,
      slug: article.slug,
      summary: article.summary,
      publishedAt: article.published_at&.iso8601
    }
  end

  def article_detail(article)
    article_summary(article).merge(body: article.body, updatedAt: article.updated_at.iso8601)
  end
end
