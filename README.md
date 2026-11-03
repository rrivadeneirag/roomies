# Roomies

Roomies connects people offering a free room in a shared home with people looking
for a place to live. Hosts publish rooms, upload photos and write house rules;
seekers apply, visit, and move in.

The original specification (Assignment 1) lives in [`docs/`](docs/).

## Tech stack

- Ruby and Rails 8 (importmap + Hotwire / Turbo)
- PostgreSQL (development and test)
- Bootstrap 5, bundled with cssbundling-rails
- Active Storage for photographs (with image variants)
- Action Text for the listing description and house rules
- **has_secure_password** + Rails 8 native sessions (authentication)
- **Pundit** for authorization (policies per role)
- **Active Job** (async) + **letter_opener** for notification emails

## Requirements

- Ruby (see `.ruby-version`)
- PostgreSQL running locally
- Node.js and Yarn (Bootstrap build)
- **libvips** — used to generate image variants. On macOS: `brew install vips`

## Setup

```bash
bundle install
yarn install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

## Running

```bash
bin/dev
```

Then open http://localhost:3000. `bin/dev` runs the server together with the
Bootstrap CSS build.

## Accounts (seed data)

Every seeded account uses the password **`password`**.

| Role      | Email                  | Can do                                                        |
|-----------|------------------------|--------------------------------------------------------------|
| Moderator | `moderator@roomies.cl` | Manage neighborhoods & amenities, see the Reports inbox, take any listing down |
| Member    | `renato@roomies.cl`    | Publish and manage their own properties/listings, apply, report listings |

Other members: `camila@roomies.cl`, `diego@roomies.cl`, `valentina@roomies.cl`,
`matias@roomies.cl`, `constanza@roomies.cl`, `elena@roomies.cl` … (all `password`).

You can also create a new account from **Sign up**; new accounts are members.

## Authentication

- Sign up, log in and log out using the Rails 8 native session generator
  (`has_secure_password`, a `Session` per sign-in, `Current.user`).
- Password reset by email is available from the login page.
- Public pages (home, rooms, properties, neighborhoods, search and the JSON API)
  can be viewed without logging in; everything else requires a session.
- Each user has a **profile** (name, phone, bio) they can edit.

## Authorization (Pundit)

Two roles, `member` and `moderator`, enforced with Pundit policies
(`app/policies/`):

- **Members** manage only their *own* properties and listings, apply to rooms,
  and can **report** a listing.
- **Moderators** manage the catalog (neighborhoods and amenities), see the
  **Reports** inbox, resolve reports, and can take any listing down.
- Buttons are hidden when the current user is not allowed, and a blocked action
  renders a friendly **403** page.

## JSON API

Public, read-only, versioned under `/api/v1` (no personal data is exposed).

| Method & path                | Description                      |
|------------------------------|----------------------------------|
| `GET /api/v1/listings`       | Published rooms (JSON)           |
| `GET /api/v1/listings/:id`   | One published room, or 404 JSON  |

Optional query filters on the index:

- `neighborhood` — neighborhood id
- `max_rent` — maximum monthly rent
- `available_on` — available on/after this date (`YYYY-MM-DD`)
- `furnished` — `true`
- `property_type` — `Apartment` / `House` / `Studio` / `Room`

Example: `GET /api/v1/listings.json?furnished=true&max_rent=350000`

## Search (fetch)

The **Search** page (`/search`) consumes the JSON API with `fetch()` and renders
results client-side, without reloading the page, as filters change.

## Notification email

When a seeker applies to a room, the host is notified by email. The message is
sent with **Active Job** (`deliver_later`, async adapter). In development the
email opens automatically in the browser via **letter_opener**.

## What you can do

- **Full CRUD**: properties, listings (always created inside a property),
  neighborhoods and amenities. Strong parameters and flash messages throughout.
- **Apply**: a seeker applies from the listing page and can withdraw while the
  application is pending or shortlisted.
- **Answer applications** (host inbox): shortlist, reject or accept. Accepting an
  application rejects every other open application on that listing and moves the
  listing to *reserved* — in a single transaction.
- **Visits**: the host proposes a visit on a shortlisted application; visits are
  confirmed, rescheduled, cancelled and completed. Only a completed visit enables
  a review.
- **Reviews**: written from the property page after a completed visit.
- **Listing lifecycle**: draft → published → reserved / rented / withdrawn.
- **Reports**: members flag a listing; moderators resolve them.

## Hotwire

- **Turbo Frame**: applying to a listing replaces the application block in place.
- **Turbo Stream**: answering an application in the host inbox updates the
  affected rows and the pending count without a full page reload.

## Team

Team Roomies — Renato Rivadeneira, Constanza Bustamante, Elena Durán. Web
Technologies, Universidad de los Andes, 2026.
