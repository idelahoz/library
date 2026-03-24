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

### Run frontend + backend together (local development)

Use two terminals so both servers run at the same time.

#### Terminal 1 (Backend: Rails API)

- `bundle install`
- `bin/rails db:prepare`
- `bin/dev` (or `bin/rails s -p 3000`)

#### Terminal 2 (Frontend: React + TypeScript)

- `cd frontend`
- `npm install`
- `npm run dev`

Frontend runs on `http://localhost:5173` and proxies `/api/*` requests to Rails at `http://localhost:3000`.

### Run tests

- `bundle exec rspec`

## API documentation

## Endpoints

Base path: `/api/v1`

### Health

- `GET /up` — Rails health check.

---

### Authentication

#### `POST /api/v1/register`
Create a member account. Returns a session token.

**Request body:**
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "secret",
  "password_confirmation": "secret"
}
```

**Response `201`:**
```json
{
  "token": "abc123",
  "user": { "id": 1, "name": "Jane Doe", "email": "jane@example.com", "role": "Member" }
}
```

---

#### `POST /api/v1/session`
Sign in and receive a session token.

**Request body:**
```json
{
  "email": "jane@example.com",
  "password": "secret"
}
```

**Response `201`:**
```json
{
  "token": "abc123",
  "user": { "id": 1, "name": "Jane Doe", "email": "jane@example.com", "role": "Member" }
}
```

**Response `401`:** Invalid credentials.

---

#### `DELETE /api/v1/session`
Sign out and destroy the current session.

**Response `200`:**
```json
{ "message": "Logged out successfully" }
```

---

### Current user

#### `GET /api/v1/me`
Returns the currently authenticated user.

**Response `200`:**
```json
{ "id": 1, "name": "Jane Doe", "email": "jane@example.com", "role": "Member" }
```

---

### Books

#### `GET /api/v1/books`
List all books. Supports optional search filters via query params.

**Query params (all optional):** `title`, `author`, `genre`

**Response `200`:**
```json
[
  { "id": 1, "title": "The Pragmatic Programmer", "author": "David Thomas", "genre": "Tech", "isbn": "978-0135957059", "total_copies": 3 }
]
```

---

#### `POST /api/v1/books` *(librarian-only)*
Create a new book.

**Request body:**
```json
{
  "title": "The Pragmatic Programmer",
  "author": "David Thomas",
  "genre": "Tech",
  "isbn": "978-0135957059",
  "total_copies": 3
}
```

**Response `201`:**
```json
{ "id": 1, "title": "The Pragmatic Programmer", "author": "David Thomas", "genre": "Tech", "isbn": "978-0135957059", "total_copies": 3 }
```

---

#### `PATCH /api/v1/books/:id` *(librarian-only)*
Update an existing book. All fields are optional.

**Request body:**
```json
{ "total_copies": 5 }
```

**Response `200`:**
```json
{ "id": 1, "title": "The Pragmatic Programmer", "author": "David Thomas", "genre": "Tech", "isbn": "978-0135957059", "total_copies": 5 }
```

---

#### `DELETE /api/v1/books/:id` *(librarian-only)*
Delete a book.

**Response `204`:** No content.

---

### Borrowings

#### `POST /api/v1/borrowings` *(member-only)*
Borrow a book. Due date is automatically set to 2 weeks from today.

**Request body:**
```json
{ "book_id": 1 }
```

**Response `201`:**
```json
{
  "id": 1,
  "borrowed_at": "2026-03-24T10:00:00.000Z",
  "due_at": "2026-04-07T10:00:00.000Z",
  "returned_at": null,
  "book": { "id": 1, "title": "The Pragmatic Programmer", "author": "David Thomas", "genre": "Tech", "isbn": "978-0135957059", "total_copies": 3 },
  "member": { "id": 2, "name": "Jane Doe", "email": "jane@example.com" }
}
```

---

#### `PATCH /api/v1/borrowings/:id/return` *(librarian or the borrowing member)*
Mark a borrowed book as returned.

**Response `200`:**
```json
{
  "id": 1,
  "borrowed_at": "2026-03-24T10:00:00.000Z",
  "due_at": "2026-04-07T10:00:00.000Z",
  "returned_at": "2026-04-05T14:30:00.000Z",
  "book": { "id": 1, "title": "The Pragmatic Programmer", "author": "David Thomas", "genre": "Tech", "isbn": "978-0135957059", "total_copies": 3 },
  "member": { "id": 2, "name": "Jane Doe", "email": "jane@example.com" }
}
```

---

### Dashboard

#### `GET /api/v1/dashboard`
Returns role-specific dashboard data.

**Librarian response `200`:**
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
      "book": { "id": 1, "title": "The Pragmatic Programmer", "author": "David Thomas" },
      "member": { "id": 2, "name": "Jane Doe", "email": "jane@example.com" }
    }
  ]
}
```

**Member response `200`:**
```json
{
  "borrowed": [
    {
      "id": 2,
      "borrowed_at": "2026-03-20T00:00:00.000Z",
      "due_at": "2026-04-03T00:00:00.000Z",
      "returned_at": null,
      "book": { "id": 3, "title": "Clean Code", "author": "Robert C. Martin" },
      "member": { "id": 5, "name": "Jane Doe", "email": "jane@example.com" }
    }
  ],
  "overdue": []
}
```

---

## Auth notes

- Protected endpoints require an `Authorization` header with a bearer token:
	- `Authorization: Bearer <token>`
- `POST /api/v1/register` and `POST /api/v1/session` are public.
- All other endpoints return `401` when unauthenticated and `403` when the user lacks the required role.
