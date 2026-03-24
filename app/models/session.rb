class Session < ApplicationRecord
  belongs_to :user

  has_secure_token

  delegate :librarian?, :member?, to: :user
end
