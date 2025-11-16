local Renamer = {}
Renamer.__index = Renamer

local Utils = require('src.utils')
local Symbols = require('src.symbols')

function Renamer.new(options)
    local self = setmetatable({}, Renamer)
    self.options = options or {}
    self.utils = Utils.new()
    self.symbols = Symbols.new()
    self.name_counter = 1
    self.name_map = {}
    self.random = self.utils:createPRNG(options.seed)
    return self
end

function Renamer:analyzeAST(ast)
    -- First pass: collect all symbols
    local symbol_collector = {
        Function = function(node, visitor)
            -- Add function name to symbols
            if node.name and type(node.name) == 'string' then
                self.symbols:addSymbol(node.name, 'function', node.is_local)
            end
            
            -- Enter function scope
            self.symbols:enterScope()
            
            -- Add parameters as local symbols
            for _, param in ipairs(node.parameters) do
                if param.type == 'Variable' then
                    self.symbols:addSymbol(param.name, 'parameter', true)
                end
            end
            
            -- Process function body
            for _, stmt in ipairs(node.body) do
                self.utils.ast:walk(stmt, visitor)
            end
            
            -- Exit function scope
            self.symbols:exitScope()
        end,
        
        LocalFunction = function(node, visitor)
            Renamer.Function(self, node, visitor)
        end,
        
        LocalAssignment = function(node, visitor)
            for _, var in ipairs(node.variables) do
                if var.type == 'Variable' then
                    self.symbols:addSymbol(var.name, 'variable', true)
                end
            end
            
            for _, expr in ipairs(node.expressions) do
                self.utils.ast:walk(expr, visitor)
            end
        end,
        
        Assignment = function(node, visitor)
            for _, var in ipairs(node.variables) do
                if var.type == 'Variable' then
                    -- If not found in symbol table, it's a global
                    if not self.symbols:findSymbol(var.name) then
                        self.symbols:addSymbol(var.name, 'variable', false)
                    end
                end
                self.utils.ast:walk(var, visitor)
            end
            
            for _, expr in ipairs(node.expressions) do
                self.utils.ast:walk(expr, visitor)
            end
        end,
        
        Variable = function(node, visitor)
            self.symbols:incrementReference(node.name)
        end
    }
    
    self.utils.ast:walk(ast, symbol_collector)
end

function Renamer:generateNewName(old_name)
    -- Don't rename whitelisted names
    if self.utils:isWhitelisted(old_name) then
        return old_name
    end
    
    -- Don't rename if already mapped
    if self.name_map[old_name] then
        return self.name_map[old_name]
    end
    
    -- Generate new short name
    local new_name
    repeat
        new_name = self.utils:generateName(self.name_counter)
        self.name_counter = self.name_counter + 1
    until not self.name_map[new_name] -- Avoid collisions
    
    self.name_map[old_name] = new_name
    return new_name
end

function Renamer:transformAST(ast)
    local transformer = {
        Function = function(node, visitor)
            -- Rename function name if it's local
            if node.is_local and node.name and type(node.name) == 'string' then
                local symbol = self.symbols:findSymbol(node.name)
                if symbol and symbol.is_local and not self.utils:isWhitelisted(node.name) then
                    node.name = self.name_map[node.name] or node.name
                end
            end
            
            -- Process parameters and body
            for _, param in ipairs(node.parameters) do
                self.utils.ast:walk(param, visitor)
            end
            for _, stmt in ipairs(node.body) do
                self.utils.ast:walk(stmt, visitor)
            end
        end,
        
        LocalFunction = function(node, visitor)
            transformer.Function(self, node, visitor)
        end,
        
        Variable = function(node, visitor)
            local symbol = self.symbols:findSymbol(node.name)
            if symbol and symbol.is_local and self.name_map[node.name] then
                node.name = self.name_map[node.name]
            end
        end,
        
        LocalAssignment = function(node, visitor)
            for i, var in ipairs(node.variables) do
                if var.type == 'Variable' then
                    local symbol = self.symbols:findSymbol(var.name)
                    if symbol and symbol.is_local and self.name_map[var.name] then
                        var.name = self.name_map[var.name]
                    end
                end
                self.utils.ast:walk(var, visitor)
            end
            
            for _, expr in ipairs(node.expressions) do
                self.utils.ast:walk(expr, visitor)
            end
        end,
        
        Assignment = function(node, visitor)
            for _, var in ipairs(node.variables) do
                self.utils.ast:walk(var, visitor)
            end
            for _, expr in ipairs(node.expressions) do
                self.utils.ast:walk(expr, visitor)
            end
        end
    }
    
    -- First, build the name mapping
    local local_symbols = self.symbols:getAllLocalSymbols()
    for _, symbol in ipairs(local_symbols) do
        if not self.utils:isWhitelisted(symbol.name) then
            self:generateNewName(symbol.name)
        end
    end
    
    -- Then apply the transformation
    self.utils.ast:walk(ast, transformer)
    
    return ast
end

function Renamer:getMapping()
    return self.name_map
end

return Renamer
