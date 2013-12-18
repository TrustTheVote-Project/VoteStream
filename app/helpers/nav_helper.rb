module NavHelper

  def nav_link_to(label, url, options = {})
    link = link_to(label, url)
    content_tag(:li, link, class: (options[:controller] == params[:controller] ? "active" : nil))
  end

end
