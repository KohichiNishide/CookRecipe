# encoding: utf-8

#!/usr/bin/env ruby
# -*- mode:ruby; coding:utf-8 -*-
require 'anemone'
require 'rubygems'
require "open-uri"
require "fileutils"

class RecipeScraping
  def initialize(options={})
  end

  def get_cookpad_recipe
    category_url = "http://cookpad.com/category/168"
    # Get page number of the category
    category_doc = Nokogiri::HTML(open(category_url))
    page_info = category_doc.xpath('//*[@id="mini_paginate"]/span/text()').shift.content.strip
    page_info_i = page_info.gsub(/[^0-9]/,"")
    page_number = page_info_i[1, page_info_i.length].to_i

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
            sleep(1)
            begin
                recipe = {}
                recipe[:ulr] = page.url.to_s
                recipe[:title] = page.doc.xpath('//*[@id="recipe-title"]/h1/text()').shift.content.strip if page.doc
                recipe[:image_ulr] = page.doc.xpath('//*[@id="main-photo"]/img').shift.attributes['src'].value
                recipe[:summary] = page.doc.xpath('//*[@id="description"]/text()').shift.content.strip
                recipe[:servings_for] = page.doc.xpath('//*[@id="ingredients"]/div[1]/h3/div[1]/span[2]').shift.children.shift.content.strip.gsub(%r![()（）]!, '')
                recipe[:ingredients_list] = []
                page.doc.xpath('//*[@id="ingredients_list"]').children.each do |ingredient|
                  next if ingredient.xpath('div[1]/span').empty?
                  recipe[:ingredients_list] << {:name => ingredient.xpath('div[1]/span').children.shift.content, :quantity => ingredient.xpath('div[2]').children.shift.content}
                end
                recipe[:steps] = []
                page.doc.xpath('//*[@id="steps"]').children.each do |step|
                  next if step.xpath('dl/dt/h3').empty?
                  recipe[:steps] << {:step => step.xpath('dl/dt/h3').children.shift.content.strip, :instruction => step.xpath('dl/dd/p').children.shift.content.strip}
                end
                recipe[:num_tsukurepo] = page.doc.xpath('//*[@id="tsukurepo"]/div[1]/div[1]/span[1]').shift.content.strip
            rescue
                next
            end
            recipes << recipe
        end
      end
    }
    save_recipes(recipes, "オムライス", "cookpad")
  end

  def get_rakuten_recipe
    category_url = "http://recipe.rakuten.co.jp/category/14-121/"
    # Get page number of the category
    category_doc = Nokogiri::HTML(open(category_url))
    page_info = category_doc.xpath('//*[@class="countBox02 clearfix"]/div[2]/ul/li[7]').shift.content.strip
    page_number = page_info.gsub(/[^0-9]/,"").to_i

    opts = {
        :skip_query_strings => false,
        :depth_limit => 1,
    }
    recipes = []
    page_number.times { |number|
        recipe_url = category_url + "/" + number.to_s
        Anemone.crawl(recipe_url, opts) do |anemone|
            anemone.focus_crawl do |page|
                page.links.keep_if { |link|
                    link.to_s.include?("/recipe/")
                }
            end
            anemone.on_every_page do |page|
                sleep(1)
                begin
                    recipe = {}
                    recipe[:ulr] = page.url.to_s
                    recipe[:title] = page.doc.xpath('//*[@property="og:title"]/@content').shift.content.strip if page.doc
                    recipe[:image_ulr] = page.doc.xpath('//*[@property="og:image"]/@content').shift.content.strip
                    recipe[:summary] = page.doc.xpath('//*[@property="og:description"]/@content').shift.content.strip
                    recipe[:servings_for] = page.doc.xpath('//*[@class="detailArea"]/div[1]/div[1]/div[3]/div[1]/h3/span[1]').shift.children.shift.content.strip.gsub(%r![()（）]!, '')
                    recipe[:ingredients_list] = []
                    page.doc.xpath('//*[@class="detailArea"]/div[1]/div[1]/div[3]/ul').children.each do |ingredient|
                        next if ingredient.xpath('p[2]').empty?
                        recipe[:ingredients_list] << {:name => ingredient.xpath('p[1]/a').children.shift.content.strip, :quantity => ingredient.xpath('p[2]').children.shift.content.strip}
                    end
                    recipe[:steps] = []
                    page.doc.xpath('//*[@class="howtoArea"]/div[1]/ul').children.each do |step|
                      next if step.xpath('h4').empty?
                      recipe[:steps] << {:step => step.xpath('h4').children.shift.content.strip, :instruction => step.xpath('p').children.shift.content.strip}
                    end
                    recipe[:num_tsukurepo] = page.doc.xpath('//*[@class="rcpRepoCont"]/div[1]/div[1]/div[1]/h2/span[1]').shift.content.strip
                rescue
                    next
                end
                recipes << recipe
              end
          end
        }
    save_recipes(recipes, "オムライス", "rakuten")
  end

  def save_recipes(recipes, kind_recipe, site)
    recipes.each do |r|
      recipe = Recipe.new
      recipe.kind = kind_recipe
      recipe.title = r[:title]
      recipe.ulr = r[:ulr]
      recipe.image_ulr = save_image(r[:image_ulr])
      recipe.summary = r[:summary]
      recipe.servings_for = r[:servings_for]
      recipe.ingredients_list = r[:ingredients_list]
      recipe.steps = r[:steps]
      recipe.site = site
      recipe.num_tsukurepo = r[:num_tsukurepo]
      begin
        recipe.save
      rescue
      end
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
end
