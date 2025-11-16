local Parser = {}
Parser.__index = Parser

local Tokenizer = require('src.tokenizer')
local AST = require('src.ast')

function Parser.new(source)
    local self = setmetatable({}, Parser)
    self.tokenizer = Tokenizer.new(source)
    self.tokens = {}
    self.current_token = nil
    self.ast_factory = AST.new()
    return self
end

function Parser:parse()
    self.tokens = self.tokenizer:tokenize()
    self.current_token = self.tokens[1]
    self.token_index = 1
    
    local statements = {}
    while self.current_token.type ~= 'EOF' do
        local stmt = self:parseStatement()
        if stmt then
            table.insert(statements, stmt)
        end
    end
    
    return self.ast_factory:createChunk(statements)
end

function Parser:parseStatement()
    local token_type = self.current_token.type
    
    if token_type == 'KEYWORD' then
        local keyword = self.current_token.value
        
        if keyword == 'local' then
            return self:parseLocalStatement()
        elseif keyword == 'function' then
            return self:parseFunctionStatement()
        elseif keyword == 'if' then
            return self:parseIfStatement()
        elseif keyword == 'for' then
            return self:parseForLoop()
        elseif keyword == 'while' then
            return self:parseWhileLoop()
        elseif keyword == 'return' then
            return self:parseReturnStatement()
        end
    end
    
    -- Default: try to parse as expression statement
    return self:parseExpressionStatement()
end

function Parser:parseLocalStatement()
    self:advance()  -- Skip 'local'
    
    if self.current_token.type == 'KEYWORD' and self.current_token.value == 'function' then
        return self:parseLocalFunction()
    else
        return self:parseLocalAssignment()
    end
end

function Parser:parseLocalFunction()
    self:advance()  -- Skip 'function'
    local name = self:expect('IDENTIFIER').value
    self:expect('OPERATOR', '(')
    
    local parameters = self:parseParameterList()
    self:expect('OPERATOR', ')')
    
    local body = self:parseBlock('end')
    self:expect('KEYWORD', 'end')
    
    return self.ast_factory:createFunction(name, parameters, body, true)
end

function Parser:parseLocalAssignment()
    local variables = {}
    
    repeat
        table.insert(variables, self.ast_factory:createVariable(self:expect('IDENTIFIER').value))
        if self.current_token.value == ',' then
            self:advance()
        else
            break
        end
    until false
    
    local expressions = {}
    if self.current_token.value == '=' then
        self:advance()
        expressions = self:parseExpressionList()
    end
    
    return self.ast_factory:createLocalAssignment(variables, expressions)
end

function Parser:parseFunctionStatement()
    self:advance()  -- Skip 'function'
    local name = self:parseVariableName()
    
    self:expect('OPERATOR', '(')
    local parameters = self:parseParameterList()
    self:expect('OPERATOR', ')')
    
    local body = self:parseBlock('end')
    self:expect('KEYWORD', 'end')
    
    return self.ast_factory:createFunction(name, parameters, body, false)
end

function Parser:parseIfStatement()
    self:advance()  -- Skip 'if'
    local condition = self:parseExpression()
    self:expect('KEYWORD', 'then')
    
    local then_block = self:parseBlock('elseif', 'else', 'end')
    local elseif_clauses = {}
    local else_block = nil
    
    while self.current_token.type == 'KEYWORD' and self.current_token.value == 'elseif' do
        self:advance()  -- Skip 'elseif'
        local elseif_condition = self:parseExpression()
        self:expect('KEYWORD', 'then')
        local elseif_body = self:parseBlock('elseif', 'else', 'end')
        
        table.insert(elseif_clauses, {
            condition = elseif_condition,
            then_block = elseif_body
        })
    end
    
    if self.current_token.type == 'KEYWORD' and self.current_token.value == 'else' then
        self:advance()  -- Skip 'else'
        else_block = self:parseBlock('end')
    end
    
    self:expect('KEYWORD', 'end')
    
    return self.ast_factory:createIfStatement(condition, then_block, elseif_clauses, else_block)
end

