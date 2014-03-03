# encoding: utf-8

# coding: utf-8
require 'anemone'
require 'rubygems'
require "open-uri"
require "fileutils"

class PagesController < ApplicationController
  layout 'amelia'
  def index
    show_all
  end

  def get_recipe
    category_url = "http://cookpad.com/category/168"
    page_number = 29

    opts = {
      :skip_query_strings => false,
      :depth_limit => 1,
    }

    recipes = []

    page_number.times { |number|
      recipe_url = category_url + "?page=" + number.to_s
      Anemone.crawl(recipe_url, opts) do |anemone|
        anemone.focus_crawl do |page|
            page.links.keep_if { |link|
                link.to_s.match(/recipe/)
            }
        end
        anemone.on_every_page do |page|
            begin
                r = {}
                r[:ulr] = page.url.to_s
                r[:title] = page.doc.xpath('//*[@id="recipe-title"]/h1/text()').shift.content.strip if page.doc
                r[:image_ulr] = page.doc.xpath('//*[@id="main-photo"]/img').shift.attributes['src'].value
                r[:summary] = page.doc.xpath('//*[@id="description"]/text()').shift.content.strip
                r[:servings_for] = page.doc.xpath('//*[@id="ingredients"]/div[1]/h3/div[1]/span[2]').shift.children.shift.content.strip.gsub(%r![()（）]!, '')
                r[:ingredients_list] = []
                page.doc.xpath('//*[@id="ingredients_list"]').children.each do |ingredient|
                  next if ingredient.xpath('div[1]/span').empty?
                  r[:ingredients_list] << {:name => ingredient.xpath('div[1]/span').children.shift.content, :quantity => ingredient.xpath('div[2]').children.shift.content}
                end
                r[:steps] = []
                page.doc.xpath('//*[@id="steps"]').children.each do |step|
                  next if step.xpath('dl/dt/h3').empty?
                  r[:steps] << {:step => step.xpath('dl/dt/h3').children.shift.content.strip, :instruction => step.xpath('dl/dd/p').children.shift.content.strip}
                end
                r[:num_tsukurepo] = page.doc.xpath('//*[@id="tsukurepo"]/div[1]/div[1]/span[1]').shift.content.strip
            rescue
                next
            end
            recipes << r
        end
      end
    }
    #puts recipes
    recipes.each do |r|
      recipe = Recipe.new
      recipe.kind = "オムライス"
      recipe.title = r[:title]
      recipe.ulr = r[:ulr]
      recipe.image_ulr = save_image(r[:image_ulr])
      recipe.summary = r[:summary]
      recipe.servings_for = r[:servings_for]
      recipe.ingredients_list = r[:ingredients_list]
      recipe.steps = r[:steps]
      recipe.site = "cookpad"
      recipe.num_tsukurepo = r[:num_tsukurepo]
      recipe.save
    end
  end

  def save_image(url)
    # ready filepath
    fileName = File.basename(url)
    newFileName = fileName.split('?')
    dirName = "./app/assets/images/"
    filePath = dirName + newFileName[0]

    # create folder if not exist
    FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)

    # write image adata
    open(filePath, 'wb') do |output|
        open(url) do |data|
            output.write(data.read)
        end
    end
    newFileName[0]
  end

  def show
    recipe = Recipe.find params[:id]
    send_data recipe.image_data, :type => "image/jpeg", :disposition => "inline"
  end

  def show_all
    @recipes = Recipe.find(:all, :order => "num_tsukurepo DESC")
  end
end
