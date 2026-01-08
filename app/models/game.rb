class Game < ApplicationRecord
  has_many :teams, dependent: :destroy
end
