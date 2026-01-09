class AddPowerToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :power, :integer
  end
end
