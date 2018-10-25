require 'logger'
require 'sentry-raven'

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

    def logger
      Logger.new(STDOUT, Logger::DEBUG)
    end
  end
end
