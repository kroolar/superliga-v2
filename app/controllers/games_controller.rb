class GamesController < ApplicationController
  def index
    @played_games = Game.where(played: true).order(date: :desc).includes(teams: :players)
    @upcoming_games = Game.where(played: false).order(date: :asc).includes(teams: :players)
  end

  def show
    @game = Game.includes(teams: :players).find(params[:id])
  end

  def generate_teams
    @game = Game.find(params[:id])
    # Logic for generating teams will be implemented later
    redirect_to @game, notice: "Teams generation functionality coming soon"
  end
end
