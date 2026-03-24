module Api
  module V1
    class BooksController < BaseController
      before_action :require_librarian!
      before_action :set_book, only: %i[update destroy]

      # POST /api/v1/books
      def create
        book = Book.create!(book_params)

        render json: {
          id: book.id,
          title: book.title,
          author: book.author,
          genre: book.genre,
          isbn: book.isbn,
          total_copies: book.total_copies
        }, status: :created
      end

      # PATCH /api/v1/books/:id
      def update
        @book.update!(book_params)

        render json: {
          id: @book.id,
          title: @book.title,
          author: @book.author,
          genre: @book.genre,
          isbn: @book.isbn,
          total_copies: @book.total_copies
        }, status: :ok
      end

      # DELETE /api/v1/books/:id
      def destroy
        @book.destroy!

        head :no_content
      end

      private

      def set_book
        @book = Book.find(params[:id])
      end

      def book_params
        params.permit(:title, :author, :genre, :isbn, :total_copies)
      end
    end
  end
end
