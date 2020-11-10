# frozen_string_literal: true

FactoryBot.define do
  factory :ingredient, class: Ingredient do
    sequence(:name) { |n| "sample ingredient #{n}" }
    base { true }
    caffeine_free { false }
    vegan { false }

    trait :caffeine_free do
      caffeine_free { true }
    end

    trait :vegan do
      vegan { true }
    end

    factory :caffeine_free_ingredient, traits: %i[caffeine_free]
    factory :vegan_ingredient, traits: %i[vegan]
  end
end
