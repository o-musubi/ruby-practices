#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
MAXIMUM_COLUMNS = 3
TYPE_PATTERNS = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze
PERMISSION_PATTERNS = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def main
  params = ARGV.getopts('l')
  file_information = fetch_file_information(params)
  formatted_file_information = params['l'] ? format_file_details(file_information) : format_file_names(file_information)
  output_file_information(formatted_file_information, file_information, params)
end

def fetch_file_information(params)
  file_names = Dir.glob('*')
  params['l'] ? fetch_details(file_names) : file_names
end

def fetch_details(file_names)
  file_names.each_with_object([]) do |file_name, details|
    object = File.stat(file_name)
    details << {
      file_mode: object.mode.to_s(8),
      hardlink: object.nlink,
      user_id: object.uid,
      group_id: object.gid,
      file_size: object.size,
      last_update_time: object.mtime,
      file_names: file_name
    }
  end
end

def format_file_details(file_details)
  file_details.map do |file_detail|
    [
      file_mode_bit_to_string(file_detail[:file_mode]),
      file_detail[:hardlink],
      Etc.getpwuid(file_detail[:user_id]).name,
      Etc.getgrgid(file_detail[:group_id]).name,
      file_detail[:file_size],
      file_detail[:last_update_time].strftime('%a %d %H:%M'),
      file_detail[:file_names]
    ]
  end
end

def file_mode_bit_to_string(number)
  number.prepend('0') if number.size == 5
  type = TYPE_PATTERNS[number[0..1]]
  permission = replace_permission(number[3..5])
  permission = replace_specific_permisson(permission, number[2]) unless number[2].to_i.zero?
  type.dup << permission
end

def replace_permission(number)
  splitted_numbers = number.chars
  permission = +''
  splitted_numbers.each { |splitted_number| permission << PERMISSION_PATTERNS[splitted_number] }
  permission
end

def replace_specific_permisson(permission, number)
  case number
  when '1'
    permission[8] = permission[8].tr('x', 't').tr('-', 'T')
  when '2'
    permission[5] = permission[5].tr('x', 's').tr('-', 'S')
  when '4'
    permission[2] = permission[2].tr('x', 's').tr('-', 'S')
  when '6'
    permission[5] = permission[5].tr('x', 's').tr('-', 'S')
    permission[2] = permission[2].tr('x', 's').tr('-', 'S')
  end
  permission
end

def format_file_names(file_names)
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

def output_file_information(formatted_file_information, file_information, params)
  widths = params['l'] ? calculate_widths_loption(formatted_file_information) : calculate_widths(file_information)
  display_total(formatted_file_information) if params['l']
  display_body(formatted_file_information, widths)
end

def calculate_widths_loption(file_details)
  row_size = file_details.size
  detail_sizes = file_details.flatten.map { |detail| detail.to_s.bytesize }.each_slice(7).to_a

  widths = []
  chunk = []

  detail_sizes.cycle(7).with_index(1) do |detail_size, i|
    chunk << detail_size.shift
    if (i % row_size).zero?
      widths << chunk.clone
      chunk.clear
    end
  end
  widths.map(&:max).flatten
end

def calculate_widths(file_names)
  row_size = file_names.size.ceildiv(MAXIMUM_COLUMNS)
  widths = file_names.map { |file_name| file_name.to_s.bytesize }
  widths.each_slice(row_size).to_a.map(&:max)
end

def display_total(file_details)
  total_size = file_details.map { |detail| detail[4].ceildiv(4096) * 4 }.sum
  puts "total #{total_size}"
end

def display_body(nested_file_information, widths)
  nested_file_information.each do |file_information|
    file_information.each_with_index do |information, index|
      printf("%-#{widths[index]}s ", information)
    end
    puts ' '
  end
end

main
