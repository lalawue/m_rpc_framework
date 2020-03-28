--
-- Copyright (c) 2020 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local Resp = require("resp")
local Log = require("middle.logger").newLogger("[Redis]", "error")

local Parser = {
    m_info = nil,
    m_data = ""
}
Parser.__index = Parser

function Parser.newRequest(rpc_info)
    local parser = setmetatable({}, Parser)
    parser.m_info = rpc_info
    return parser
end

function Parser.newResponse(rpc_info)
    local parser = setmetatable({}, Parser)
    parser.m_info = rpc_info
    return parser
end

local _proto_info = {}

-- return ret_value, proto_info, data_table
-- the proto_info would be empty_table
function Parser:process(data)
    if type(data) ~= "string" then
        Log:error("Invalid process data")
        return -1
    end
    self.m_data = self.m_data .. data
    if self.m_data:len() <= 0 then
        Log:error("Empty data")
        return 0
    end
    local consumed, output, typ = Resp.decode(self.m_data)
    if consumed == self.m_data:len() then
        self.m_data = ""
        return 1, _proto_info, output
    elseif consumed == Resp.EILSEQ then
        -- Found illegal byte sequence
        Log:error("Found illegal byte sequence ")
        return -1
    end
    -- Not enough data available.
    Log:error("Not enough data")
    return 0
end

function Parser:destroy()
    self.m_data = ""
end

return Parser
