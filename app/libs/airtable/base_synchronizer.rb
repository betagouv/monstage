# frozen_string_literal: true
module Airtable
  class BaseSynchronizer

    # main job, with some safe stuffs
    def pull_all
      # ActiveRecord::Base.transaction do
      #   Operator.where(airtable_reporting_enabled: true).map do |operator|
      #     AirTable::TableSynchronizer.new(app_id: operator.airtable_app_id, table: operator.airtable_table)
      #                                .pull_all
      #   end
      # end
    end
  end
end
