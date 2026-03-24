export type UserRole = 'Librarian' | 'Member'

export interface User {
  id: number
  name: string
  email: string
  role: UserRole
}

export interface AuthResponse {
  token: string
  user: User
}

export interface Book {
  id: number
  title: string
  author: string
  genre: string
  isbn: string
  total_copies: number
  available_copies: number
}

export interface MemberSummary {
  id: number
  name: string
  email: string
}

export interface Borrowing {
  id: number
  borrowed_at: string
  due_at: string
  returned_at: string | null
  book: Book
  member: MemberSummary
}

export interface LibrarianDashboard {
  total_books: number
  total_borrowed: number
  due_today: number
  overdue_borrowings: Borrowing[]
}

export interface MemberDashboard {
  borrowed: Borrowing[]
  overdue: Borrowing[]
}

export type DashboardResponse = LibrarianDashboard | MemberDashboard
