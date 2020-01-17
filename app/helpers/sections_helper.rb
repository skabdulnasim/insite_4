module SectionsHelper

  def get_section_details(section_id)
    Section.find(section_id)
  end

  def simple_tax_classes
    TaxClass.where(:tax_type => "simple")
  end

  def added_tax_classes(section)
    saved_section_tax_classes_id = Array.new
    section.tax_classes.uniq.each do |tax_class|
      saved_section_tax_classes_id.push tax_class[:id]
    end
    return saved_section_tax_classes_id
  end
end
