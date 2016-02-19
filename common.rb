#Common classes for the serverADS
require 'net/smtp'

$smtp = "mail.alara.co.uk"
$smtpuser = "it@alara.co.uk"
$smtppsswrd = "A1ara45678"

class SendMail(msg,target)
  def initialize
    @@msgtype = msg
    @@target = target
  end
end
