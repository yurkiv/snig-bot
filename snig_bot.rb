require 'telegram/bot'
require 'open-uri'
require 'dotenv'

Dir.chdir(File.dirname(__FILE__))
Dotenv.load
token = ENV['TELEGRAM_API_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  resorts = JSON.parse(File.read('resorts.json'), symbolize_names: true)
  resorts_list = resorts.map { |resort| resort[:resort].prepend('/') }.join("\n")

  bot.listen do |message|
    case message.text
    when '/start', '/list'
      bot.api.sendMessage(chat_id: message.chat.id, text: resorts_list)
    end

    resort = resorts.find { |r| r[:resort] == message.text }
    if resort
      resort[:cams].each do |cam|
        photo = Faraday::UploadIO.new(open("https://img.snig.info/#{cam[:id]}/last.jpg"), 'image/jpeg')
        text = "#{cam[:title]}: https://snig.info/#{cam[:id]}"

        bot.api.send_photo(chat_id: message.chat.id, photo: photo, caption: text)
      end
      bot.api.sendMessage(chat_id: message.chat.id, text: '/list')
    end
  end
end
