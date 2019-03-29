module Users
  class Student < User
    belongs_to :school
    belongs_to :class_room, optional: true
    validates :first_name,
              :last_name,
              :birth_date,
              :gender,
              presence: true

    include TargetableInternshipOffersInSchool


    has_many :internship_applications, dependent: :destroy
    after_initialize :init
    def age
      ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor
    end

    def to_s
      "#{super}, in school: #{school&.zipcode}"
    end

    def init
      self.birth_date ||= 14.years.ago
    end
  end
end
