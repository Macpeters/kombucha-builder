# frozen_string_literal: true

class Rating < ApplicationRecord
  has_one :user
  has_one :kombucha

  validates_uniqueness_of [:user_id, :kombucha_id]

  validates :score, inclusion: { in: (1..5).to_a }

  def self.average_for_kombucha(kombucha_id)
    Rating.average(:score).where(kombucha_id: kombucha_id)
  end
end
