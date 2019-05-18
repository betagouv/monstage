class AddUnitedWayLAllianceOperator < ActiveRecord::Migration[5.2]
  def up
    Operator.create(name: "United Way L’Alliance")
  end
end
