# There's a known bug in Rails 7.0 and it's documented here :
# https://github.com/rails/rails/issues/44252
# and here
# https://github.com/rails/rails/pull/36487


module StiPreload
  unless Rails.application.config.eager_load
    extend ActiveSupport::Concern

    class_methods do
      def type_condition(...)
        unless @_sti_preloaded
          types_in_db = base_class.unscoped.select(inheritance_column).distinct.pluck(inheritance_column).compact
          @_sti_preloaded = types_in_db.map { |type| type.safe_constantize }.all?
        end
        super
      end
    end
  end
end
