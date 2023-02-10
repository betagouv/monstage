include ActionView::Helpers::TagHelper
include ActionView::Context    
module Presenters
  class InternshipOffer

    def weeks_boundaries
      "Du #{I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy)}" \
      " au #{I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy)}"
    end

    def remaining_seats
      count = internship_offer.remaining_seats_count
      "#{count} #{"place".pluralize(count)}"
    end

    def internship_week_description
      %w(lundi mardi mercredi jeudi vendredi).map do |day|
        if internship_offer.weekly_planning?
          hours = internship_offer.weekly_hours
          lunch_break = internship_offer.weekly_lunch_break
          daily_schedule = [ "de #{hours[0]} à #{hours[1]}".gsub!(':', 'h') ]
        else
          hours = internship_offer.new_daily_hours[day]
          lunch_break = internship_offer.daily_lunch_break[day]
          next if hours.blank? || hours.size != 2
          daily_schedule = [ "de #{hours[0]} à #{hours[1]}".gsub!(':', 'h') ]
        end
  
        content_tag(:div,
          content_tag(:div, "#{day.capitalize} : #{daily_schedule.join(', ')}", class: 'fr-tag fr-icon-calendar-fill fr-tag--icon-left'),
          class: 'fr-my-2w'
         ) +
        content_tag(:div, "Pause déjeuner : #{lunch_break}") if lunch_break.present?

      end.join.html_safe
    end

    private

    attr_reader :internship_offer

    def initialize(internship_offer)
      @internship_offer = internship_offer
    end

  end
end