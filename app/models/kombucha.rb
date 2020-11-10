# frozen_string_literal: true

class Kombucha < ApplicationRecord
  has_many :recipe_items
  has_many :ingredients, through: :recipe_items

  validates :name, presence: true
  validates :fizziness_level, inclusion: { in: %w( high medium low ) }

  scope :by_fizziness, ->(fizziness_level) do
    where(fizziness_level: fizziness_level) if fizziness_level.present?
  end

  def self.caffeine_free(caffeine_free)
    if caffeine_free == 'true'
      cafd = Kombucha.joins(:ingredients).merge(Ingredient.caffeinated).pluck(:id)
      return Kombucha.where.not(id: cafd)
    end
    Kombucha.all
  end

  def self.vegan(vegan)
    if vegan == 'true'
      not_vegan = Kombucha.joins(:ingredients).merge(Ingredient.not_vegan).pluck(:id)
      return Kombucha.where.not(id: not_vegan)
    end
    Kombucha.all
  end

  def to_h
    {
      "id": self.id,
      "name": self.name,
      "fizziness_level": self.fizziness_level,
      "ingredients": self.ingredients.map(&:name)
    }
  end
end
