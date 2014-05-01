class AddRowsTable < ActiveRecord::Migration
  def change
    create_table :rows do |t|
      t.string :content
    end
  end
end
