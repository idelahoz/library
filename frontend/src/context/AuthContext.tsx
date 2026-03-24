import { useEffect, useMemo, useState } from 'react'
import * as authApi from '../shared/api/auth'
import { tokenStorage } from '../shared/api/client'
import type { User } from '../shared/types/api'
import { AuthContext, type AuthContextType } from './auth-context'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [token, setToken] = useState<string | null>(tokenStorage.get())
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const bootstrap = async () => {
      const existingToken = tokenStorage.get()

      if (!existingToken) {
        setIsLoading(false)
        return
      }

      try {
        const me = await authApi.me()
        setUser(me)
        setToken(existingToken)
      } catch {
        tokenStorage.clear()
        setUser(null)
        setToken(null)
      } finally {
        setIsLoading(false)
      }
    }

    void bootstrap()
  }, [])

  const value = useMemo<AuthContextType>(
    () => ({
      user,
      token,
      isLoading,
      isAuthenticated: Boolean(user && token),
      login: async (email, password) => {
        const response = await authApi.login({ email, password })
        tokenStorage.set(response.token)
        setToken(response.token)
        setUser(response.user)
      },
      register: async (payload) => {
        const response = await authApi.register(payload)
        tokenStorage.set(response.token)
        setToken(response.token)
        setUser(response.user)
      },
      logout: async () => {
        try {
          await authApi.logout()
        } finally {
          tokenStorage.clear()
          setToken(null)
          setUser(null)
        }
      },
    }),
    [user, token, isLoading],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
