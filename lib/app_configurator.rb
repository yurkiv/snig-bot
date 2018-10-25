require 'logger'
require 'sentry-raven'
require 'open-uri'

# Class for application configuration
class AppConfigurator
  class << self
    def token
      YAML.safe_load(IO.read('config/secrets.yml'))['telegram_bot_token']
    end

    def raven
      sentry_url = YAML.safe_load(IO.read('config/secrets.yml'))['sentry_url']
      Raven.configure { |config| config.dsn = sentry_url }
    end

    def metrics_token
      YAML.safe_load(IO.read('config/secrets.yml'))['bot_metrics_token']
    end

    def logger
      Logger.new('log/bot.log', 7, 1_024_000)
    end
  end
end
