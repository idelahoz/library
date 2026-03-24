require "rails_helper"

RSpec.describe "Api::V1::Me", type: :request do
  let(:member) do
    Member.create!(
      name: "Mario Member",
      email: "mario@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:librarian) do
    Librarian.create!(
      name: "Ana Librarian",
      email: "ana@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  describe "GET /api/v1/me" do
    context "when authenticated" do
      it "returns the current member's profile" do
        get "/api/v1/me", headers: auth_headers_for(member)

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["id"]).to eq(member.id)
        expect(json["email"]).to eq(member.email)
        expect(json["name"]).to eq(member.name)
        expect(json["role"]).to eq("Member")
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
