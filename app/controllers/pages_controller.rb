# coding: utf-8

class PagesController < ApplicationController
  def index
  end

  def get_recipe
    cookpad = Cookpad.new
    @msg =  cookpad.get_recipe('/recipe/1012764')
  end

  def show
    recipe = Recipe.find params[:id]
    send_data recipe.data, :type => "image/jpeg", :disposition => "inline"
  end
end
