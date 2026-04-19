# Repository instructions for GitHub Copilot

This repository implements a technical challenge for appointment requests between guests and nutritionists.

## Goal
Build a small web application where guests can search nutritionists and request appointments, while nutritionists can review pending requests and accept or reject them.

## Stack
- Ruby on Rails 7.2+
- PostgreSQL
- React for the nutritionist pending requests page
- TailwindCSS is allowed and preferred for speed
- No authentication required unless strictly necessary

## Delivery priorities
1. Functional coverage
2. Correct business rules
3. Clear database design
4. Clean, maintainable code
5. Reasonable UI fidelity to the provided reference

Do not prioritize extra features before the mandatory requirements are complete.

## Mandatory features
- Public search page for nutritionists
- Search by nutritionist name, service name, and location
- If location is blank or invalid, default to Braga
- List matching nutritionists and their services
- "Schedule Appointment" action for each nutritionist
- Appointment request collects:
  - guest name
  - guest email
  - desired date
  - desired time
- A guest can only have one pending appointment request at a time
- Creating a new pending request must invalidate previous pending requests from the same guest
- Nutritionist pending requests page must be implemented using React
- Nutritionist can accept or reject each request
- When one request is accepted, all overlapping pending requests for the same professional must be automatically rejected
- Guest must receive an email when the request is answered
- Include seeds for quick manual testing
- Include a test suite for implemented features
- Include a README with setup and run instructions

## Extra-mile features
These are optional and should only be implemented if core requirements are already complete:
- Sorting by distance
- Improved external search
- Internationalization
- More polished UI details

## Architecture guidance
- Prefer simple Rails conventions over overengineering
- Keep controllers thin
- Put non-trivial business rules in service objects
- Keep models readable and focused
- Use database constraints and indexes where appropriate
- Prefer explicit code over magic
- Avoid adding unnecessary gems

## Suggested domain model
Use simple explicit entities such as:
- Nutritionist
- Service
- AppointmentRequest

Possible appointment statuses:
- pending
- accepted
- rejected
- invalidated

## Business rules to protect carefully
- One pending request per guest email at a time
- Accepting one request must reject all overlapping pending requests for the same nutritionist
- Overlap logic must be deterministic and tested
- State transitions must be safe and preferably transactional

## Search behavior
- Search by nutritionist name OR service name
- Filter by location
- If location is missing or invalid, use Braga
- Make the search easy to validate with seeded data

## Frontend guidance
- Use TailwindCSS for speed if helpful
- Keep the public page simple and close to the reference image
- For React, prefer small functional components
- Avoid excessive abstraction in frontend state
- Optimize for clarity and submission speed, not perfection

## Testing guidance
Add tests for:
- search filtering
- one pending request per guest
- appointment request creation
- accept/reject actions
- auto-rejection of overlapping pending requests
- email notification trigger on decision

Favor request specs, model specs, and service specs.
Do not generate fake tests that do not validate business behavior.

## Seeds guidance
Seed enough data to immediately validate:
- multiple nutritionists
- multiple services per nutritionist
- different locations
- different prices
- pending requests for nutritionist review

## Output style
When generating code:
- prefer complete runnable snippets
- keep code simple and production-like
- explain assumptions briefly
- ask before inventing missing business behavior
- do not rewrite large unrelated files unless necessary

## Working style
For each task:
1. restate the objective briefly
2. propose the minimal implementation
3. generate the code
4. mention tests to add
5. mention any assumption or tradeoff

Always optimize for finishing the challenge today with a credible submission.