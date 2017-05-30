class AddPriceDifferencePercentageToRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :records, :difference_percentage, :float
  end
end
