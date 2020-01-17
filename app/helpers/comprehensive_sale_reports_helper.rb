module ComprehensiveSaleReportsHelper

	def show_delivery_name_from_json(object)
		_deliverable_type = object.keys.first
    if ['Address','Customer'].include?(_deliverable_type.humanize)
      content_tag(:span, "#{_deliverable_type.humanize}")
    elsif ['Resource'].include?(_deliverable_type.humanize)
      content_tag(:span,"Resource: #{object[_deliverable_type]['name']}")
    else  
      content_tag(:span, "#{_deliverable_type.humanize}: #{object[_deliverable_type]['name']}")
    end
  end

end