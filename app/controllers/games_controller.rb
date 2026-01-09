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

  def regenerate_teams
    @game = Game.find(params[:id])

    # Delete existing teams and their players
    @game.teams.destroy_all

    # Mark game as not played
    @game.update!(played: false)

    # Create 2 new empty teams
    2.times { @game.teams.create! }

    redirect_to generate_teams_game_path(@game), notice: "Drużyny zostały zresetowane"
  end

  def update_result
    @game = Game.find(params[:id])

    # Update location if provided
    @game.location = params[:game][:location] if params[:game][:location].present?

    # Update team results
    if params[:team_a_result].present? && params[:team_b_result].present?
      team_a = @game.teams.first
      team_b = @game.teams.last

      team_a.update!(result: params[:team_a_result].to_i)
      team_b.update!(result: params[:team_b_result].to_i)

      # Mark game as played
      @game.update!(played: true)

      redirect_to game_path(@game), notice: "Wynik został zapisany"
    else
      redirect_to game_path(@game), alert: "Proszę podać wyniki dla obu drużyn"
    end
  end

  def create_teams
    @game = Game.find(params[:id])

    # Get enabled players and goalkeepers from params
    enabled_player_ids = params[:enabled_players]&.map(&:to_i) || []
    goalkeeper_ids = params[:goalkeepers]&.map(&:to_i) || []

    if enabled_player_ids.empty?
      redirect_to generate_teams_game_path(@game), alert: "Proszę wybrać zawodników"
      return
    end

    team_a_players = []
    team_b_players = []

    loop do
      team_a_players, team_b_players = shuffle(enabled_player_ids, goalkeeper_ids)

      # Calculate power excluding goalkeepers
      team_a_power = team_a_players.reject { |p| goalkeeper_ids.include?(p.id) }.sum(&:power)
      team_b_power = team_b_players.reject { |p| goalkeeper_ids.include?(p.id) }.sum(&:power)

      power_diff = ((team_a_power / team_a_players.size) - (team_b_power / team_b_players.size)).abs

      break if power_diff <= 5
    end

    # Delete existing teams
    @game.teams.destroy_all

    # Mark game as not played (in case of regeneration)
    @game.update!(played: false)

    # Create 2 teams
    team_a = @game.teams.create!
    team_b = @game.teams.create!

    # Assign players to teams with goalkeeper flag
    team_a_players.each do |player|
      TeamPlayer.create!(
        team: team_a,
        player: player,
        goalkeeper: goalkeeper_ids.include?(player.id)
      )
    end

    team_b_players.each do |player|
      TeamPlayer.create!(
        team: team_b,
        player: player,
        goalkeeper: goalkeeper_ids.include?(player.id)
      )
    end

    redirect_to game_path(@game), notice: "Drużyny zostały wygenerowane"
  end

  def shuffle(enabled_player_ids, goalkeeper_ids)
    all_players = Player.where(id: enabled_player_ids).to_a
    goalkeepers = all_players.select { |p| goalkeeper_ids.include?(p.id) }
    field_players = all_players.reject { |p| goalkeeper_ids.include?(p.id) }.shuffle

    team_a_players = []
    team_b_players = []

    # Distribute goalkeepers first - one to each team
    goalkeepers.each_with_index do |gk, index|
      if index.even?
        team_a_players << gk
      else
        team_b_players << gk
      end
    end

    # Then distribute field players alternately
    field_players.each_with_index do |player, index|
      if index.even?
        team_a_players << player
      else
        team_b_players << player
      end
    end

    [ team_a_players, team_b_players ]
  end
end
