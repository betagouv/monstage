# base class for hooks on internship_applications (compute various counters for dashboard/reporting
class InternshipApplicationCountersHook
  private
  attr_reader :internship_application

  def initialize(internship_application:)
    @internship_application = internship_application
    @internship_application.reload
  end
end
