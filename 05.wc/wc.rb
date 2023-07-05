#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  params = pick_params_from_argv
  source_data = select_source_data
  counted_data = count(source_data)
  filtered_data = filter_data_by_argument(params, counted_data)
  transformed_data = transform_data(filtered_data)
  output(transformed_data)
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

def select_source_data
  if ARGV.empty?
    $stdin.read
  else
    open_file(ARGV)
  end
end

def open_file(file_names)
  file_names.each_with_object([]) do |file_name, texts|
    File.open(file_name) { |lines| texts << lines.readlines.join }
  end
end

def count(texts)
  {
    l: count_lines(texts),
    w: count_words(texts),
    c: count_byte(texts)
  }
end

def count_lines(texts_of_file)
  lines_count = []
  if texts_of_file.instance_of?(Array)
    texts_of_file.each { |text| lines_count << text.count("\n") }
  else
    lines_count << texts_of_file.count("\n")
  end
  lines_count
end

def count_words(texts_of_file)
  words_count = []
  if texts_of_file.instance_of?(Array)
    texts_of_file.each { |text| words_count << text.squeeze(' ').split.size }
  else
    words_count << texts_of_file.squeeze(' ').split.size
  end
  words_count
end

def count_byte(texts_of_file)
  byte_count = []
  if texts_of_file.instance_of?(Array)
    texts_of_file.each { |text| byte_count << text.bytesize }
  else
    byte_count << texts_of_file.bytesize
  end
  byte_count
end

def filter_data_by_argument(params, counted_data)
  filtered_data = []
  params = { l: true, w: true, c: true } if params.empty?
  %i[l w c].each do |param|
    filtered_data << counted_data.fetch(param) if params[param]
  end
  filtered_data
end

def transform_data(filtered_data)
  if ARGV.empty?
    {
      width: calculate_width(filtered_data),
      data: filtered_data.flatten
    }
  else
    add_total(filtered_data)
    {
      width: calculate_width(filtered_data),
      data: sort_data(filtered_data)
    }
  end
end

def calculate_width(filtered_data)
  filtered_data.flatten.map { |data| data.to_s.bytesize }.each_slice(filtered_data.size).to_a.map(&:max)
end

def add_total(filtered_data)
  filtered_data.each { |array| array << array.sum } unless (filtered_data[0].size == 1) || ARGV.empty?
end

def sort_data(filtered_data)
  number_of_times = filtered_data[0].size
  chunk = []
  displayed_array = []
  filtered_data.cycle(number_of_times) { |array| chunk << array.shift }
  second_number_of_times = filtered_data.size
  chunk.each_slice(second_number_of_times) { |data| displayed_array << data }
  displayed_array
end

def output(displayed_data)
  if ARGV.empty?
    displayed_data[:data].each { |array| printf("%#{displayed_data[:width].join.to_i * 2}s ", array) }
  else
    file_name = ARGV.dup
    file_name << 'total' if (file_name.size != 1) && !ARGV.empty?
    displayed_data[:data].each_with_index do |displayed_array, first_index|
      displayed_array.each_with_index do |array, second_index|
        printf("%#{displayed_data[:width][second_index]}s ", array)
      end
      print "#{file_name[first_index]}\n"
    end
  end
end

main
