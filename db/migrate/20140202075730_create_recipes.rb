class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.binary :data

      t.timestamps
    end
  end
end
