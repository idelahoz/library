require "rails_helper"

RSpec.describe "Api::V1::Dashboard", type: :request do
  let(:member) { create(:member) }
  let(:librarian) { create(:librarian) }
  let(:book) { create(:book, total_copies: 3) }
  let(:another_book) { create(:book, total_copies: 3) }
  let(:yet_another_book) { create(:book, total_copies: 3) }

  describe "GET /api/v1/dashboard" do
    context "when authenticated as librarian" do
      let!(:active_borrowing) { create(:borrowing, book:, member:) }
      let!(:overdue_borrowing) { create(:borrowing, book: another_book, member:, borrowed_at: 3.weeks.ago, due_at: 1.week.ago) }
      let!(:returned_borrowing) { create(:borrowing, book: yet_another_book, member:, returned_at: 1.day.ago) }

      it "returns the librarian dashboard" do
        get "/api/v1/dashboard", headers: auth_headers_for(librarian)

        expect(response).to have_http_status(:ok)
        body = response.parsed_body

        expect(body["total_books"]).to eq(Book.count)
        expect(body["total_borrowed"]).to eq(2)
        expect(body["due_today"]).to be_a(Integer)
        expect(body["overdue_borrowings"]).to be_an(Array)
        expect(body["overdue_borrowings"].length).to eq(1)

        overdue_item = body["overdue_borrowings"].first
        expect(overdue_item["id"]).to eq(overdue_borrowing.id)
        expect(overdue_item["book"]["title"]).to eq(another_book.title)
        expect(overdue_item["member"]["email"]).to eq(member.email)
      end

      it "does not include returned borrowings in overdue_borrowings" do
        get "/api/v1/dashboard", headers: auth_headers_for(librarian)

        overdue_ids = response.parsed_body["overdue_borrowings"].map { |b| b["id"] }
        expect(overdue_ids).not_to include(returned_borrowing.id)
      end
    end

    context "when authenticated as member" do
      let!(:active_borrowing) { create(:borrowing, book:, member:) }
      let!(:overdue_borrowing) { create(:borrowing, book: another_book, member:, borrowed_at: 3.weeks.ago, due_at: 1.week.ago) }
      let!(:other_member_borrowing) { create(:borrowing, book: yet_another_book, member: create(:member)) }

      it "returns the member dashboard" do
        get "/api/v1/dashboard", headers: auth_headers_for(member)

        expect(response).to have_http_status(:ok)
        body = response.parsed_body

        expect(body["borrowed"]).to be_an(Array)
        expect(body["overdue"]).to be_an(Array)

        expect(body["borrowed"].map { |b| b["id"] }).to include(active_borrowing.id)
        expect(body["overdue"].map { |b| b["id"] }).to include(overdue_borrowing.id)
      end

      it "does not include other members borrowings" do
        get "/api/v1/dashboard", headers: auth_headers_for(member)

        all_ids = (response.parsed_body["borrowed"] + response.parsed_body["overdue"]).map { |b| b["id"] }
        expect(all_ids).not_to include(other_member_borrowing.id)
      end

      it "does not expose librarian-only fields" do
        get "/api/v1/dashboard", headers: auth_headers_for(member)

        body = response.parsed_body
        expect(body.keys).not_to include("total_books", "total_borrowed", "overdue_borrowings")
      end
    end

    it "returns 401 when unauthenticated" do
      get "/api/v1/dashboard"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq("Not authenticated")
    end
  end
end
