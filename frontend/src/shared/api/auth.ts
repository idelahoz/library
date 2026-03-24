import { api } from './client'
import type { AuthResponse, User } from '../types/api'

export const register = async (payload: {
  name: string
  email: string
  password: string
  password_confirmation: string
}) => {
  const { data } = await api.post<AuthResponse>('/register', payload)
  return data
}

export const login = async (payload: { email: string; password: string }) => {
  const { data } = await api.post<AuthResponse>('/session', payload)
  return data
}

export const logout = async () => {
  await api.delete('/session')
}

export const me = async () => {
  const { data } = await api.get<User>('/me')
  return data
}
