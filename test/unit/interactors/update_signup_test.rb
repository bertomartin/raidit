require 'unit/test_helper'
require 'interactors/update_signup'
require 'models/user'
require 'models/raid'
require 'models/permission'

describe UpdateSignup do

  it "requires the current user and signup" do
    user = User.new
    signup = Signup.new
    action = UpdateSignup.new user, signup

    action.current_user.must_equal user
    action.signup.must_equal signup
  end

  describe "#run" do

    before do
      @user = User.new
      @signup = Signup.new user: @user
      @action = UpdateSignup.new @user, @signup
    end

    ##
    # Valid acceptance_status transitions
    ##

    describe "available -> accepted" do
      before do
        @perm = Permission.new
        @perm.user = @user
        Repository.for(Permission).save(@perm)

        @signup.acceptance_status = :available
      end

      it "fails without the accept_sign_up permission" do
        @action.run :accept

        @signup.acceptance_status.must_equal :available
      end

      it "moves the signup to accepted" do
        @perm.allow :accept_signup
        @action.run :accept

        @signup.acceptance_status.must_equal :accepted
      end

      it "saves the changes" do
        @perm.allow :accept_signup
        @action.run :accept

        s = Repository.for(Signup).all.first
        s.acceptance_status.must_equal :accepted
      end
    end

    describe "accepted -> available" do
      before do
        @perm = Permission.new
        @perm.user = @user
        Repository.for(Permission).save(@perm)

        @signup.acceptance_status = :accepted
      end

      it "fails without the unaccept_signup permission" do
        @action.run :unaccept

        @signup.acceptance_status.must_equal :accepted
      end

      it "updates the signup accordingly" do
        @perm.allow :unaccept_signup
        @action.run :unaccept

        @signup.acceptance_status.must_equal :available
      end
    end

    describe "available -> cancelled" do
      before do
        @perm = Permission.new
        @perm.user = @user
        Repository.for(Permission).save(@perm)

        @signup.acceptance_status = :available
      end

      it "fails if user tries to cancel a signup he doesn't own" do
        other_user = User.new
        @signup.user = other_user

        @action.run :cancel

        @signup.acceptance_status.must_equal :available
      end

      it "updates the signup accordingly" do
        @action.run :cancel

        @signup.acceptance_status.must_equal :cancelled
      end
    end

    describe "cancelled -> available" do
      before do
        @perm = Permission.new
        @perm.user = @user
        Repository.for(Permission).save(@perm)

        @signup.acceptance_status = :cancelled
      end

      it "fails if user tries to enqueue a signup he doesn't own" do
        other_user = User.new
        @signup.user = other_user

        @action.run :enqueue

        @signup.acceptance_status.must_equal :cancelled
      end

      it "updates the signup accordingly" do
        @action.run :enqueue

        @signup.acceptance_status.must_equal :available
      end
    end

    describe "accepted -> cancelled" do
      before do
        @perm = Permission.new
        @perm.user = @user
        Repository.for(Permission).save(@perm)

        @signup.acceptance_status = :accepted
      end

      it "fails if user tries to cancel a signup he doesn't own" do
        other_user = User.new
        @signup.user = other_user

        @action.run :cancel

        @signup.acceptance_status.must_equal :accepted
      end

      it "updates the signup accordingly" do
        @action.run :cancel

        @signup.acceptance_status.must_equal :cancelled
      end
    end

    ##
    # Invalid acceptance_status transitions
    ##

    it "doesn't allow transition from cancelled to accepted" do
      @signup.acceptance_status = :cancelled
      @action.run :accept

      @signup.acceptance_status.must_equal :cancelled
    end

  end
end
