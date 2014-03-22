# coding: utf-8

class PagesController < ApplicationController
  layout 'amelia'
  def index
    @recipes = Recipe.find(:all, :order => "num_tsukurepo DESC")
  end

  def get_recipe
    recipe_scraping = RecipeScraping.new
    recipe_scraping.get_cookpad_recipe
    #recipe_scraping.get_rakuten_recipe
  end
end
