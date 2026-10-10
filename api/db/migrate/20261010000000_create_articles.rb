class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false, limit: 100
      # URL に使う名前（例: /articles/autumn-campaign）
      t.string :slug, null: false, limit: 80
      # 一覧と、検索エンジン向けの説明文に使う要約
      t.string :summary, limit: 200
      t.text :body, null: false
      t.string :status, null: false, default: "draft", limit: 20
      t.datetime :published_at

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    # 公開側の一覧（公開済み・公開日時の新しい順）で使う
    add_index :articles, %i[status published_at]
  end
end
