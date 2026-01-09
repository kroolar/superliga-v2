class GamesController < ApplicationController
  def index
    @games = Game.order(date: :asc).includes(teams: :players)
  end

  def show
    @game = Game.includes(teams: :players).find(params[:id])
  end

  def generate_teams
    @game = Game.find(params[:id])
    @players = Player.order(:name)
  end
end
