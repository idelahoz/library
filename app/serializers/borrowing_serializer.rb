class BorrowingSerializer < ActiveModel::Serializer
  attributes :id, :borrowed_at, :due_at, :returned_at
  belongs_to :book, serializer: BookSerializer
end
