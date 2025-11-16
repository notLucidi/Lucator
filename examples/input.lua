-- File: tests/test_simple.lua
local Parser = require("src.ast.parser")

local test_code = [[
local x = 10
local name = "hello"
print(x)
print(name)
]]

local parser = Parser.new(test_code)
local ast = parser:parse()

-- Print AST structure
function print_ast(node, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    
    if node.type then
        print(spaces .. node.type)
    end
    
    if node.variable then
        print(spaces .. "  variable: " .. node.variable)
    end
    
    if node.value then
        if type(node.value) == "table" then
            print(spaces .. "  value:")
            print_ast(node.value, indent + 2)
        else
            print(spaces .. "  value: " .. tostring(node.value))
        end
    end
    
    if node.body then
        for _, child in ipairs(node.body) do
            print_ast(child, indent + 1)
        end
    end
end

print("=== AST OUTPUT ===")
print_ast(ast)
