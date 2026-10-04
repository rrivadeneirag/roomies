# Roomies — seed data
# Running `bin/rails db:seed` on an empty database leaves the app fully browsable.
# It clears existing rows first so it can be run more than once.

puts "Clearing existing data..."
Review.destroy_all
Visit.destroy_all
Application.destroy_all
SavedListing.destroy_all
Report.destroy_all
Photo.destroy_all
PropertyAmenity.destroy_all
Listing.destroy_all
Property.destroy_all
Amenity.destroy_all
Neighborhood.destroy_all
User.destroy_all

IMAGES = [
  "/images/bright-furnished-room.jpg",
  "/images/cozy-interior-room.jpg",
  "/images/spacious-main-room.jpg"
].freeze

puts "Creating neighborhoods..."
neighborhoods = {}
[
  "Providencia", "Ñuñoa", "Las Condes", "Santiago Centro",
  "Macul", "La Reina", "San Miguel"
].each do |name|
  neighborhoods[name] = Neighborhood.create!(name: name, city: "Santiago")
end

puts "Creating amenities..."
amenities = {}
[
  "WiFi", "Laundry", "Furnished kitchen", "Parking",
  "Heating", "Pet friendly", "Gym", "Rooftop terrace"
].each do |name|
  amenities[name] = Amenity.create!(name: name)
end

puts "Creating users..."
moderator = User.create!(
  name: "Admin Moderator", email: "moderator@roomies.cl",
  password_digest: "seeded", role: :moderator, phone: "+56 9 1111 1111"
)

hosts = []
[
  ["Camila Rojas", "camila@roomies.cl"],
  ["Diego Fuentes", "diego@roomies.cl"],
  ["Valentina Soto", "valentina@roomies.cl"],
  ["Matías Herrera", "matias@roomies.cl"]
].each do |name, email|
  hosts << User.create!(name: name, email: email, password_digest: "seeded",
                        role: :member, phone: "+56 9 2222 0000")
end

seekers = []
[
  ["Renato Rivadeneira", "renato@roomies.cl"],
  ["Constanza Bustamante", "constanza@roomies.cl"],
  ["Elena Durán", "elena@roomies.cl"],
  ["Tomás Vial", "tomas@roomies.cl"],
  ["Francisca León", "francisca@roomies.cl"],
  ["Ignacio Pérez", "ignacio@roomies.cl"]
].each do |name, email|
  seekers << User.create!(name: name, email: email, password_digest: "seeded",
                          role: :member, phone: "+56 9 3333 0000")
end

puts "Creating properties with amenities..."
property_specs = [
  { host: hosts[0], neighborhood: "Providencia", address: "Av. Providencia 1234, Depto 52",
    type: "Apartment", bedrooms: 3, bathrooms: 2,
    shared: "Living room, kitchen and a small balcony.",
    amenities: ["WiFi", "Laundry", "Furnished kitchen", "Heating"] },
  { host: hosts[0], neighborhood: "Ñuñoa", address: "Calle Dublé Almeyda 3450",
    type: "House", bedrooms: 4, bathrooms: 2,
    shared: "Garden, living room and dining room.",
    amenities: ["WiFi", "Parking", "Pet friendly"] },
  { host: hosts[1], neighborhood: "Las Condes", address: "Av. Apoquindo 5600, Torre B",
    type: "Apartment", bedrooms: 2, bathrooms: 2,
    shared: "Shared kitchen and rooftop terrace.",
    amenities: ["WiFi", "Gym", "Rooftop terrace", "Furnished kitchen"] },
  { host: hosts[1], neighborhood: "Santiago Centro", address: "Calle Santa Rosa 120",
    type: "Apartment", bedrooms: 3, bathrooms: 1,
    shared: "Kitchen and laundry area.",
    amenities: ["WiFi", "Laundry"] },
  { host: hosts[2], neighborhood: "Macul", address: "Av. Macul 4820",
    type: "House", bedrooms: 5, bathrooms: 3,
    shared: "Large living room, backyard and parking.",
    amenities: ["WiFi", "Parking", "Heating", "Pet friendly"] },
  { host: hosts[3], neighborhood: "La Reina", address: "Av. Larraín 9100",
    type: "House", bedrooms: 3, bathrooms: 2,
    shared: "Kitchen, terrace and garden.",
    amenities: ["WiFi", "Furnished kitchen", "Rooftop terrace"] }
]

properties = property_specs.map do |spec|
  property = Property.create!(
    host: spec[:host], neighborhood: neighborhoods[spec[:neighborhood]],
    address: spec[:address], property_type: spec[:type],
    bedrooms: spec[:bedrooms], bathrooms: spec[:bathrooms], shared_spaces: spec[:shared]
  )
  spec[:amenities].each do |amenity_name|
    PropertyAmenity.create!(property: property, amenity: amenities[amenity_name])
  end
  property
end

