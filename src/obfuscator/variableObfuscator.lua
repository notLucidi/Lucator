local VariableObfuscator = {}

local function generateVarName(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local result = "_"
    for _ = 1, length do
        local rand = math.random(1, #charset)
        result = result .. charset:sub(rand, rand)
    end
    return result
end

function VariableObfuscator:obfuscate(code)
    local varMap = {}
    
    local obfuscated = code:gsub("([%a_][%w_]*)", function(var)
        local keywords = {
            "and", "break", "do", "else", "elseif", "end", "false", "for",
            "function", "if", "in", "local", "nil", "not", "or", "repeat",
            "return", "then", "true", "until", "while"
        }
        
        for _, keyword in ipairs(keywords) do
            if var == keyword then return var end
        end
        
        if not varMap[var] then
            varMap[var] = generateVarName(math.random(5, 10))
        end
        
        return varMap[var]
    end)
    
    return obfuscated, varMap
end

return VariableObfuscator
