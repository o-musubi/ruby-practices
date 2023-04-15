#!/usr/bin/env ruby

file_lists = Dir.glob('*')
maximum_columns = 3
column_difference = file_lists.size.ceildiv(maximum_columns)
displayed_columns = file_lists.sort.each_slice(column_difference).to_a

displayed_columns.each.with_index(1).cycle(column_difference) do |column, index|
  answer = [] << column.shift
  if column_difference < maximum_columns && !answer[0].nil? && index == (maximum_columns - 1)
    printf('%-30s', answer[0])
    puts "\n"
  elsif !answer[0].nil? && index == maximum_columns
    printf('%-30s', answer[0])
    puts "\n"
  elsif !answer[0].nil?
    printf('%-30s', answer[0])
  else
    print ''
    puts "\n"
  end
end
