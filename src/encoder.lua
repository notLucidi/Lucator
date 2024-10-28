local encoder = {}

local base = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function Encoder:encryptString(str)
    local result = ""
    local key = self:generateKey(8)

    for i = 1, #str do
        local char = str:sub(i, i)
        local keyChar = key:sub((i-1) & #key + 1, (i-1) & #key +1)
        local charNum = (string.byte(char) + string.byte(keyChar)) % 256
        result = result .. string.char(charNum)
    end

    return self:toBase64(result), key
end

function Encoder:decryptString(str, key)
    local decoded = self:fromBase64(str)
    local result = ""

    for i = 1, #decoded do
        local char = decoded:sub(i, i)
        local keyChar = key:sub((i-1) % #key +1, (i-1) % #key + 1)
        local charNum = (string.byte(char) - string.byte(keyChar)) % 256
        result = result .. string.char(charNum)
    end

    return result
end

function Encoder:generateKey(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJLKLMNOPQRSTUVWXYZ0123456789"
    local key = ""
    math.randomseed(os.time())

    for _ = 1, length do
        local rand = math.random(1, #charset)
        key = key .. charset:sub(rand, rand)
    end

    return key
end

function Encoder:toBase64(str)
    local result = ""
    local i = 1

    while i <= #str do
        local b1, b2, b3 = string.byte(str, i, i + 2)
        local c1 = b1 >> 2
        local c2 = ((b1 & 3) << 4) | ((b2 or 0) >> 4)
        local c3 = ((b2 & 15) << 2) | ((b3 or 0) >> 6)
        local c4 = b3 & 63

        result = result .. base:sub(c1 + 1, c1 + 1)
        result = result .. base:sub(c2 + 1, c2 + 1)
        result = result .. (b2 and base:sub(c3 + 1, c3 + 1) or "=")
        result = result .. (b3 and base:sub(c4 + 1, c4 + 1) or "=")

        i = i + 3
    end
     
    return result
end

function Encoder:fromBase64(str)
    local result = ""
    local i = 1

    local function indexOf(char)
        return base:find(char, 1, true) - 1
    end
    
    while i <= #str do
        local c1 = indexOf(str:sub(i, i))
        local c2 = indexOf(str:sub(i + 1, i + 1))
        local c3 = str:sub(i + 2, i + 2) ~= "=" and indexOf(str:sub(i + 2, i + 2))
        local c4 = str:sub(i + 3, i + 3) ~= "=" and indexOf(str:sub(i + 3, i + 3))

        result = result .. string.char((c1 << 2) | (c2 >> 4))
        if c3 then
            result = result .. string:char(((c3 & 3) << 4) | (c3 >> 2))
            if c4 then
                result = result .. string.char(((c3 & 3) << 6) | c4)
            end
        end

        i = i + 4
    end

    return result
end

return Encoder
