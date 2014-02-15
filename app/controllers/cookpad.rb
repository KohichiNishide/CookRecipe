require 'open-uri'
require 'nokogiri'

class Cookpad
  def initialize(options={})
  end

  def get_recipe(uri)
    r = {}
    doc = Nokogiri::HTML(open('http://cookpad.com' << uri))
    r[:title] = doc.xpath('//*[@id="recipe-title"]/h1/text()').shift.content.strip
    r[:image] = doc.xpath('//*[@id="main-photo"]/img').shift.attributes['src'].value
    r[:summary] = doc.xpath('//*[@id="description"]/text()').shift.content.strip
    r[:servings_for] = doc.xpath('//*[@id="ingredients"]/div[1]/h3/div[1]/span[2]').shift.children.shift.content.strip.gsub(%r![()（）]!, '')
    r[:ingredients_list] = []
    doc.xpath('//*[@id="ingredients_list"]').children.each do |ingredient|
      next if ingredient.xpath('div[1]/span').empty?
      r[:ingredients_list] << {:name => ingredient.xpath('div[1]/span').children.shift.content, :quantity => ingredient.xpath('div[2]').children.shift.content}
    end
    r[:steps] = []
    doc.xpath('//*[@id="steps"]').children.each do |step|
      next if step.xpath('dl/dt/h3').empty?
      r[:steps] << {:step => step.xpath('dl/dt/h3').children.shift.content.strip, :instruction => step.xpath('dl/dd/p').children.shift.content.strip}
    end
    r
  end
end
