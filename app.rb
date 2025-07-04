require 'sinatra'
require 'time'
require 'date'

get '/hello' do
  @name = "Artem"
  erb :hello
end

get '/' do
  puts "redirecting to /write"
  redirect "/write"
end

get '/write' do
  erb :write
end

post '/submit' do
  log = params[:log]
  time = Time.now
  formattedTime = time.strftime("%B %d, %Y - %I:%M %p")
  timedLog = "[#{formattedTime}] #{log}"

  File.open("log.txt", "a") { |file| file.puts(timedLog)}

  redirect "/entries"
end
  
get "/entries" do
  @entries = File.exist?("log.txt") ? File.readlines("log.txt") : []

  current_year = Time.now.year
  current_month = Time.now.month

  @filled_days = []
  @entries.each do |entry|
    if (ts = entry[/\[(.*?)\]/, 1])
      time = Time.parse(ts) rescue nil
      if time && time.year == current_year && time.month == current_month
        @filled_days << time.day
      end
    end
  end
  @filled_days.uniq!

  if params['day']
    day = params['day'].to_i
    @entries = @entries.select do |entry|
      if (ts = entry[/\[(.*?)\]/, 1])
        t = Time.parse(ts) rescue nil
        t && t.year == current_year && t.month == current_month && t.day == day
      else
        false
      end
    end
  end

  @days_in_month = Date.civil(current_year, current_month, -1).day

  erb :entries
end

post "/delete" do
  index = params[:index].to_i
  entries = File.exist?("log.txt") ? File.readlines("log.txt") : []

  if index >= 0 && index < entries.length
    # entries are displayed in reverse order, so delete from the end
    entries.delete_at(-1 - index)
    File.open("log.txt", "w") { |f| f.puts(entries) }
  end

  redirect "/entries"
end

get "/export" do
  if File.exist?("log.txt")
    send_file "log.txt", filename: "log.txt", type: "text/plain", disposition: "attachment"
  else
    status 404
    "No log available"
  end
end
