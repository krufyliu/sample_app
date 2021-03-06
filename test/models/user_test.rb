require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @user = User.new(name: 'Mike', email: 'mike@test.com',
      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.name = 'a' * 244 + '@example.com'
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                             first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                               foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    other_user = @user.dup
    other_user.email = other_user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
    assert_not other_user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'should follow a user and unfollow a user' do
    mike = users(:mike)
    panda = users(:panda)
    assert_not mike.following?(panda)
    mike.follow(panda)
    assert mike.following?(panda)
    assert panda.followers.include?(mike)
    # 取消关注
    mike.unfollow(panda)
    assert_not mike.following?(panda)
  end

  test "feed should have the right posts" do
    mike = users(:mike)
    jordan = users(:jordan)
    panda = users(:panda)

    # 关注的用户发布的微博
    jordan.microposts.each do |post_following|
      assert mike.feed.include?(post_following)
    end

    # 自己的微博
    mike.microposts.each do |post_self|
      assert mike.feed.include?(post_self)
    end

    # 未关注用户的微博
    panda.microposts.each do |post_unfollowed|
      assert_not mike.feed.include?(post_unfollowed)
    end
  end
end
