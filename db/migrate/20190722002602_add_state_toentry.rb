class AddStateToentry < ActiveRecord::Migration[5.2]
    def change
        add_column :entries, :status, :integer , default: 1
        add_column :entries, :author, :string
        add_column :entries, :published_at, :string
    end
end