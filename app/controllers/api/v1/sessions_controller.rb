module Api
  module V1
    class SessionsController < BaseController
      allow_unauthenticated_access only: [:create]

      # POST /api/v1/session
      def create
        user = User.find_by(email: params[:email].to_s.strip.downcase)

        if user&.authenticate(params[:password])
          session_record = start_new_session_for(user)
          render json: session_payload(session_record.token, user), status: :created
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/session
      def destroy
        terminate_session
        render json: { message: "Logged out successfully" }
      end

      private

      def session_payload(token, user)
        {
          token: token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.type
          }
        }
      end
    end
  end
end
