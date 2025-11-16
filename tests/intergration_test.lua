local Obfuscator = require('src.obfuscator')

local function test_integration()
    print("Running integration tests...")
    
    local test_script = [[
-- Simple test script
local function calculate(x, y)
    local sum = x + y
    local product = x * y
    return sum, product
end

local a, b = 10, 20
local result1, result2 = calculate(a, b)
print("Sum: " .. result1)
print("Product: " .. result2)
]]
    
    -- Test low mode
    local result_low = Obfuscator.obfuscate({
        code = test_script,
        mode = 'low',
        seed = 42
    })
    
    assert(result_low.obfuscated_code, "Low mode should produce output")
    assert(#result_low.obfuscated_code > 0, "Output should not be empty")
    
    -- Test medium mode
    local result_medium = Obfuscator.obfuscate({
        code = test_script,
        mode = 'medium', 
        seed = 42
    })
    
    assert(result_medium.obfuscated_code, "Medium mode should produce output")
    
    print("✓ Integration tests passed!")
    print("Low mode output length: " .. #result_low.obfuscated_code)
    print("Medium mode output length: " .. #result_medium.obfuscated_code)
end

test_integration()
