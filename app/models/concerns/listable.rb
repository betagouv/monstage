# frozen_string_literal: true

module Listable
  extend ActiveSupport::Concern

  included do
    scope :next_from, lambda { |current:, column:, order:|
      operator = order == :asc ? '>' : '<'

      query = where("#{table_name}.#{column} #{operator} :current_column_value",
                    current_column_value: current.send(column))
      query = query.reorder(column => order)
      query
    }

    scope :previous_from, lambda { |current:, column:, order:|
      operator = order == :asc ? '<' : '>'

      query = where("#{table_name}.#{column} #{operator} :current_column_value",
                    current_column_value: current.send(column))
      query = query.reorder(column => order)
      query = query.reverse_order
      query
    }
  end
end
