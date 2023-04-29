#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  files = format_files
  width = files[:list].map { |a| a.to_s.bytesize }.max
  files[:displayed_files].each do |displayed_files|
    displayed_files.each do |displayed_file|
      printf("%-#{width}s\t", displayed_file)
    end
    puts ' '
  end
end

def format_files
  files = find_files
  column_difference = files[:list].size.ceildiv(MAXIMUM_COLUMNS)
  splited_columns = files[:list].each_slice(column_difference).to_a
  sorted_files = []
  splited_columns.cycle(column_difference) { |splited_column| sorted_files << splited_column.shift }

  specific_count = MAXIMUM_COLUMNS - splited_columns.size
  files[:displayed_files] =
    if specific_count.zero?
      sorted_files.each_slice(MAXIMUM_COLUMNS).to_a
    else
      sorted_files.each_slice(MAXIMUM_COLUMNS - specific_count).to_a
    end
  files
end

def find_files
  {
    list: Dir.glob('*')
  }
end

MAXIMUM_COLUMNS = 3
main
