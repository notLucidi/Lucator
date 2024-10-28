local Utils = {}

function Utils.fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

function Utils.randomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    math.randomseed(os.time())
    
    for _ = 1, length do
        local rand = math.random(1, #charset)
        result = result .. charset:sub(rand, rand)
    end
    
    return result
end

function Utils.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils.deepCopy(orig_key)] = Utils.deepCopy(orig_value)
        end
        setmetatable(copy, Utils.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function Utils.formatSize(bytes)
    local sizes = {'B', 'KB', 'MB', 'GB'}
    local i = 1
    while bytes >= 1024 and i < #sizes do
        bytes = bytes / 1024
        i = i + 1
    end
    return string.format("%.2f %s", bytes, sizes[i])
end

function Utils.getFileSize(path)
    local file = io.open(path, "rb")
    if not file then return 0 end
    local size = file:seek("end")
    file:close()
    return size
end

Utils.Logger = {
    INFO = 1,
    WARNING = 2,
    ERROR = 3,
    level = 1,
    
    log = function(self, level, message)
        if level >= self.level then
            local levels = {"INFO", "WARNING", "ERROR"}
            print(string.format("[%s] %s", levels[level], message))
        end
    end
}

Utils.String = {
    trim = function(s)
        return s:match("^%s*(.-)%s*$")
    end,
    
    split = function(s, delimiter)
        local result = {}
        for match in (s..delimiter):gmatch("(.-)"..delimiter) do
            table.insert(result, match)
        end
        return result
    end
}

Utils.Timer = {
    start = function()
        return os.clock()
    end,
    
    stop = function(startTime)
        return os.clock() - startTime
    end
}

return Utils
