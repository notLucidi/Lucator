local Renamer = require('src.generators.renamer')

local function test_renamer()
    print("Testing Renamer...")
    
    local options = {
        seed = 12345,
        mode = 'low'
    }
    
    local renamer = Renamer.new(options)
    
    -- Test name generation
    local name1 = renamer:generateNewName("myVariable")
    local name2 = renamer:generateNewName("anotherVar")
    
    assert(name1 ~= "myVariable", "Name should be changed")
    assert(name2 ~= "anotherVar", "Name should be changed")
    assert(name1 ~= name2, "Generated names should be different")
    
    print("✓ Renamer tests passed!")
end

test_renamer()
