Geocoder.configure(
  lookup: :nominatim,
  timeout: 5,
  units: :km,
  nominatim: {
    host: "nominatim.openstreetmap.org"
  }
)
