class PopulateMonths < ActiveRecord::Migration[6.1]
  def up
    next_month = 3.years.ago.beginning_of_month
    loop do
      Month.create!(date: next_month)
      next_month = next_month.next_month
      break if next_month > 50.years.from_now
    end
  end

  def down
    Month.delete_all
  end
end
