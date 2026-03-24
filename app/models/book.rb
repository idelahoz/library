class Book < ApplicationRecord
  validates :title, :author, :genre, :isbn, presence: true
  validates :isbn, uniqueness: { case_sensitive: false }
  validates :total_copies,
    numericality: {
      only_integer: true,
      greater_than: 0
    }
end
