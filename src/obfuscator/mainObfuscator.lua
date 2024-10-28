local StringObfuscator = require("obfuscator.stringObfuscator")
local VariableObfuscator = require("obfuscator.variableObfuscator")
local NumberObfuscator = require("obfuscator.numberObfuscator")
local ControlFlowObfuscator = require("obfuscator.controlFlowObfuscator")

local MainObfuscator = {}

function MainObfuscator:obfuscate(code, settings)
    local result = code
    local decoders = {}
    
    if settings.encryptStrings then
        result = result:gsub('"([^"]*)"', function(str)
            local encoded, decoder, key = StringObfuscator:obfuscate(str)
            table.insert(decoders, decoder)
            return string.format('decode("%s", %d)', encoded, key)
        end)
    end
    
    if settings.encryptNumbers then
        result = result:gsub("(%d+)", function(num)
            return NumberObfuscator:obfuscate(tonumber(num))
        end)
    end
    
    if settings.renameVariables then
        result = VariableObfuscator:obfuscate(result)
    end
    
    if settings.controlFlow then
        result = ControlFlowObfuscator:obfuscate(result)
    end
    
    if settings.watermark then
        result = string.format([[
            --[[ %s ]]
            %s
        ]], settings.watermarkText, result)
    end
    
    local finalCode = table.concat(decoders, "\n") .. "\n" .. result
    
    if settings.minify then
        finalCode = finalCode:gsub("%-%-[^\n]*", "")
                           :gsub("%s+", " ")
                           :gsub("^%s*(.-)%s*$", "%1")
    end
    
    return finalCode
end

return MainObfuscator
