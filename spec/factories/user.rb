FactoryBot.define do
  factory :user do
    name {Faker::Lorem.word}
    email {Faker::Internet.email(name: name)}
    password {"password"}
    password_confirmation {"password"}
  end
end
