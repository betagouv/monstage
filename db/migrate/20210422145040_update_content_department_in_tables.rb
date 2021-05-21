class UpdateContentDepartmentInTables < ActiveRecord::Migration[6.1]
  def up
    change_table :users do |t|
      t.rename :department_name, :department
    end
    ex_north = 'Nord (département français)|Nord'
    current_north = 'Nord'

    User.where(department: ex_north).update_all(department: current_north)
    InternshipOffer.where(department: ex_north).update_all(department: current_north)
    Organisation.where(department: ex_north).update_all(department: current_north)
    School.where(department: ex_north).update_all(department: current_north)
  end

  def down
    change_table :users do |t|
      t.rename :department, :department_name
    end
    ex_north = 'Nord'
    current_north = 'Nord (département français)|Nord'

    User.where(department_name: ex_north).update_all(department_name: current_north)
    InternshipOffer.where(department: ex_north).update_all(department: current_north)
    Organisation.where(department: ex_north).update_all(department: current_north)
    School.where(department: ex_north).update_all(department: current_north)
  end
end
