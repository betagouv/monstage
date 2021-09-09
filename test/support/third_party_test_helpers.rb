module ThirdPartyTestHelpers
  def prismic_root_path_stubbing
    mock_prismic = Marshal.load(
      File.read(
        Rails.root.join('test', 'fixtures', 'files', 'prismic-homepage-response.dump')
      )
    )
    PrismicFinder.stub(:homepage, mock_prismic) { yield }
  end
end