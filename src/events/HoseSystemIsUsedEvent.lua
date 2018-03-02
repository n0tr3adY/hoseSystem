--
-- Grabpoint is used event
--
-- Authors: Wopster
-- Description: Event when the grabpoint is used by player or object
--
-- Copyright (c) Wopster, 2017

HoseSystemIsUsedEvent = {}
HoseSystemIsUsedEvent_mt = Class(HoseSystemIsUsedEvent, Event)

InitEventClass(HoseSystemIsUsedEvent, 'HoseSystemIsUsedEvent')

function HoseSystemIsUsedEvent:emptyNew()
    local event = Event:new(HoseSystemIsUsedEvent_mt)
    return event
end

function HoseSystemIsUsedEvent:new(object, index, isConnected, isExtendable, isCalledFromReference)
    local event = HoseSystemIsUsedEvent:emptyNew()

    event.object = object
    event.index = index
    event.isConnected = isConnected
    event.isExtendable = isExtendable
    event.isCalledFromReference = isCalledFromReference

    return event
end

function HoseSystemIsUsedEvent:writeStream(streamId, connection)
    writeNetworkNodeObject(streamId, self.object)
    streamWriteUIntN(streamId, self.index - 1, HoseSystemUtil.eventHelper.GRABPOINTS_NUM_SEND_BITS)
    streamWriteBool(streamId, self.isConnected)
    streamWriteBool(streamId, self.isExtendable)
    streamWriteBool(streamId, self.isCalledFromReference)
end

function HoseSystemIsUsedEvent:readStream(streamId, connection)
    self.object = readNetworkNodeObject(streamId)
    self.index = streamReadUIntN(streamId, HoseSystemUtil.eventHelper.GRABPOINTS_NUM_SEND_BITS) + 1
    self.isConnected = streamReadBool(streamId)
    self.isExtendable = streamReadBool(streamId)
    self.isCalledFromReference = streamReadBool(streamId)
    self:run(connection)
end

function HoseSystemIsUsedEvent:run(connection)
    self.object.poly.interactiveHandling:setGrabPointIsUsed(self.index, self.isConnected, self.isExtendable, self.isCalledFromReference, true)

    if not connection:getIsServer() then
        g_server:broadcastEvent(self, false, connection, self.object)
    end
end

function HoseSystemIsUsedEvent.sendEvent(object, index, isConnected, isExtendable, isCalledFromReference, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(HoseSystemIsUsedEvent:new(object, index, isConnected, isExtendable, isCalledFromReference), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(HoseSystemIsUsedEvent:new(object, index, isConnected, isExtendable, isCalledFromReference))
        end
    end
end