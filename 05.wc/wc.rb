#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  params = pick_params_from_argv
  file_names = ARGV
  source_data = select_source_data(file_names)
  counted_data = count(source_data)
  filtered_data = filter_data_by_argument(params, counted_data)
  transformed_data = transform_data(filtered_data)
  output(transformed_data, file_names)
end

def pick_params_from_argv
  opt = OptionParser.new
  params = {}
  opt.on('-l') { |param| param }
  opt.on('-w') { |param| param }
  opt.on('-c') { |param| param }
  opt.parse!(ARGV, into: params)
  params
end

def select_source_data(file_names)
  if file_names.empty?
    [$stdin.read]
  else
    open_file(file_names)
  end
end

def open_file(file_names)
  file_names.map do |file_name|
    File.open(file_name) { |lines| lines.readlines.join }
  end
end

def count(texts)
  {
    l: texts.map { |text| text.count("\n") },
    w: texts.map { |text| text.squeeze(' ').split.size },
    c: texts.map(&:bytesize)
  }
end

def filter_data_by_argument(params, counted_data)
  params = { l: true, w: true, c: true } if params.empty?
  filtered_data = counted_data.select { |key| params[key] }
  filtered_data.values
end

def transform_data(filtered_data)
  if filtered_data[0].size == 1
    {
      width: calculate_width(filtered_data),
      data: [filtered_data.flatten]
    }
  else
    added_total_data = filtered_data.dup.each { |data| data << data.sum }
    {
      width: calculate_width(added_total_data),
      data: added_total_data.transpose
    }
  end
end

def calculate_width(filtered_data)
  filtered_data.flatten.map { |data| data.to_s.bytesize }.max
end

def output(displayed_data, file_names)
  if file_names.empty?
    displayed_data[:data].flatten.each { |data| print '     ', data.to_s }
    puts ' '
  else
    displayed_data[:data].each_with_index do |displayed_array, index|
      print displayed_array.map { |array| array.to_s.rjust(displayed_data[:width]) }.join(' ')
      puts file_names[index] ? " #{file_names[index]}" : ' total'
    end
  end
end

main
