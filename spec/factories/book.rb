FactoryBot.define do
  factory :book do
    title { Faker::Lorem.word }
    category
    publisher

    trait :published do
      status {rand(1..2)}
    end

    trait :unpublished do
      status {0}
    end
  end
end
