require 'telegram/bot'
require 'pry'
require 'rb-readline'

token = ENV['TELEGRAM_API_TOKEN']
resorts = JSON.parse(File.read('resorts.json'), symbolize_names: true)

resorts_list = resorts.map { |resort| resort[:resort].prepend('/') }.join("\n")

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start', '/list'
      bot.api.sendMessage(chat_id: message.chat.id, text: resorts_list)
    end

    resort = resorts.find { |r| r[:resort] == message.text }
    if resort
      resort[:cams].each do |cam|
        bot.api.sendMessage(chat_id: message.chat.id, text: cam[:title])
        bot.api.send_photo(chat_id: message.chat.id, photo: "https://img.snig.info/#{cam[:id]}/last.jpg")
      end
    end
  end
end