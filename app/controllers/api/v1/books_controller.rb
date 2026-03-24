module Api
  module V1
    class BooksController < BaseController
      before_action :require_librarian!, only: %i[create update destroy]
      before_action :set_book, only: %i[update destroy]

      # GET /api/v1/books
      def index
        books = Book.search(search_params).order(:id)

        render json: books, each_serializer: BookSerializer, status: :ok
      end

      # POST /api/v1/books
      def create
        book = Book.create!(book_params)

        render json: book, serializer: BookSerializer, status: :created
      end

      # PATCH /api/v1/books/:id
      def update
        @book.update!(book_params)

        render json: @book, serializer: BookSerializer, status: :ok
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

      def search_params
        params.permit(:title, :author, :genre)
      end

      def book_params
        params.permit(:title, :author, :genre, :isbn, :total_copies)
      end
    end
  end
end
