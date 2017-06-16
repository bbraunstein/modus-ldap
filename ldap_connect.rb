require 'rubygems'
require 'net/ldap'
require 'optparse'
require_relative "secrets"

options = { :username => nil, :filter => nil }

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ldap_connect.rb [options]"
  opts.on('-u', '--username <username>,..', 'Accepts single username or comma-separated list.') do |username|
    options[:username] = username.split(',')
  end
  opts.on('-f', '--filter <filter>', 'Specify a filter to constrain LDAP searches.') do |filter|
    options[:filter] = filter
  end
  opts.on('-h', '--help', 'Displays this help and exit.') do
    puts opts
    exit
  end
end

parser.parse!

if options[:username] == nil
  puts "Error: no username specified."
  exit
end

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

ldap = Net::LDAP.new :host => Host,
    :port => 389,
    :auth => {
      :method => :simple,
      :username => Username,
      :password => Password
    }

if options[:username].is_a?(Array)
  options[:username].each do |u|
    filter = Net::LDAP::Filter.eq("cn", u)
    ldap.search( :base => Treebase, :filter => filter ) do |entry|
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
  filter = Net::LDAP::Filter.eq("cn", options[:username])
  ldap.search( :base => Treebase, :filter => filter ) do |entry|
    puts "#{entry.dn}"
    entry.each do |attribute, values|
      print "#{attribute}: "
      values.each do |value|
        puts "#{value}"
      end
    end
  end
end

# Uncomment for debug info on LDAP connection
#p ldap.get_operation_result
