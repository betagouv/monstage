# frozen_string_literal: true

require 'fileutils'

module CachedPagesHelpers
  include Html5Validator

  def read_cached_html_pages
    Html5Validator.files_to_validates.each do |file|
      yield File.read(file), file
    end
  end

  def check_page_title
    read_cached_html_pages do |file_data, filename|
      assert page_title_ok?(file_data),
             "#{filename} is missing a uniq non default title"
    end
  end

  def page_title_ok?(data)
    titles_array = data.match(/<title>(.*)<\/title>/).captures
    return false if titles_array.count > 1
    return false if titles_array.first == 'Monstage | Monstage'

    true
  end
end