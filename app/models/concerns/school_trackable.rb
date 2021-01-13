module SchoolTrackable
  extend ActiveSupport::Concern

  included do
    enum school_track: {
      troisieme_generale: 'troisieme_generale',
      troisieme_prepa_metier: 'troisieme_prepa_metier',
      troisieme_segpa: 'troisieme_segpa',
      bac_pro: 'bac_pro'
    }

    validates :school_track, presence: true
  end
end
