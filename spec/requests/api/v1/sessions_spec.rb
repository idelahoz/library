require "rails_helper"

RSpec.describe "Api::V1::Sessions", type: :request do
  let(:librarian) do
    Librarian.create!(
      name: "Ana Librarian",
      email: "ana@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:member) do
    Member.create!(
      name: "Mario Member",
      email: "mario@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  describe "POST /api/v1/session" do
    context "with valid credentials" do
      it "returns a token and user payload for a Librarian" do
        post "/api/v1/session", params: { email: librarian.email, password: "password123" }

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json["token"]).to be_present
        expect(json["user"]["role"]).to eq("Librarian")
        expect(json["user"]["email"]).to eq(librarian.email)
      end

      it "returns a token and user payload for a Member" do
        post "/api/v1/session", params: { email: member.email, password: "password123" }

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json["token"]).to be_present
        expect(json["user"]["role"]).to eq("Member")
      end

      it "creates a Session record in the database" do
        expect {
          post "/api/v1/session", params: { email: member.email, password: "password123" }
        }.to change(Session, :count).by(1)
      end
    end

    context "with invalid credentials" do
      it "returns 401 for wrong password" do
        post "/api/v1/session", params: { email: member.email, password: "wrong" }

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Invalid email or password")
      end

      it "returns 401 for unknown email" do
        post "/api/v1/session", params: { email: "nobody@example.com", password: "password123" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/session" do
    it "destroys the session and returns 200" do
      headers = auth_headers_for(member)
      expect {
        delete "/api/v1/session", headers: headers
      }.to change(Session, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["message"]).to eq("Logged out successfully")
    end

    it "returns 401 without a token" do
      delete "/api/v1/session"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
