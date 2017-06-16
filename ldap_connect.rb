require 'rubygems'
require 'net/ldap'
require_relative "secrets"

# {{{ global defs
def print_dotted_line
  # Prints a horizontal line for data separation
  65.times do |i|
  print '-'
  if i == 64
    puts '-'
  end
  end
end
#}}}


@user = [ "bbraunstein", "bbondarenko", "bfrost" ]

ldap = Net::LDAP.new :host => Host,
    :port => 389,
    :auth => {
      :method => :simple,
      :username => Username,
      :password => Password
    }

if @user.is_a?(Array)
  @user.each do |u|
    filter = Net::LDAP::Filter.eq("cn", u)
    treebase = "dc=modusagency,dc=com"

    ldap.search( :base => treebase, :filter => filter ) do |entry|
      puts "DN: #{entry.dn}"
      entry.each do |attribute, values|
        print "#{attribute}: "
        values.each do |value|
          puts "#{value}"
        end
      end
    end
    # Print dotted line to sanitize results
    print_dotted_line
  end
else
  filter = Net::LDAP::Filter.eq("cn", @user)
  treebase = "dc=modusagency,dc=com"

  ldap.search( :base => treebase, :filter => filter ) do |entry|
    puts "#{entry.dn}"
    entry.each do |attribute, values|
      puts "#{attribute}: "
      values.each do |value|
        puts "#{value}"
      end
    end
  end
end

# Uncomment for debug info on LDAP connection
#p ldap.get_operation_result
