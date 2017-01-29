class User < Struct.new(:title)
  attr_accessor :id, :latitude, :longitude, :skills 
  def initialize(title) 
	  @id = title[0]
	  @latitude = title[1]
	  @longitude = title[2]
	  @skills = title[3..title.size]
	  puts @id
	  puts @latitude
	  puts @longitude

  end
end


class UserRecommender
  def initialize user, users
    @user, @users = user, users
  end

  def recommendations
    # Map jaccard_index to each item and sort array
    @users.map! do |this_user|

      # We can define jaccard_index getter in runtime as singleton...
      this_user.define_singleton_method(:jaccard_index) do
        @jaccard_index
      end

      # also setter
      this_user.define_singleton_method("jaccard_index=") do |index|
        @jaccard_index = index || 0.0
      end

      # Calculate intersection between sets
      intersection = (@user.skills & this_user.skills).size
      # ... and union
      union = (@user.skills | this_user.skills).size

      # Assign the division and rescue if division is not possible with 0
      this_user.jaccard_index = (intersection.to_f / union.to_f) rescue 0.0

      this_user

      # Sort items
    end.sort_by { |user| 1 - user.jaccard_index }
  end
end

# postgresql query will give us an object of some sort
# 1. parse object to array of User objects.
mocked_users = [
	["user0", 52.63931349979668, 13.39851379394531, "skilla", "skillb", "skillc"],
	["user1", 52.234, 12, "skillb", "skillj", "skillc"],
	["user2", 52.345, 12, "skille", "skillb", "skillb"],
	["user3", 52.456, 12, "skilli", "skillf", "skillh"],
	["user4", 52.567, 12, "skillh", "skillb", "skillc"],
	["user5", 52.678, 12, "skilld", "skille", "skillf"],
	["user6", 52.789, 12, "skillc", "skillb", "skillc"],
	["user7", 52.890, 12, "skille", "skillc", "skillc"],
	["user8", 52.901, 12, "skillg", "skillf", "skilld"],
	["user9", 52.012, 12, "skilla", "skillh", "skillc"]
	]
USERS = []
mocked_users.each { |u|
	USERS << User.new(u)
}

# Define current user
current_user = User.new(["user999", 52.64, 13.4, "look", "at", "my", "ruby", "skilla"])

# Do recommendation...
users = UserRecommender.new(current_user, USERS).recommendations[0..4]

users.each do |user|
  puts "#{user.id} at (#{user.latitude}, #{user.longitude}) has similarity of (#{'%.2f' % user.jaccard_index})"
end
