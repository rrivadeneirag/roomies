json.count @listings.size
json.listings @listings do |listing|
  json.partial! "api/v1/listings/listing", listing: listing
end
