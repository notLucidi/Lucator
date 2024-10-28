local Transformer = require("transformer")
local Settings = require("settings")
local Utils = require("utils")

local function printBanner()
    print([[
    ╦  ╦ ╦╔═╗╔═╗╔╦╗╔═╗╦═╗
    ║  ║ ║║  ╠═╣ ║ ║ ║╠╦╝
    ╩═╝╚═╝╚═╝╩ ╩ ╩ ╚═╝╩╚═
    Lua Code Obfuscator v1.0
    ]])
end

local function main()
    printBanner()
    
    local args = {...}
    if #args < 2 then
        print("Usage: lua main.lua <input_file> <output_file> [options]")
        return
    end

    local inputFile = args[1]
    local outputFile = args[2]

    if not Utils.fileExists(inputFile) then
        print("Error: Input file not found!")
        return
    end

    local settings = Settings.load()
    
    local success, err = pcall(function()
        Transformer:obfuscate(inputFile, outputFile, settings)
    end)
    
    if not success then
        print("Error during obfuscation: " .. tostring(err))
    else
        print("Obfuscation completed successfully!")
        print("Output file: " .. outputFile)
    end
end

main()
