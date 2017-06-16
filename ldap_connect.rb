require 'rubygems'
require 'net/ldap'
require 'optparse'
require_relative "secrets"

options = { :username => nil, :filter => nil, :attrs => nil }

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ldap_connect.rb [options]"
  opts.on('-u', '--username <username>,..', 'Accepts single username or comma-separated list.') do |username|
    options[:username] = username.split(',')
  end
  opts.on('-f', '--filter <filter>', 'Specify a filter to constrain LDAP searches.') do |filter|
    options[:filter] = filter
  end
  opts.on('-a', '--attributes <attributes>', 'String or array of strings specifying the LDAP attributes to return from the server') do |attrs|
    options[:attrs] = attrs.split(',')
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


def print_dotted_line
  # Prints a horizontal line for data separation
  65.times do |i|
  print '-'
  if i == 64
    puts '-'
  end
  end
end

# Initialize connection to LDAP host
ldap = Net::LDAP.new :host => Host,
    :port => 389,
    :auth => {
      :method => :simple,
      :username => Username,
      :password => Password
    }

# Confirm binding to the LDAP server, otherwise fail
if ! ldap.bind
  fail(ldap.get_operation_result.to_s)
end

# NOTE: username.split(',') automatically converts class String
#       to class Array, even if its just one value.
# TODO:
#   * Add testing statements if user exists/is valid
#   * Integrate options[:filter]
#     - pass/fail if user is part of a group
options[:username].each do |user|
  filter = Net::LDAP::Filter.eq("cn", user)
  ldap.search( :base => Treebase, :filter => filter, :attributes => options[:attrs]) do |entry|
    puts "DN: #{entry.dn}"
    entry.each do |attribute, values|
      print "#{attribute}: "
      values.each do |value|
        puts "#{value}"
      end
    end
  end
  # Print dotted line to sanitize multiple results
  print_dotted_line
end
