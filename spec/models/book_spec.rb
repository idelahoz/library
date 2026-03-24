require "rails_helper"

RSpec.describe Book, type: :model do
  it "is valid with required attributes" do
    expect(build(:book)).to be_valid
  end

  it "requires a unique isbn" do
    create(:book, isbn: "9780000001111")
    duplicate = build(:book, isbn: "9780000001111")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:isbn]).to include("has already been taken")
  end

  it "requires total_copies greater than zero" do
    book = build(:book, total_copies: 0)

    expect(book).not_to be_valid
    expect(book.errors[:total_copies]).to include("must be greater than 0")
  end
end
