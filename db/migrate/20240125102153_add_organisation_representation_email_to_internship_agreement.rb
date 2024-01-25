class AddOrganisationRepresentationEmailToInternshipAgreement < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_agreements, :organisation_representative_email, :string
    
    TaskManager.new(allowed_environments: %w[development test production review staging],
      task_name: 'data_migrations:create_organisation_representative_email',
      arguments: []
    ).play_task_each_time(run_with_a_job: false)
  end
  end
end
