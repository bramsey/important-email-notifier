module UsersHelper
  
  def gravatar_for(user, options = { :size => 50})
    gravatar_image_tag(user.email.downcase, :alt => user.name,
                                            :class => 'gravatar',
                                            :gravatar => options)
  end
  
  def show_reliability_for(user)
    case user.reliability_to(current_user)
    when "Reliable"
      content_tag(:span, :class => "reliable") { user.reliability_to(current_user) }
    when "Unreliable"
      content_tag(:span, :class => "unreliable") { user.reliability_to(current_user) }
    when "Insufficiently tested"
      content_tag(:span, :class => "untested") { user.reliability_to(current_user) }
    else
      content_tag(:span, :class => "unknown") { "Unknown" }
    end
  end
end
