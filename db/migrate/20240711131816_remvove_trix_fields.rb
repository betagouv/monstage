class RemvoveTrixFields < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :resume_educational_background, :text
    add_column :users, :resume_other, :text
    add_column :users, :resume_languages, :text

    add_column :organisations, :employer_description, :text
    add_column :internship_offers, :employer_description, :text

    add_column :internship_agreements, :activity_preparation, :text
  end
end
