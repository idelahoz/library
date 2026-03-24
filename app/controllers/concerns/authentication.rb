module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    token = bearer_token
    return unless token.present?

    session_record = Session.find_by(token: token)
    return unless session_record

    Current.session = session_record
  end

  def bearer_token
    request.headers["Authorization"]&.sub(/\ABearer /, "")
  end

  def request_authentication
    render json: { error: "Not authenticated" }, status: :unauthorized
  end

  def authenticated?
    Current.session.present?
  end

  def current_user
    Current.user
  end

  def start_new_session_for(user)
    user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    ).tap { |s| Current.session = s }
  end

  def terminate_session
    Current.session&.destroy
  end
end
