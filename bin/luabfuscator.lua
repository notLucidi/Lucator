#!/usr/bin/env lua

local obfuscator = require('src.obfuscator')

local function showHelp()
    print([[
Lua Obfuscator - Pure Lua obfuscator for GrowLauncher

Usage: luabfuscator.lua -i INPUT -o OUTPUT [OPTIONS]

Options:
  -i, --input FILE        Input Lua file
  -o, --output FILE       Output obfuscated file
  --mode MODE             Obfuscation mode: none|low|medium|high (default: medium)
  --vm-percent NUMBER     Percentage of functions to VM-compile (0-100, default: 0)
  --strings TYPE          String encoding: none|xor|table|split (default: xor)
  --seed NUMBER           Seed for deterministic obfuscation
  --map FILE              Write mapping file
  --no-checksum           Disable anti-tamper checksum
  --growlauncher-safe     Enable strict compatibility mode
  -h, --help              Show this help

Examples:
  luabfuscator.lua -i script.lua -o script_obf.lua --mode=high
  luabfuscator.lua -i script.lua -o script_obf.lua --seed=12345 --map=mapping.json
]])
end

local function main()
    local args = {...}
    local options = {
        mode = 'medium',
        vm_percent = 0,
        strings = 'xor'
    }
    
    if #args == 0 then
        showHelp()
        return
    end
    
    -- Parse command line arguments
    for i = 1, #args do
        local arg = args[i]
        
        if arg == '-i' or arg == '--input' then
            options.input = args[i + 1]
            i = i + 1
        elseif arg == '-o' or arg == '--output' then
            options.output = args[i + 1]
            i = i + 1
        elseif arg == '--mode' then
            options.mode = args[i + 1]
            i = i + 1
        elseif arg == '--vm-percent' then
            options.vm_percent = tonumber(args[i + 1])
            i = i + 1
        elseif arg == '--strings' then
            options.strings = args[i + 1]
            i = i + 1
        elseif arg == '--seed' then
            options.seed = tonumber(args[i + 1])
            i = i + 1
        elseif arg == '--map' then
            options.mapping = args[i + 1]
            i = i + 1
        elseif arg == '--no-checksum' then
            options.checksum = false
        elseif arg == '--growlauncher-safe' then
            options.growlauncher_safe = true
        elseif arg == '-h' or arg == '--help' then
            showHelp()
            return
        end
    end
    
    -- Validate required arguments
    if not options.input or not options.output then
        print("Error: Input and output files are required")
        showHelp()
        os.exit(1)
    end
    
    -- Read input file
    local file = io.open(options.input, 'r')
    if not file then
        print("Error: Cannot open input file: " .. options.input)
        os.exit(1)
    end
    
    local source = file:read('*a')
    file:close()
    
    -- Obfuscate
    local success, result = pcall(obfuscator.obfuscate, {
        code = source,
        mode = options.mode,
        vm_percent = options.vm_percent,
        strings = options.strings,
        seed = options.seed,
        mapping = options.mapping,
        checksum = options.checksum ~= false,
        growlauncher_safe = options.growlauncher_safe
    })
    
    if not success then
        print("Error during obfuscation: " .. result)
        os.exit(1)
    end
    
    -- Write output file
    local out_file = io.open(options.output, 'w')
    if not out_file then
        print("Error: Cannot open output file: " .. options.output)
        os.exit(1)
    end
    
    out_file:write(result.obfuscated_code)
    out_file:close()
    
    -- Write mapping file if requested
    if options.mapping and result.mapping then
        local map_file = io.open(options.mapping, 'w')
        if map_file then
            -- TODO: Serialize mapping to JSON or similar format
            map_file:write("-- Mapping file placeholder\n")
            map_file:close()
        end
    end
    
    print("Obfuscation completed successfully: " .. options.output)
end

main()
