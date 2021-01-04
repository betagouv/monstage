# frozen_string_literal: true

module RadioButton
  module LargeBinary
    class Component < RadioButton::Common
      def initialize(
        form:,
        group_label:,
        radio_field:,
        labels:,
        checked: false,
        disabled: false,
        required: true,
        handle_click: nil)
        super
        @checked = checked
      end

      def checked?(index)
        index.even? ? checked : !checked
      end

      def symbolic_label_tag(index)
        "#{radio_field}_#{index.even?}".to_sym
      end
    end
  end
end