#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  file_names = find_file_names
  formatted_file_names = format_file_names(file_names)
  display_files(formatted_file_names)
end

def find_file_names
  Dir.glob('*')
end

def format_file_names(found_file_names)
  file_names = found_file_names
  difference = column_difference(file_names)
  columns = splited_columns(file_names, difference)

  file_names_to_display = []
  chunk = []
  specific_count = MAXIMUM_COLUMNS - columns.size

  columns.cycle(difference).with_index(1) do |column, i|
    chunk << column.shift
    if !specific_count.zero? && (i % (MAXIMUM_COLUMNS - specific_count)).zero? ||
       specific_count.zero? && (i % MAXIMUM_COLUMNS).zero?
      file_names_to_display << chunk.clone
      chunk.clear
    end
  end
  file_names_to_display
end

def column_difference(file_names)
  file_names.size.ceildiv(MAXIMUM_COLUMNS)
end

def splited_columns(file_names, difference)
  file_names.each_slice(difference).to_a
end

def display_files(nested_file_names)
  width = nested_file_names.flatten.map { |a| a.to_s.bytesize }.max
  nested_file_names.each do |file_names|
    file_names.each { |file_name| printf("%-#{width}s\t", file_name) }
    puts ' '
  end
end

MAXIMUM_COLUMNS = 3
main
