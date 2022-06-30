# frozen_string_literal: true

module ClassRoomsHelper
  def school_track_options_for_default
    '-- Veuillez choisir la classe --'
  end

  def options_for_school_tracks
    school_tracks_hash_translated = {}
    ClassRoom.school_tracks.map do |key, val|
      next if current_user&.student? &&
              current_user.class_room.present? &&
              current_user.school_track != key

      school_tracks_hash_translated['3e'] = val
    end
    school_tracks_hash_translated
  end
end
