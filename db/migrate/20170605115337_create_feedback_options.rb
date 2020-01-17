class CreateFeedbackOptions < ActiveRecord::Migration
  def change
    create_table :feedback_options do |t|
      t.string :option_title

      t.timestamps
    end
  end
end
