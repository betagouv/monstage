# module StiPreload
#   unless Rails.application.config.eager_load
#     extend ActiveSupport::Concern

#     included do
#       cattr_accessor :preloaded, instance_accessor: false
#     end

#     class_methods do
#       def descendants
#         preload_sti unless preloaded
#         super
#       end

#       # Constantizes all types present in the database. There might be more on
#       # disk, but that does not matter in practice as far as the STI API is
#       # concerned.
#       #
#       # Assumes store_full_sti_class is true, the default.
#       def preload_sti
#         types_in_db = \
#           base_class.
#             unscoped.
#             select(inheritance_column).
#             distinct.
#             pluck(inheritance_column).
#             compact

#         types_in_db.each do |type|
#           logger.debug("Preloading STI type #{type}")
#           type.safe_constantize
#         end

#         self.preloaded = true
#       end
#     end
#   end
# end


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
