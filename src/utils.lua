local Utils = {}
Utils.__index = Utils

-- GrowLauncher API Whitelist (harus diperluas berdasarkan dokumentasi aktual)
Utils.GROWL_WHITELIST = {
    -- Global functions
    'print', 'type', 'tostring', 'tonumber', 'pairs', 'ipairs', 'next',
    'select', 'unpack', 'table', 'string', 'math', 'coroutine', 'os',
    
    -- GrowLauncher specific APIs (contoh - sesuaikan dengan dokumentasi)
    'GetLocal', 'sendPacketRaw', 'findItemID', 'getInventory', 'getPlayer',
    'getMap', 'getMonsters', 'getNPCs', 'getSkills', 'getQuests',
    'moveTo', 'useSkill', 'useItem', 'attack', 'talkToNPC',
    'getTickCount', 'getTime', 'wait', 'sleep', 'log' 'LogToConsole' 
    
    -- Standard Lua libraries (partial)
    'table.insert', 'table.remove', 'table.concat', 'table.sort',
    'string.sub', 'string.find', 'string.gsub', 'string.match', 'string.lower', 'string.upper',
    'math.floor', 'math.ceil', 'math.random', 'math.max', 'math.min', 'math.sqrt',
    
    -- Add more as needed from GrowLauncher documentation
}

function Utils.new()
    local self = setmetatable({}, Utils)
    self.whitelist = {}
    
    -- Build whitelist lookup table
    for _, name in ipairs(Utils.GROWL_WHITELIST) do
        self.whitelist[name] = true
    end
    
    return self
end

function Utils:isWhitelisted(name)
    return self.whitelist[name] == true
end

-- Base62 character set for short names
Utils.BASE62 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

function Utils:generateName(index)
    local name = ""
    local n = index
    
    repeat
        local remainder = (n - 1) % 62
        name = Utils.BASE62:sub(remainder + 1, remainder + 1) .. name
        n = (n - remainder) / 62
    until n == 0
    
    return name
end

-- Simple deterministic PRNG for seeded operations
function Utils:createPRNG(seed)
    local state = seed or os.time()
    return function()
        state = (state * 1103515245 + 12345) % (2^31)
        return state / (2^31)
    end
end

-- Check if variable is a global (simple heuristic)
function Utils:isGlobalVariable(name, scope)
    -- If it's in our whitelist, it's definitely global
    if self:isWhitelisted(name) then
        return true
    end
    
    -- If it starts with uppercase, likely global in GrowLauncher scripts
    if name:match("^[A-Z]") then
        return true
    end
    
    -- Common global patterns
    local global_patterns = {
        "^_G%.", "^get", "^set", "^is", "^has", "^create", "^find", "^send", "^move"
    }
    
    for _, pattern in ipairs(global_patterns) do
        if name:match(pattern) then
            return true
        end
    end
    
    return false
end

return Utils
