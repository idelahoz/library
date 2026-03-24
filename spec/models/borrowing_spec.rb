require "rails_helper"

RSpec.describe Borrowing, type: :model do
  describe "validations" do
    it "is valid with required attributes" do
      book = create(:book, total_copies: 3)
      member = create(:member)

      borrowing = build(:borrowing, book:, member:)

      expect(borrowing).to be_valid
    end

    it "requires a book" do
      member = create(:member)
      borrowing = build(:borrowing, book: nil, member:)

      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:book_id]).to include("can't be blank")
    end

    it "requires a member" do
      book = create(:book)
      borrowing = build(:borrowing, book:, member: nil)

      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:member_id]).to include("can't be blank")
    end

    it "validates book is available" do
      book = create(:book, total_copies: 1)
      member = create(:member)
      create(:borrowing, book:, member: create(:member))

      borrowing = build(:borrowing, book:, member:)

      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:book]).to include("is not available")
    end

    it "prevents member from borrowing the same book twice" do
      book = create(:book, total_copies: 3)
      member = create(:member)
      create(:borrowing, book:, member:)

      borrowing = build(:borrowing, book:, member:)

      expect(borrowing).not_to be_valid
      expect(borrowing.errors[:base]).to include("Member already has an unreturned copy of this book")
    end

    it "allows reborrow after returning" do
      book = create(:book, total_copies: 1)
      member = create(:member)
      returned = create(:borrowing, book:, member:, returned_at: Time.current)

      borrowing = build(:borrowing, book:, member:)

      expect(borrowing).to be_valid
    end
  end

  describe "scopes" do
    let(:book) { create(:book) }
    let(:member) { create(:member) }

    it ".active returns unreturned borrowings" do
      active = create(:borrowing, book:, member:)
      create(:borrowing, book:, member: create(:member), returned_at: Time.current)

      expect(Borrowing.active).to include(active)
      expect(Borrowing.active.size).to eq(1)
    end

    it ".returned returns returned borrowings" do
      create(:borrowing, book:, member:)
      returned = create(:borrowing, book:, member: create(:member), returned_at: Time.current)

      expect(Borrowing.returned).to include(returned)
      expect(Borrowing.returned.size).to eq(1)
    end
  end

  describe "associations" do
    let(:book) { create(:book) }
    let(:member) { create(:member) }
    let(:borrowing) { create(:borrowing, book:, member:) }

    it "belongs to a book" do
      expect(borrowing.book).to eq(book)
    end

    it "belongs to a member" do
      expect(borrowing.member).to eq(member)
    end
  end
end
