-- File: src/ast/parser.lua
local Parser = {}
Parser.__index = Parser

function Parser.new(source_code)
    local self = setmetatable({}, Parser)
    self.source = source_code
    self.pos = 1
    self.len = #source_code
    return self
end

-- HANYA handle 3 construct dulu:
-- 1. Variable assignments (local x = 10)
-- 2. Function calls (print("hello"))
-- 3. Basic expressions (a + b)

function Parser:parse()
    local ast = {
        type = "Program",
        body = {}
    }
    
    while self.pos <= self.len do
        self:skip_whitespace()
        if self.pos > self.len then break end
        
        local token = self:peek_token()
        
        if token == "local" then
            table.insert(ast.body, self:parse_local_assignment())
        elseif self:is_identifier(token) then
            table.insert(ast.body, self:parse_function_call())
        else
            self.pos = self.pos + 1 -- Skip unknown chars for now
        end
    end
    
    return ast
end

function Parser:parse_local_assignment()
    self:expect("local")
    local var_name = self:parse_identifier()
    self:expect("=")
    local value = self:parse_expression()
    return {
        type = "LocalAssignment",
        variable = var_name,
        value = value
    }
end

function Parser:parse_function_call()
    local func_name = self:parse_identifier()
    self:expect("(")
    local args = self:parse_arguments()
    self:expect(")")
    return {
        type = "FunctionCall", 
        name = func_name,
        arguments = args
    }
end

function Parser:parse_expression()
    -- Simple expression parser untuk angka dan string
    if self:peek() == '"' or self:peek() == "'" then
        return self:parse_string()
    elseif self:is_digit(self:peek()) then
        return self:parse_number()
    else
        return self:parse_identifier()
    end
end

-- Basic tokenizer helpers
function Parser:peek()
    return self.source:sub(self.pos, self.pos)
end

function Parser:expect(expected)
    local token = self:next_token()
    if token ~= expected then
        error("Expected '" .. expected .. "' but got '" .. token .. "'")
    end
end

function Parser:skip_whitespace()
    while self.pos <= self.len and self:is_whitespace(self:peek()) do
        self.pos = self.pos + 1
    end
end

function Parser:is_whitespace(char)
    return char == ' ' or char == '\t' or char == '\n' or char == '\r'
end

function Parser:is_digit(char)
    return char >= '0' and char <= '9'
end

function Parser:is_identifier_char(char)
    return (char >= 'a' and char <= 'z') or 
           (char >= 'A' and char <= 'Z') or 
           char == '_' or
           (char >= '0' and char <= '9')
end

return Parser
