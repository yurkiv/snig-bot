require 'api_cache'

module Providers
  class SnigInfo
    URL = 'https://snig.info/api/snigbot/telegram.json'.freeze

    class << self
      def resorts
        response = APICache.get(URL, cache: 600)
        JSON.parse(response, symbolize_names: true)
      end

      def camera_photo(cam_id)
        Faraday::UploadIO.new(open("https://img.snig.info/#{cam_id}/last.jpg"), 'image/jpeg')
      end

      def camera_link(cam_id)
        "https://snig.info/#{cam_id}"
      end
    end
  end
end
