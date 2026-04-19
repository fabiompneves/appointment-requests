# Appointment Requests System

A web application for managing appointment requests between guests and nutritionists. Built with Ruby on Rails and React.

## Features

- **Public Search**: Search for nutritionists by name, service, or location (defaults to Braga)
- **Appointment Requests**: Guests can request appointments with their preferred nutritionist
- **Request Management**: Nutritionists can view, accept, or reject pending appointment requests via a React interface
- **Smart Conflict Resolution**: When a nutritionist accepts an appointment, all overlapping pending requests are automatically rejected
- **Email Notifications**: Guests receive email notifications when their requests are accepted or rejected
- **One Request Per Guest**: Each guest email can only have one pending appointment request at a time

## Tech Stack

- **Ruby**: 3.4.6
- **Rails**: 8.1.3
- **PostgreSQL**: Database
- **React**: 19.2.5
- **TailwindCSS**: 4.2.2
- **esbuild**: JavaScript bundling
- **Propshaft**: Asset pipeline
- **letter_opener**: Email preview in development

## Prerequisites

- Ruby 3.4.6
- PostgreSQL
- Node.js and npm

## Setup Instructions

### 1. Clone the repository

```bash
git clone git@github.com:fabiompneves/appointment-requests.git
cd appointment-requests
```

### 2. Install dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
npm install
```

### 3. Database setup

```bash
# Create database
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Seed the database with sample data
bin/rails db:seed
```

The seed data includes:
- 12 nutritionists across Braga, Porto, and Lisboa
- 50+ services (Consulta Geral, Nutrição Desportiva, Emagrecimento, etc.)
- Sample pending appointment requests for testing

### 4. Build assets

```bash
# Build JavaScript assets
npm run build

# Or use the Rails asset compilation
bin/rails assets:precompile
```

## Running the Application

### Development Mode

#### Option 1: Using bin/dev (recommended)

```bash
bin/dev
```

This starts:
- Rails server on http://localhost:3000
- Asset watching (Tailwind CSS and esbuild)

### Access the Application

- **Public Search**: http://localhost:3000
- **Nutritionist Pending Requests**: http://localhost:3000/nutritionists/:id/pending_requests

Replace `:id` with a nutritionist ID from the seeds (e.g., use IDs 1-12).

## Running Tests

### Backend Tests (Rails)

Run the complete test suite:

```bash
bin/rails test
```

Run specific test files:

```bash
# Model tests
bin/rails test test/models/

# Service tests
bin/rails test test/services/

# Controller tests
bin/rails test test/controllers/

# Mailer tests
bin/rails test test/mailers/
```

The backend test suite includes:
- **57 tests** covering all business logic
- Model validations and associations
- Service layer business rules (overlap detection, one pending per guest)
- Controller/request specs
- Email delivery specs

### Frontend Tests (Jest + React Testing Library)

Run the React component tests:

```bash
# Run all tests
npm test

# Run tests in watch mode (auto-reruns on file changes)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

The frontend test suite includes:
- **23 tests** covering the PendingRequestsApp React component
- Loading states and error handling
- Empty state display
- Request list rendering and data display
- Accept/reject actions with confirmations
- API call verification
- Alert messages and user feedback
- Date formatting

## Email Preview in Development

When the app sends emails in development, they automatically open in your browser thanks to `letter_opener`. Check your browser for new tabs after accepting/rejecting requests.
