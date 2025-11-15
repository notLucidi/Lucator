local StringObfuscator = {}
StringObfuscator.__index = StringObfuscator

function StringObfuscator.new()
    local self = setmetatable({}, StringObfuscator)
    return self
end

function StringObfuscator:obfuscate_string(str)
    -- Simple XOR obfuscation untuk mulai
    local key = math.random(1, 255)
    local encoded = {}
    for i = 1, #str do
        local byte = string.byte(str, i)
        table.insert(encoded, string.format("0x%02x", byte ~ key))
    end
    
    return {
        type = "CallExpression",
        base = {
            type = "Identifier",
            value = "string"
        },
        method = "char",
        arguments = {
            {
                type = "BinaryExpression",
                operator = "bxor",
                left = {type = "NumericLiteral", value = tonumber(encoded[1], 16)},
                right = {type = "NumericLiteral", value = key}
            }
        }
    }
end
