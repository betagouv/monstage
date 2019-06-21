# frozen_string_literal: true

class AddLeReseauOperator < ActiveRecord::Migration[5.2]
  def change
    Operator.create(name: 'Le Réseau')
  end
end
