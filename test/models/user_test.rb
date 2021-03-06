require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
  	@user = User.new(name: "Example User", email: "user@example.org", password: "fubareh", password_confirmation: "fubareh")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "name should be present" do
  	@user.name = "     "
  	assert_not @user.valid?
  end

  test "name should not be too long" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = "    "
  	assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "a" * 244 + "@example.com"
  	assert_not @user.valid?
  end

  test "email addresses should be unique" do
  	duplicate_user = @user.dup
  	duplicate_user.email = @user.email.upcase
  	@user.save
  	assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "email validation should accept valid addresses" do
  	valid_addresses = %w[user@example.com USER@fu.com A_US-ER@fu.bar.org first.last@fu.jp alice+bob@bar.cn]
  	valid_addresses.each do |valid_address|
  		@user.email = valid_address
  		assert @user.valid?, "#{valid_address.inspect} should be valid"
  	end
  end

  test "email validation should reject invalid email addresses" do
  	invalid_addresses = %w[user@example,org user_at_fu.org user.name@example. fu@bar_baz.com fu@bar+baz.com fu@bar..com]
  	invalid_addresses.each do |invalid_address|
  		@user.email = invalid_address
  		assert_not @user.valid?, "#{invalid_address} should be invalid"
  	end
  end

  test "password should be present" do
  	@user.password = @user.password_confirmation = " " * 6
  	assert_not @user.valid?
  end

  test "password should have a minimum length" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert_not @user.valid?
  end

  test "authenticated? shoudl return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, nil)
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    reacher = users(:reacher)
    archer = users(:archer)
    assert_not reacher.following?(archer)
    reacher.follow(archer)
    assert reacher.following?(archer)
    assert archer.followers.include?(reacher)
    reacher.unfollow(archer)
    assert_not reacher.following?(archer)
  end

  test "feed should have the right posts" do
    reacher = users(:reacher)
    archer = users(:archer)
    lana = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert reacher.feed.include?(post_following)
    end
    # Posts from self
    reacher.microposts.each do |post_self|
      assert reacher.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not reacher.feed.include?(post_unfollowed)
    end
  end

end
