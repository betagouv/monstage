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

    def last_week_kpis(last_monday: , last_sunday:)
      subscriptions = recent_subscriptions(
        last_monday: last_monday,
        last_sunday: last_sunday
      )
      applications_count, student_applyers_count = recent_applications(
        last_monday: last_monday,
        last_sunday: last_sunday
      )
      offers_count, seats_count = internship_offers_count

      {
        subscriptions: subscriptions,
        applications_count: applications_count,
        student_applyers_count: student_applyers_count,
        offers_count: offers_count,
        seats_count: seats_count
      }
    end

    private

    def recent_subscriptions(last_monday: , last_sunday:)
      translator = Presenters::UserManagementRole
      subscriptions = User.select('type, count(type)')
                          .where('created_at >= ? ',last_monday)
                          .where('created_at <= ?', last_sunday)
                          .where.not(type: 'Users::SchoolManagement')
                          .group(:type)
                          .inject({}) { |hash, rec| hash[translator.human_types_and_roles(rec.type.to_sym)]= rec.count; hash}
      Users::SchoolManagement.select('role, count(role)')
                              .where('created_at >= ? ', last_monday)
                              .where('created_at <= ?', last_sunday)
                              .group(:role)
                              .inject(subscriptions) do |hash, rec|
                                hash[translator.human_types_and_roles(rec.role.to_sym)]= rec.count; hash
                              end
    end

    def recent_applications(last_monday: , last_sunday:)
      applications = InternshipApplication.where('created_at >= ? ', last_monday)
                                          .where('created_at <= ?', last_sunday)

      applications_students = applications.select('user_id, count(user_id)')
                                          .group(:user_id)

      [applications.count, applications_students.pluck(:user_id).count]
    end

    def internship_offers_count
      offers = ::InternshipOffer.kept.in_the_future
      [offers.count, offers.pluck(:max_candidates).sum]
    end

    def initialize; end
  end
end
