local StringObfuscator = {}

function StringObfuscator:obfuscate(str)
    local result = ""
    local key = math.random(1, 255)

    for i = 1, #str do
        local byte = str:byte(i)
        local encoded = (byte + key) % 256
        result = result .. string.char(encoded)
    end

    local decoder = string.format([[
        local function decode(str, key)
            local result = ""
            for i = 1, #str do
                local byte = str:byte(i)
                local decoded = (byte - key) %% 256
                result = result .. string.char(decoded)
            end
            return result
        end
    ]], key)
    
    return result, decoder, key
end

return StringObfuscator
