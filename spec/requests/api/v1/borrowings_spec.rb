require "rails_helper"

RSpec.describe "Api::V1::Borrowings", type: :request do
  let(:member) { create(:member) }
  let(:librarian) { create(:librarian) }
  let(:book) { create(:book, total_copies: 2) }

  describe "POST /api/v1/borrowings" do
    it "creates a borrowing when authenticated as member" do
      expect do
        post "/api/v1/borrowings", params: { book_id: book.id }, headers: auth_headers_for(member)
      end.to change(Borrowing, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include(
        "borrowed_at" => match(/\d{4}-\d{2}-\d{2}/),
        "due_at" => match(/\d{4}-\d{2}-\d{2}/),
        "returned_at" => nil
      )
      expect(response.parsed_body["book"]).to include(
        "id" => book.id,
        "title" => book.title,
        "author" => book.author
      )
    end

    it "returns 403 when authenticated as librarian" do
      post "/api/v1/borrowings", params: { book_id: book.id }, headers: auth_headers_for(librarian)

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to eq("Forbidden")
    end

    it "returns 401 when unauthenticated" do
      post "/api/v1/borrowings", params: { book_id: book.id }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Not authenticated")
    end

    it "prevents duplicate borrowing of the same book" do
      create(:borrowing, book:, member:)

      post "/api/v1/borrowings", params: { book_id: book.id }, headers: auth_headers_for(member)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include("Member already has an unreturned copy of this book")
    end

    it "prevents borrowing when book is unavailable" do
      other_member = create(:member)
      create(:borrowing, book:, member: other_member)
      create(:borrowing, book:, member: create(:member))

      post "/api/v1/borrowings", params: { book_id: book.id }, headers: auth_headers_for(member)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include("Book is not available")
    end

    it "returns 404 for non-existent book" do
      post "/api/v1/borrowings", params: { book_id: 99_999 }, headers: auth_headers_for(member)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/borrowings/:id/return" do
    let(:borrowing) { create(:borrowing, book:, member:) }

    it "marks a borrowing as returned when authenticated as librarian" do
      patch "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers_for(librarian)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "id" => borrowing.id,
        "borrowed_at" => match(/\d{4}-\d{2}-\d{2}/),
        "returned_at" => match(/\d{4}-\d{2}-\d{2}/)
      )
      expect(borrowing.reload.returned_at).not_to be_nil
    end

    it "marks a borrowing as returned when authenticated as the borrowing member" do
      patch "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers_for(member)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "id" => borrowing.id,
        "returned_at" => match(/\d{4}-\d{2}-\d{2}/)
      )
      expect(borrowing.reload.returned_at).not_to be_nil
    end

    it "returns 403 when authenticated as different member" do
      other_member = create(:member)

      patch "/api/v1/borrowings/#{borrowing.id}/return", headers: auth_headers_for(other_member)

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to eq("Forbidden")
    end

    it "returns 401 when unauthenticated" do
      patch "/api/v1/borrowings/#{borrowing.id}/return"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Not authenticated")
    end

    it "returns 404 for non-existent borrowing" do
      patch "/api/v1/borrowings/99999/return", headers: auth_headers_for(librarian)

      expect(response).to have_http_status(:not_found)
    end
  end
end
