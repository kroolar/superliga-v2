class AddPlayedToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :played, :boolean, default: false, null: false
  end
end
