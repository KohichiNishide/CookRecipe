# coding: utf-8
require 'anemone'
require 'rubygems'
require "open-uri"
require "fileutils"

class PagesController < ApplicationController
  def index
  end

  def get_recipe
category_url = "http://cookpad.com/category/10"
page_number = 1

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
    recipe.title = r[:title]
    recipe.ulr = r[:ulr]
    recipe.image_ulr = save_image(r[:image_ulr])
    recipe.summary = r[:summary]
    recipe.num_tsukurepo = r[:num_tsukurepo]
    recipe.save
end
  end

def save_image(url)
    # ready filepath
    fileName = File.basename(url) + ".jpg"
    dirName = "/root/rails_projects/ryorigasusumu/app/app/assets/images/"
    filePath = dirName + fileName
    
    # create folder if not exist
    FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)
    
    # write image adata
    open(filePath, 'wb') do |output|
        open(url) do |data|
            output.write(data.read)
        end
    end
    filePath
end

  def show
    recipe = Recipe.find params[:id]
    send_data recipe.image_data, :type => "image/jpeg", :disposition => "inline"
  end
end
