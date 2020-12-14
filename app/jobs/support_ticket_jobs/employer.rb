module SupportTicketJobs
  class Employer < CreateSupportTicketJob
    def build_zammad_ticket_service(params:)
      Services::ZammadTickets::Employer.new(params: params)
    end
  end
end