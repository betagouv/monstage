include ActionView::Helpers::TagHelper
include ActionView::Context
module Presenters
  class InternshipOffer

    def weeks_boundaries
      "Du #{I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy)}" \
      " au #{I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy)}"
    end

    def weeks_summary
      free_weeks = InternshipOfferWeek.free_weeks_on_school_year( internship_offer: internship_offer )
      { weeks_count: free_weeks.size,
        weeks_list: Presenters::WeekList.new(weeks: free_weeks)
      }
    end

    def address
      "#{internship_offer.street}, #{internship_offer.zipcode} #{internship_offer.city}"
    end

    def entreprise
      name = internship_offer.employer_name
      internship_offer.is_public ? "administration publique '#{name}'" : "entreprise '#{name}'"
    end

    def remaining_seats
      count = internship_offer.remaining_seats_count
      "#{count} #{"place".pluralize(count)}"
    end

    def internship_week_description
      internship_offer.weekly_planning? ? internship_weekly_description : internship_daily_description
    end

    def internship_weekly_description
      hours = internship_offer.weekly_hours
      lunch_break = internship_offer.weekly_lunch_break
      daily_schedule = [ "#{hours[0]} à #{hours[1]}".gsub!(':', 'h') ]

      content_tag(:div,
        content_tag(:div, "#{daily_schedule.join(', ')}", class: 'fr-tag fr-icon-calendar-fill fr-tag--icon-left'),
        class: 'fr-mb-2w'
       ) +
      content_tag(:div, "Pause déjeuner : #{lunch_break}", class: 'fr-mb-3w') if lunch_break.present?
    end

    def internship_daily_description
      hours = internship_offer.weekly_hours
      %w(lundi mardi mercredi jeudi vendredi).map do |day|
        internship_offer.daily_hours&.[](day) || []
        lunch_break = internship_offer.daily_lunch_break[day]
        next if hours.blank? || hours.size != 2
        daily_schedule = [ "de #{hours[0]} à #{hours[1]}".gsub!(':', 'h') ]

        content_tag(:div,
          content_tag(:div, "#{day.capitalize} : #{daily_schedule.join(', ')}", class: 'fr-tag fr-icon-calendar-fill fr-tag--icon-left'),
          class: 'fr-mb-2w'
         ) +
        content_tag(:div, "Pause déjeuner : #{lunch_break}", class: 'fr-mb-3w') if lunch_break.present?
      end.join.html_safe
    end

    private

    attr_reader :internship_offer

    def free_weeks
      week_ids = InternshipOfferWeek.joins(:internship_offer)
                                    .where(internship_offer: internship_offer)
                                    .where.not(blocked_applications_count: internship_offer.max_students_per_group)
                                    .where(week_id: Week.selectable_on_school_year.ids.to_a)
                                    .pluck(:week_id)
      Week.where(id: week_ids)
    end

    def initialize(internship_offer)
      @internship_offer = internship_offer
    end

  end
end