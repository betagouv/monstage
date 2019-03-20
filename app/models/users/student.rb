module Users
  class Student < User
    belongs_to :school
    belongs_to :class_room, optional: true
    validates :first_name,
              :last_name,
              :birth_date,
              :gender,
              presence: true
    include NearbyIntershipOffersQueryable

    has_many :internship_applications, dependent: :destroy

    def age
      ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor
    end

    def to_s
      "#{super}, in school: #{school&.zipcode}"
    end
  end
end
