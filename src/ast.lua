local AST = {}
AST.__index = AST

-- AST Node types
local NodeTypes = {
    CHUNK = 'Chunk',
    FUNCTION = 'Function',
    LOCAL_FUNCTION = 'LocalFunction',
    ASSIGNMENT = 'Assignment',
    LOCAL_ASSIGNMENT = 'LocalAssignment',
    CALL = 'Call',
    METHOD_CALL = 'MethodCall',
    IF_STATEMENT = 'IfStatement',
    FOR_LOOP = 'ForLoop',
    WHILE_LOOP = 'WhileLoop',
    REPEAT_LOOP = 'RepeatLoop',
    RETURN = 'Return',
    BREAK = 'Break',
    BINARY_OP = 'BinaryOp',
    UNARY_OP = 'UnaryOp',
    VARIABLE = 'Variable',
    STRING = 'String',
    NUMBER = 'Number',
    BOOLEAN = 'Boolean',
    NIL = 'Nil',
    TABLE = 'Table',
    INDEX = 'Index',
    MEMBER = 'Member'
}

function AST.new()
    local self = setmetatable({}, AST)
    self.NodeTypes = NodeTypes
    return self
end

-- Factory methods for creating AST nodes
function AST:createChunk(statements)
    return {
        type = NodeTypes.CHUNK,
        statements = statements or {}
    }
end

function AST:createFunction(name, parameters, body, is_local)
    return {
        type = is_local and NodeTypes.LOCAL_FUNCTION or NodeTypes.FUNCTION,
        name = name,
        parameters = parameters or {},
        body = body or {},
        is_local = is_local or false
    }
end

function AST:createAssignment(variables, expressions)
    return {
        type = NodeTypes.ASSIGNMENT,
        variables = variables,
        expressions = expressions
    }
end

function AST:createLocalAssignment(variables, expressions)
    return {
        type = NodeTypes.LOCAL_ASSIGNMENT,
        variables = variables,
        expressions = expressions
    }
end

function AST:createCall(function_expr, arguments)
    return {
        type = NodeTypes.CALL,
        function_expr = function_expr,
        arguments = arguments or {}
    }
end

function AST:createIfStatement(condition, then_block, elseif_clauses, else_block)
    return {
        type = NodeTypes.IF_STATEMENT,
        condition = condition,
        then_block = then_block,
        elseif_clauses = elseif_clauses or {},
        else_block = else_block
    }
end

function AST:createForLoop(variable, start_expr, end_expr, step_expr, body)
    return {
        type = NodeTypes.FOR_LOOP,
        variable = variable,
        start_expr = start_expr,
        end_expr = end_expr,
        step_expr = step_expr,
        body = body or {}
    }
end

function AST:createWhileLoop(condition, body)
    return {
        type = NodeTypes.WHILE_LOOP,
        condition = condition,
        body = body or {}
    }
end

function AST:createReturn(expressions)
    return {
        type = NodeTypes.RETURN,
        expressions = expressions or {}
    }
end

function AST:createBinaryOp(operator, left, right)
    return {
        type = NodeTypes.BINARY_OP,
        operator = operator,
        left = left,
        right = right
    }
end

function AST:createVariable(name)
    return {
        type = NodeTypes.VARIABLE,
        name = name
    }
end

function AST:createString(value)
    return {
        type = NodeTypes.STRING,
        value = value
    }
end

function AST:createNumber(value)
    return {
        type = NodeTypes.NUMBER,
        value = value
    }
end

function AST:createBoolean(value)
    return {
        type = NodeTypes.BOOLEAN,
        value = value
    }
end

function AST:createNil()
    return {
        type = NodeTypes.NIL
    }
end

function AST:createTable(fields)
    return {
        type = NodeTypes.TABLE,
        fields = fields or {}
    }
end

-- AST Visitor pattern implementation
function AST:walk(node, visitor)
    if not node or not visitor then return end
    
    local node_type = node.type
    
    if visitor[node_type] then
        visitor[node_type](node, visitor)
    end
    
    -- Recursively walk child nodes based on node type
    if node_type == NodeTypes.CHUNK then
        for _, stmt in ipairs(node.statements) do
            self:walk(stmt, visitor)
        end
    
    elseif node_type == NodeTypes.FUNCTION or node_type == NodeTypes.LOCAL_FUNCTION then
        for _, param in ipairs(node.parameters) do
            self:walk(param, visitor)
        end
        for _, stmt in ipairs(node.body) do
            self:walk(stmt, visitor)
        end
    
    elseif node_type == NodeTypes.ASSIGNMENT or node_type == NodeTypes.LOCAL_ASSIGNMENT then
        for _, var in ipairs(node.variables) do
            self:walk(var, visitor)
        end
        for _, expr in ipairs(node.expressions) do
            self:walk(expr, visitor)
        end
    
    elseif node_type == NodeTypes.CALL then
        self:walk(node.function_expr, visitor)
        for _, arg in ipairs(node.arguments) do
            self:walk(arg, visitor)
        end
    
    elseif node_type == NodeTypes.IF_STATEMENT then
        self:walk(node.condition, visitor)
        for _, stmt in ipairs(node.then_block) do
            self:walk(stmt, visitor)
        end
        for _, clause in ipairs(node.elseif_clauses) do
            self:walk(clause.condition, visitor)
            for _, stmt in ipairs(clause.then_block) do
                self:walk(stmt, visitor)
            end
        end
        if node.else_block then
            for _, stmt in ipairs(node.else_block) do
                self:walk(stmt, visitor)
            end
        end
    
    elseif node_type == NodeTypes.FOR_LOOP then
        self:walk(node.variable, visitor)
        self:walk(node.start_expr, visitor)
        self:walk(node.end_expr, visitor)
        if node.step_expr then
            self:walk(node.step_expr, visitor)
        end
        for _, stmt in ipairs(node.body) do
            self:walk(stmt, visitor)
        end
    
    elseif node_type == NodeTypes.WHILE_LOOP then
        self:walk(node.condition, visitor)
        for _, stmt in ipairs(node.body) do
            self:walk(stmt, visitor)
        end
    
    elseif node_type == NodeTypes.RETURN then
        for _, expr in ipairs(node.expressions) do
            self:walk(expr, visitor)
        end
    
    elseif node_type == NodeTypes.BINARY_OP then
        self:walk(node.left, visitor)
        self:walk(node.right, visitor)
    
    elseif node_type == NodeTypes.TABLE then
        for _, field in ipairs(node.fields) do
            if field.key then
                self:walk(field.key, visitor)
            end
            self:walk(field.value, visitor)
        end
    end
end

return AST
