class PlayersController < ApplicationController
  def index
    # Get total played games (where played = true)
    @total_played_games = Game.where(played: true).count
    players = Player.includes(teams: { game: :teams }).all

    @players_stats = players.map do |player|
      teams = player.teams.includes(game: :teams)
      # Only count games that were actually played
      played_teams = teams.joins(:game).where(games: { played: true })
      games_played = played_teams.count

      # Calculate actual results considering opponent scores
      wins = 0
      draws = 0
      losses = 0
      total_result = 0

      played_teams.each do |team|
        game = team.game
        opponent_team = game.teams.where.not(id: team.id).first

        if team.result.nil? || opponent_team.nil? || opponent_team.result.nil?
          next
        end

        team_score = team.result
        opponent_score = opponent_team.result

        # Determine actual result based on both team scores
        if team_score == 0 && opponent_score == 0
          # True draw
          draws += 1
          total_result += 0
        elsif team_score == 0 && opponent_score > 0
          # Lost (opponent won)
          losses += 1
          total_result -= opponent_score
        elsif team_score > 0 && opponent_score == 0
          # Won
          wins += 1
          total_result += team_score
        elsif team_score > opponent_score
          # Won
          wins += 1
          total_result += team_score
        elsif team_score < opponent_score
          # Lost
          losses += 1
          total_result += team_score # team_score is already negative or less
        else
          # Draw (equal positive scores)
          draws += 1
          total_result += 0
        end
      end

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
