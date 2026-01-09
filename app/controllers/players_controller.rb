class PlayersController < ApplicationController
  def index
    # Get total played games (where played = true)
    @total_played_games = Game.where(played: true).count
    players = Player.includes(teams: :game).all

    @players_stats = players.map do |player|
      teams = player.teams
      # Only count games that were actually played
      games_played = teams.joins(:game).where(games: { played: true }).count
      wins = teams.where("result > 0").count
      draws = teams.where(result: 0).count
      losses = teams.where("result < 0").count
      total_result = teams.sum(:result)
      # Calculate frequency: how many played games the player participated in
      frequency = @total_played_games > 0 ? ((games_played.to_f / @total_played_games) * 100).round(1) : 0

      # Get last 5 played games with their teams, ordered by game date
      last_5_teams = teams.joins(:game).where(games: { played: true }).order("games.date DESC").limit(5)

      {
        player: player,
        games_played: games_played,
        wins: wins,
        draws: draws,
        losses: losses,
        total_result: total_result,
        frequency: frequency,
        last_5_teams: last_5_teams
      }
    end

    # Sort by wins (desc), then by total result (desc)
    @players_stats.sort_by! { |stat| [ -stat[:wins], -stat[:total_result] ] }
  end
end
