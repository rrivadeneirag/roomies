json.id            listing.id
json.property_type listing.property.property_type
json.neighborhood  listing.property.neighborhood.name
json.city          listing.property.neighborhood.city
json.address       listing.property.address
json.monthly_rent  listing.monthly_rent
json.deposit       listing.deposit
json.available_on  listing.available_on
json.minimum_stay_months listing.minimum_stay_months
json.furnished     listing.furnished
json.private_bathroom listing.private_bathroom
json.status        listing.status
json.url           listing_url(listing)
json.photo_url (listing.photos.attached? ? url_for(listing.photos.first.variant(resize_to_limit: [400, 300])) : nil)
