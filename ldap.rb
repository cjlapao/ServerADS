require "rubygems"
require "net/ping"

$computers = []

class Computers
  attr_accessor :count
  @@computers = []

  def initialize
    @count = 0
  end

  def insert(name,domain)
    c = Computer.new
    c.name = name
    c.domain = domain
    c.alive?
    @@computers.push(c)
    @count += 1
  end

  def items
    @@computers
  end
end

class Computer
  attr_accessor :name, :domain, :status, :querydate

  def alive?
    pingit = Net::Ping::External.new(name+'.'+domain)
    if pingit.ping? == true
      status = true
    else
      status = false
    end
  end
end

class Ldap
  def initialize(server,domain)
    @@domain = domain
    @@server = server
    @cs = Computers.new
    listComputers
  end

  def listComputers
    IO.popen('ldapsearch -LLL -H ldap://'+@@server+'.'+@@domain+' -x -D "factory\cjlapao" -w "!512Cf61b" -b "dc=factory,dc=alara,dc=co,dc=uk" "objectClass=computer" name') {|s1|
      s1.each{|line|
        if line.include?('name:')
          nline = line[line.index(":")+2..line.length-2]
          @cs.insert(nline,@@domain)
        end
      }
    }
  end

  def computers
    @cs
  end
end
