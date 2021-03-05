# frozen_string_literal: true

module Reporting
  class Kpi
    def student_funnel_goal
      @student_funnel_goal ||= {
        total: Users::Student.count,
        confirmed: Users::Student.where.not(confirmed_at: nil).count
      }
    end

    def school_manager_funnel_goal
      @school_manager_funnel_goal ||= {
        total: School.count,
        with_school_manager: School.joins(:users).where(users: { type: Users::SchoolManagement.name }).count
      }
    end

    private

    def initialize; end
  end
end
