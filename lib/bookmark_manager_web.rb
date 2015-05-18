require 'sinatra/base'
require_relative 'server'

class BookmarkManager < Sinatra::Base

  get '/' do
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params['url']
    title = params['title']
    Link.create(url: url, title: title)
    redirect to('/')
  end

end
