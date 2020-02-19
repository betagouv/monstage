# frozen_string_literal: true

class MigrateOldGroupToGroup < ActiveRecord::Migration[6.0]
  def change
    Group.all.each do |group|
      InternshipOffer.where(old_group: group.name).update_all(group_id: group.id)
    end
  end
end
