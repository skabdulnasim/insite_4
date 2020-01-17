module DateLimit
  def self.included(target)
    #puts "included into #{target}"
    target.class_eval do
      default_scope { where(:created_at => Time.now - 3.months .. Time.now) }
    end
  end
end