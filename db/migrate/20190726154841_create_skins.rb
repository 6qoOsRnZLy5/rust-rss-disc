class CreateSkins < ActiveRecord::Migration[5.2]
  def change
    create_table :skins do |t|
      t.references :feed, foreign_key: true
      t.string :gameid
      t.string :skinid
      t.string :steamlink
      t.string :steampic
      t.string :name
      t.string :price_chf
      t.string :price_eur
      t.string :price_usd
      t.string :price_aud
      t.string :price_eur
      t.integer :status, default: 1

      t.timestamps
    end
  end
end
