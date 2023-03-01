#TO TO REMOVE
class UserHideableComponentPreview < ViewComponent::Preview
  layout "preview"

  def with_employer
    partial_path = 'dashboard/remote_internship_block'

    render(UserHideableComponent.new(partial_path: partial_path, user: Users::Employer.first))
  end

  def with_school_manager
    partial_path = 'dashboard/remote_internship_block'
    render(UserHideableComponent.new(partial_path: partial_path, user: Users::SchoolManagement.school_manager.first))
  end
end

