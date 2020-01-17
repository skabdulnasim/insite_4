module TablesHelper
  def get_table_color(state)
    if state == 1
      "green"
    elsif state ==2
      "orange"
    elsif state ==3
      "purple"
    elsif state ==4
      "red"
    elsif state ==5
      "blue"
    elsif state ==6
      "grey"
    end
  end
end
