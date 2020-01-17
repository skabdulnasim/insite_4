class AddImageToQuestionsAndOptions < ActiveRecord::Migration
  def change
  	add_attachment :questions, :image
  	add_attachment :options, :image
  end
end
