require 'rubygems'
require 'net/ssh'
require 'optparse'

@hostname = "192.168.1.22"
@username = "root"
@password = "A1ara45678"
@cmd = "reboot"
@msgtitle = '"Software Deployment"'
@msgbody = '"Starting to deploy software on the machine"'

ARGV.each{|a|
  puts "#{a}"
  if a == "-r"
    $sa = "r"
  elsif a == "-i"
    $sa = "i"
  end
  puts "#{$sa}"
}

Net::SSH.start(@hostname, @username, :password => @password) do |ssh|
#    ssh.exec("notify-send -t 10 [#{@msgtitle}] #{@msgbody}")
  ssh.exec("dnf info thunderbird") {|dc,stream,data|
    puts data
    data.each_line{|line|
      if line.include?('Available Packages')
        puts "1 method: #{$sa}"
        $complete = false
        if $sa == "i"
          puts "1.1"
          puts "Thunderbird not deployed, Deploying"
          ssh.exec("dnf -y install thunderbird"){|dc, stream, data|
            data.each_line{|rline|
            if rline.include?('Complete!')
              puts "Installed sucessfully"
              $complete = true
              break
            end
            }
          }
        elsif $sa == "r"
          puts "1.2"
          puts "package not installed yet cannot remove"
          $complete = true
        end
        if !$complete
          puts "something went wrong, please review the logs"
        end
        break
      elsif data.include?('Installed Packages')
        puts "2"
        $complete = false
        if $sa == "i"
          puts "Thunderbird already installed, exiting"
          $complete = true
        elsif $sa == "r"
          puts "Thunderbird installed, Removing"
          ssh.exec("dnf -y remove thunderbird"){|dc, stream, data|
            data.each_line{|rline|
            if rline.include?('Complete!')
              puts "Removed sucessfully"
              $complete = true
              break
            end
            }
          }
        end
        if !$complete
          puts "something went wrong, please review the logs"
        end
      break
      end
    }
  }
end
