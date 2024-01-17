module Api
  class SectorsController < ApiBaseController
    before_action :authenticate_api_user!

    # lookup sectors
    def index
      render_ok(sectors: Sector.all)
    end
  end
end
