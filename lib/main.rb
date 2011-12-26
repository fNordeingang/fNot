# coding: utf-8
require "rubygems"
require "bundler/setup"
require "net/http"
require "cinch"


bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = ["#fnordeingang"]
    c.nick = "fNot"
    @notifications = {}
  end

  on :message, /.*/ do |m|
    unless @notifications[m.user.nick].nil?
      bot.logger.debug "#{m.user.nick} has messages"
      m.reply "#{m.user.nick}: Nachricht von #{@notifications[m.user.nick][:from]}"
      m.reply @notifications[m.user.nick][:msg]
      @notifications[m.user.nick] = nil
    else
      bot.logger.debug "#{m.user.nick} has no messages"
    end
  end
  
  on :message, /^!notify$/ do |m|
    m.reply "#{m.user.nick}: !notify <nickname> \"<nachricht>\""
  end

  on :message, /^!notify (.*) "(.*)"$/ do |m,nick,msg|
    @notifications[nick] = {:from => m.user.nick, :msg => msg}
    m.reply "#{m.user.nick}: #{nick} wird benachrichtigt sobald ich von ihm hoere"
  end
  
  on :message, /^!status$/ do |m,nick,msg|
    response = Net::HTTP.get_response("status.fnordeingang.de","/")
    if response.body =~ /true/
      m.reply "fNordeingang is open!"
    else
      m.reply "fNordeingang is closed :("
    end
  end
end

bot.start