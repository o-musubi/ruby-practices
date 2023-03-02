#!/usr/bin/env ruby

require 'date'
require 'optparse'

# 今日の月、年を変数に代入
def today
  @month = Date.today.month
  @year = Date.today.year
end

# オプションの引数として指定した数字があれば変数に代入
def to_i_arguments
  params = ARGV.getopts("m:y:")
  @month = params["m"].to_i  unless params["m"] == nil
  @year = params["y"].to_i unless params["y"] == nil
end

# 想定していない引数が指定された場合今日の月、年を変数に代入
def unexpected_arguments
  unless (1..12).cover?(@month) && (1970..2100).cover?(@year)
    puts "想定していない引数が与えられました。\nデフォルト値(今日)を指定します。" ,"\s"
    today
  end
end

# (日付を繰り返し表示するための)基準日
def base_date 
  @first_date = Date.new(@year,@month,1)
  @last_date = Date.new(@year,@month,-1)
end

# カレンダーのヘッダー部分を出力する
def output_header
  puts "\s" * 5 + "#{@month}月" + "\s" + "#{@year}"
  ["日", "月", "火", "水", "木", "金", "土"].each {|str| print str, "\s"}
  print "\n"
  @first_date.wday.times {print "\s" * 3}
end

# カレンダーの日付の部分を出力する
def output_main
  (@first_date..@last_date).each do |a_date| 
  print  a_date.strftime("%e"), "\s"
  print "\n" if a_date.saturday?
  end
end

today
to_i_arguments
unexpected_arguments
base_date
output_header
output_main
