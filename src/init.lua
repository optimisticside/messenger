-- OptimisticSide
-- 12/30/2020

local Server = {}
Server.__index = Server

Server.Topic = script.Topic
Server.TopicThread = script.TopicThread

local Topic = require(script.Topic)
local TopicThread = require(script.TopicThread)

-- Gets the server's data
-- @returns the array containing the server's data (place ID and job ID)
function Server:getData(): table
    return { self.placeId, self.jobId }
end

-- Gets a topic
-- @param topicName the name of the topic
-- @returns the topic
function Server:getTopic(topicName: string): table
    -- get the existing topic (if exists)
    local topic = self.topics[topicName]

    -- create topic if it doesn't exist
    if not topic then
        topic = Topic.new(self, topicName)
        self.topics[topicName] = topic
    end

    -- return the topic
    return topic
end

-- Subscribes to a topic
-- @param topicName the name of the topic
-- @param func the function to connect to the topic
-- @returns the connection along with the topic (tuple)
function Server:subscribe(topicName: string, func: callback): Tuple
    -- create topic and subscribe to it
    local topic = Topic.new(self, topicName)
    local connection = topic:subscribe(func)

    -- return connection and topic
    return connection, topic
end

-- Publishes data to a topic
-- @param topicName the name of the topic
-- @param data the data to publish to the topic
-- @returns the thread ID along with the topic (tuple)
function Server:publish(topicName: string, data: any): Tuple
    -- create topic and send data through it
    local topic = Topic.new(self, topicName)
    local threadId = topic:send(data)

    -- return thread ID and topic
    return threadId, topic
end

-- Creates a new message server
-- @returns the constructed message server
function Server.new(): table
    local self = {}
    setmetatable(self, Server)

    -- set up fields
    self.topics = {}
    self.placeId = game.PlaceId
    self.jobId = game.JobId

    return self
end

return Server