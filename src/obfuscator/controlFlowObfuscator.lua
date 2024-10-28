local ControlFlowObfuscator = {}

function ControlFlowObfuscator:obfuscate(code)
    local function addJunkCode()
        local junks = {
            "if true then end",
            "do end",
            "while false do break end",
            "repeat until true"
        }
        return junks[math.random(1, #junks)]
    end
    
    local wrapped = string.format([[
        do
            local _ENV = _ENV
            local function _wrap()
                %s
                if true then
                    %s
                end
                %s
            end
            _wrap()
        end
    ]], addJunkCode(), code, addJunkCode())
    
    return wrapped
end

return ControlFlowObfuscator
