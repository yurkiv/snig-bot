require './lib/message_sender'
require './lib/providers/snig_info'

# Class for input messages
class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user
  attr_reader :chat_id
  attr_reader :repository_name

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @message_text = options[:message].text
    @user = options[:user]
    @chat_id = options[:message_chat_id]
    @repository_name = options[:repository_name]
  end

  def respond
    # binding.pry
    case @message_text

    when '/start', '/list'
      resorts_list
    else
      check_resort
      # answer_with_message 'Unknown command, use /help for information'
    end
  end

  def resorts_list
    resorts_list = snig_resorts.map { |resort| resort[:resort] }
    resorts_list = resorts_list.insert(2, 'bukovel queue control')
    answer_with_keyboard('Choose resort:', resorts_list)
  end

  private

  def help_message
    answer_with_message "/status <repository-name> - Update the status of repository and show it\n" \
           "/last_build <repository-name> - Show the status of the <repository-name>" \
             " last build\n" \
           "/last_builds - Show the status of last builds of all my repositories\n" \
           "/my_repos - Show the list of my repositories\n" \
           "/help - Show this message\n"
  end

  def snig_resorts
    Providers::SnigInfo.resorts
  end

  def check_resort
    snig_resort = snig_resorts.find { |r| r[:resort] == message.text }
    snig_resort_answer(snig_resort) if snig_resort
  end

  def snig_resort_answer(resort)
    active_cams = resort[:cams].select { |cam| cam[:status] == 'online' }
    if active_cams.any?
      active_cams.each do |cam|
        photo = Providers::SnigInfo.camera_photo(cam[:id])
        text = "#{cam[:title]}: #{Providers::SnigInfo.camera_link(cam[:id])}}"
        answer_with_photo(text, photo)
      end
    else
      answer_with_message('There are no active cams :(')
    end
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def answer_with_keyboard(text, answers)
    MessageSender.new(bot: bot, chat: message.chat, text: text, answers: answers).send
  end

  def answer_with_photo(text, photo)
    MessageSender.new(bot: bot, chat: message.chat, text: text, photo: photo).send
  end
end