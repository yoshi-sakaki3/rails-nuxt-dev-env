Rails.application.routes.draw do
  # 稼働確認（起動できていれば 200）
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    # 公開側（Nuxt の公開ページから呼ぶ）
    resources :articles, only: %i[index show], param: :slug

    # 管理側（Nuxt のサーバーが、合言葉を付けて呼ぶ）
    namespace :admin do
      resource :session, only: :show
      resources :articles
    end
  end
end
