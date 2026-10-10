module Api
  # 公開側：公開済みで、公開日時を過ぎた記事だけを返す
  class ArticlesController < ApplicationController
    PER_PAGE = 5

    def index
      page = [ params[:page].to_i, 1 ].max
      scope = Article.visible
      total = scope.count
      articles = scope.newest_first.offset((page - 1) * PER_PAGE).limit(PER_PAGE)

      render json: {
        articles: articles.map { |a| article_summary(a) },
        page:,
        totalPages: [ (total.to_f / PER_PAGE).ceil, 1 ].max,
        total:
      }
    end

    # 下書き・予約中の記事は、URL を知っていても 404 にする
    def show
      render json: article_detail(Article.visible.find_by!(slug: params[:slug]))
    end
  end
end
