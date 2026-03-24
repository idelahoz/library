module AuthHelpers
  def auth_headers_for(user)
    session = create(:session, user: user)
    { "Authorization" => "Bearer #{session.token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
