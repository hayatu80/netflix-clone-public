Fabricator (:invitation) do
  friend_name { Faker::Name.name }
  friend_email { Faker::Internet.email }
  message { Faker::Lorem.characters }
  token { Faker::Lorem.characters }
end