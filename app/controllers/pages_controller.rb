# encoding: utf-8

# coding: utf-8

class PagesController < ApplicationController
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
      recipe_scraping.get_cookpad_recipe(category_name, category["cookpad"].to_s)
      recipe_scraping.get_rakuten_recipe(category_name, category["rakuten"])
    }
  end

  def show_category
    @id = params[:id]
    case @id
    when '1270' then #たけのこ
      @recipes = Recipe.where(:kind => "たけのこ").order("num_tsukurepo DESC").limit(50)
    when '1272' then #アスパラガス
      @recipes = Recipe.where(:kind => "アスパラガス").order("num_tsukurepo DESC").limit(50)
    when '1274' then #グリーンピース
      @recipes = Recipe.where(:kind => "グリーンピース").order("num_tsukurepo DESC").limit(50)
    when '1276' then #さやえんどう
      @recipes = Recipe.where(:kind => "さやえんどう").order("num_tsukurepo DESC").limit(50)
    when '1278' then #そら豆
      @recipes = Recipe.where(:kind => "そら豆").order("num_tsukurepo DESC").limit(50)
    when '522' then #新たまねぎ
      @recipes = Recipe.where(:kind => "新たまねぎ").order("num_tsukurepo DESC").limit(50)
    when '520' then #新じゃがいも
      @recipes = Recipe.where(:kind => "新じゃがいも").order("num_tsukurepo DESC").limit(50)
    when '1271' then #アボカド
      @recipes = Recipe.where(:kind => "アボカド").order("num_tsukurepo DESC").limit(50)
    when '525' then #レタス
      @recipes = Recipe.where(:kind => "レタス").order("num_tsukurepo DESC").limit(50)
    when '1430' then #ふき
      @recipes = Recipe.where(:kind => "ふき").order("num_tsukurepo DESC").limit(50)
    else
    end
  end

  def contact
  end
end
