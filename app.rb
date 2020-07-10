require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'csv'

set :public_folder, 'public'



enable :sessions

def db 
  PG::connect(
    :host => "localhost",
    :user => 'yshintani',
    :password => '',
    :dbname => "heroku_sinatra_nemo"
  )
end

get '/index' do
  sql = "select * from nemologs;"
  @nemologs = db.exec_params(sql).to_a
  erb :index

end

get '/log' do
  erb :log
end

get '/' do
  erb :topr, layout: nil
end

post '/post' do
  @image = params[:image][:filename]
  @species = params[:species]
  @date = params[:date]
  @location = params[:location]
  @size = params[:size]
  @depth = params[:depth]
  @memo = params[:memo]
  FileUtils.mv(params[:image][:tempfile], "./public/images/#{params[:image][:filename]}")
  db.exec("insert into nemologs (image, species, date, location, size, depth, memo) values($1, $2, $3, $4, $5, $6, $7)",[@image, @species, @date, @location, @size, @depth, @memo])
  redirect '/index'
end

get '/signup' do
  erb :signup
end

post '/signup' do 
  @name = params[:name]
  @password = params[:password]
  db.exec("insert into users (name, password) values($1, $2)",[@name, @password])
  redirect '/index'
end

get '/login' do
  erb :login
end

post '/login' do
  name = params[:name]
  password = params[:password]
  id = db.exec("select id from users where name = $1 and password = $2",[name, password]).first
  if id.nil?
    redirect '/login'
  else
    session[:id] = id['id']
    redirect '/index'
  end
end


# get '/image' do
#   @images = Dir.glob("./public/images/*").map{|path| path.split('/').last }
#   erb :upload
# end

# get '/nemolog' do
#   sql = "select * from nemolog;"
#   @users = db.exec_params(sql).to_a
#   erb :nemologs
# end


get '/nemolog/:id' do
  id = params[:id]
  sql = "select * from nemologs where id = #{id};"
  @nemologs = db.exec_params(sql)[0]
  erb :individual
end

get '/list' do
  sql = "select * from nemologs;"
  @nemologs = db.exec_params(sql).to_a
  # binding.irb
  # content_type "text/csv"
  # attachment "text.csv"
  # File.write('nemo.txt', @nemolog)
  erb :list
end
