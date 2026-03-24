module Api
  module V1
    class RegistrationsController < BaseController
      allow_unauthenticated_access only: [:create]

      # POST /api/v1/register
      def create
        user = Member.new(registration_params)

        if user.save
          session_record = start_new_session_for(user)
          render json: {
            token: session_record.token,
            user: {
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.type
            }
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def registration_params
        params.permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
