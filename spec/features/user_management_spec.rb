require 'spec_helper'
require_relative 'helpers/session'
include SessionHelpers

feature 'User signs up' do

  # Strictly speaking, the tests that check the UI
  # (have_content, etc.) should be separate from the tests
  # that check what we have in teh DB. The reason is that
  # you should test one thing at a time, whereas
  # by mixing the two we're testing both
  # the business logic and the views.

  # However, let's not worry about this yet
  # to keep the example simple.

  scenario 'when being a new user visiting the site' do
    expect { sign_up }.to change(User, :count).by(1)
    expect(page).to have_content("Welcome, alice@example.com")
    expect(User.first.email).to eq('alice@example.com')
  end

  scenario 'with a password that does not match' do
    expect { sign_up('a@a.com', 'pass', 'wrong') }.to change(User, :count).by 0
    expect(current_path).to eq('/users')
    expect(page).to have_content('Password does not match the confirmation')
  end

  scenario 'with an email that is already registered' do
    expect { sign_up }.to change(User, :count).by 1
    expect { sign_up }.to change(User, :count).by 0
    expect(page).to have_content('This email is already taken')
  end

end

feature 'User signs in' do

  before(:each) do
    User.create(email: 'test@test.com',
                password: 'test',
                password_confirmation: 'test')
  end

  scenario 'with correct credentials' do
    visit '/'
    expect(page).not_to have_content('Welcome, test@test.com')
    sign_in('test@test.com', 'test')
    expect(page).to have_content('Welcome, test@test.com')
  end

  scenario 'with incorrect credentials' do
    visit '/'
    expect(page).not_to have_content('Welcome, test@test.com')
    sign_in('test@test.com', 'wrong')
    expect(page).not_to have_content('Welcome, test@test.com')
  end

end

feature 'User signs out' do

  before(:each) do
    User.create(email: 'test@test.com',
                password: 'test',
                password_confirmation: 'test')
  end

  scenario 'while being signed in' do
    sign_in('test@test.com', 'test')
    click_button 'Sign out'
    expect(page).to have_content('Good bye!') # where does this message go?
    expect(page).not_to have_content('Welcome, test@test.com')
  end

end

feature 'User forgets password' do

  before(:each) do
    User.create(email: 'test@test.com',
                password: 'test',
                password_confirmation: 'test')
  end

  scenario 'and submits a valid email, and gets a token' do
    visit '/sessions/new'
    expect(page).to have_content('Forgot password')
    fill_in 'forgot_email', with: 'test@test.com'
    click_button 'Forgot password'
    expect(page).to have_content('Please check your email')
  end

  scenario 'and submits an invalid email, and gets an error' do
    visit '/sessions/new'
    expect(page).to have_content('Forgot password')
    fill_in 'forgot_email', with: 'invalid@test.com'
    click_button 'Forgot password'
    expect(page).to have_content('Invalid email')
  end

  xscenario 'and submits a valid email with an expired token, and gets an error' do

    visit '/reset/:token'
    expect(page).to have_content('Expired link')
  end
end
