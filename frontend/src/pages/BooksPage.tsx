import { useMemo, useState } from 'react'
import type { FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { AxiosError } from 'axios'
import { createBook, deleteBook, fetchBooks, updateBook, type BookFilters } from '../shared/api/books'
import { borrowBook } from '../shared/api/borrowings'
import { useAuth } from '../context/useAuth'
import type { Book } from '../shared/types/api'

const emptyBookForm = {
  title: '',
  author: '',
  genre: '',
  isbn: '',
  total_copies: 1,
}

export default function BooksPage() {
  const { user } = useAuth()
  const queryClient = useQueryClient()
  const [filters, setFilters] = useState<BookFilters>({})
  const [bookForm, setBookForm] = useState(emptyBookForm)
  const [editingBookId, setEditingBookId] = useState<number | null>(null)

  const { data: books = [], isLoading } = useQuery({
    queryKey: ['books', filters],
    queryFn: () => fetchBooks(filters),
  })

  const refresh = () => {
    queryClient.invalidateQueries({ queryKey: ['books'] })
    queryClient.invalidateQueries({ queryKey: ['dashboard'] })
  }

  const createMutation = useMutation({
    mutationFn: () => createBook(bookForm),
    onSuccess: () => {
      setBookForm(emptyBookForm)
      refresh()
    },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: Partial<Book> }) => updateBook(id, payload),
    onSuccess: () => {
      setEditingBookId(null)
      setBookForm(emptyBookForm)
      refresh()
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (id: number) => deleteBook(id),
    onSuccess: refresh,
  })

  const borrowMutation = useMutation({
    mutationFn: (bookId: number) => borrowBook(bookId),
    onSuccess: refresh,
  })

  const borrowErrorMessage = (() => {
    if (!borrowMutation.error) return null

    const error = borrowMutation.error
    if (error instanceof AxiosError) {
      const payload = error.response?.data as { errors?: string[]; error?: string } | undefined
      if (payload?.errors?.length) return payload.errors.join(', ')
      if (payload?.error) return payload.error
    }

    return 'Unable to borrow this book.'
  })()

  const bookById = useMemo(() => new Map(books.map((book) => [book.id, book])), [books])

  const handleSubmit = (event: FormEvent) => {
    event.preventDefault()

    if (editingBookId) {
      const existing = bookById.get(editingBookId)
      if (!existing) return

      updateMutation.mutate({ id: editingBookId, payload: { ...bookForm, total_copies: Number(bookForm.total_copies) } })
      return
    }

    createMutation.mutate()
  }

  const startEdit = (book: Book) => {
    setEditingBookId(book.id)
    setBookForm({
      title: book.title,
      author: book.author,
      genre: book.genre,
      isbn: book.isbn,
      total_copies: book.total_copies,
    })
  }

  return (
    <div className="stack">
      <h1>Books</h1>

      <section className="card">
        <h2>Search</h2>
        <div className="filters-grid">
          <input
            placeholder="Title"
            value={filters.title ?? ''}
            onChange={(e) => setFilters((prev) => ({ ...prev, title: e.target.value }))}
          />
          <input
            placeholder="Author"
            value={filters.author ?? ''}
            onChange={(e) => setFilters((prev) => ({ ...prev, author: e.target.value }))}
          />
          <input
            placeholder="Genre"
            value={filters.genre ?? ''}
            onChange={(e) => setFilters((prev) => ({ ...prev, genre: e.target.value }))}
          />
        </div>
      </section>

      {user?.role === 'Librarian' && (
        <section className="card">
          <h2>{editingBookId ? 'Edit book' : 'Create book'}</h2>
          <form className="filters-grid" onSubmit={handleSubmit}>
            <input
              placeholder="Title"
              value={bookForm.title}
              onChange={(e) => setBookForm((prev) => ({ ...prev, title: e.target.value }))}
              required
            />
            <input
              placeholder="Author"
              value={bookForm.author}
              onChange={(e) => setBookForm((prev) => ({ ...prev, author: e.target.value }))}
              required
            />
            <input
              placeholder="Genre"
              value={bookForm.genre}
              onChange={(e) => setBookForm((prev) => ({ ...prev, genre: e.target.value }))}
              required
            />
            <input
              placeholder="ISBN"
              value={bookForm.isbn}
              onChange={(e) => setBookForm((prev) => ({ ...prev, isbn: e.target.value }))}
              required
            />
            <input
              type="number"
              min={1}
              placeholder="Total copies"
              value={bookForm.total_copies}
              onChange={(e) => setBookForm((prev) => ({ ...prev, total_copies: Number(e.target.value) }))}
              required
            />
            <button type="submit" disabled={createMutation.isPending || updateMutation.isPending}>
              {editingBookId ? 'Save changes' : 'Create book'}
            </button>
            {editingBookId && (
              <button
                type="button"
                onClick={() => {
                  setEditingBookId(null)
                  setBookForm(emptyBookForm)
                }}
              >
                Cancel edit
              </button>
            )}
          </form>
        </section>
      )}

      <section className="table-wrap">
        {borrowErrorMessage && <p className="error-text">{borrowErrorMessage}</p>}
        {isLoading ? (
          <p>Loading books...</p>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Title</th>
                <th>Author</th>
                <th>Genre</th>
                <th>ISBN</th>
                <th>Available / Total</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {books.map((book) => (
                <tr key={book.id}>
                  <td>{book.title}</td>
                  <td>{book.author}</td>
                  <td>{book.genre}</td>
                  <td>{book.isbn}</td>
                  <td>
                    {book.available_copies} / {book.total_copies}
                  </td>
                  <td className="actions-cell">
                    {user?.role === 'Librarian' ? (
                      <>
                        <button onClick={() => startEdit(book)}>Edit</button>
                        <button onClick={() => deleteMutation.mutate(book.id)} disabled={deleteMutation.isPending}>
                          Delete
                        </button>
                      </>
                    ) : (
                      <button
                        onClick={() => borrowMutation.mutate(book.id)}
                        disabled={borrowMutation.isPending || book.available_copies <= 0}
                      >
                        Borrow
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  )
}
