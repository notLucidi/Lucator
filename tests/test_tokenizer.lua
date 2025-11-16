local Tokenizer = require('src.tokenizer')

local function test_tokenizer()
    print("Testing Tokenizer...")
    
    local source = [[
local function add(a, b)
    return a + b
end

print("Hello " .. "World")
]]
    
    local tokenizer = Tokenizer.new(source)
    local tokens = tokenizer:tokenize()
    
    local expected_types = {
        'KEYWORD', 'KEYWORD', 'IDENTIFIER', 'OPERATOR', 'IDENTIFIER', 'COMMA', 
        'IDENTIFIER', 'OPERATOR', 'KEYWORD', 'IDENTIFIER', 'OPERATOR', 'IDENTIFIER',
        'KEYWORD', 'IDENTIFIER', 'OPERATOR', 'STRING', 'OPERATOR', 'STRING',
        'OPERATOR', 'EOF'
    }
    
    for i, token in ipairs(tokens) do
        if expected_types[i] then
            assert(token.type == expected_types[i], 
                   "Token " .. i .. " expected " .. expected_types[i] .. " got " .. token.type)
        end
    end
    
    print("✓ Tokenizer tests passed!")
end

test_tokenizer()
