FactoryBot.define do
  factory :member, class: "Member" do
    sequence(:name) { |n| "Member #{n}" }
    sequence(:email) { |n| "member#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end

  factory :librarian, class: "Librarian" do
    sequence(:name) { |n| "Librarian #{n}" }
    sequence(:email) { |n| "librarian#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
