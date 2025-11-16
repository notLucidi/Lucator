local Minifier = {}
Minifier.__index = Minifier

function Minifier.new(options)
    local self = setmetatable({}, Minifier)
    self.options = options or {}
    return self
end

function Minifier:minifyCode(code)
    local lines = {}
    local in_comment = false
    local in_string = false
    local current_string_delimiter = nil
    local current_line = ""
    local escape_next = false
    
    for i = 1, #code do
        local char = code:sub(i, i)
        local next_char = code:sub(i + 1, i + 1)
        
        if escape_next then
            current_line = current_line .. char
            escape_next = false
        
        elseif in_string then
            if char == '\\' then
                escape_next = true
                current_line = current_line .. char
            elseif char == current_string_delimiter then
                in_string = false
                current_string_delimiter = nil
                current_line = current_line .. char
            else
                current_line = current_line .. char
            end
        
        elseif in_comment then
            if char == '\n' then
                in_comment = false
                -- Don't add the comment to current_line
            end
        
        else
            if char == '-' and next_char == '-' then
                -- Line comment starts
                in_comment = true
                i = i + 1 -- Skip next dash
            
            elseif char == '[' and next_char == '[' then
                -- Long string starts
                in_string = true
                current_string_delimiter = '[['
                current_line = current_line .. char .. next_char
                i = i + 1
            
            elseif char == '"' or char == "'" then
                -- Short string starts
                in_string = true
                current_string_delimiter = char
                current_line = current_line .. char
            
            elseif char:match('%s') then
                -- Reduce multiple whitespace to single space
                if #current_line > 0 and not current_line:match('%s$') then
                    current_line = current_line .. ' '
                end
                -- Skip additional whitespace
                while code:sub(i + 1, i + 1):match('%s') do
                    i = i + 1
                end
            
            elseif char == '\n' then
                -- End of line, add to lines if not empty
                if #current_line > 0 then
                    table.insert(lines, current_line)
                    current_line = ""
                end
            
            else
                current_line = current_line .. char
            end
        end
    end
    
    -- Add last line if not empty
    if #current_line > 0 then
        table.insert(lines, current_line)
    end
    
    return table.concat(lines, '\n')
end

-- Simple constant folding for basic expressions
function Minifier:foldConstants(ast)
    local transformer = {
        BinaryOp = function(node, visitor)
            self.utils.ast:walk(node.left, visitor)
            self.utils.ast:walk(node.right, visitor)
            
            -- Fold simple arithmetic
            if node.left.type == 'Number' and node.right.type == 'Number' then
                local left_val = node.left.value
                local right_val = node.right.value
                
                if node.operator == '+' then
                    return {type = 'Number', value = left_val + right_val}
                elseif node.operator == '-' then
                    return {type = 'Number', value = left_val - right_val}
                elseif node.operator == '*' then
                    return {type = 'Number', value = left_val * right_val}
                elseif node.operator == '/' and right_val ~= 0 then
                    return {type = 'Number', value = left_val / right_val}
                end
            end
            
            -- Fold string concatenation
            if node.operator == '..' and node.left.type == 'String' and node.right.type == 'String' then
                return {type = 'String', value = node.left.value .. node.right.value}
            end
        end
    }
    
    self.utils.ast:walk(ast, transformer)
    return ast
end

return Minifier
