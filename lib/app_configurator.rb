require 'logger'

# Class for application configuration
class AppConfigurator
  class << self
    def get_token
      YAML::load(IO.read('config/secrets.yml'))['telegram_bot_token']
    end

    def get_logger
      Logger.new(STDOUT, Logger::DEBUG)
    end
  end
end
