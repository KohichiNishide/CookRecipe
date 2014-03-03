class RemoveColumesToRecipes < ActiveRecord::Migration
  def change
    remove_column :recipes, :servings_for, :string
    remove_column :recipes, :ingredients_list, :string
    remove_column :recipes, :steps, :string
  end
end
