require 'unit/test_helper'
require 'models/character'
require 'models/user'

describe Character do

  it "is an entity" do
    Character.ancestors.must_include Entity
  end

  it "takes attributes in a hash" do
    u = User.new
    c = Character.new name: "Weemuu", user: u, game: "game", server: "Detheroc",
      region: "US"
    c.name.must_equal "Weemuu"
    c.user.must_equal u
    c.game.must_equal "game"
    c.server.must_equal "Detheroc"
    c.region.must_equal "US"
  end
end
