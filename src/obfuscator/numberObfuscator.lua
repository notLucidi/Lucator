local NumberObfuscator = {}

function NumberObfuscator:obfuscate(number)
    local operations = {
        function(n) return string.format("(%d+%d)", n-math.random(1,100), math.random(1,100)) end,
        function(n) return string.format("(%d*%d/%d)", n*2, 2, 2) end,
        function(n) return string.format("(%d-%d+%d)", n+10, 5, -5) end
    }
    
    return operations[math.random(1, #operations)](number)
end

return NumberObfuscator
