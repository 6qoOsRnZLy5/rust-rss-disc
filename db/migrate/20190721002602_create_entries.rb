class CreateEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :entries do |t|
      t.references :feed, foreign_key: true
      t.string :title
      t.text :description
      t.string :picture
      t.string :link1
      t.string :link2
      t.string :guid, unique: true

      t.timestamps
    end

  end
end
