require "test_helper"

class LargeBinaryRadioButtonComponentTest < ViewComponent::TestCase

  def test_component_renders_a_multiline_radio_button
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    form_with model: organisation,
                url: dashboard_stepper_organisations_path(organisation),
                method: :post do |form|
      radio_hash = {
        form: form,
        group_label: 'Type de stage',
        radio_field: :internship_type,
        labels: ["Individuel|un seul élève par stage", "Collectif|un group de plusieurs élèves"],
        checked: true,
        required: true,
        disabled: false,
        handle_click: "change->internship-offer-infos#toggleInternshipMaxCandidates"
      }
      result = render_inline(RadioButton::LargeBinary::Component.new(radio_hash))
      assert_includes result.css('.label').to_html, "Type de stage"
    end
  end
end
