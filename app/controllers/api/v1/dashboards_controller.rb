module Api
  module V1
    class DashboardsController < BaseController
      # GET /api/v1/dashboard
      def show
        if current_user.librarian?
          render json: librarian_dashboard
        else
          render json: member_dashboard
        end
      end

      private

      def librarian_dashboard
        overdue = Borrowing.overdue.includes(:book, :member)

        {
          total_books: Book.count,
          total_borrowed: Borrowing.active.count,
          due_today: Borrowing.active.where(due_at: Date.current.all_day).count,
          overdue_borrowings: overdue.map { |b| borrowing_payload(b) }
        }
      end

      def member_dashboard
        active = current_user.borrowings.active.includes(:book)
        overdue = current_user.borrowings.overdue.includes(:book)

        {
          borrowed: active.map { |b| borrowing_payload(b) },
          overdue: overdue.map { |b| borrowing_payload(b) }
        }
      end

      def borrowing_payload(borrowing)
        {
          id: borrowing.id,
          borrowed_at: borrowing.borrowed_at,
          due_at: borrowing.due_at,
          returned_at: borrowing.returned_at,
          book: {
            id: borrowing.book.id,
            title: borrowing.book.title,
            author: borrowing.book.author
          },
          member: {
            id: borrowing.member.id,
            name: borrowing.member.name,
            email: borrowing.member.email
          }
        }
      end
    end
  end
end
