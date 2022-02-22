class CreateInternshipAgreementPreset < ActiveRecord::Migration[6.1]
  def up
    create_table :internship_agreement_presets do |t|
      t.date :school_delegation_to_sign_delivered_at
      t.references :school

      t.timestamps
    end
    School.find_each(batch_size: 100) do |school|
      internship_agreement_preset = school.create_internship_agreement_preset!
    end
  end

  def down
    drop_table :internship_agreement_presets
  end
end
