# お知らせ・ブログの記事。
# 公開側に出るのは「公開済み」かつ「公開日時を過ぎたもの」だけ（公開日時を未来にすると予約公開になる）。
class Article < ApplicationRecord
  enum :status, { draft: "draft", published: "published" }, validate: true

  before_validation :normalize
  before_validation :set_published_at

  validates :title, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, length: { maximum: 80 }, uniqueness: true,
                   format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: :invalid_slug }
  validates :summary, length: { maximum: 200 }
  validates :body, presence: true, length: { maximum: 20_000 }

  scope :visible, -> { published.where(published_at: ..Time.current) }
  scope :newest_first, -> { order(published_at: :desc, id: :desc) }

  # 公開側に出ているか
  def visible?
    published? && published_at.present? && published_at <= Time.current
  end

  # 公開済みだが、公開日時がまだ来ていない
  def scheduled?
    published? && published_at.present? && published_at > Time.current
  end

  private

  def normalize
    self.title = title.strip if title
    self.slug = slug.strip.downcase if slug
    self.summary = summary.strip.presence if summary
  end

  # 公開日時を入れずに公開したら、今すぐ公開にする
  def set_published_at
    self.published_at ||= Time.current if published?
  end
end
