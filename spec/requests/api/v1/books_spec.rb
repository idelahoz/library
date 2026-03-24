require "rails_helper"

RSpec.describe "Api::V1::Books", type: :request do
  let(:librarian) { create(:librarian) }
  let(:member) { create(:member) }

  let(:book_params) do
    {
      title: "The Pragmatic Programmer",
      author: "Andrew Hunt",
      genre: "Programming",
      isbn: "9780135957059",
      total_copies: 5
    }
  end

  describe "GET /api/v1/books" do
    let!(:pragmatic) do
      create(:book, title: "The Pragmatic Programmer", author: "Andrew Hunt", genre: "Programming")
    end
    let!(:clean_code) do
      create(:book, title: "Clean Code", author: "Robert Martin", genre: "Programming")
    end
    let!(:gatsby) do
      create(:book, title: "The Great Gatsby", author: "F. Scott Fitzgerald", genre: "Classic")
    end

    it "returns all books for authenticated member" do
      get "/api/v1/books", headers: auth_headers_for(member)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.size).to eq(3)
      expect(response.parsed_body.map { |b| b["id"] }).to eq([pragmatic.id, clean_code.id, gatsby.id])
    end

    it "allows authenticated librarian" do
      get "/api/v1/books", headers: auth_headers_for(librarian)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.size).to eq(3)
    end

    it "filters by title" do
      get "/api/v1/books", params: { title: "pragmatic" }, headers: auth_headers_for(member)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |b| b["id"] }).to eq([pragmatic.id])
    end

    it "filters by author" do
      get "/api/v1/books", params: { author: "martin" }, headers: auth_headers_for(member)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |b| b["id"] }).to eq([clean_code.id])
    end

    it "filters by genre" do
      get "/api/v1/books", params: { genre: "program" }, headers: auth_headers_for(member)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |b| b["id"] }).to eq([pragmatic.id, clean_code.id])
    end

    it "combines filters" do
      get "/api/v1/books",
        params: { author: "andrew", genre: "programming" },
        headers: auth_headers_for(member)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |b| b["id"] }).to eq([pragmatic.id])
    end

    it "returns empty list when there are no matches" do
      get "/api/v1/books", params: { title: "non-existent" }, headers: auth_headers_for(member)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end

    it "returns 401 when unauthenticated" do
      get "/api/v1/books"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Not authenticated")
    end
  end

  describe "POST /api/v1/books" do
    it "creates a book when authenticated as librarian" do
      expect do
        post "/api/v1/books", params: book_params, headers: auth_headers_for(librarian)
      end.to change(Book, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include(
        "title" => "The Pragmatic Programmer",
        "author" => "Andrew Hunt",
        "genre" => "Programming",
        "isbn" => "9780135957059",
        "total_copies" => 5
      )
    end

    it "returns 403 when authenticated as member" do
      post "/api/v1/books", params: book_params, headers: auth_headers_for(member)

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to eq("Forbidden")
    end

    it "returns 401 when unauthenticated" do
      post "/api/v1/books", params: book_params

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Not authenticated")
    end

    it "returns 422 for invalid params" do
      post "/api/v1/books",
        params: book_params.merge(title: "", total_copies: 0),
        headers: auth_headers_for(librarian)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "PATCH /api/v1/books/:id" do
    let!(:book) { create(:book) }

    it "updates a book when authenticated as librarian" do
      patch "/api/v1/books/#{book.id}",
        params: { title: "Clean Code", total_copies: 7 },
        headers: auth_headers_for(librarian)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "id" => book.id,
        "title" => "Clean Code",
        "total_copies" => 7
      )
      expect(book.reload.title).to eq("Clean Code")
      expect(book.total_copies).to eq(7)
    end

    it "returns 403 when authenticated as member" do
      patch "/api/v1/books/#{book.id}",
        params: { title: "Unauthorized Update" },
        headers: auth_headers_for(member)

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to eq("Forbidden")
    end

    it "returns 401 when unauthenticated" do
      patch "/api/v1/books/#{book.id}", params: { title: "No Auth" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Not authenticated")
    end

    it "returns 422 for invalid params" do
      patch "/api/v1/books/#{book.id}",
        params: { title: "", total_copies: 0 },
        headers: auth_headers_for(librarian)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "DELETE /api/v1/books/:id" do
    let!(:book) { create(:book) }

    it "deletes a book when authenticated as librarian" do
      expect do
        delete "/api/v1/books/#{book.id}", headers: auth_headers_for(librarian)
      end.to change(Book, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 when authenticated as member" do
      delete "/api/v1/books/#{book.id}", headers: auth_headers_for(member)

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to eq("Forbidden")
    end

    it "returns 401 when unauthenticated" do
      delete "/api/v1/books/#{book.id}"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Not authenticated")
    end
  end
end
