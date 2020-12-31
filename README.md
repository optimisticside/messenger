# Messenger
Messenger is a lightweight, minimal library that allows for seamless cross-server messaging on the Roblox platform. It's comprised of topics, which are like channels for servers to communicate in. These topics should each have their own specific use. Topics can be used to listen for data, and send data. Topic threads can be used to create a stream of messages between servers for a specific reason.

## Usage
Messenger is a fully object-oriented library. It's main class is called `Server`, which is a messaging server. It doesn't provide much functionality, but provides similar functions as you would find in Roblox's built-in `MessagingService`.  A message server can be created as follows. 
```lua
local messageServer = Server.new()
```
You can send data using the `publish` function, which takes in the name of the topic in which to publish the message, along with the message itself. Messenger provides extra data other than the data you send, that contains the server's `PlaceId` and `JobId`.
```lua
local SERVER_START_TOPIC = "ServerStart"

-- tell other servers that we've started
-- we do not need to provide any data, as this server's info is automatically provided by messenger
messageServer:publish(SERVER_START_TOPIC)
```
You can listen for data in a topic by subscribing to it, which can be done using the `subscribe` function. It takes the name of the topic to subscribe to, along with a callback function to be executed every time data is sent. It returns a `RBXScriptConnection`, and can be disconnected when needed.
```lua
-- subscribe to topic
messageServer:subscribe(SERVER_START_TOPIC, function(message)
    print("New server started!")
    print("Place ID is", message.server.placeId)
    print("Job ID is", message.server.jobId)
end)
```
## Topic
A topic is a channel of communication between servers. A topic can be accessed by the `getTopic` function of the `Server` class, or just constructing it through it's class table.
```lua
local PLAYER_JOIN_TOPIC = "PlayerJoin"

local playerJoinTopic = messageServer:getTopic(PLAYER_JOIN_TOPIC)
```
We can send data through this topic using the `send` function, which takes in the data to be sent through the topic.
```lua
local Players = game:GetService("Players")

-- connect to whenever a player is added
Players.PlayerAdded:Connect(function(player)
    -- send a message to other servers
    playerJoinTopic:send(player.UserId)
end)
```
We can listen for messages through this topic by using the `subscribe` function, which takes in the callback function to be run every time a message is recieved, and returns the `RBXScriptConnection`.
```lua
playerJoinTopic:subscribe(function(message)
    print("Player joined!")
    print("User ID:", message.message)
    print("PlaceID:", message.server.placeId)
    print("Job ID:", message.server.jobId)
end)
```
## Threads
Threads allow us to create a message stream between servers. They are handled by the metadata in the messages sent through topics internally. They can be created by using the `createThread` function of the `Topic` class.
```lua
local GET_SERVERS_TOPIC = "GetServers"
local getServersTopic = messageServer:getTopic(GET_SERVERS_TOPIC)

-- send message to servers and create thread
local thread = getServersTopic:createThread(getServersTopic:send())

-- listen for responses
local listener = thread:subscribe(function(message)
    -- print the server's information
    print(message.server.placeId, " - ", message.server.jobId)
end)
```
We can reply to a message by using threads as well.
```lua
-- subscribe to the topic
getServersTopic:subscribe(function(message)
    -- create a thread from the message's thread ID
    local thread = getServersTopic:createThread(message.threadId)

    -- send a message in that thread (equivalent to a reply)
    thread:send()
end)
```