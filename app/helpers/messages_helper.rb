module MessagesHelper
  
  def wrap(content)
    sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
  end
  
  def display_urgency(message)
    case message.urgency
    when 1
      content_tag(:span, :class => "urgent1") { "Immediate" }
    when 2
      content_tag(:span, :class => "urgent2") { "Today" }
    when 3
      content_tag(:span, :class => "urgent3") { "This week" }
    else
      "Not urgent"
    end
  end
  
  def agree_link( message )
    link_to 'agree', agree_message_path(message), 
			:method => "post", :class => "agree"
	end
	
	def disagree_link( message )
	  link_to 'disagree', disagree_message_path(message), 
			:method => "post", :class => "disagree"
	end
	
  private

    def wrap_long_string(text, max_width = 30)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : 
                                  text.scan(regex).join(zero_width_space)
    end
end
