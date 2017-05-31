class AddTickerToRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :records, :ticker, :integer, null: false, default: 0
    add_index :records, :ticker
  end
end
