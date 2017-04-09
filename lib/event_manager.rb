require "csv"
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

puts "EventManager Initialized!"

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def clean_phone(phone)
  phone_s= phone.to_s.scan(/\d+/).join
  phone_length = phone_s.length
  if phone_length == 10
    "#{phone_s[0..2]}-#{phone_s[3..5]}-#{phone_s[6..9]}"
  elsif phone_length == 11 and phone_s[0] == "1"
    "1-#{phone_s[1..3]}-#{phone_s[4..6]}-#{phone_s[7..10]}"
  else
    "missing"
  end
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end


def peak_time_tally(reg_date)
  @peak_time = Hash.new(0) unless @peak_time
  @peak_time[reg_date.hour] += 1
end

def peak_time_table
  sorted = @peak_time.sort_by {|time, occurrence| time}
  puts "time: occurence"
  sorted.each do |i|
    puts "#{i[0].to_s.rjust(4)}: #{i[1].to_s.rjust(5)}"
  end
end

def peak_wday_tally(reg_date)
  @peak_wday = Hash.new(0) unless @peak_wday
  @peak_wday[reg_date.wday] += 1
end

def peak_wday_table
  sorted = @peak_wday.sort_by {|wday, occurrence| wday}
  puts "   weekday: occurence"
  sorted.each do |i|
    case i[0]
    when 0
      then wday = :Sunday
    when 1
      then wday = :Monday
    when 2
      then wday = :Tuesday
    when 3
      then wday = :Wednesday
    when 4
      then wday = :Thurday
    when 5
      then wday = :Friday
    when 6
      then wday = :Saturday
    end

    puts "#{wday.to_s.rjust(10)}: #{i[1].to_s.rjust(5)}"
  end
end

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter



contents.each do |row|
#  id = row[0]
#  name = row[:first_name]
#  zipcode = clean_zipcode(row[:zipcode])
#  legislators = legislators_by_zipcode(zipcode)
  phone = clean_phone(row[:homephone])
#  puts phone

  reg_date = DateTime.strptime(row[:regdate],'%m/%d/%Y %H:%M')
  peak_time_tally(reg_date)
  peak_wday_tally(reg_date)

#  form_letter = erb_template.result(binding)
#  save_thank_you_letters(id, form_letter)
end

peak_time_table
peak_wday_table



#lines = File.readlines("event_attendees.csv")
#lines.each_with_index do |line, index|
#  next if index == 0
#  columns = line.split(",")
#  name = columns[2]
#  puts name
#end
