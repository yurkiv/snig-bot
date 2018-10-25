require 'api_cache'

module Providers
  class BukovelQueueControl
    NAME = 'Bukovel queue control'.freeze
    CAMS = %w[lift1R lift2 lift2R lift3 lift5_1 lift7 lift8 lift11 lift12 lift13 lift14 lift15 lift16 lift17 lift22].freeze

    class << self
      def camera_photo(cam_id)
        Faraday::UploadIO.new(open("https://yeti.bukovel.com/delays/#{cam_id}.jpg"), 'image/jpeg')
      end
    end
  end
end
