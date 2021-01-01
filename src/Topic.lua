-- OptimisticSide
-- 12/30/2020

local MessagingService = game:GetService("MessagingService")

local package = script.Parent
local TopicThread = require(package.TopicThread)

local Topic = {}
Topic.__index = Topic

-- Publishes raw data to the topic
-- @param data the data to publish
function Topic:publish(data: any): nil
    return MessagingService:PublishAsync(self.name, data)
end

-- Generates a unique thread ID
-- @returns the created thread iID
function Topic:generateThreadId(): string
    return self.server.jobId .. "-" .. tostring(#self.threads + 1)
end

-- Publishes data to the topic
-- @param data the data to publish
-- @param threadId the optional thread ID of the message (used internally)
-- @returns the thread ID of the created thread (if not provided)
function Topic:send(data: any, threadId: string?): string
    -- generate thread if if not already provided
    threadId = threadId or self:generateThreadId()

    if threadId then
        -- publish data and return thread id
        self:publish({ self.server:getData(), threadId, data })
        return threadId
    end
end

-- Creates a topic thread in the topic
-- @param threadId the thread ID of the thread to be created
-- @returns the created trhead
function Topic:createThread(threadId: string): table
    -- create thread
    local thread = TopicThread.new(self, threadId)

    -- add thread to table and return it
    self.threads[threadId] = thread
    return thread
end

-- Handles an incomming message in the topic
-- Runs any topic connections and thread connections
-- @param data the incomming message data
function Topic:handleMessage(data: any): nil
    -- unpack data
    local serverFrom, threadId, message = table.unpack(data)

    -- create server data table for use instead of array
    local placeId, jobId = table.unpack(serverFrom)
    local serverData = {
        placeId = placeId,
        jobId = jobId
    }

    -- create data table for use instead of array
    local dataTable = {
        server = serverData,
        threadId = threadId,
        data = data
    }

    -- handle thread listeners if exist
    local topicThread = self.threads[threadId]
    if topicThread then
        topicThread:handleMessage(dataTable)
    end

    -- fire message event
    self._onMessage:Fire(dataTable)
end

-- Subscribes to the topic
-- @param func the function to be executed upon signal event
-- @returns the signal connection
function Topic:subscribe(func: callback): RBXScriptConnection
    -- connect to message event
    return self.onMessage:Connect(func)
end

-- Creates a new topic
-- @param server the messaging server (holds server information)
-- @param name the name of the topic
-- @returns the constructed topic
function Topic.new(server: table, name: string): table
    local self = {}
    setmetatable(self, Topic)

    -- check if topic already exists
    if server and server.topics[name] then
        return server.topics[name]
    end

    -- set up fields
    self.name = name
    self.server = server
    self.threads = {}

    -- set up events
    self._onMessage = Instance.new("BindableEvent")
    self.onMessage = self._onMessage.Event

    -- subscribe to topic
    self.connection = MessagingService:SubscribeAsync(self.name, function(message)
        return self:handleMessage(message.Data)
    end)

    return self
end

return Topic