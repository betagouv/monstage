module EmailSpamEuristicsAssertions
  def refute_email_spammyness(email)
    assert_subject_length_is_between_35_and_50_chars(email)
    assert_body_does_not_contains_upcase_word(email)
  end

  private

  def assert_subject_length_is_between_35_and_50_chars(email)
    assert(email.subject.size >= 35 && email.subject.size <= 50,
           "woops, too long subject [35<=#{email.subject.size}>=50]: #{email.subject}")
  end

  def assert_body_does_not_contains_upcase_word(email)
    nokogiri_doc = Nokogiri::HTML(email.html_part.body.to_s)
    text_nodes = nokogiri_doc.search('//text()')
                             .reject{|el| el.is_a?(Nokogiri::XML::CDATA) }
    upcase_words = text_nodes.map(&:text).grep(/([[:upper:]]){2,}/)

    assert(upcase_words.size.zero?,
           "whoops, what happens there is an upcase word: #{upcase_words.join("\n")}")
  end
end
