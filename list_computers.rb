require "net/ping"

@domain = "alara.co.uk"
@username
@password

IO.popen('ldapsearch -LLL -H ldap://alarasvr.factory.alara.co.uk -x -D "factory\cjlapao" -w "!512Cf61b" -b "dc=factory,dc=alara,dc=co,dc=uk" "objectClass=computer" name
') {|s1|
  s1.each{|line|
    if line.include?('name:')
      nline = line[line.index(":")+2..line.length-2]
      ipa = nline+"."+@domain
      p1 = Net::Ping::External.new(ipa)
      if p1.ping? == true
        puts "Host #{ipa} Alive"
      else
        puts "Host #{ipa} Dead"
      end
    end
  }
}
