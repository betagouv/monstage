class EmployerTabFinder
  def approved_application_count
    @application_count ||= user.internship_applications.approved.count
  end

  private

  attr_reader :user

  def initialize(user:)
    @user = user
  end
end
