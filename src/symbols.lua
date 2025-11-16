local Symbols = {}
Symbols.__index = Symbols

local function newScope(parent)
    return {
        parent = parent,
        symbols = {},
        children = {}
    }
end

function Symbols.new()
    local self = setmetatable({}, Symbols)
    self.root_scope = newScope(nil)
    self.current_scope = self.root_scope
    self.scope_stack = {self.root_scope}
    return self
end

function Symbols:enterScope()
    local new_scope = newScope(self.current_scope)
    table.insert(self.current_scope.children, new_scope)
    table.insert(self.scope_stack, new_scope)
    self.current_scope = new_scope
    return new_scope
end

function Symbols:exitScope()
    if #self.scope_stack > 1 then
        table.remove(self.scope_stack)
        self.current_scope = self.scope_stack[#self.scope_stack]
    end
    return self.current_scope
end

function Symbols:addSymbol(name, node_type, is_local)
    local symbol = {
        name = name,
        node_type = node_type,
        is_local = is_local,
        references = 0,
        scope = self.current_scope
    }
    
    self.current_scope.symbols[name] = symbol
    return symbol
end

function Symbols:findSymbol(name)
    local scope = self.current_scope
    
    while scope do
        if scope.symbols[name] then
            return scope.symbols[name]
        end
        scope = scope.parent
    end
    
    return nil
end

function Symbols:isLocal(name)
    local symbol = self:findSymbol(name)
    return symbol and symbol.is_local
end

function Symbols:getAllLocalSymbols()
    local locals = {}
    
    local function collectFromScope(scope)
        for name, symbol in pairs(scope.symbols) do
            if symbol.is_local then
                table.insert(locals, symbol)
            end
        end
        
        for _, child in ipairs(scope.children) do
            collectFromScope(child)
        end
    end
    
    collectFromScope(self.root_scope)
    return locals
end

function Symbols:incrementReference(name)
    local symbol = self:findSymbol(name)
    if symbol then
        symbol.references = symbol.references + 1
    end
end

return Symbols
