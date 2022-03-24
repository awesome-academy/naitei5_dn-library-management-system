FactoryBot.define do
  factory :comment do
    user
    content {Faker::Lorem.sentence}
  end
end
