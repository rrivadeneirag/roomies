# Roomies — Domain Model

## Diagram

![Roomies domain model](domain-model.png)

## DBML

Produced in [dbdiagram.io](https://dbdiagram.io); it compiles as it stands. The types
are the ones the Rails schema will use in Assignment 2. `note:` values list the states
each lifecycle column may hold.

```dbml
Table users {
  id bigint [primary key]
  name varchar [not null]
  email varchar [not null, unique]
  password_digest varchar [not null]
  role varchar [not null, note: 'member or moderator']
  phone varchar
  created_at timestamp
  updated_at timestamp
}

Table neighborhoods {
  id bigint [primary key]
  name varchar [not null, unique]
  city varchar [not null]
  created_at timestamp
  updated_at timestamp
}

Table amenities {
  id bigint [primary key]
  name varchar [not null, unique]
  created_at timestamp
  updated_at timestamp
}

Table properties {
  id bigint [primary key]
  host_id bigint [not null]
  neighborhood_id bigint [not null]
  address varchar [not null]
  property_type varchar [not null]
  bedrooms integer [not null]
  bathrooms integer [not null]
  shared_spaces text
  created_at timestamp
  updated_at timestamp
}

Table property_amenities {
  id bigint [primary key]
  property_id bigint [not null]
  amenity_id bigint [not null]
  created_at timestamp
  updated_at timestamp

  indexes {
    (property_id, amenity_id) [unique]
  }
}

Table listings {
  id bigint [primary key]
  property_id bigint [not null]
  monthly_rent decimal(10,2) [not null]
  deposit decimal(10,2) [not null]
  available_on date [not null]
  minimum_stay_months integer [not null]
  furnished boolean [not null]
  private_bathroom boolean [not null]
  description text
  status varchar [not null, note: 'Draft, Published, Reserved, Rented, Withdrawn']
  created_at timestamp
  updated_at timestamp
}

Table photos {
  id bigint [primary key]
  listing_id bigint [not null]
  image_url varchar [not null]
  position integer [not null]
  created_at timestamp
  updated_at timestamp
}

Table applications {
  id bigint [primary key]
  listing_id bigint [not null]
  seeker_id bigint [not null]
  message text [not null]
  move_in_on date [not null]
  stay_months integer [not null]
  status varchar [not null, note: 'Pending, Shortlisted, Accepted, Rejected, Withdrawn']
  created_at timestamp
  updated_at timestamp

  indexes {
    (listing_id, seeker_id) [unique]
  }
}

Table visits {
  id bigint [primary key]
  application_id bigint [not null]
  scheduled_at datetime [not null]
  status varchar [not null, note: 'Proposed, Confirmed, Cancelled, Completed']
  created_at timestamp
  updated_at timestamp
}

Table reviews {
  id bigint [primary key]
  visit_id bigint [not null, unique]
  rating integer [not null, note: '1 to 5']
  comment text [not null]
  matched boolean [not null]
  reviewed_on date [not null]
  created_at timestamp
  updated_at timestamp
}

Table reports {
  id bigint [primary key]
  listing_id bigint [not null]
  reporter_id bigint [not null]
  reason text [not null]
  status varchar [not null, note: 'Pending, Reviewed, Dismissed, ActionTaken']
  moderator_id bigint
  resolved_on date
  created_at timestamp
  updated_at timestamp
}

Table saved_listings {
  id bigint [primary key]
  user_id bigint [not null]
  listing_id bigint [not null]
  created_at timestamp
  updated_at timestamp

  indexes {
    (user_id, listing_id) [unique]
  }
}

Ref: properties.host_id > users.id
Ref: properties.neighborhood_id > neighborhoods.id
Ref: property_amenities.property_id > properties.id
Ref: property_amenities.amenity_id > amenities.id
Ref: listings.property_id > properties.id
Ref: photos.listing_id > listings.id
Ref: applications.listing_id > listings.id
Ref: applications.seeker_id > users.id
Ref: visits.application_id > applications.id
Ref: reviews.visit_id - visits.id
Ref: reports.listing_id > listings.id
Ref: reports.reporter_id > users.id
Ref: reports.moderator_id > users.id
Ref: saved_listings.user_id > users.id
Ref: saved_listings.listing_id > listings.id