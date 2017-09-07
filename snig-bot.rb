require 'telegram/bot'
require 'pry'
require 'rb-readline'

token = '380682928:AAGtYEMJumwcTYRJIj3swwEXv4_uVE1CHiQ'
resorts = JSON.parse(File.read("resorts.json"), symbolize_names: true)

resorts_list = resorts.map{|resort| resort[:resort].prepend('/')}.join("\n")

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
      when '/start'
        bot.api.sendMessage(chat_id: message.chat.id, text: resorts_list)
    end

#    puts message.text[1..-1]
#    binding.pry
    resort = resorts.find{|r| r[:resort]==message.text}
#    binding.pry
    if resort
      resort[:cams].each do |cam|
        bot.api.sendMessage(chat_id: message.chat.id, text: cam[:title])
        bot.api.send_photo(chat_id: message.chat.id, photo: "https://img.snig.info/#{cam[:id]}/last.jpg")
      end
    end
  end
end