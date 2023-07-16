module Api
  module V1
    class UrlsController < ApiController
      def index
        urls = Url.latest
        render json: urls, include: 'clicks'
      end
    end
  end
end