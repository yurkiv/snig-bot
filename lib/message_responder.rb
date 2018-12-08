require './lib/message_sender'
require './lib/providers/snig_info'
require './lib/providers/bukovel_queue_control'

# Class for input messages
class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user
  attr_reader :chat_id

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @message_text = options[:message].text
    @user = options[:user]
    @chat_id = options[:message_chat_id]
  end

  def respond
    # binding.pry
    case @message_text

    when '/start', '/list'
      resorts_list
    else
      check_resort
    end
  end

  private

  def resorts_list
    resorts_list = snig_resorts.map { |resort| resort[:resort].capitalize }
    resorts_list = resorts_list.insert(2, Providers::BukovelQueueControl::NAME)
    answer('Choose resort:', answers: resorts_list)
  end

  def check_resort
    snig_resort = snig_resorts.find { |r| r[:resort].capitalize == message.text }
    snig_resort_answer(snig_resort) if snig_resort
    bukovel_queue_control_answer if message.text == Providers::BukovelQueueControl::NAME
    answer('/list')
  end

  def snig_resort_answer(resort)
    active_cams = resort[:cams].select { |cam| cam[:status] == 'online' }
    if active_cams.any?
      active_cams.each do |cam|
        photo = Providers::SnigInfo.camera_photo(cam[:id])
        text = "#{cam[:title]}: #{Providers::SnigInfo.camera_link(cam[:id])}}"
        answer(text, photo: photo)
      end
    else
      answer('There are no active cams :(')
    end
  end

  def bukovel_queue_control_answer
    Providers::BukovelQueueControl::CAMS.each do |cam|
      photo = Providers::BukovelQueueControl.camera_photo(cam)
      next unless photo.io.is_a?(Tempfile)
      answer("Bukovel #{cam}", photo: photo)
    end
  end

  def snig_resorts
    @snig_resorts ||= Providers::SnigInfo.resorts
  end

  def answer(text, options = {})
    MessageSender.new(bot: bot, chat: message.chat, text: text, answers: options[:answers], photo: options[:photo]).send
  end
end
