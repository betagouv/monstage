require 'test_helper'

class UserHideableComponentTest < ViewComponent::TestCase
  delegate :application, to: Rails
  delegate :routes, to: :application
  delegate :url_helpers, to: :routes

  test "when user has not seen it, renders partial_path" do
    hidden_partial_path = 'dashboard/remote_internship_block'
    hideable_partial_path = 'dashboard/remote_internship_block'
    employer = create(:employer, banners: {
      :"hidden_partial_path" => true
    })
    render_inline(UserHideableComponent.new(partial_path: hideable_partial_path, user: employer))

    assert_selector(".user-hideable-component")
    assert_selector("form[method=post][action=\"#{url_helpers.account_path}\"  ]")
    assert_selector("input[name=_method][value=patch]", visible: false)
    assert_selector("input[name=\"user[banners][#{hidden_partial_path}]\"]", visible: false)
    assert_selector("input[name=\"user[banners][#{hideable_partial_path}]\"]", visible: false)
  end

  test "when user has not seen it, does not renders partial_path" do
    partial_path = 'dashboard/remote_internship_block'
    employer = create(:employer, banners: { "#{partial_path}" => true})

    render_inline(UserHideableComponent.new(partial_path: partial_path, user: employer))

    assert_no_selector(".user-hideable-component")
  end
end
