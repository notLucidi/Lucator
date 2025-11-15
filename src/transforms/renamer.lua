local Renamer = {}
Renamer.__index = Renamer

function Renamer.new()
    local self = setmetatable({}, Renamer)
    self.var_counter = 0
    self.used_names = {}
    return self
end

function Renamer:generate_name()
    local name
    repeat
        self.var_counter = self.var_counter + 1
        name = "_" .. string.format("%08x", math.random(0, 0xFFFFFFFF))
    until not self.used_names[name]
    self.used_names[name] = true
    return name
end

function Renamer:transform(ast)
    local scope = {}
    return self:process_node(ast, scope)
end

function Renamer:process_node(node, scope)
    if node.type == "LocalStatement" then
        return self:process_local_statement(node, scope)
    elseif node.type == "Assignment" then
        return self:process_assignment(node, scope)
    end
    return node
end
