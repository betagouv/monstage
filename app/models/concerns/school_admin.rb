module SchoolAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        field :id
        field :name
        field :visible
        field :kind
        field :address do
          pretty_value do
            school = bindings[:object]
            "#{school.city} – CP #{school.zipcode} (#{school.department})"
          end
        end
        field :school_manager
        field :city do
          visible false
        end
        field :department do
          visible false
        end
        field :zipcode do
          visible false
        end
        scopes [:all, :with_manager, :without_manager]
      end

      edit do
        field :name
        field :visible
        field :kind, :enum do
          enum do
            ::School::VALID_TYPE_PARAMS
          end
        end
        field :code_uai

        field :coordinates do
          partial 'autocomplete_address'
        end

        field :class_rooms

        field :street do
          partial 'void'
        end
        field :zipcode do
          partial 'void'
        end
        field :city do
          partial 'void'
        end
        field :department do
          partial 'void'
        end
      end

      show do
        field :name
        field :visible
        field :kind
        field :street
        field :zipcode
        field :city
        field :department
        field :class_rooms
        field :internship_offers
        field :weeks do
          pretty_value do
            school = bindings[:object].weeks.map(&:short_select_text_method)
          end
        end
        field :school_manager
      end

      export do
        field :name
        field :zipcode
        field :city
        field :department
        field :kind
        field :school_manager, :string do
          export_value do
            bindings[:object].school_manager.try(:name)
          end
        end
        # Weeks are removed for now because it is not readable as an export
        field :weeks, :string do
          export_value do
            bindings[:object].weeks.map(&:short_select_text_method)
          end
        end
      end
    end
  end
end