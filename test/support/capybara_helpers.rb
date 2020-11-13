module CapybaraHelpers
  def field_edit_is_allowed?(label:, id: nil)
    test_word = 'test word'
    if label.present?
      id.present? ? fill_in(label, id: id, with: test_word) : fill_in(label, with: test_word)
      assert find_field(label).value == test_word
    end
    true
  end

  def field_edit_is_not_allowed?(label: nil, id: nil)
    assert find("input##{id}")['disabled'] == 'true' if id.present?
    assert find_field(label, disabled: true) if label.present?
    true
  end

  def fill_in_trix_editor(id, with:)
    find(:xpath, "//trix-editor[@id='#{id}']").click.set(with)
  end

  def find_trix_editor(id)
    find(:xpath, "//*[@id='#{id}']")
  end

  def trix_editor_editable?(id, should_be_editable)
    test_word = 'test_word'
    fill_in_trix_editor id, with: test_word
    tested_word = should_be_editable ? test_word : ''
    find_trix_editor(id).assert_text(tested_word)
  end
end