class User < ApplicationRecord
  TYPES = %w[Librarian Member].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :borrowings, foreign_key: :member_id, dependent: :destroy

  before_validation :normalize_email

  validates :type, presence: true, inclusion: { in: TYPES }
  validates :name, presence: true
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  def librarian?
    is_a?(Librarian)
  end

  def member?
    is_a?(Member)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
