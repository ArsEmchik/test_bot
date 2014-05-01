class AddContenttextColumn < ActiveRecord::Migration
  def change
    add_column :rows, :content_text, :tsvector
  end
end
