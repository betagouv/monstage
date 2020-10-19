module Services
  # Services::StudentArchiver.new(begins_at: Date.new(2019, 9, 1), ends_at: Date.new(2020, 8, 31))
  class StudentArchiver

    def run
      archive_students
    end


    private

    def archive_students
      Users::Student.where(created_at: (begins_at..ends_at))
                    .where.not(anonymized: true)
                    .in_batches(of: 10)
                    .each_record(&:archive)
    end

    attr_reader :begins_at, :ends_at
    def initialize(begins_at:, ends_at:)
      @begins_at = begins_at
      @ends_at = ends_at
    end
  end
end

