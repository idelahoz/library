require "rails_helper"

RSpec.describe "Api::V1::Registrations", type: :request do
  describe "POST /api/v1/register" do
    let(:valid_params) do
      {
        name: "New Member",
        email: "newmember@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    context "with valid parameters" do
      it "creates a Member user and returns a token" do
        expect {
          post "/api/v1/register", params: valid_params
        }.to change(Member, :count).by(1)

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json["token"]).to be_present
        expect(json["user"]["role"]).to eq("Member")
        expect(json["user"]["email"]).to eq("newmember@example.com")
      end

      it "always creates a Member, never a Librarian" do
        post "/api/v1/register", params: valid_params

        expect(User.last).to be_a(Member)
        expect(User.last).not_to be_a(Librarian)
      end

      it "creates a session for the new user" do
        expect {
          post "/api/v1/register", params: valid_params
        }.to change(Session, :count).by(1)
      end
    end

    context "with invalid parameters" do
      it "returns 422 when email is already taken" do
        Member.create!(
          name: "Existing",
          email: "newmember@example.com",
          password: "password123",
          password_confirmation: "password123"
        )

        post "/api/v1/register", params: valid_params

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["errors"]).to be_present
      end

      it "returns 422 when required fields are missing" do
        post "/api/v1/register", params: { email: "incomplete@example.com" }

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 when passwords do not match" do
        post "/api/v1/register", params: valid_params.merge(password_confirmation: "different")

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
