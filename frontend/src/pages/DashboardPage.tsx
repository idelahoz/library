import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { fetchDashboard } from '../shared/api/dashboard'
import { returnBook } from '../shared/api/borrowings'
import { useAuth } from '../context/useAuth'
import type { Borrowing, LibrarianDashboard, MemberDashboard } from '../shared/types/api'

function BorrowingsTable({ items = [], canReturn }: { items?: Borrowing[]; canReturn: boolean }) {
  const queryClient = useQueryClient()
  const returnMutation = useMutation({
    mutationFn: (id: number) => returnBook(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['dashboard'] })
      queryClient.invalidateQueries({ queryKey: ['books'] })
    },
  })

  if (items.length === 0) return <p className="empty-text">No items.</p>

  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Book</th>
            <th>Member</th>
            <th>Due date</th>
            <th>Status</th>
            {canReturn && <th>Action</th>}
          </tr>
        </thead>
        <tbody>
          {items.map((borrowing) => (
            <tr key={borrowing.id}>
              <td>{borrowing.book.title}</td>
              <td>{borrowing.member.name}</td>
              <td>{new Date(borrowing.due_at).toLocaleDateString()}</td>
              <td>{borrowing.returned_at ? 'Returned' : 'Borrowed'}</td>
              {canReturn && (
                <td>
                  {!borrowing.returned_at && (
                    <button onClick={() => returnMutation.mutate(borrowing.id)} disabled={returnMutation.isPending}>
                      Return
                    </button>
                  )}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export default function DashboardPage() {
  const { user } = useAuth()
  const { data, isLoading, isError } = useQuery({
    queryKey: ['dashboard', user?.id],
    queryFn: fetchDashboard,
    enabled: Boolean(user),
  })

  if (isLoading) return <p>Loading dashboard...</p>
  if (isError || !data || !user) return <p className="error-text">Unable to load dashboard.</p>

  if (user.role === 'Librarian') {
    const librarianData = data as LibrarianDashboard

    return (
      <div className="stack">
        <h1>Librarian dashboard</h1>
        <div className="stats-grid">
          <article className="stat-card">
            <h3>Total books</h3>
            <p>{librarianData.total_books}</p>
          </article>
          <article className="stat-card">
            <h3>Total borrowed</h3>
            <p>{librarianData.total_borrowed}</p>
          </article>
          <article className="stat-card">
            <h3>Due today</h3>
            <p>{librarianData.due_today}</p>
          </article>
        </div>

        <section>
          <h2>Members with overdue books</h2>
          <BorrowingsTable items={librarianData.overdue_borrowings ?? []} canReturn />
        </section>
      </div>
    )
  }

  const memberData = data as MemberDashboard

  return (
    <div className="stack">
      <h1>My dashboard</h1>
      <section>
        <h2>Borrowed books</h2>
        <BorrowingsTable items={memberData.borrowed ?? []} canReturn />
      </section>
      <section>
        <h2>Overdue books</h2>
        <BorrowingsTable items={memberData.overdue ?? []} canReturn />
      </section>
    </div>
  )
}
