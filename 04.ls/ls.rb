#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  file = format_file
  file[:splited_columns].each.with_index(1).cycle(file[:column_difference]) do |column, index|
    displayed_columns = [] << column.shift
    if displayed_columns[0].nil?
      puts ' '
    elsif file[:splited_columns[file[:specific_number]]].nil? && index == file[:specific_number]
      printf('%-20s', displayed_columns[0])
      puts ' '
    elsif index == file[:maximum_columns]
      printf('%-20s', displayed_columns[0])
      puts ' '
    else
      printf('%-20s', displayed_columns[0])
    end
  end
end

def set_conditions
  {
    file: Dir.glob('*'),
    maximum_columns: 3
  }
end

def format_file
  condition = set_conditions
  condition[:column_difference] = condition[:file].size.ceildiv(condition[:maximum_columns])
  condition[:splited_columns] = condition[:file].sort.each_slice(condition[:column_difference]).to_a
  condition[:specific_number] = condition[:splited_columns].size
  condition
end

main