function Parser:parseForLoop()
    -- TODO: Implement for loop parsing
    self:advance()  -- Skip 'for'
    -- ... parsing logic for numeric and generic for loops
end

function Parser:parseWhileLoop()
    self:advance()  -- Skip 'while'
    local condition = self:parseExpression()
    self:expect('KEYWORD', 'do')
    
    local body = self:parseBlock('end')
    self:expect('KEYWORD', 'end')
    
    return self.ast_factory:createWhileLoop(condition, body)
end

function Parser:parseReturnStatement()
    self:advance()  -- Skip 'return'
    local expressions = self:parseExpressionList()
    return self.ast_factory:createReturn(expressions)
end

function Parser:parseExpressionStatement()
    local expr = self:parseExpression()
    -- Could be a function call or assignment
    return expr
end

function Parser:parseExpression()
    -- TODO: Implement expression parsing with operator precedence
    return self:parsePrimaryExpression()
end

function Parser:parsePrimaryExpression()
    local token = self.current_token
    
    if token.type == 'IDENTIFIER' then
        self:advance()
        return self.ast_factory:createVariable(token.value)
    
    elseif token.type == 'STRING' then
        self:advance()
        return self.ast_factory:createString(token.value)
    
    elseif token.type == 'NUMBER' then
        self:advance()
        return self.ast_factory:createNumber(tonumber(token.value))
    
    elseif token.type == 'KEYWORD' then
        if token.value == 'true' then
            self:advance()
            return self.ast_factory:createBoolean(true)
        elseif token.value == 'false' then
            self:advance()
            return self.ast_factory:createBoolean(false)
        elseif token.value == 'nil' then
            self:advance()
            return self.ast_factory:createNil()
        end
    end
    
    -- TODO: Handle other expression types
    error("Unexpected token: " .. token.value)
end

function Parser:parseParameterList()
    local parameters = {}
    
    if self.current_token.type == 'OPERATOR' and self.current_token.value == ')' then
        return parameters
    end
    
    repeat
        if self.current_token.type == 'IDENTIFIER' then
            table.insert(parameters, self.ast_factory:createVariable(self.current_token.value))
            self:advance()
        elseif self.current_token.type == 'OPERATOR' and self.current_token.value == '...' then
            table.insert(parameters, self.ast_factory:createVariable('...'))
            self:advance()
        end
        
        if self.current_token.value == ',' then
            self:advance()
        else
            break
        end
    until false
    
    return parameters
end

function Parser:parseExpressionList()
    local expressions = {}
    
    repeat
        table.insert(expressions, self:parseExpression())
        if self.current_token.value == ',' then
            self:advance()
        else
            break
        end
    until false
    
    return expressions
end

function Parser:parseBlock(terminator, ...)
    local terminators = {[terminator] = true, ...}
    local statements = {}
    
    while self.current_token.type ~= 'EOF' and not terminators[self.current_token.value] do
        local stmt = self:parseStatement()
        if stmt then
            table.insert(statements, stmt)
        end
    end
    
    return statements
end

function Parser:parseVariableName()
    local parts = {}
    
    table.insert(parts, self:expect('IDENTIFIER').value)
    
    while self.current_token.value == '.' do
        self:advance()  -- Skip '.'
        table.insert(parts, self:expect('IDENTIFIER').value)
    end
    
    if self.current_token.value == ':' then
        self:advance()  -- Skip ':'
        table.insert(parts, self:expect('IDENTIFIER').value)
    end
    
    return table.concat(parts, self.current_token.value == ':' and ':' or '.')
end

function Parser:advance()
    self.token_index = self.token_index + 1
    self.current_token = self.tokens[self.token_index] or {type = 'EOF', value = ''}
    return self.current_token
end

function Parser:expect(expected_type, expected_value)
    local token = self.current_token
    
    if token.type ~= expected_type then
        error(string.format("Expected %s, got %s", expected_type, token.type))
    end
    
    if expected_value and token.value ~= expected_value then
        error(string.format("Expected '%s', got '%s'", expected_value, token.value))
    end
    
    self:advance()
    return token
end

return Parser
