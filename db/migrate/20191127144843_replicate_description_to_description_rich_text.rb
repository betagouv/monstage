class ReplicateDescriptionToDescriptionRichText < ActiveRecord::Migration[6.0]
  def change
    InternshipOffer.all.in_batches(of: 10) do |batch|
      batch.each do |io|
        io.description_rich_text = io.description
        io.employer_description_rich_text = io.employer_description
        io.save
      end
    end
  end
end
