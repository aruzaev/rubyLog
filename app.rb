require 'sinatra'

get '/write' do
  erb :write
end

post '/save' do
  log = params[:log]
  time = Time.now
  formattedTime = time.strftime("%B %d, %Y - %I:%M %p")
  timedLog = "[#{formattedTime}] #{log}"

  File.open("log.txt", "a") { |file| file.puts(timedLog)}

  redirect "/entries"
end
  
get "/entries" do
  @entries = File.exist?("log.txt") ? File.readlines("log.txt") : []
  erb :entries
end
