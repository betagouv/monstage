
module Presenters
  # class or null object which avoids .try(:attribute) || 'default'
  class AreaNotification
    def notified?
      area_notification.notify
    end

    def label
      "Notifications #{notified? ? 'activées' : 'désactivées'}"
    end

    def klasses
      klasses = 'fr-link fr-link--icon-left fr-mt-5w fr-raw-link'
      klasses = "#{klasses} fr-icon-volume-up-line" if notified?
      klasses = "#{klasses} fr-icon-volume-mute-fill" unless notified?
      klasses
    end

    def notif_parameters
      { internship_offer_area_id: internship_offer_area.id, id: area_notification.id }
    end

    attr_reader :area_notification, :internship_offer_area

    private

    def initialize(area_notification)
      @area_notification     = area_notification
      @internship_offer_area = @area_notification.internship_offer_area
    end
  end
end