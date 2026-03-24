FactoryBot.define do
  factory :borrowing do
    association :book
    association :member, factory: :member
    borrowed_at { Time.current }
    due_at { 2.weeks.from_now }
    returned_at { nil }
  end
end
