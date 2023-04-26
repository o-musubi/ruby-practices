#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  condition = find_condition
  condition[:splited_columns].each.with_index(1).cycle(condition[:column_difference]) do |column, index|
    displayed_name = column.shift
    printf("%-#{condition[:maximum]}s\t", displayed_name)
    puts ' ' if displayed_name.nil? || index == MAXIMUM_COLUMNS || !condition[:specific_case].zero? && index == MAXIMUM_COLUMNS - condition[:specific_case]
  end
end

def find_file
  {
    list: Dir.glob('*')
  }
end

def find_condition
  file = find_file
  file[:column_difference] = file[:list].size.ceildiv(MAXIMUM_COLUMNS)
  file[:maximum] = file[:list].map { |a| a.to_s.bytesize }.max
  file[:splited_columns] = file[:list].each_slice(file[:column_difference]).to_a
  file[:specific_case] = MAXIMUM_COLUMNS - file[:splited_columns].size
  file
end

MAXIMUM_COLUMNS = 3
main
