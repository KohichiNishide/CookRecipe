class AddColumsToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :kind, :string
  end
end
