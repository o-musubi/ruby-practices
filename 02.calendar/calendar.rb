#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def option_valid?
  params = ARGV.getopts('m:', 'y:')
  option = { month: params['m'].to_i, year: params['y'].to_i }
  option[:month] = Date.today.month unless (1..12).cover?(option[:month])
  option[:year] = Date.today.year unless (1970..2100).cover?(option[:year])
  option
end

def first_last
  base_date = option_valid?
  target_period = {}
  target_period[:first] = Date.new(base_date[:year], base_date[:month], 1)
  target_period[:last] = Date.new(base_date[:year], base_date[:month], -1)
  target_period
end

def print_calendar
  print_period = first_last
  puts "#{'\s' * 5}#{print_period[:first].month}月\\s#{print_period[:first].year}"
  %(日 月 火 水 木 金 土).each { |str| print str, '\s' }
  print '\n'
  print_period[:first].wday.times { print '\s' * 3 }
  (print_period[:first]..print_period[:last]).each do |date|
    print date.strftime('%e'), '\s'
    print '\n' if date.saturday?
  end
end

print_calendar
