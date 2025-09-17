module ApplicationHelper
  def dynamic_favicon
    if user_signed_in? && current_user.company_level_user? && current_user.company.has_icon?
      current_user.company.display_icon_url
    else
      '/icon.png'
    end
  end

  def page_title_with_company
    title = content_for(:page_title) || "Dashboard"
    if user_signed_in? && current_user.company_level_user?
      "#{title} - #{current_user.company.name}"
    elsif user_signed_in? && current_user.sysadmin?
      "#{title} - SysAdmin"
    else
      title
    end
  end
end
