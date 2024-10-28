local Parser = require("parser")
local Encoder = require("encoder")

local Transformer = {}

function Transformer:obfuscate(inputFile, outputFile)
    local content = Parser:readFile(inputFile)

    local encryptedContent, key = Encoder:encryptString(content)
    
    local obfuscatedCode = string.format([[
local function decode(str, key)
    -- [Masukkan fungsi dekripsi di sini]
    -- Fungsi ini akan ditambahkan nanti
end

local encrypted = %q
local key = %q
local decoded = decode(encrypted, key)
load(decoded)()
    ]], encryptedContent, key)
    
    Parser:writeFile(outputFile, obfuscatedCode)
    print("Obfuscation complete!")
end

return Transformer
