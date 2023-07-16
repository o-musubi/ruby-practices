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
  file_names.each_with_object([]) do |file_name, texts|
    File.open(file_name) { |lines| texts << lines.readlines.join }
  end
end

def count(texts)
  {
    l: texts.each_with_object([]) { |text, lines_count| lines_count << text.count("\n") },
    w: texts.each_with_object([]) { |text, words_count| words_count << text.squeeze(' ').split.size },
    c: texts.each_with_object([]) { |text, byte_count| byte_count << text.bytesize }
  }
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
  if filtered_data[0].size == 1
    {
      width: calculate_width(filtered_data),
      data: [filtered_data.flatten]
    }
  else
    filtered_data.each { |array| array << array.sum }
    {
      width: calculate_width(filtered_data),
      data: sort_data(filtered_data)
    }
  end
end

def calculate_width(filtered_data)
  filtered_data.flatten.map { |data| data.to_s.bytesize }.max
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

def output(displayed_data, file_names)
  if file_names.empty?
    displayed_data[:data].flatten.each { |data| print '     ', data.to_s }
    puts ' '
  else
    file_names << 'total' unless displayed_data[:data].size == 1
    displayed_data[:data].each_with_index do |displayed_array, index|
      displayed_array.each do |array|
        print array.to_s.rjust(displayed_data[:width])
        print ' '
      end
      puts file_names[index]
    end
  end
end

main
