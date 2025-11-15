local ControlFlow = {}
ControlFlow.__index = ControlFlow

function ControlFlow.new()
    local self = setmetatable({}, ControlFlow)
    return self
end

function ControlFlow:add_opaque_predicates(block)
    local new_statements = {}
    
    for _, stmt in ipairs(block) do
        -- Add junk if statements that always true
        if math.random() < 0.3 then
            local predicate = self:generate_opaque_predicate()
            table.insert(new_statements, {
                type = "IfStatement",
                condition = predicate,
                body = {stmt},
                else_clause = nil
            })
        else
            table.insert(new_statements, stmt)
        end
    end
    
    return new_statements
end

function ControlFlow:generate_opaque_predicate()
    -- Always returns true but hard to analyze
    return {
        type = "BinaryExpression",
        operator = "==",
        left = {
            type = "BinaryExpression", 
            operator = "+",
            left = {type = "NumericLiteral", value = 1},
            right = {type = "NumericLiteral", value = 1}
        },
        right = {type = "NumericLiteral", value = 2}
    }
end
