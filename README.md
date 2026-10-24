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

New setup steps since Assignment 2: the `image_processing` gem is enabled in the
`Gemfile` (run `bundle install`) and **libvips** must be installed (`brew install vips`)
so Active Storage can resize photos.

## Running

```bash
bin/dev
```

Then open http://localhost:3000. `bin/dev` runs the server together with the
Bootstrap CSS build.

## Photo uploads

- A listing can have several photographs (JPG, PNG, WEBP or GIF).
- **Maximum size: 5 MB per photo.** Non-images and larger files are rejected.
- Index and search cards show a resized **variant**, not the full-resolution image.

## No authentication yet

There is no login (that is Assignment 4). Use the **"Acting as"** selector in the
navbar to choose which user you act as; that user is the author of every action.

## What you can do

- **Full CRUD**: properties, listings (always created inside a property),
  neighborhoods and amenities. Strong parameters and flash messages throughout.
- **Apply**: a seeker applies from the listing page and can withdraw while the
  application is pending or shortlisted.
- **Answer applications** (host inbox): shortlist, reject or accept. Accepting an
  application rejects every other open application on that listing and moves the
  listing to *reserved* — the three effects happen in a single transaction.
- **Visits**: the host proposes a visit on a shortlisted application; visits are
  confirmed, rescheduled, cancelled and completed. Only a completed visit enables a
  review.
- **Reviews**: written from the property page after a completed visit.
- **Listing lifecycle**: draft → published → reserved / rented / withdrawn, with the
  available actions changing by state. A draft is visible only to its host.

## Hotwire

- **Turbo Frame**: applying to a listing replaces the application block in place,
  without reloading the photos and description.
- **Turbo Stream**: answering an application in the host inbox updates the affected
  rows and the pending count without a full page reload (including the rows that are
  auto-rejected when an application is accepted).

## Changes since Assignment 2

- Added **Active Storage** (photographs) and **Action Text** (description and house
  rules). The old `photos` table and the `listings.description` column were removed.
- Added the listing lifecycle actions and the application / visit / review business
  rules (enforced in the models).

## Team

Team Roomies — Renato Rivadeneira, Constanza Bustamante, Elena Durán. Web
Technologies, Universidad de los Andes, 2026.
