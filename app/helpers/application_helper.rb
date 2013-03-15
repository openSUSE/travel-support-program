module ApplicationHelper
  def nav_tab(label, path)
    css = current_page?(path) ? "active" : nil
    content_tag(:li, link_to(t(label), path), :class => css)
  end

  def country_label(country_code)
    country_code + " - " + I18n.t("countries.#{country_code}")
  end
end
