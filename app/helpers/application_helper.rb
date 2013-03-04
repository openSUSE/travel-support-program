module ApplicationHelper
  def nav_tab(label, path)
    css = current_page?(path) ? "active" : nil
    content_tag(:li, link_to(t(label), path), :class => css)
  end
end
