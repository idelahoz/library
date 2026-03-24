# Development seed data
#
# Run with:
#   bin/rails db:seed

require "factory_bot"

FactoryBot.definition_file_paths = [Rails.root.join("spec/factories").to_s]
FactoryBot.reload

seed_password = "password123"

users_data = [
  { type: "Librarian", name: "Alice Librarian", email: "alice.librarian@library.local" },
  { type: "Librarian", name: "Bob Librarian", email: "bob.librarian@library.local" },
  { type: "Member", name: "Jane Member", email: "jane.member@library.local" },
  { type: "Member", name: "John Member", email: "john.member@library.local" },
  { type: "Member", name: "Sara Member", email: "sara.member@library.local" }
]

users_by_email = users_data.each_with_object({}) do |attrs, hash|
  factory = attrs[:type] == "Librarian" ? :librarian : :member
  built_user = FactoryBot.build(
    factory,
    name: attrs[:name],
    email: attrs[:email],
    password: seed_password,
    password_confirmation: seed_password
  )

  user = built_user.class.find_or_initialize_by(email: built_user.email)
  user.assign_attributes(
    type: built_user.type,
    name: built_user.name,
    password: seed_password,
    password_confirmation: seed_password
  )
  user.save!
  hash[attrs[:email]] = user
end

books_data = [
  {
    title: "The Pragmatic Programmer",
    author: "Andrew Hunt",
    genre: "Technology",
    isbn: "9780135957059",
    total_copies: 4
  },
  {
    title: "Clean Code",
    author: "Robert C. Martin",
    genre: "Technology",
    isbn: "9780132350884",
    total_copies: 3
  },
  {
    title: "The Hobbit",
    author: "J.R.R. Tolkien",
    genre: "Fantasy",
    isbn: "9780547928227",
    total_copies: 5
  },
  {
    title: "Sapiens",
    author: "Yuval Noah Harari",
    genre: "History",
    isbn: "9780062316097",
    total_copies: 2
  },
  {
    title: "Dune",
    author: "Frank Herbert",
    genre: "Science Fiction",
    isbn: "9780441172719",
    total_copies: 3
  }
]

books_by_isbn = books_data.each_with_object({}) do |attrs, hash|
  built_book = FactoryBot.build(:book, **attrs)
  book = Book.find_or_initialize_by(isbn: built_book.isbn)
  book.assign_attributes(
    title: built_book.title,
    author: built_book.author,
    genre: built_book.genre,
    total_copies: built_book.total_copies
  )
  book.save!
  hash[built_book.isbn] = book
end

borrowings_data = [
  {
    member_email: "jane.member@library.local",
    isbn: "9780135957059",
    borrowed_at: 10.days.ago,
    due_at: 4.days.from_now,
    returned_at: nil
  },
  {
    member_email: "john.member@library.local",
    isbn: "9780132350884",
    borrowed_at: 20.days.ago,
    due_at: 6.days.ago,
    returned_at: nil
  },
  {
    member_email: "sara.member@library.local",
    isbn: "9780547928227",
    borrowed_at: 18.days.ago,
    due_at: 4.days.ago,
    returned_at: 2.days.ago
  },
  {
    member_email: "jane.member@library.local",
    isbn: "9780062316097",
    borrowed_at: 30.days.ago,
    due_at: 16.days.ago,
    returned_at: 14.days.ago
  }
]

borrowings_data.each do |attrs|
  member = users_by_email.fetch(attrs[:member_email])
  book = books_by_isbn.fetch(attrs[:isbn])

  built_borrowing = FactoryBot.build(
    :borrowing,
    member: member,
    book: book,
    borrowed_at: attrs[:borrowed_at],
    due_at: attrs[:due_at],
    returned_at: attrs[:returned_at]
  )

  borrowing = Borrowing.find_or_initialize_by(
    member_id: member.id,
    book_id: book.id,
    borrowed_at: built_borrowing.borrowed_at
  )

  borrowing.assign_attributes(
    due_at: built_borrowing.due_at,
    returned_at: built_borrowing.returned_at
  )
  borrowing.save!
end

puts "✅ Seed complete"
puts "\nLibrarian credentials:"
users_data.select { |u| u[:type] == "Librarian" }.each do |u|
  puts "- #{u[:email]} / #{seed_password}"
end

puts "\nMember credentials:"
users_data.select { |u| u[:type] == "Member" }.each do |u|
  puts "- #{u[:email]} / #{seed_password}"
end
