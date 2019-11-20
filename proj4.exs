a = System.argv()
numUsers = String.to_integer(Enum.at(a,0))
numTweets = String.to_integer(Enum.at(a,1))

Project4.start_project(numUsers, numTweets)
