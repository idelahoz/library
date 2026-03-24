require "rails_helper"

RSpec.describe "Api::V1::Me", type: :request do
  let(:member) { create(:member, email: "mario@example.com") }
  let(:librarian) { create(:librarian, email: "ana@example.com") }

  describe "GET /api/v1/me" do
    context "when authenticated" do
      it "returns the current member's profile" do
        get "/api/v1/me", headers: auth_headers_for(member)

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json).to include(
          "id" => member.id,
          "name" => member.name,
          "email" => member.email,
          "role" => "Member"
        )
      end

      it "returns the current librarian's profile" do
        get "/api/v1/me", headers: auth_headers_for(librarian)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["role"]).to eq("Librarian")
      end
    end

    context "when unauthenticated" do
      it "returns 401" do
        get "/api/v1/me"

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Not authenticated")
      end

      it "returns 401 for an invalid token" do
        get "/api/v1/me", headers: { "Authorization" => "Bearer invalid-token-xyz" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
