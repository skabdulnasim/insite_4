require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size => 14) do
	pdf.text_box "Date: #{params[:from_date]}", :at => [500, 70]
	pdf.move_down 200
	pdf.stroke do
		pdf.stroke_color 'EEEEEE'
		pdf.line_width 2
		pdf.stroke_horizontal_rule
	end
end
_pref = ["role","name","email","unit","sign in at","sign out at"]
_pref_humanize = _pref.map{|x| (x.humanize)}
data = [_pref_humanize]
@login_details.each do |login_detail|
	_row = Array.new
	_row.push(login_detail.user_role_name.humanize)
	_row.push(login_detail.user.profile.firstname + " " + login_detail.user.profile.lastname)
	_row.push(login_detail.user.email)
	_row.push(login_detail.user.unit.unit_name)
	_row.push(login_detail.sign_in_at.strftime("%Y-%b-%d %I:%M%p"))
	_row.push(login_detail.sign_out_at.present? ? login_detail.sign_out_at.strftime("%Y-%b-%d %I:%M%p") : "-")
	data += [_row]
end
pdf.table data, {:header => false, :width => 540} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  # table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end

