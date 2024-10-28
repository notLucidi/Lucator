local Parser = require("parser")
local MainObfuscator = require("obfuscator.mainObfuscator")

local Transformer = {}

function Transformer:obfuscate(inputFile, outputFile, settings)
    local content = Parser:readFile(inputFile)
    
    local obfuscatedCode = MainObfuscator:obfuscate(content, settings)
    
    Parser:writeFile(outputFile, obfuscatedCode)
    
    local originalSize = #content
    local obfuscatedSize = #obfuscatedCode
    
    print(string.format("Original size: %d bytes", originalSize))
    print(string.format("Obfuscated size: %d bytes", obfuscatedSize))
    print(string.format("Ratio: %.2f%%", (obfuscatedSize/originalSize)*100))
end

return Transformer
