require 'sinatra'
require 'sass'
require 'coffee-script'
require 'yaml'
require 'json'
require 'excon'

$data = nil

configure :development do
  require 'rack/reloader'
  Sinatra::Application.reset!
  use Rack::Reloader
end

set :protection, :except => :frame_options

get '/' do
  erb :index, :layout => :layout
end

DATA_SOURCE = "https://github.com/triketora/women-in-software-eng/raw/master/data.txt"

get '/data.json' do
  $data ||= begin
    contents = Excon.get(
      DATA_SOURCE,
      ssl_version: :TLSv1,
      middlewares: Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower]
    ).body

    # YAML-ify
    contents = contents.gsub(/^\[(.*?)\]/, '\1:').gsub(/^[\t ]+/, '  ')

    data = YAML.load(contents)
  end
  JSON.dump($data)
end

get '/screen.css' do
  scss :"stylesheets/screen"
end

get '/:name.js' do
  coffee :"#{params[:name]}"
end

get '/:name' do
  erb :"/#{params[:name].to_sym}"
end