# frozen_string_literal: true

class MessageForAasmState
  # for html formatted default message
  delegate :student,
           :internship_offer,
           :week,
           to: :internship_application
  # "exposed" attributes
  delegate :approved_message,
           :rejected_message,
           :canceled_message,
           to: :internship_application

  MAP_TARGET_TO_BUTTON_COLOR = {
    approve!: 'danger',
    cancel!: 'outline-danger',
    reject!: 'danger'
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
    cancel!: :canceled_message,
    reject!: :rejected_message
  }.freeze

  MAP_TARGET_TO_RICH_TEXT_INITIALIZER = {
    approve!: :on_approved_message,
    cancel!: :on_canceled_message,
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

  def on_approved_message
    <<~HTML.strip
      <p>Bonjour #{Presenters::User.new(student).full_name},</p>
      <p>Votre candidature pour le stage "#{internship_offer.title}" est acceptée pour la semaine #{week.short_select_text_method}.</p>
      <p>Vous devez maintenant faire signer la convention de stage.</p>
    HTML
  end

  def on_rejected_message
    <<~HTML.strip
      <p>Bonjour #{Presenters::User.new(student).full_name},</p>
      <p>Votre candidature pour le stage "#{internship_offer.title}" est refusée pour la semaine #{week.short_select_text_method}.</p>
    HTML
  end

  def on_canceled_message
    <<~HTML.strip
      <p>Bonjour #{Presenters::User.new(student).full_name},</p>
      <p>Votre candidature pour le stage "#{internship_offer.title}" est annulée pour la semaine #{week.short_select_text_method}.</p>
    HTML
  end
end
