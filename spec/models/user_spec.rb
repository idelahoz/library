require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with a supported STI type" do
      librarian = build(:librarian)

      expect(librarian).to be_valid
    end

    it "normalizes the email before validation" do
      member = create(:member, email: " Mario@Example.COM ")

      expect(member.reload.email).to eq("mario@example.com")
    end

    it "does not allow duplicate emails ignoring case" do
      create(:librarian, email: "reader@example.com")

      duplicate = build(:member, email: "READER@example.com")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "raises when an unsupported STI type is used" do
      expect do
        User.new(
          type: "Admin",
          name: "Wrong Role",
          email: "wrong@example.com",
          password: "password123",
          password_confirmation: "password123"
        )
      end.to raise_error(ActiveRecord::SubclassNotFound)
    end
  end

  describe "authentication" do
    it "authenticates with the correct password" do
      member = create(:member, email: "member@example.com")

      expect(member.authenticate("password123")).to eq(member)
      expect(member.authenticate("wrong-password")).to be(false)
    end
  end
end
