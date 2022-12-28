class AddSurveyAnsweredToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :survey_answered, :boolean, default: false
  end
end
