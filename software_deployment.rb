require 'rubygems'
require 'net/ssh'

@hostname =
@username =
@password =
$output = []
$Installed
@session = false

class DeploySoftware
  def initialize(hostname,username,password)
    @hostname = hostname
    @username = username
    @password = password
  end

  def info(package)
    $Installed = false
    Net::SSH.start(@hostname,@username,:password => @password) do |ssh|
      ssh.exec("dnf info #{package}"){|dc,stream,data|
        data.each_line{|line|
          if line.include?("Installed Packages")
            $Installed = true
          end
        }
      }
    end
    return $Installed
  end

  def install(package)
    if !info(package)
      Net::SSH.start(@hostname,@username,:password => @password) do |ssh|
        ssh.exec("dnf -y install #{package}"){|dc,stream,data|
          data.each_line{|line|
            puts line
            $output[$output.size] = line
          }
        }
      end
    end
    return $output
  end

  def remove(package)
    if info(package)
      Net::SSH.start(@hostname,@username,:password => @password) do |ssh|
        ssh.exec("dnf -y remove #{package}"){|dc,stream,data|
          data.each_line{|line|
            puts line
            $output[$output.size] = line
          }
        }
      end
    end
    return $output
  end

end
