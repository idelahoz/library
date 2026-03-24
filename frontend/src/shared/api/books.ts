import { api } from './client'
import type { Book } from '../types/api'

type BookPayload = Omit<Book, 'id' | 'available_copies'>

export interface BookFilters {
  title?: string
  author?: string
  genre?: string
}

export const fetchBooks = async (filters: BookFilters) => {
  const { data } = await api.get<Book[]>('/books', { params: filters })
  return data
}

export const createBook = async (payload: BookPayload) => {
  const { data } = await api.post<Book>('/books', payload)
  return data
}

export const updateBook = async (id: number, payload: Partial<BookPayload>) => {
  const { data } = await api.patch<Book>(`/books/${id}`, payload)
  return data
}

export const deleteBook = async (id: number) => {
  await api.delete(`/books/${id}`)
}
