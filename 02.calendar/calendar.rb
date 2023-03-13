#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def recieve_options
  params = ARGV.getopts('m:', 'y:')
  recieved_options = { month: params['m'].to_i, year: params['y'].to_i }
  recieved_options[:month] = Date.today.month unless (1..12).cover?(recieved_options[:month])
  recieved_options[:year] = Date.today.year unless (1970..2100).cover?(recieved_options[:year])
  recieved_options
end

def determine_period
  options = recieve_options
  {
    first: Date.new(options[:year], options[:month], 1),
    last: Date.new(options[:year], options[:month], -1)
  }
end

def print_calendar
  period = determine_period
  puts "#{"\s" * 5}#{period[:first].month}月 #{period[:first].year}"
  puts '日 月 火 水 木 金 土'
  period[:first].wday.times { print "\s" * 3 }
  (period[:first]..period[:last]).each do |date|
    print date.strftime('%e'), "\s"
    print "\n" if date.saturday?
  end
end

print_calendar
