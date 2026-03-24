module Api
  module V1
    class BorrowingsController < BaseController
      before_action :require_member!, only: :create
      before_action :load_borrowing, only: :return
      before_action :authorize_member_or_librarian, only: :return
      before_action :load_book, only: :create

      # POST /api/v1/borrowings
      def create
        borrowing = current_user.borrowings.build(book_id: @book.id)
        borrowing.due_at = 2.weeks.from_now
        borrowing.save!

        render json: borrowing, serializer: BorrowingSerializer, status: :created
      end

      # PATCH /api/v1/borrowings/:id/return
      def return
        @borrowing.returned_at = Time.current
        @borrowing.save!

        render json: @borrowing, serializer: BorrowingSerializer, status: :ok
      end

      private

      def load_borrowing
        @borrowing = Borrowing.find(params[:id])
      end

      def authorize_member_or_librarian
        authorize_borrowing_member_or_librarian!(@borrowing)
      end

      def load_book
        @book = Book.find(params[:book_id])
      end

      def borrowing_params
        params.permit(:book_id)
      end
    end
  end
end
