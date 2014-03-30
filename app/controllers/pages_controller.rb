# coding: utf-8

class PagesController < ApplicationController
  layout 'amelia'
  def index
    @recipes = Recipe.find(:all, :order => "num_tsukurepo DESC")
  end

  def get_recipe
    recipe_scraping = RecipeScraping.new
    @categories = YAML.load_file("data/recipe_category.yml")
    @categories.each{|category|
      #Rails.logger.debug(category["category_name"]);
      #Rails.logger.debug(category["cookpad"]);
      #Rails.logger.debug(category["rakuten"]);
      category_name = category["category_name"]
      #recipe_scraping.get_cookpad_recipe(category_name, category["cookpad"].to_s)
      recipe_scraping.get_rakuten_recipe(category_name, category["rakuten"])
    }
  end

  def show_category

  end
end
