class Borrowing < ApplicationRecord
  belongs_to :member, class_name: "User"
  belongs_to :book

  validates :member_id, :book_id, presence: true
  validate :book_must_be_available
  validate :member_cannot_have_unreturned_copy

  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }

  private

  def book_must_be_available
    return unless book

    if book.available_copies <= 0
      errors.add(:book, "is not available")
    end
  end

  def member_cannot_have_unreturned_copy
    return unless member && book

    if Borrowing.active.exists?(member_id:, book_id:)
      errors.add(:base, "Member already has an unreturned copy of this book")
    end
  end
end
