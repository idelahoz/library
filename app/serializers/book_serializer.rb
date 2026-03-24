class BookSerializer < ActiveModel::Serializer
  attributes :id, :title, :author, :genre, :isbn, :total_copies
end
