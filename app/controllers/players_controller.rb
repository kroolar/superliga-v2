class PlayersController < ApplicationController
  def index
    @total_games = Game.count
    players = Player.includes(teams: :game).all

    @players_stats = players.map do |player|
      teams = player.teams
      games_played = teams.count
      wins = teams.where("result > 0").count
      draws = teams.where(result: 0).count
      losses = teams.where("result < 0").count
      total_result = teams.sum(:result)
      absence_rate = @total_games > 0 ? (((@total_games - games_played).to_f / @total_games) * 100).round(1) : 0

      # Get last 5 teams with their games, ordered by game date
      last_5_teams = teams.joins(:game).order("games.date DESC").limit(5)

      {
        player: player,
        games_played: games_played,
        wins: wins,
        draws: draws,
        losses: losses,
        total_result: total_result,
        absence_rate: absence_rate,
        last_5_teams: last_5_teams
      }
    end

    # Sort by wins (desc), then by total result (desc)
    @players_stats.sort_by! { |stat| [ -stat[:wins], -stat[:total_result] ] }
  end
end
