#Common classes for the serverADS
require 'rubygems'
require 'mail'

class SendMail
  def initialize(msg,trgt)
    smtp = { :address => 'mail.alara.co.uk', :port => 25, :domain => 'alara.co.uk', :user_name => 'it@alara.co.uk', :password => 'A1ara45678', :enable_starttls_auto => true, :openssl_verify_mode => 'none' }
    Mail.defaults { delivery_method :smtp, smtp }
    @@message = msg
    if trgt == 1
      @@subject = "Node Down"
    end
  end

  def send
    mail = Mail.new do
      from 'it@alara.co.uk'
      to 'carlos@alara.co.uk'
      subject @@subject
      body 'body testing'
    end
    mail.deliver!
  end
end
