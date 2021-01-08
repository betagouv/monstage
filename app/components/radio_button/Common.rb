module RadioButton
  class Common < ViewComponent::Base
    attr_reader :form,
                :group_label,
                :radio_field,
                :labels,
                :main_labels,
                :secondary_labels,
                :checked,
                :disabled,
                :required,
                :handle_click

    LABEL_SEPARATOR = '|'

    def initialize(
      form:,
      group_label:,
      radio_field:,
      labels:,
      checked: false,
      disabled: false,
      required: true,
      handle_click: nil)
      @form             = form
      @group_label      = group_label
      @radio_field      = radio_field
      @disabled         = disabled
      @required         = required
      @handle_click     = handle_click
      @labels           = labels
      @main_labels      = []
      @secondary_labels = []
      extract_labels
    end

    def extract_labels
      @labels.each do |label|
        composition = label.split(LABEL_SEPARATOR)
        @main_labels << composition.first.strip
        sec_label = composition.count > 1 ? composition.second.strip : ''
        @secondary_labels << sec_label
      end
    end

    def symbolic_label_tag(index)
      "#{radio_field}_#{index.even?}".to_sym
    end
  end
end