module UtilityManagement
  def self.get_cron_argument(days, times)
    @times = times.split(':')
    @string = "#{@times[1]} #{@times[0]} * * #{days}"
    return @string
  end
end