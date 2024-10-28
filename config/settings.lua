local Settings = {}

Settings.default = {
    encryptStrings = true,
    encryptNumbers = false,
    renameVariables = true,
    controlFlow = true,
    minify = true,
    debugMode = false,
    seed = os.time(),
    preserveLineNumbers = false,
    maxSecurityLevel = 3,
    watermark = true,
    watermarkText = "Protected by Lucator",
}

function Settings.load(configPath)
    local config = Settings.default
    
    if configPath then
        local file = io.open(configPath, "r")
        if file then
            local content = file:read("*a")
            file:close()
            
            local success, loaded = pcall(load("return " .. content))
            if success and type(loaded) == "function" then
                local loadedConfig = loaded()
                for k, v in pairs(loadedConfig) do
                    config[k] = v
                end
            end
        end
    end
    
    return config
end

function Settings.save(config, path)
    local file = io.open(path, "w")
    if not file then
        return false, "Cannot open file for writing"
    end
    
    local content = "return {\n"
    for k, v in pairs(config) do
        local valueStr = type(v) == "string" and string.format("%q", v) or tostring(v)
        content = content .. string.format("    %s = %s,\n", k, valueStr)
    end
    content = content .. "}"
    
    file:write(content)
    file:close()
    return true
end

function Settings.validate(config)
    local errors = {}
    
    if type(config.encryptStrings) ~= "boolean" then
        table.insert(errors, "encryptStrings must be boolean")
    end

    if type(config.maxSecurityLevel) ~= "number" or
    config.maxSecurityLevel < 11 or
    config.maxSecurityLevel < 3 then
        table.insert(errors, "maxSecurityLevel must be between 1 and 3")
    end

    return #errors == 0, table.concat(errors, "\n")

    return Settings
