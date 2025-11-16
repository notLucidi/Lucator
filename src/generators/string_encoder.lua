local StringEncoder = {}
StringEncoder.__index = StringEncoder

local Utils = require('src.utils')

function StringEncoder.new(options)
    local self = setmetatable({}, StringEncoder)
    self.options = options or {}
    self.utils = Utils.new()
    self.random = self.utils:createPRNG(options.seed)
    self.encoded_strings = {}
    return self
end

function StringEncoder:encodeXOR(str, key)
    key = key or 0x55 -- Default XOR key
    local bytes = {}
    
    for i = 1, #str do
        local byte = str:byte(i)
        local encoded = bit32.bxor(byte, key)
        table.insert(bytes, encoded)
    end
    
    return bytes, key
end

function StringEncoder:encodeSplit(str)
    local parts = {}
    local part_length = math.random(2, 5)
    
    for i = 1, #str, part_length do
        local part = str:sub(i, i + part_length - 1)
        table.insert(parts, part)
    end
    
    return parts
end

function StringEncoder:transformAST(ast)
    local string_counter = 0
    local string_table = {}
    
    local transformer = {
        String = function(node, visitor)
            if #node.value > 2 then -- Only encode strings longer than 2 chars
                string_counter = string_counter + 1
                local encoded_bytes, key = self:encodeXOR(node.value)
                
                -- Replace string node with decode function call
                local decode_call = {
                    type = 'Call',
                    function_expr = {
                        type = 'Variable',
                        name = '__decode_string'
                    },
                    arguments = {
                        {
                            type = 'Table',
                            fields = self:bytesToTable(encoded_bytes)
                        },
                        {
                            type = 'Number',
                            value = key
                        }
                    }
                }
                
                -- Store original string for decoder generation
                string_table[string_counter] = {
                    original = node.value,
                    encoded = encoded_bytes,
                    key = key
                }
                
                return decode_call
            end
        end
    }
    
    self.utils.ast:walk(ast, transformer)
    self.encoded_strings = string_table
    
    return ast, string_table
end

function StringEncoder:bytesToTable(bytes)
    local fields = {}
    for i, byte in ipairs(bytes) do
        table.insert(fields, {
            key = {type = 'Number', value = i},
            value = {type = 'Number', value = byte}
        })
    end
    return fields
end

function StringEncoder:generateDecoder()
    return [[
local function __decode_string(bytes, key)
    local str = ""
    for i = 1, #bytes do
        local byte = bytes[i]
        local char = string.char(bit32.bxor(byte, key))
        str = str .. char
    end
    return str
end
]]
end

return StringEncoder
