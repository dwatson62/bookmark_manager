require 'data_mapper'
require 'sinatra'
require 'rack-flash'
require './lib/link'
require './lib/tag'
require './lib/user'
require './data_mapper_setup'

enable :sessions
set :session_secret, 'super secret'
use Rack::Flash
use Rack::MethodOverride

  helpers do

    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end

  end

  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    tags = params['tags'].split(' ').map do |tag|
      # this will either find this tag or create
      # it if it doesn't exist already
      Tag.first_or_create(text: tag)
    end
    url = params['url']
    title = params['title']
    Link.create(url: url, title: title, tags: tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(text: params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    # note the view is in views/users/new.erb
    # we need the quote because otherwise
    # ruby would divide the symbol :users by the
    # variable new (which makes no sense)
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    # we just initialize the object
    # without saving it. It may be invalid
    @user = User.create(email: params[:email],
                password: params[:password],
                password_confirmation: params[:password_confirmation])
    # let's try saving it
    # if the model is valid
    # it will be saved
    if @user.save
      session[:user_id] = @user.id
      redirect to ('/')
      # if it's not valid,
      # we'll show the same
      # form again
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash[:errors] = ['The email or password is incorrect']
      erb :'sessions/new'
    end
  end

  delete '/sessions' do
    flash[:notice] = 'Good bye!'
    session[:user_id] = nil
    redirect to('/')
  end