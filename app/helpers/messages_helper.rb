module MessagesHelper
  
  def wrap(content)
    sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
  end
  
  def display_urgency(message)
    case message.urgency
    when 1
      "Immediate"
    when 2
      "Today"
    when 3
      "This week"
    else
      "Not urgent"
    end
  end

  private

    def wrap_long_string(text, max_width = 30)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : 
                                  text.scan(regex).join(zero_width_space)
    end
end
