module ApplicationHelper

	def error_tag(model, attribute)
		if model.errors.has_key? attribute
			content_tag(:div, model.errors[attribute].first, :class => 'error_message')
		else
			content_tag(:div, "", :class => 'error_message')
		end
	end

	def create_nav_link(path, text, controller, glyph)
		params[:controller] == controller ? c = "active" : c = ""
		content_tag :li, class: "#{c}" do
			link_to path do
				content_tag(:span, "", class: "glyphicon #{glyph}") +
					"    #{text}"
			end
		end 
	end

end

