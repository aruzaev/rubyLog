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