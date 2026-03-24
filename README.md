# Library API

## Setup

### Prerequisites

- Ruby (project uses Rails 8.x)
- Bundler
- PostgreSQL

### Install dependencies

- `bundle install`

### Database setup

- `bin/rails db:create`
- `bin/rails db:migrate`

For test database:

- `bin/rails db:migrate RAILS_ENV=test`

### Run the app

- `bin/dev`

### Run tests

- `bundle exec rspec`

## API documentation

## Endpoints

Base path: `/api/v1`

### Health

- `GET /up` — Rails health check.

### Authentication

- `POST /api/v1/register` — Create a user account.
- `POST /api/v1/session` — Sign in and create a session.
- `DELETE /api/v1/session` — Sign out and destroy the current session.

### Current user

- `GET /api/v1/me` — Return the currently authenticated user.

### Books

- `GET /api/v1/books` — List/search books (authenticated users).
- `POST /api/v1/books` — Create a book (librarian-only).
- `PATCH /api/v1/books/:id` — Update a book (librarian-only).
- `DELETE /api/v1/books/:id` — Delete a book (librarian-only).

Search query params (optional):

- `title`
- `author`
- `genre`

Example:

- `GET /api/v1/books?title=pragmatic`

### Borrowings

- `POST /api/v1/borrowings` — Borrow a book (member-only).
- `PATCH /api/v1/borrowings/:id/return` — Mark a book as returned (librarian or the borrowing member).

### Dashboard

- `GET /api/v1/dashboard` — Returns role-specific dashboard data (authenticated users).

**Librarian response:**
```json
{
  "total_books": 10,
  "total_borrowed": 3,
  "due_today": 1,
  "overdue_borrowings": [
    {
      "id": 1,
      "borrowed_at": "2026-03-01T00:00:00.000Z",
      "due_at": "2026-03-15T00:00:00.000Z",
      "returned_at": null,
      "book": { "id": 1, "title": "...", "author": "..." },
      "member": { "id": 2, "name": "...", "email": "..." }
    }
  ]
}
```

**Member response:**
```json
{
  "borrowed": [
    {
      "id": 2,
      "borrowed_at": "2026-03-20T00:00:00.000Z",
      "due_at": "2026-04-03T00:00:00.000Z",
      "returned_at": null,
      "book": { "id": 3, "title": "...", "author": "..." },
      "member": { "id": 5, "name": "...", "email": "..." }
    }
  ],
  "overdue": []
}
```

## Auth notes

- Protected endpoints require an `Authorization` header with a bearer token:
	- `Authorization: Bearer <token>`
- `POST /api/v1/register` and `POST /api/v1/session` are public.
