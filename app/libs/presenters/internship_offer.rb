module Presenters
  class InternshipOffer
    def filter_options
      {
        component_label: 'Filtrer par',
        mobile_extra_option: [{
          value: 'all',
          id: 'search-by-all',
          label: 'Toutes les filières'
        }],
        options: [
          { value: 'troisieme_generale',
            id: 'search-by-troisieme-generale',
            label: '3ème'},
          { value: 'troisieme_segpa',
            id: 'search-by-troisieme-segpa',
            label: '3e SEGPA'},
          { value: 'troisieme_prepa_metiers',
            id: 'search-by-troisieme-prepa-metiers',
            label: '3e prépa métiers'},
          { value: 'bac_pro',
            id: 'search-by-bac-pro',
            label: 'Bac Pro'}
        ]
      }
    end
    def mobile_tag_filter_options
      options = filter_options[:mobile_extra_option] +
                filter_options[:options]
      options.map { |option| [ option[:label], option[:value]] }
    end
  end
end
