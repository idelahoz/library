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

- `POST /api/v1/books` — Create a book (librarian-only).
- `PATCH /api/v1/books/:id` — Update a book (librarian-only).
- `DELETE /api/v1/books/:id` — Delete a book (librarian-only).

## Auth notes

- Protected endpoints require an `Authorization` header with a bearer token:
	- `Authorization: Bearer <token>`
- `POST /api/v1/register` and `POST /api/v1/session` are public.
