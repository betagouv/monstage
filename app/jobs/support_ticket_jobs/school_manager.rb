module SupportTicketJobs
  class SchoolManager < CreateSupportTicketJob
    def build_zammad_ticket_service(params:)
      Services::ZammadTickets::SchoolManager.new(params: params)
    end
  end
end