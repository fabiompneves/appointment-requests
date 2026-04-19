# Appointment Requests System

A web application for managing appointment requests between guests and nutritionists. Built with Ruby on Rails and React.

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

### Quick Setup (Recommended)

```bash
# Clone the repository
git clone git@github.com:fabiompneves/appointment-requests.git
cd appointment-requests

# Run the automated setup script
bin/setup
```

**Setup Options:**
- `bin/setup` - Normal setup (preserves existing data)
- `bin/setup --reset` - Reset database and re-seed
- `bin/setup --no-server` - Skip starting the server

## Running the Application

### Development Mode

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

### Total Test Coverage

**103 tests total** across backend and frontend:
- ✅ 80 Rails tests (models, services, controllers, mailers, API)
- ✅ 23 Jest tests (React components)

All business requirements are tested:
- ✅ Search filtering (name, service, location)
- ✅ One pending request per guest email
- ✅ Appointment request creation
- ✅ Accept/reject actions
- ✅ Auto-rejection of overlapping pending requests
- ✅ Email notification triggers
- ✅ Status transitions and validations
- ✅ React UI interactions and state management

### Continuous Integration

The project includes a GitHub Actions workflow that automatically runs on every push:

```yaml
# .github/workflows/ci.yml runs:
- Security scans (Brakeman, Bundler Audit)
- Code quality checks (RuboCop)
- Backend tests (80 Rails tests)
- Frontend tests (23 Jest tests)
```

## Email Preview in Development

When the app sends emails in development, they automatically open in your browser thanks to `letter_opener`. Check your browser for new tabs after accepting/rejecting requests.
