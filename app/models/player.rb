class Player < ApplicationRecord
  has_many :team_players, dependent: :destroy
  has_many :teams, through: :team_players
  has_many :games, through: :teams
end
