module Api
  module V1
    class BorrowingsController < BaseController
      before_action :require_member!
      before_action :load_book, only: :create

      # POST /api/v1/borrowings
      def create
        borrowing = current_user.borrowings.build(book_id: @book.id)
        borrowing.due_at = 2.weeks.from_now
        borrowing.save!

        render json: borrowing, serializer: BorrowingSerializer, status: :created
      end

      private

      def load_book
        @book = Book.find(params[:book_id])
      end

      def borrowing_params
        params.permit(:book_id)
      end
    end
  end
end
