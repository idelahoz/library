module Api
  module V1
    class MeController < BaseController
      # GET /api/v1/me
      def show
        render json: {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email,
          role: current_user.type
        }
      end
    end
  end
end
