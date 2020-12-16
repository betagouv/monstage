require 'test_helper'

class SupportTicketTest < ActiveSupport::TestCase
  test 'SchoolManager validates its custom params' do
    ticket = SupportTickets::SchoolManager.new(webinar: 1,
                                               class_rooms_quantity: '',
                                               students_quantity: 'string',
                                               week_ids: [])
    refute ticket.valid?
    assert ticket.errors.keys.include?(:week_ids)
    assert ticket.errors.keys.include?(:class_rooms_quantity)
    assert ticket.errors.keys.include?(:students_quantity)
  end

  test 'Employer validates its custom params' do
    ticket = SupportTickets::Employer.new(webinar: 1,
                                          speechers_quantity: '',
                                          business_lines_quantity: 'string',
                                          week_ids: [])
    refute ticket.valid?
    assert ticket.errors.keys.include?(:week_ids)
    assert ticket.errors.keys.include?(:speechers_quantity)
    assert ticket.errors.keys.include?(:business_lines_quantity)
  end
end
