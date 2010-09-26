# coding: utf-8
require "rubygems"
require "bundler/setup"

require "cinch"

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = ["#fnordeingang"]
    c.nick = "fnot"
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

  on :message, /^!notify (.*) (.*)$/ do |m,nick,msg|
    @notifications[nick] = {:from => m.user.nick, :msg => msg}
    m.reply "#{m.user.nick}: #{nick} wird benachrichtigt sobald ich von ihm höre"
  end
end

bot.start