class Recipe < ActiveRecord::Base
	serialize :servings_for
	serialize :ingredients_list
	serialize :steps
end
