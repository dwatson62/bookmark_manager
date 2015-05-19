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