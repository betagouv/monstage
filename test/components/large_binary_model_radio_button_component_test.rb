require "test_helper"
require "view_component/test_case"

class LargeBinaryModelRadioButtonComponentTest < ViewComponent::TestCase

  test 'component renders a multiline radio button with default values' do
    new_internship_offer = InternshipOffers::WeeklyFramed.new()
    form = Minitest::Mock.new
    form.expect(:rg2a_required_content_tag, 'test_form_tag')

    6.times { |_| form.expect :object, new_internship_offer }
    radio_hash = {
      form: form,
      group_label: 'Type de stage',
      radio_field: :type,
      labels: ["title_1|small_1", "title_2|small_2"],
      handle_click: "a_change_string"
    }
    render_inline(RadioButton::LargeBinaryModel::Component.new(radio_hash))
    assert_selector(".toggle-radio")
    assert_selector( '.label', text: "Type de stage")
    assert_selector("input[data-action='a_change_string']")
    assert_selector("span.small", text: 'small_1')
    assert_selector("span.small", text: 'small_2')
    assert_selector("input[required='required']")
    assert_selector("input[value='true']", count: 1)
    assert_selector("input[value='false']", count: 1)
  end

  test 'component_renders_a_single_line_radio_button' do
    new_internship_offer = InternshipOffers::WeeklyFramed.new()
    form = Minitest::Mock.new
    form.expect(:rg2a_required_content_tag, 'test_form_tag')

    6.times { |_| form.expect :object, new_internship_offer }
    form.expect :label, 'rtest', [Symbol, String]
    form.expect :label, 'rtest', [Symbol, String]

    radio_hash = {
      form: form,
      group_label: 'Type de stage',
      radio_field: :type,
      labels: ["title_1", "title_2"],
      required: false,
      disabled: true
    }
    render_inline(RadioButton::LargeBinaryModel::Component.new(radio_hash))
    assert_selector(".toggle-radio")
    assert_selector('.label', text: "Type de stage")
    assert_selector("input[value='true']", count: 1)
    assert_selector("input[value='false']", count: 1)
    assert_selector("input[disabled='disabled']", count: 2)

    refute_selector("input[required='required']")
    refute_selector("input[data-action]")
    refute_selector("span.small")
  end
end
