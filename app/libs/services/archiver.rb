module Services
  # Services::StudentArchiver.new(begins_at: Date.new(2019, 9, 1), ends_at: Date.new(2020, 8, 31))
  class Archiver

    def self.archive_students
      Users::Student.kept
                    .in_batches(of: 100)
                    .each_record(&:archive)
    end

    def self.delete_invitations
      Invitation.in_batches(of: 100)
                .each_record(&:destroy)
    end

    def self.archive_internship_agreements
      InternshipAgreement.kept
                         .in_batches(of: 100)
                         .each_record(&:archive)
    end
  end
end

