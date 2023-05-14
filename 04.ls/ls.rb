#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
MAXIMUM_COLUMNS = 3

def main
  file_names = find_file_names
  formatted_file_names = format_file_names(file_names)
  display_file_names(formatted_file_names)
end

def find_file_names
  params = ARGV.getopts('a')
  flags = params['a'] ? File::FNM_DOTMATCH : 0
  Dir.glob('*', flags)
end

def format_file_names(found_file_names)
  file_names = found_file_names
  row_size = file_names.size.ceildiv(MAXIMUM_COLUMNS)
  splitted_rows = file_names.each_slice(row_size).to_a
  swap_file_names(row_size, splitted_rows)
end

def swap_file_names(row_size, rows)
  file_names_to_display = []
  chunk = []
  specific_count = MAXIMUM_COLUMNS - rows.size

  rows.cycle(row_size).with_index(1) do |row, i|
    chunk << row.shift
    if !specific_count.zero? && (i % (MAXIMUM_COLUMNS - specific_count)).zero? ||
       specific_count.zero? && (i % MAXIMUM_COLUMNS).zero?
      file_names_to_display << chunk.clone
      chunk.clear
    end
  end
  file_names_to_display
end

def display_file_names(nested_file_names)
  width = nested_file_names.flatten.map { |a| a.to_s.bytesize }.max
  nested_file_names.each do |file_names|
    file_names.each { |file_name| printf("%-#{width}s\t", file_name) }
    puts ' '
  end
end

main
