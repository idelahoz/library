class Book < ApplicationRecord
  has_many :borrowings, dependent: :destroy

  validates :title, :author, :genre, :isbn, presence: true
  validates :isbn, uniqueness: { case_sensitive: false }
  validates :total_copies,
    numericality: {
      only_integer: true,
      greater_than: 0
    }

  def self.search(filters = {})
    title = filters[:title] || filters["title"]
    author = filters[:author] || filters["author"]
    genre = filters[:genre] || filters["genre"]

    relation = all
    relation = relation.where("title ILIKE ?", like_pattern(title)) if title.present?
    relation = relation.where("author ILIKE ?", like_pattern(author)) if author.present?
    relation = relation.where("genre ILIKE ?", like_pattern(genre)) if genre.present?
    relation
  end

  def self.like_pattern(value)
    "%#{sanitize_sql_like(value.to_s.strip)}%"
  end
  private_class_method :like_pattern

  def borrowing_count
    borrowings.active.count
  end

  def available_copies
    total_copies - borrowing_count
  end
end
