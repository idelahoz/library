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

  describe ".search" do
    let!(:pragmatic) do
      create(:book, title: "The Pragmatic Programmer", author: "Andrew Hunt", genre: "Programming")
    end
    let!(:clean_code) do
      create(:book, title: "Clean Code", author: "Robert Martin", genre: "Programming")
    end
    let!(:gatsby) do
      create(:book, title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Classic")
    end

    it "filters by title" do
      expect(Book.search(title: "pragmatic")).to contain_exactly(pragmatic)
    end

    it "filters by author" do
      expect(Book.search(author: "martin")).to contain_exactly(clean_code)
    end

    it "filters by genre" do
      expect(Book.search(genre: "program")).to contain_exactly(pragmatic, clean_code)
    end

    it "combines filters" do
      expect(Book.search(author: "andrew", genre: "programming")).to contain_exactly(pragmatic)
    end

    it "returns all records when no filters are provided" do
      expect(Book.search).to contain_exactly(pragmatic, clean_code, gatsby)
    end
  end
end
