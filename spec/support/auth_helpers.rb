module AuthHelpers
  def auth_headers_for(user)
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")
    { "Authorization" => "Bearer #{session.token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
