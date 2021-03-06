require "test_helper"

describe UsersController do
  describe 'auth_callback' do
    it 'creates an account for a new user and redirects to the root route' do
      start_count = User.count
      user = User.create(provider: 'github', uid: 87_872, username: 'test_user', name: 'Test User', email: 'test@user.com')

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal start_count + 1

      session[:user_id].must_equal User.last.id
    end

    it 'logs in an existing user and redirects to the root route' do
      start_count = User.count
      user = users(:bob)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal user.id

      User.count.must_equal start_count
    end

    it 'redirects to the login route if given invalid user data' do
      start_count = User.count
      user = User.new(provider: 'github', uid: -8, username: 'test', name: 'Test User', email: 'test@user.com')

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
      get auth_callback_path(:github)

      must_redirect_to root_path

      User.count.must_equal start_count
    end

    it 'redirects to the login route and deletes the session when the user logs out' do
      user = users(:bob)
      perform_login(user)
      delete logout_path(user)
      must_redirect_to root_path

      session[:user_id].must_equal nil
    end
end
end
