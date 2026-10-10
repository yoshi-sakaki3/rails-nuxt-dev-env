module Api
  module Admin
    # 管理側：下書き・予約中も含めて、記事の一覧・追加・変更・削除
    class ArticlesController < BaseController
      before_action :set_article, only: %i[show update destroy]

      def index
        render json: { articles: Article.order(updated_at: :desc, id: :desc).map { |a| admin_article(a) } }
      end

      def show
        render json: admin_article(@article)
      end

      def create
        article = Article.new(article_params)
        if article.save
          render json: admin_article(article), status: :created
        else
          render_errors(article)
        end
      end

      def update
        if @article.update(article_params)
          render json: admin_article(@article)
        else
          render_errors(@article)
        end
      end

      def destroy
        @article.destroy!
        head :no_content
      end

      private

      def set_article
        @article = Article.find(params[:id])
      end

      # 画面からは publishedAt で届く（JavaScript の書き方に合わせた名前）
      def article_params
        permitted = params.expect(article: %i[title slug summary body status publishedAt])
        permitted[:published_at] = permitted.delete(:publishedAt) if permitted.key?(:publishedAt)
        permitted
      end
    end
  end
end
