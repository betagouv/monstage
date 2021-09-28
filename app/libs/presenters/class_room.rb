# frozen_string_literal: true

module Presenters
  # class or null object which avoids .try(:attribute) || 'default'
  module ClassRoom
    def self.or_null(class_room)
      return class_room if class_room

      Null.instance
    end

    def self.school_tracks_options
      general_track = ['Voie générale', [[self.tr_school_track('troisieme_generale'), :troisieme_generale]]]
      professional_track = ['Voie professionnelle', ::ClassRoom.school_tracks.keys.difference(['troisieme_generale']).collect {|tra| [self.tr_school_track(tra), tra]}]
      [general_track, professional_track]
    end

    def self.tr_school_track(track)
      I18n.t("enum.school_tracks.#{track}")
    end

    def self.with_school_tracks(school)
      school.class_rooms
            .current
            .includes([:students])
            .order(:name)
            .group_by { |c| c.school_track }
    end

    def self.students_without_class_room(school)
      school.students.without_class_room
    end

    class Null
      include Singleton
      def id
        'nil-class-room'
      end

      def name
        'Sans classe'
      end
    end
  end
end
