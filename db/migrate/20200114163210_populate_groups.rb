# frozen_string_literal: true

class PopulateGroups < ActiveRecord::Migration[6.0]
  def change
    OldGroup::PUBLIC.each do |group_name|
      Group.find_or_create_by(name: group_name, is_public: true)
    end
    OldGroup::PRIVATE.each do |group_name|
      Group.find_or_create_by(name: group_name, is_public: false)
    end
  end
end
