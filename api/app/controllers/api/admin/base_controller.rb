module Api
  module Admin
    # 管理用の API。合言葉（トークン）が合ったときだけ通す。
    #   Authorization: Bearer <ADMIN_API_TOKEN>
    # トークンは環境変数で渡す。未設定のときは、誰も通さない（うっかり全開にしない）。
    class BaseController < ApplicationController
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate_admin!

      private

      def authenticate_admin!
        expected = ENV["ADMIN_API_TOKEN"].to_s
        ok = expected.present? && authenticate_with_http_token do |token, _options|
          # 文字数や一致した位置が処理時間から漏れないよう、一定時間で比べる
          ActiveSupport::SecurityUtils.secure_compare(token, expected)
        end
        render json: { error: "認証が必要です" }, status: :unauthorized unless ok
      end

      def admin_article(article)
        article_detail(article).merge(
          status: article.status,
          visible: article.visible?,
          scheduled: article.scheduled?
        )
      end
    end
  end
end
