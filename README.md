# Roomies

Roomies connects people offering a free room in a shared home with people looking
for a place to live. Seekers browse rooms by neighborhood, rent and availability,
read property details and reviews, and follow their applications and visits.

This repository contains the Rails 8 application (Assignment 2). The original
specification from Assignment 1 — user stories, domain model and design
decisions — lives in [`docs/`](docs/).

## Tech stack

- Ruby 3.x and Rails 8
- PostgreSQL (development and test)
- Bootstrap 5, bundled with cssbundling-rails

## Requirements

- Ruby (see `.ruby-version`)
- PostgreSQL running locally
- Node.js and Yarn (used by cssbundling to build Bootstrap)

## Setup

```bash
bundle install
yarn install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

Running `bin/rails db:seed` on an empty database leaves the application fully
browsable, with listings in every lifecycle state, applications, visits and
reviews.

## Running

```bash
bin/dev
```

Then open http://localhost:3000.

`bin/dev` starts the Rails server together with the Bootstrap CSS build (via the
`Procfile.dev` that cssbundling-rails provides).

## What you can browse (read-only)

This assignment is about the data layer and about reading it — nothing in the app
creates, edits or deletes records.

- **Home (`/`)** — the landing page, with featured published rooms.
- **Rooms (`/listings`)** — every published listing with its neighborhood, rent
  and availability. Each room's page shows the full detail, the property's
  amenities and the reviews of that property.
- **Properties (`/properties`)** — each property with the listings it contains and
  its reviews.
- **Neighborhoods (`/neighborhoods`)** — each neighborhood with the rooms
  available in it.
- **Applications (`/applications`)** — the applications and their visits.

## Domain model

Eleven entities: `users`, `neighborhoods`, `amenities`, `properties`,
`property_amenities`, `listings`, `photos`, `applications`, `visits`, `reviews`,
`reports`, `saved_listings`.

- **Associations** — one-to-many, one-to-one (visit ↔ review) and three
  many-to-many: properties ↔ amenities (`property_amenities`), users ↔ listings as
  seekers (`applications`) and as savers (`saved_listings`).
- **Enums** — the three lifecycles: `Listing#status`, `Application#status` and
  `Visit#status` (plus `Report#status` and `User#role`).
- **Validations** — presence of required attributes, unique email, a seeker may
  not apply twice to the same listing, numeric rent/deposit/stay, a review rating
  between 1 and 5, an availability date not in the past, and a visit scheduled
  after its application was created.
- **Scopes** — `Listing.published` (from the enum), `Listing.available_from(date)`,
  `Listing.under_rent(amount)`, and `Application.pending_answer`.

## Changes since Assignment 1

The relational structure (tables, columns, types, relationships and unique
indexes) matches the Assignment 1 diagram in [`docs/domain-model.md`](docs/domain-model.md).
Two additions were made while implementing it in Rails:

- **Timestamps** — `created_at` / `updated_at` were added to every table (Rails
  convention; `created_at` is also what the "visit scheduled after the application
  was created" rule compares against).
- **Defaults** — database defaults were set for the state and boolean columns
  (`listings.status` → Draft, `applications.status` → Pending, `visits.status` →
  Proposed, `reports.status` → Pending, `users.role` → member, `furnished` and
  `private_bathroom` → false).

## Team

Team Roomies — Renato Rivadeneira, Constanza Bustamante, Elena Durán. Web
Technologies, Universidad de los Andes, 2026.
