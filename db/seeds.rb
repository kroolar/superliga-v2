def generate_games
  # Generate games for every Monday of 2026
  start_date = Date.new(2026, 1, 1)
  end_date = Date.new(2026, 12, 31)

  # Find the first Monday of the year
  current_date = start_date
  current_date += 1 until current_date.monday?

  # Create games for every Monday
  while current_date <= end_date
    game = Game.find_or_create_by!(date: current_date.to_datetime)

    # Create 2 teams for each game if they don't exist
    if game.teams.count < 2
      (2 - game.teams.count).times do
        game.teams.create!
      end
    end

    current_date += 7.days
  end

  puts "Created #{Game.count} games for 2026"
end

def generate_players
  [
   'Adrian', 'Adam', 'Bartek', 'Krzysztof', 'Krzysztof B.', 'Artur',
   'Darek', 'Fasol', 'Grzesiek', 'Tomek', 'Mirek', 'Jacek', 'Mariusz', 'Bogdan'
  ].each do |name|
    Player.find_or_create_by!(name:)
  end

  puts "Created #{Player.count} players"
end

generate_games
generate_players

teams = Game.first.teams

[ 'Adrian', 'Artur', 'Tomek', 'Darek', 'Fasol' ].each do |player_name|
  player = Player.find_by(name: player_name)
  team = teams.first
  team.players << player
  team.result = -5
  team.save!
end

[ 'Bartek', 'Adam', 'Krzysztof', 'Krzysztof B.', 'Jacek' ].each do |player_name|
  player = Player.find_by(name: player_name)
  team = teams.last
  team.players << player
  team.result = 5
  team.save!
end
