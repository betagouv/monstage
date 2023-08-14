module Services
  # Services::StudentArchiver.new(begins_at: Date.new(2019, 9, 1), ends_at: Date.new(2020, 8, 31))
  class Archiver

    def archive_students
      Users::Student.kept
                    .where(created_at: (begins_at..ends_at))
                    .where.not(anonymized: true)
                    .in_batches(of: 100)
                    .each_record(&:archive)
    end

    def delete_invitations
      Invitation.where(created_at: (begins_at..ends_at))
                .in_batches(of: 100)
                .each_record(&:destroy)
    end

    attr_reader :begins_at, :ends_at
    def initialize(begins_at:, ends_at:)
      @begins_at = begins_at
      @ends_at = ends_at
    end
  end
end

