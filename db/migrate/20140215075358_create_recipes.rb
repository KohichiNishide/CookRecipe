class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :title
      t.string :ulr
      t.string :summary
      t.binary :image_data
      t.integer :num_tsukurepo

      t.timestamps
    end
  end
end
