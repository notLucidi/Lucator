-- Simple recursive descent parser for Lua 5.4
local Parser = {}
Parser.__index = Parser

function Parser.new(source)
    local self = setmetatable({}, Parser)
    self.source = source
    self.pos = 1
    self.len = #source
    self.tokens = {}
    return self
end

function Parser:parse()
    return self:parse_chunk()
end

function Parser:parse_chunk()
    local block = {type = "Chunk"}
    block.body = self:parse_block()
    return block
end

function Parser:parse_block()
    local statements = {}
    while not self:is_eof() and not self:check("end") and not self:check("else") and not self:check("elseif") and not self:check("until") do
        local stmt = self:parse_statement()
        if stmt then
            table.insert(statements, stmt)
        end
    end
    return statements
end

-- Basic tokenization
function Parser:next_token()
    -- Implement simple tokenizer
    if self.pos > self.len then return nil end
    
    local char = self.source:sub(self.pos, self.pos)
    
    -- Skip whitespace
    if char:match("%s") then
        self.pos = self.pos + 1
        return self:next_token()
    end
    
    -- Handle identifiers
    if char:match("[a-zA-Z_]") then
        return self:read_identifier()
    end
    
    -- Handle numbers
    if char:match("%d") then
        return self:read_number()
    end
    
    -- Handle strings
    if char == '"' or char == "'" then
        return self:read_string()
    end
    
    -- Handle operators
    local op = self:read_operator()
    if op then return op end
    
    self.pos = self.pos + 1
    return {type = "Unknown", value = char}
end

function Parser:read_identifier()
    local start = self.pos
    while self.pos <= self.len and self.source:sub(self.pos, self.pos):match("[a-zA-Z0-9_]") do
        self.pos = self.pos + 1
    end
    local value = self.source:sub(start, self.pos - 1)
    return {type = "Identifier", value = value}
end
