module PagesHelper
  def db_image_tag(id, options={})
    image_tag("/pages/#{id}", options)
  end
end
