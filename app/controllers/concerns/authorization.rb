module Authorization
  extend ActiveSupport::Concern

  private

  def require_librarian!
    return if current_user&.librarian?

    render json: { error: "Forbidden" }, status: :forbidden
  end

  def require_member!
    return if current_user&.member?

    render json: { error: "Forbidden" }, status: :forbidden
  end

  def authorize_self_or_librarian!(user)
    return if current_user&.librarian? || current_user == user

    render json: { error: "Forbidden" }, status: :forbidden
  end
end
