require 'dotenv'
require 'rest-client'
require 'pry'

Dir.chdir(File.dirname(__FILE__))
Dotenv.load

class Stat
  def self.send(message, user_id)
    bot_metrics_token = ENV['BOT_METRICS_TOKEN']
    params = {
      text: message,
      message_type: 'incoming',
      user_id: user_id,
      platform: 'telegram'
    }
    RestClient.post "https://api.bot-metrics.com/v1/messages?token=#{bot_metrics_token}", params
  end
end