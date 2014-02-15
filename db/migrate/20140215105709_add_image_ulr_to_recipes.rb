class AddImageUlrToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :image_ulr, :string
  end
end
