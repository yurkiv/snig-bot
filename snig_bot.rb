require 'telegram/bot'
require 'open-uri'
require 'dotenv'
require 'api_cache'
require 'sentry-raven'
require 'pry'
require_relative 'stat'

Dir.chdir(File.dirname(__FILE__))
Dotenv.load
token = ENV['TELEGRAM_API_TOKEN']
Raven.configure { |config| config.dsn = ENV['SENTRY_URL'] }

buk_query_cams = %w(lift1R lift2 lift2R lift3 lift5_1 lift7 lift8 lift11 lift12 lift13 lift14 lift15 lift16 lift17 lift22)

Telegram::Bot::Client.run(token, logger: Logger.new('bot.log', 7, 1_024_000)) do |bot|
  bot.logger.info('Bot has been started')
  begin
    bot.listen do |message|
      bot.logger.info message
      Stat.send(message.text, "#{message.from.id}-#{message.from.username}")

      response = APICache.get('https://snig.info/api/snigbot/telegram.json', cache: 600)
      resorts = JSON.parse(response, symbolize_names: true)
      resorts_list = resorts.map { |resort| resort[:resort] }
      resorts_list = resorts_list.insert(2, 'bukovel queue control')

      case message.text
      when '/start', '/list'
        answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: resorts_list, one_time_keyboard: false)
        bot.api.send_message(chat_id: message.chat.id, text: 'Choose resort:', reply_markup: answers)
      when 'bukovel queue control'
        buk_query_cams.each do |cam|
          photo = Faraday::UploadIO.new(open("https://yeti.bukovel.com/delays/#{cam}.jpg"), 'image/jpeg')
          bot.api.send_photo(chat_id: message.chat.id, photo: photo, caption: "Bukovel #{cam}")
        end
      end

      resort = resorts.find { |r| r[:resort] == message.text }
      if resort
        active_cams = resort[:cams].select { |cam| cam[:status] == 'online' }
        bot.api.sendMessage(chat_id: message.chat.id, text: 'There are no active cams :(') if active_cams.empty?

        active_cams.each do |cam|
          photo = Faraday::UploadIO.new(open("https://img.snig.info/#{cam[:id]}/last.jpg"), 'image/jpeg')
          text = "#{cam[:title]}: https://snig.info/#{cam[:id]}"
          bot.api.send_photo(chat_id: message.chat.id, photo: photo, caption: text)
        end
      end
    end
  # rescue StandardError => e
  #   Raven.capture_exception(e)
  #   bot.logger.error e
  #   bot.logger.error e.backtrace
  #   retry
  end
end
