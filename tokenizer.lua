local Tokenizer = {}
Tokenizer.__index = Tokenizer

local keywords = {
    ['and'] = true, ['break'] = true, ['do'] = true, ['else'] = true,
    ['elseif'] = true, ['end'] = true, ['false'] = true, ['for'] = true,
    ['function'] = true, ['if'] = true, ['in'] = true, ['local'] = true,
    ['nil'] = true, ['not'] = true, ['or'] = true, ['repeat'] = true,
    ['return'] = true, ['then'] = true, ['true'] = true, ['until'] = true,
    ['while'] = true
}

local operators = {
    ['+'] = 'ADD', ['-'] = 'SUB', ['*'] = 'MUL', ['/'] = 'DIV', ['%'] = 'MOD',
    ['^'] = 'POW', ['#'] = 'LEN', ['=='] = 'EQ', ['~='] = 'NEQ',
    ['<='] = 'LE', ['>='] = 'GE', ['<'] = 'LT', ['>'] = 'GT',
    ['='] = 'ASSIGN', ['('] = 'LPAREN', [')'] = 'RPAREN',
    ['{'] = 'LBRACE', ['}'] = 'RBRACE', ['['] = 'LBRACK', [']'] = 'RBRACK',
    [';'] = 'SEMI', [':'] = 'COLON', [','] = 'COMMA', ['.'] = 'DOT',
    ['..'] = 'CONCAT', ['...'] = 'VARARG'
}

function Tokenizer.new(source)
    local self = setmetatable({}, Tokenizer)
    self.source = source
    self.position = 1
    self.line = 1
    self.column = 1
    self.tokens = {}
    return self
end

function Tokenizer:tokenize()
    while self.position <= #self.source do
        local char = self.source:sub(self.position, self.position)
        
        -- Skip whitespace
        if char:match('%s') then
            self:skipWhitespace()
        
        -- Comments
        elseif char == '-' and self:peek() == '-' then
            self:skipComment()
        
        -- Strings
        elseif char == '"' or char == "'" then
            self:readString(char)
        
        -- Numbers
        elseif char:match('%d') or (char == '.' and self:peek():match('%d')) then
            self:readNumber()
        
        -- Identifiers and keywords
        elseif char:match('[%a_]') then
            self:readIdentifier()
        
        -- Operators
        else
            self:readOperator()
        end
    end
    
    self:addToken('EOF', '')
    return self.tokens
end

function Tokenizer:skipWhitespace()
    while self.position <= #self.source do
        local char = self.source:sub(self.position, self.position)
        if char == '\n' then
            self.line = self.line + 1
            self.column = 1
        elseif not char:match('%s') then
            break
        end
        self.position = self.position + 1
        self.column = self.column + 1
    end
end

function Tokenizer:skipComment()
    self.position = self.position + 2  -- Skip '--'
    self.column = self.column + 2
    
    -- Block comment
    if self:peek() == '[' then
        self.position = self.position + 1
        self.column = self.column + 1
        
        local level = 0
        while self:peek() == '=' do
            level = level + 1
            self.position = self.position + 1
            self.column = self.column + 1
        end
        
        if self:peek() == '[' then
            self:readLongString(level, true)
        else
            -- Not a block comment, treat as regular comment
            self:skipLineComment()
        end
    else
        self:skipLineComment()
    end
end

function Tokenizer:skipLineComment()
    while self.position <= #self.source and self.source:sub(self.position, self.position) ~= '\n' do
        self.position = self.position + 1
        self.column = self.column + 1
    end
end

function Tokenizer:readString(quote)
    local start = self.position
    self.position = self.position + 1  -- Skip opening quote
    self.column = self.column + 1
    
    local value = ""
    local escaped = false
    
    while self.position <= #self.source do
        local char = self.source:sub(self.position, self.position)
        
        if escaped then
            if char == 'n' then
                value = value .. '\n'
            elseif char == 't' then
                value = value .. '\t'
            else
                value = value .. char
            end
            escaped = false
        elseif char == '\\' then
            escaped = true
        elseif char == quote then
            self.position = self.position + 1
            self.column = self.column + 1
            break
        else
            value = value .. char
        end
        
        self.position = self.position + 1
        self.column = self.column + 1
    end
    
    self:addToken('STRING', value)
end

function Tokenizer:readNumber()
    local start = self.position
    local pattern = '^[%d%.eE+-]+'
    
    while self.position <= #self.source do
        local char = self.source:sub(self.position, self.position)
        if not char:match('[%d%.eE+-]') then
            break
        end
        self.position = self.position + 1
        self.column = self.column + 1
    end
    
    local value = self.source:sub(start, self.position - 1)
    self:addToken('NUMBER', value)
end

function Tokenizer:readIdentifier()
    local start = self.position
    
    while self.position <= #self.source do
        local char = self.source:sub(self.position, self.position)
        if not char:match('[%a%d_]') then
            break
        end
        self.position = self.position + 1
        self.column = self.column + 1
    end
    
    local value = self.source:sub(start, self.position - 1)
    
    if keywords[value] then
        self:addToken('KEYWORD', value)
    else
        self:addToken('IDENTIFIER', value)
    end
end

function Tokenizer:readOperator()
    local char = self.source:sub(self.position, self.position)
    local next_char = self:peek()
    local two_char = char .. next_char
    
    if operators[two_char] then
        self:addToken('OPERATOR', two_char)
        self.position = self.position + 2
        self.column = self.column + 2
    elseif operators[char] then
        self:addToken('OPERATOR', char)
        self.position = self.position + 1
        self.column = self.column + 1
    else
        -- Unknown character, skip
        self.position = self.position + 1
        self.column = self.column + 1
    end
end

function Tokenizer:peek()
    if self.position + 1 <= #self.source then
        return self.source:sub(self.position + 1, self.position + 1)
    end
    return ''
end

function Tokenizer:addToken(type, value)
    table.insert(self.tokens, {
        type = type,
        value = value,
        line = self.line,
        column = self.column
    })
end

return Tokenizer
