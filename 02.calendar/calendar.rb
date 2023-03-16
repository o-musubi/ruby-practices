#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def recieve_options
  params = ARGV.getopts('m:', 'y:')
  options = { month: params['m'].to_i, year: params['y'].to_i }
  options[:month] = Date.today.month unless (1..12).cover?(options[:month])
  options[:year] = Date.today.year unless (1970..2100).cover?(options[:year])
  options
end

def determine_dates
  options = recieve_options
  {
    first: Date.new(options[:year], options[:month], 1),
    last: Date.new(options[:year], options[:month], -1)
  }
end

def print_calendar
  dates = determine_dates
  puts "     #{dates[:first].month}月 #{dates[:first].year}"
  puts '日 月 火 水 木 金 土'
  dates[:first].wday.times { print '   ' }
  (dates[:first]..dates[:last]).each do |date|
    print date.strftime('%e'), "\s"
    print "\n" if date.saturday?
  end
end

print_calendar
