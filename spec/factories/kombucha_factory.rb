# frozen_string_literal: true

FactoryBot.define do
  factory :kombucha do
    sequence(:name) { |n| "sample kombucha #{n}" }
    fizziness_level { "low" }

    trait :with_low_fizziness do
      fizziness_level { "low" }
    end

    trait :with_medium_fizziness do
      fizziness_level { "medium" }
    end

    trait :with_high_fizziness do
      fizziness_level { "high" }
    end

    factory :kombucha_with_high_fizziness, traits: %i[with_high_fizziness]
    factory :kombucha_with_low_fizziness, traits: %i[with_low_fizziness]
    factory :kombucha_with_medium_fizziness, traits: %i[with_medium_fizziness]
  end
end
