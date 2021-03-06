-- OptimisticSide
-- Messenger
-- TopicThread.lua
-- 12/30/2020

local MessagingService = game:GetService("MessagingService")

local TopicThread = {}
TopicThread.__index = TopicThread

-- Publishes data to the thread
-- @param data the data to publish
-- @returns the thread ID of the current thread
function TopicThread:send(data: any): string
    -- send data through topic with provided thread ID
    return self.topic:send(data, self.threadId)
end

-- Handles an incoming message in the thread
-- Runs any connections
-- @param data the incoming message data
function TopicThread:handleMessage(dataTable: any): nil
    -- fire message event
    self._onMessage:Fire(dataTable)
end

-- Subscribes to the thread
-- @param func the function to be executed upon signal event
-- @returns the signal connection
function TopicThread:subscribe(func: callback): RBXScriptConnection
    -- connect to message event
    return self.onMessage:Connect(func)
end

-- Creates a new thread
-- @param topic the topic of the thread
-- @param threadId the thread ID of the thread
-- @returns the constructed thread
function TopicThread.new(topic: table, threadId: string): table
    local self = {}
    setmetatable(self, TopicThread)

    -- check if topic thread already exists
    if topic and topic.threads[threadId] then
        return topic.threads[threadId]
    end

    -- set up fields
    self.topic = topic
    self.threadId = threadId

    -- set up events
    self._onMessage = Instance.new("BindableEvent")
    self.onMessage = self._onMessage.Event

    -- add thread to topic
    if topic then
        topic.threads[threadId] = self
    end

    return self
end

return TopicThread