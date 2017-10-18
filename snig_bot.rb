require 'telegram/bot'
require 'open-uri'
require 'dotenv'
require 'api_cache'

Dir.chdir(File.dirname(__FILE__))
Dotenv.load
token = ENV['TELEGRAM_API_TOKEN']

Telegram::Bot::Client.run(token, logger: Logger.new('bot.log', 7, 1_024_000)) do |bot|
  bot.logger.info('Bot has been started')
  begin
    bot.listen do |message|
      bot.logger.info message

      response = APICache.get('https://snig.info/api/snigbot/telegram.json', cache: 600)
      resorts = JSON.parse(response, symbolize_names: true)
      resorts.each {|resort| resort[:resort] = resort[:resort].tr(' ', '_')}
      resorts_list = resorts.map { |resort| resort[:resort].prepend('/') }.join("\n")

      case message.text
      when '/start', '/list'
        bot.api.sendMessage(chat_id: message.chat.id, text: resorts_list)
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
        bot.api.sendMessage(chat_id: message.chat.id, text: '/list')
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    bot.logger.error e
    bot.logger.error e.backtrace
    retry
  end
end