puts "Creating listings with photos..."
# statuses spread across the lifecycle so the views show every state
listing_specs = [
  { property: properties[0], rent: 320_000, status: :published, furnished: true,  bath: true },
  { property: properties[0], rent: 280_000, status: :published, furnished: false, bath: false },
  { property: properties[1], rent: 300_000, status: :published, furnished: true,  bath: false },
  { property: properties[2], rent: 410_000, status: :published, furnished: true,  bath: true },
  { property: properties[2], rent: 390_000, status: :reserved,  furnished: true,  bath: true },
  { property: properties[3], rent: 250_000, status: :published, furnished: false, bath: false },
  { property: properties[4], rent: 350_000, status: :published, furnished: true,  bath: true },
  { property: properties[4], rent: 330_000, status: :rented,    furnished: true,  bath: false },
  { property: properties[5], rent: 360_000, status: :published, furnished: true,  bath: true },
  { property: properties[5], rent: 300_000, status: :draft,     furnished: false, bath: false },
  { property: properties[1], rent: 290_000, status: :withdrawn, furnished: false, bath: false }
]

listings = listing_specs.each_with_index.map do |spec, i|
  listing = Listing.create!(
    property: spec[:property],
    monthly_rent: spec[:rent],
    deposit: spec[:rent],
    available_on: Date.current + (7 * (i + 1)).days,
    minimum_stay_months: [3, 6, 12].sample,
    furnished: spec[:furnished],
    private_bathroom: spec[:bath],
    description: "A comfortable room in #{spec[:property].neighborhood.name}. " \
                 "Close to public transport, shops and green areas.",
    status: spec[:status]
  )
  # 1 to 3 photos per listing
  rand(1..3).times do |n|
    Photo.create!(listing: listing, image_url: IMAGES[n % IMAGES.size], position: n + 1)
  end
  listing
end

published = listings.select(&:published?)

puts "Creating applications, visits and reviews..."
# A completed, reviewed application (backdated so the visit sits in the past)
app1 = Application.create!(
  listing: published[0], seeker: seekers[0],
  message: "Hi! I loved the room and the neighborhood. I'm tidy and work from home.",
  move_in_on: Date.current + 20.days, stay_months: 12, status: :accepted,
  created_at: 15.days.ago
)
visit1 = Visit.create!(application: app1, scheduled_at: 10.days.ago, status: :completed)
Review.create!(visit: visit1, rating: 5, comment: "Great room and very friendly housemates.",
               matched: true, reviewed_on: 8.days.ago)

app2 = Application.create!(
  listing: published[0], seeker: seekers[1],
  message: "Interested in a 6-month stay. Non-smoker, no pets.",
  move_in_on: Date.current + 25.days, stay_months: 6, status: :shortlisted,
  created_at: 5.days.ago
)
Visit.create!(application: app2, scheduled_at: 3.days.from_now, status: :confirmed)

app3 = Application.create!(
  listing: published[1], seeker: seekers[2],
  message: "Looking for a bright room near my university.",
  move_in_on: Date.current + 30.days, stay_months: 12, status: :pending,
  created_at: 2.days.ago
)
Visit.create!(application: app3, scheduled_at: 5.days.from_now, status: :proposed)

app4 = Application.create!(
  listing: published[2], seeker: seekers[3],
  message: "Can move in soon, flexible on the date.",
  move_in_on: Date.current + 15.days, stay_months: 6, status: :rejected,
  created_at: 12.days.ago
)
visit4 = Visit.create!(application: app4, scheduled_at: 7.days.ago, status: :completed)
Review.create!(visit: visit4, rating: 3, comment: "Nice place but a bit far from the metro.",
               matched: false, reviewed_on: 6.days.ago)

app5 = Application.create!(
  listing: published[3], seeker: seekers[4],
  message: "I'd love to join. I keep common areas clean.",
  move_in_on: Date.current + 40.days, stay_months: 12, status: :pending,
  created_at: 1.day.ago
)
Visit.create!(application: app5, scheduled_at: 6.days.from_now, status: :proposed)

app6 = Application.create!(
  listing: published[3], seeker: seekers[5],
  message: "Quiet student, references available.",
  move_in_on: Date.current + 45.days, stay_months: 6, status: :withdrawn,
  created_at: 8.days.ago
)
Visit.create!(application: app6, scheduled_at: 4.days.ago, status: :cancelled)

# A couple more applications to exercise the many-to-many between users and listings
Application.create!(
  listing: published[4], seeker: seekers[0],
  message: "Interested in this one too, great location.",
  move_in_on: Date.current + 18.days, stay_months: 12, status: :pending,
  created_at: 3.days.ago
)
Application.create!(
  listing: published[5], seeker: seekers[1],
  message: "Would like to schedule a visit.",
  move_in_on: Date.current + 22.days, stay_months: 6, status: :pending,
  created_at: 4.days.ago
)

puts "Creating reports..."
Report.create!(listing: published[2], reporter: seekers[3],
               reason: "The photos do not match the actual room.",
               status: :pending)
Report.create!(listing: published[1], reporter: seekers[4],
               reason: "Suspected duplicate listing.",
               status: :reviewed, moderator: moderator, resolved_on: 2.days.ago)

puts "Creating saved listings..."
seekers[0].saved_rooms << [published[1], published[3]]
seekers[1].saved_rooms << published[0]
seekers[2].saved_rooms << [published[0], published[2]]

puts "Done!"
puts "  Users:        #{User.count}"
puts "  Neighborhoods:#{Neighborhood.count}"
puts "  Amenities:    #{Amenity.count}"
puts "  Properties:   #{Property.count}"
puts "  Listings:     #{Listing.count} (published: #{Listing.published.count})"
puts "  Applications: #{Application.count}"
puts "  Visits:       #{Visit.count}"
puts "  Reviews:      #{Review.count}"
puts "  Reports:      #{Report.count}"
puts "  Saved:        #{SavedListing.count}"
