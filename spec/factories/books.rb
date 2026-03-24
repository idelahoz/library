FactoryBot.define do
  factory :book do
    sequence(:title)  { |n| "Book Title #{n}" }
    sequence(:author) { |n| "Author #{n}" }
    genre { "Fiction" }
    sequence(:isbn) { |n| "978000000#{n.to_s.rjust(4, '0')}" }
    total_copies { 3 }
  end
end
