import { api } from './client'
import type { DashboardResponse } from '../types/api'

export const fetchDashboard = async () => {
  const { data } = await api.get<DashboardResponse>('/dashboard')
  return data
}
