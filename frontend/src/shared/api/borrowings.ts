import { api } from './client'
import type { Borrowing } from '../types/api'

export const borrowBook = async (book_id: number) => {
  const { data } = await api.post<Borrowing>('/borrowings', { book_id })
  return data
}

export const returnBook = async (borrowingId: number) => {
  const { data } = await api.patch<Borrowing>(`/borrowings/${borrowingId}/return`)
  return data
}
