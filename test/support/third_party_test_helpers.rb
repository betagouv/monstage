module ThirdPartyTestHelpers
  # write a mock : File.open(Rails.root.join('test', 'fixtures', 'files', 'prismic-homepage-response.dump'), 'wb') { |fd| fd.write Marshal.dump(rs) }
  # read a mock : Marshal.load(File.read(Rails.root.join('test', 'fixtures', 'files', 'prismic-homepage-response.dump')))
  # mock with mock : PrismicFinder.stub(:homepage, mock_prismic)
  def prismic_root_path_stubbing
    mock_prismic = Marshal.load(
      File.read(
        Rails.root.join('test', 'fixtures', 'files', 'prismic-homepage-response.dump')
      )
    )
    PrismicFinder.stub(:homepage, mock_prismic) { yield }
  end
end