# frozen_string_literal: true

# wire default rich text message with internship_application rich text attributes
# * approved_message (on internship_application aasm transition approved)
# * examined_message (on internship_application aasm transition examined)
# * rejected_message (on internship_application aasm transition rejected)
# * canceled_by_employer_message (on internship_application aasm transition canceled_by_employer)
# * canceled_by_student_message (on internship_application aasm transition canceled_by_student)
class InternshipApplicationAasmMessageBuilder
  # "exposed" attributes
  delegate :approved_message,
           :examined_message,
           :rejected_message,
           :canceled_by_employer_message,
           :canceled_by_student_message,
           to: :internship_application

  MAP_TARGET_TO_BUTTON_COLOR = {
    approve!: '',
    examine!: 'fr-btn--secondary',
    cancel_by_employer!: 'fr-btn--secondary',
    cancel_by_student!: 'fr-btn--secondary',
    reject!: 'fr-btn--secondary'
  }.freeze

  def target_action_color
    MAP_TARGET_TO_BUTTON_COLOR.fetch(aasm_target)
  end

  #
  # depending on target aasm_state, user edit custom message but
  # action_text default is a bit tricky to initialize
  # so depending on the targeted state, fetch the rich_text_object (void)
  # and assign the body [which show on front end the text]
  #
  MAP_TARGET_TO_RICH_TEXT_ATTRIBUTE = {
    approve!: :approved_message,
    examine!: :examined_message,
    cancel_by_employer!: :canceled_by_employer_message,
    cancel_by_student!: :canceled_by_student_message,
    reject!: :rejected_message
  }.freeze

  MAP_TARGET_TO_RICH_TEXT_INITIALIZER = {
    approve!: :on_approved_message,
    examine!: :on_examined_message,
    cancel_by_employer!: :on_canceled_by_employer_message,
    cancel_by_student!: :on_canceled_by_student_message,
    reject!: :on_rejected_message
  }.freeze

  def assigned_rich_text_attribute
    rich_text_object = MAP_TARGET_TO_RICH_TEXT_ATTRIBUTE.fetch(aasm_target)
    rich_text_initializer = MAP_TARGET_TO_RICH_TEXT_INITIALIZER.fetch(aasm_target)

    send(rich_text_object).body = send(rich_text_initializer)

    rich_text_object
  end

  private

  attr_reader :aasm_target, :internship_application
  def initialize(internship_application:, aasm_target:)
    @internship_application = internship_application
    @aasm_target = aasm_target
  end
end
