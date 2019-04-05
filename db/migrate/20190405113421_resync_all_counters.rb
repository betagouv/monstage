class ResyncAllCounters < ActiveRecord::Migration[5.2]
  def change
    InternshipApplication.all.map(&:update_all_counters)
  end
end
