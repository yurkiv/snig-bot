require 'http'

class Metrics
  BOT_METRICS_TOKEN = AppConfigurator.metrics_token

  class << self
    def send(message)
      params = {
        text: message.text,
        message_type: 'incoming',
        user_id: message.from.username,
        platform: 'telegram'
      }
      HTTP.post("https://api.bot-metrics.com/v1/messages?token=#{BOT_METRICS_TOKEN}", json: params)
    end
  end
end
