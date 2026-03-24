FactoryBot.define do
  factory :borrowing do
    borrowed_at { Time.current }
    due_at { 2.weeks.from_now }
    returned_at { nil }

    # Set associations explicitly in specs until the model contract is finalized, e.g.:
    # association :book
    # association :member, factory: :member
  end
end
