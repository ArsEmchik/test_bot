class CreateToken < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :token
    end
  end
end
