class AddGoalkeeperToTeamPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :team_players, :goalkeeper, :boolean, default: false, null: false
  end
end
