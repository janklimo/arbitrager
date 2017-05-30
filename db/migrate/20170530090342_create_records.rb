class CreateRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :records do |t|
      t.float :price_bx_thb
      t.float :price_kraken_usd
      t.float :price_kraken_thb
      t.float :difference_thb
      t.float :exchange_rate

      t.timestamps
    end
  end
end
