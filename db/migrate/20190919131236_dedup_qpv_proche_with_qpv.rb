class DedupQpvProcheWithQpv < ActiveRecord::Migration[6.0]
  def up
    School.where(kind: :qpv_proche).each do |possibly_duplicate|
      deduper = Dto::SchoolDedup.new(school: possibly_duplicate)
      deduper.migrate if deduper.dup?
    end

    School.where(kind: :qpv_proche).update_all(visible: true)
  end
end
