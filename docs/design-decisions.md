# Roomies — Design Decisions

## Entities we introduced that the description does not name explicitly

- **neighborhoods** and **amenities** are catalog tables, not free-text columns,
  because moderators manage them as shared catalogs and seekers search by them. A
  property points at one neighborhood and, through **property_amenities**, at many
  amenities.
- **photos** is its own table: a listing carries several photographs, each belonging to
  one listing and keeping a display position.
- **visits** is its own table rather than a few columns on the application, because a
  visit has a date/time and a state of its own, and one application can go through more
  than one visit if a first is cancelled and another proposed.
- **reports** is its own table: a report carries a reason, a state, and the moderator
  who resolved it.
- **saved_listings** is the join table for the bookmarks (users ↔ listings).
- We did **not** model a "visitor" table. A visitor is simply someone not signed in.
  Only members and moderators are rows in **users**, told apart by `role`. Permissions
  then depend on **ownership**, not only on role: a member is a host on their own
  listings and a seeker on everyone else's.

## Lifecycle of a listing

`listings.status` moves **Draft → Published → Reserved → Rented**, and can reach
**Withdrawn** at any point when the host or a moderator takes it down. Draft is visible
only to the host; Published is open for applications; Reserved is set when an
application is accepted (no new applications); Rented once the housemate has moved in.
We store the state as one column, because the transitions come from explicit actions,
not from other data.

## Lifecycle of an application

`applications.status` moves **Pending → Shortlisted → Accepted / Rejected**, and can
reach **Withdrawn** while still open. Accepting one application is a single decision with
several consequences: that application becomes Accepted, every other Pending or
Shortlisted application on the same listing becomes Rejected, and the listing moves to
Reserved — all at once, so a listing never ends with two accepted applicants.

## Reviews: the "once per completed visit" rule

A review carries its own data (rating 1–5, a comment, whether the place matched) and
belongs to exactly one **completed visit** (`reviews.visit_id` is unique). Through the
visit, a review is tied to one seeker (the applicant) and one property (the visited
listing's property). This structurally enforces the rules the owner stated: a review
exists only after a visit that actually happened, at most one per completed visit, and a
host can never review their own property, because a host is never the applicant on their
own listing. We anchored the review on the visit rather than on a plain (seeker,
property) pair precisely because the rule is "once per **completed visit**".

## Applications as an association that carries its own data

An application is not just a link between a seeker and a listing: it holds a message, an
intended move-in date, an intended length of stay, and a state. The unique index on
`(listing_id, seeker_id)` enforces "a seeker may not apply twice to the same listing".

## Assumptions the description does not settle

- A user is either a **member** or a **moderator** (a moderator can do everything a
  member can); we represent this with a `role` column, not separate tables.
- `minimum_stay_months` and `stay_months` are whole months.
- A property points at one catalog neighborhood; the street address is a free-text column.
- In the model, photos are a table and the listing description is a `text` column; in
  Rails they become Active Storage and Action Text.
- The rules "a seeker may not apply to their own listing, nor to a listing that is not
  published" are enforced in the application (Assignment 2), not by the schema.
