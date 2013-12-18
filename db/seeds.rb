states = [
  ["AK", "Alaska"],
  ["AL", "Alabama"],
  ["AR", "Arkansas"],
  ["AS", "American Samoa"],
  ["AZ", "Arizona"],
  ["CA", "California"],
  ["CO", "Colorado"],
  ["CT", "Connecticut"],
  ["DC", "District of Columbia"],
  ["DE", "Delaware"],
  ["FL", "Florida"],
  ["GA", "Georgia"],
  ["GU", "Guam"],
  ["HI", "Hawaii"],
  ["IA", "Iowa"],
  ["ID", "Idaho"],
  ["IL", "Illinois"],
  ["IN", "Indiana"],
  ["KS", "Kansas"],
  ["KY", "Kentucky"],
  ["LA", "Louisiana"],
  ["MA", "Massachusetts"],
  ["MD", "Maryland"],
  ["ME", "Maine"],
  ["MI", "Michigan"],
  ["MN", "Minnesota", "120000000027"],
  ["MO", "Missouri"],
  ["MS", "Mississippi"],
  ["MT", "Montana"],
  ["NC", "North Carolina"],
  ["ND", "North Dakota"],
  ["NE", "Nebraska"],
  ["NH", "New Hampshire"],
  ["NJ", "New Jersey"],
  ["NM", "New Mexico"],
  ["NV", "Nevada"],
  ["NY", "New York"],
  ["OH", "Ohio"],
  ["OK", "Oklahoma"],
  ["OR", "Oregon"],
  ["PA", "Pennsylvania"],
  ["PR", "Puerto Rico"],
  ["RI", "Rhode Island"],
  ["SC", "South Carolina"],
  ["SD", "South Dakota"],
  ["TN", "Tennessee"],
  ["TX", "Texas"],
  ["UT", "Utah"],
  ["VA", "Virginia"],
  ["VI", "Virgin Islands"],
  ["VT", "Vermont"],
  ["WA", "Washington"],
  ["WI", "Wisconsin"],
  ["WV", "West Virginia"],
  ["WY", "Wyoming"] ]

states.each_with_index do |data, index|
  code, name, uid = *data
  uid ||= index
  State.create_with(name: name, uid: uid).find_or_create_by(code: code)
end

# load juridef and eledef data
require 'open-uri'
Locality.destroy_all
District.destroy_all
DataLoader.new(open("#{Rails.root}/spec/fixtures/Ramsey-County-MN-Jurisdiction-Definition-VIP.xml")).load
DataLoader.new(open("#{Rails.root}/spec/fixtures/Ramsey-County-MN-Election-Definition-Nov-2012-VIP-Draft.xml")).load
