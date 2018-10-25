require './lib/message_sender'

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
    @user = options[:user]
    @chat_id = options[:message_chat_id]
    @repository_name = options[:repository_name]
  end

  def respond
    case @message
    when %r{^\/help}
      help_message
    else
      answer 'Unknown command, use /help for information'
    end
  end

  private

  def help_message
    answer "/status <repository-name> - Update the status of repository and show it\n" \
           "/last_build <repository-name> - Show the status of the <repository-name>" \
             " last build\n" \
           "/last_builds - Show the status of last builds of all my repositories\n" \
           "/my_repos - Show the list of my repositories\n" \
           "/help - Show this message\n"
  end

  def answer(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
    # MessageSender.send(@bot.api, @chat_id, text)
  end
end