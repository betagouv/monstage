module SchoolTrackable
  extend ActiveSupport::Concern

  included do
    enum school_track: {
      troisieme_generale: 'troisieme_generale',
      troisieme_prepa_metiers: 'troisieme_prepa_metiers',
      troisieme_segpa: 'troisieme_segpa'
    }

    validates :school_track, presence: true
  end
end
