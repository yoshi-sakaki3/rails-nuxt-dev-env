module Api
  module Admin
    # トークンが正しいかだけを確かめる（ログイン画面で使う）
    class SessionsController < BaseController
      def show
        head :no_content
      end
    end
  end
end
