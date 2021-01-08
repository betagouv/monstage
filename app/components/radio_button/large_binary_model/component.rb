# frozen_string_literal: true

module RadioButton
  module LargeBinaryModel
    class Component < RadioButton::Common
      def form_object_sym
        form.object.class.name.split('s::').first.underscore.to_sym
      end

      def checked?
        form.object.send(radio_field) == true
      end

      def symbolic_label_tag(index)
        "#{form_object_sym}_#{radio_field}_#{index.even?}".to_sym
      end

      def radio_label(index)
        "#{radio_field}_#{index.even?}".to_sym
      end
    end
  end
end
