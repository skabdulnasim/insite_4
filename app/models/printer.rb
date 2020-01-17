class Printer < ActiveRecord::Base
  attr_accessible :assignable_id, :assignable_type, :ip, :name, :unit_id

  belongs_to :assignable, polymorphic: true
  belongs_to :unit
  validates :ip, :format => { :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex), message: "%{value} is reserved." }
  

  scope :check_printer_unit,              lambda {|current_unit|where(["unit_id =(?)", current_unit])}


  def self.exchange_printer_ip(from_printer_id, to_printer_id)
    _from_printer = Printer.find(from_printer_id)
    _to_printer = Printer.find(to_printer_id)
    _to_printer[:ip] = _from_printer[:ip]
    if _to_printer.save
      return _to_printer
    else
      return 0
    end
  end

  def self.save_printer(printer_params,assignable_ids,printer_id=nil)
    @printer = Printer.find(printer_id) if printer_id.present?
    _exist_assignable_id = @printer.assignable_id if printer_id.present?
    assignable_type = printer_params[:assignable_type]
    assignable_ids.each do |assignable_id|
      if printer_id.present? && _exist_assignable_id.to_i == assignable_id.to_i
        @printer.update_attributes(printer_params)
      else
        assignable = assignable_type.capitalize.classify.constantize.find(assignable_id)
        printer_params[:assignable_id] = assignable_id
        @printer = assignable.printers.new(printer_params)
        @printer.save
      end
    end
    if @printer.save || @printer.update_attributes(printer_params)
      return true
    else
      return false
    end

  end

  def self.current_unit_printers(_model_name, unit_id)
    # _model_name.find(:all, :conditions => ["unit_id =(?)", unit_id])
    _model_name.where(:unit_id => unit_id)
  end
end
