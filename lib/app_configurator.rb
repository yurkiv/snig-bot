require 'logger'

# Class for application configuration
class AppConfigurator
  class << self
    def token
      YAML.safe_load(IO.read('config/secrets.yml'))['telegram_bot_token']
    end

    def logger
      Logger.new(STDOUT, Logger::DEBUG)
    end
  end
end
