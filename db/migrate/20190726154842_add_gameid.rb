class AddGameid < ActiveRecord::Migration[5.2]
    def change
        add_column :feeds, :gameid, :string
    end
end
