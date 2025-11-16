local Obfuscator = {}
Obfuscator.__index = Obfuscator

local Parser = require('src.parser')
local Renamer = require('src.generators.renamer')
local Minifier = require('src.generators.minifier')
local StringEncoder = require('src.generators.string_encoder')

function Obfuscator.new()
    local self = setmetatable({}, Obfuscator)
    return self
end

function Obfuscator.obfuscate(options)
    local code = options.code
    local mode = options.mode or 'medium'
    local seed = options.seed
    
    print("Starting obfuscation with mode: " .. mode)
    
    -- Parse source code
    local parser = Parser.new(code)
    local ast = parser:parse()
    
    local result = {
        obfuscated_code = code, -- fallback
        mapping = {}
    }
    
    -- Apply transformations based on mode
    if mode == 'none' then
        -- Only minification
        local minifier = Minifier.new(options)
        result.obfuscated_code = minifier:minifyCode(code)
    
    elseif mode == 'low' then
        -- Minification + renaming
        local minifier = Minifier.new(options)
        local renamer = Renamer.new(options)
        
        renamer:analyzeAST(ast)
        ast = renamer:transformAST(ast)
        result.mapping = renamer:getMapping()
        
        -- TODO: Generate code from transformed AST
        result.obfuscated_code = minifier:minifyCode(code)
    
    elseif mode == 'medium' then
        -- Low + string encoding
        local minifier = Minifier.new(options)
        local renamer = Renamer.new(options)
        local string_encoder = StringEncoder.new(options)
        
        renamer:analyzeAST(ast)
        ast = renamer:transformAST(ast)
        ast, string_table = string_encoder:transformAST(ast)
        result.mapping = renamer:getMapping()
        
        -- TODO: Generate code with decoder
        result.obfuscated_code = minifier:minifyCode(code)
    
    elseif mode == 'high' then
        -- Medium + control flow obfuscation
        -- TODO: Implement control flow obfuscation
        result.obfuscated_code = code
    else
        error("Unknown obfuscation mode: " .. mode)
    end
    
    return result
end

return Obfuscator
