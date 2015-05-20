post '/reset' do
  email = params[:forgot_email]
  user = User.first(email: email)
  if user
    user.password_token = (1..10).map{('A'..'Z').to_a.sample}.join
    user.password_token_timestamp = Time.now
    user.save
    flash[:notice] = 'Please check your email'
  else
    flash[:notice] = 'Invalid email'
  end
end