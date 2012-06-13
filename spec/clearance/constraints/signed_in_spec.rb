require 'spec_helper'

describe Clearance::Constraints::SignedIn do
  it 'returns true when user is signed in' do
    user = create(:user, :remember_token => 'abc')

    signed_in_constraint = Clearance::Constraints::SignedIn.new
    signed_in_constraint.matches?(request_with_remember_token(user.remember_token)).should be_true
  end

  it 'returns false when user is not signed in' do
    signed_in_constraint = Clearance::Constraints::SignedIn.new
    signed_in_constraint.matches?(request_with_remember_token(nil)).should be_false
  end

  it 'yields a signed-in user to a provided block' do
    user = create(:user, :email => 'before@example.com')
    signed_in_constraint = Clearance::Constraints::SignedIn.new do |user|
      user.update_attribute(:email, 'after@example.com')
    end

    signed_in_constraint.matches?(request_with_remember_token(user.remember_token))
    user.reload.email.should == 'after@example.com'
  end

  it 'does not yield a user if they are not signed in' do
    user = create(:user, :email => 'before@example.com')

    signed_in_constraint = Clearance::Constraints::SignedIn.new do |user|
      user.update_attribute(:email, 'after@example.com')
    end

    signed_in_constraint.matches?(request_with_remember_token(nil))
    user.reload.email.should == 'before@example.com'
  end

  def request_with_remember_token(remember_token)
    cookies = {'action_dispatch.cookies' => {
      Clearance::Session::REMEMBER_TOKEN_COOKIE => remember_token
    }}
    env = { :clearance => Clearance::Session.new(cookies) }
    Rack::Request.new(env)
  end
end
