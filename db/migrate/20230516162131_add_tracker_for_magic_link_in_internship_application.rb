class AddTrackerForMagicLinkInInternshipApplication < ActiveRecord::Migration[7.0]
  def change
    # 0: Not sent
    # 1: used
    # 2: expired
    add_column :internship_applications, :magic_link_tracker, :integer, default: 0
  end
end
