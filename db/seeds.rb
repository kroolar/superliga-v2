def generate_games
  # Generate games for every Monday of 2026
  start_date = Date.new(2026, 1, 1)
  end_date = Date.new(2026, 12, 31)

  # Find the first Monday of the year
  current_date = start_date
  current_date += 1 until current_date.monday?

  # Create games for every Monday
  while current_date <= end_date
    Game.find_or_create_by!(date: current_date.to_datetime)

    current_date += 7.days
  end

  puts "Created #{Game.count} games for 2026"
end

def generate_players
  [
    { name: 'Bartek', power: 100 },
    { name: 'Adrian', power: 95 },
    { name: 'Mirek', power: 85 },
    { name: 'Mariusz', power: 80 },
    { name: 'Grzesiek', power: 80 },
    { name: 'Fasol', power: 75 },
    { name: 'Artur', power: 75 },
    { name: 'Jacek', power: 65 },
    { name: 'Krzysztof', power: 65 },
    { name: 'Bogdan', power: 55 },
    { name: 'Krzysztof B.', power: 50 },
    { name: 'Darek', power: 40 },
    { name: 'Tomek', power: 40 },
    { name: 'Adam', power: 20 }
  ].each do |player_data|
    player = Player.find_or_create_by!(name: player_data[:name])
    player.power = player_data[:power]
    player.save!
  end

  puts "Created #{Player.count} players"
end

generate_games
generate_players

# # Mark first game as played and set up teams with players
# first_game = Game.first
# first_game.update!(played: true)

# teams = first_game.teams

# [ 'Adrian', 'Artur', 'Tomek', 'Darek', 'Fasol' ].each do |player_name|
#   player = Player.find_by(name: player_name)
#   team = teams.first
#   team.players << player unless team.players.include?(player)
#   team.result = -5
#   team.save!
# end

# [ 'Bartek', 'Adam', 'Krzysztof', 'Krzysztof B.', 'Jacek' ].each do |player_name|
#   player = Player.find_by(name: player_name)
#   team = teams.last
#   team.players << player unless team.players.include?(player)
#   team.result = 5
#   team.save!
# end

# puts "Marked first game as played and assigned players to teams"
