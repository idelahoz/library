module Api
  module V1
    class BaseController < ActionController::API
      include Authentication
      include Authorization

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

      def not_found(e)
        render json: { error: e.message }, status: :not_found
      end

      def unprocessable_entity(e)
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      end
    end
  end
end
