module Listable
  extend ActiveSupport::Concern

  included do
    scope :next_from, lambda { |current:, column:,order:|
      operator = order == :asc ? '>' : '<'
      query = where("internship_offers.#{column} #{operator} :current_column_value",
            current_column_value: current.send(column))
      query = query.reorder(column => order)
      query
    }

    scope :previous_from, lambda { |current:, column:, order:|
      operator = order == :asc ? '<' : '>'
      query = where("internship_offers.#{column} #{operator} :current_column_value",
                    current_column_value: current.send(column))

      query = query.reorder(column => order)
      query = query.reverse_order
      query
    }

    scope :next_first, lambda { |current:, column:,order:|
      next_from(current: current, column: column, order: order)
        .limit_and_first
    }

    scope :previous_first, lambda { |current:, column:,order:|
      previous_from(current: current, column: column, order: order)
        .limit_and_first
    }

    scope :limit_and_first,  lambda { limit(1).first }
  end
end
