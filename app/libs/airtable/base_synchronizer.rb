# frozen_string_literal: true
module Airtable
  class BaseSynchronizer

    # main job, with some safe stuffs
    def pull_all()
      synchronizers = Operator.reportable
                              .map { |operator| Airtable::TableSynchronizer.new(operator: operator) }

      pool = Concurrent::FixedThreadPool.new(synchronizers.size, fallback_policy: :abort)
      synchronizers.map do |synchronizer|
        pool.post do
          synchronizer.pull_all
        end
      end
      pool.shutdown
      pool.wait_for_termination
    end
  end
end
