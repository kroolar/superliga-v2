class Game < ApplicationRecord
  has_many :teams, dependent: :destroy

  validates :teams, length: { is: 2 }
end
