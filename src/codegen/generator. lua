local CodeGenerator = {}
CodeGenerator.__index = CodeGenerator

function CodeGenerator.new()
    local self = setmetatable({}, CodeGenerator)
    return self
end

function CodeGenerator:generate(ast)
    local output = {}
    self:generate_node(ast, output, 0)
    return table.concat(output, "\n")
end

function CodeGenerator:generate_node(node, output, indent)
    if node.type == "Chunk" then
        self:generate_chunk(node, output, indent)
    elseif node.type == "LocalStatement" then
        self:generate_local_statement(node, output, indent)
    elseif node.type == "Assignment" then
        self:generate_assignment(node, output, indent)
    -- Handle other node types...
    end
end

function CodeGenerator:generate_local_statement(node, output, indent)
    local indent_str = string.rep(" ", indent)
    table.insert(output, indent_str .. "local ")
    
    local vars = {}
    for _, var in ipairs(node.variables) do
        table.insert(vars, self:generate_expression(var, output, 0))
    end
    
    table.insert(output, table.concat(vars, ", "))
    
    if node.init then
        table.insert(output, " = ")
        local inits = {}
        for _, init in ipairs(node.init) do
            table.insert(inits, self:generate_expression(init, output, 0))
        end
        table.insert(output, table.concat(inits, ", "))
    end
end
