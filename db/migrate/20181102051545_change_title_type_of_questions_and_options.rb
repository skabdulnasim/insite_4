class ChangeTitleTypeOfQuestionsAndOptions < ActiveRecord::Migration

	def change
  	change_column :questions, :title, :text
  	change_column :options, :title, :text
  end

end