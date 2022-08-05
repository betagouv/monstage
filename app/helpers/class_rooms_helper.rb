# frozen_string_literal: true

module ClassRoomsHelper
  def school_track_options_for_default
    '-- Veuillez choisir la filière de cette classe --'
  end

  def options_for_school_tracks
    school_tracks_hash_translated = {}
    ClassRoom.school_tracks.map do |key, val|
      next if current_user&.student? &&
              current_user.class_room.present? &&
              current_user.school_track != key

      school_tracks_hash_translated[tr_school_track(key)] = val
    end
    school_tracks_hash_translated
  end

  def tr_school_track(school_track)
    I18n.t("enum.school_tracks.#{school_track}")
  end
end
