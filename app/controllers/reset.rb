post '/reset' do
  email = params[:forgot_email]
  user = User.first(email: email)
  if user
    user.password_token = (1..10).map{('A'..'Z').to_a.sample}.join
    user.password_token_timestamp = Time.now
    user.save
    user.send_simple_message
    flash[:notice] = 'Please check your email'
  else
    flash[:notice] = 'Invalid email'
  end
end

get '/reset/:token' do
  @token = params[:token]
  @user = User.first(password_token: @token)
  if @user
    time_now = Time.new
    time_now = time_now.strftime("%H")
    time_stamp = @user.password_token_timestamp
    time_stamp = time_stamp.strftime("%H")
    if time_now.to_i - time_stamp.to_i >= 2
      flash[:notice] = 'Expired link'
    else
      erb :reset_password
    end
  else
    flash[:notice] = 'Incorrect token'
  end
end

post '/reset/done' do
  @token = params[:token]
  @user = User.first(password_token: @token)
  @user.password = params[:password]
  @user.password_confirmation = params[:password_confirmation]
  @user.password_token = nil
  @user.password_token_timestamp = nil
  @user.save
  flash[:notice] = 'Password updated'
  redirect to '/'
end