local Parser = {}

function Parser:readFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        error("Could not open file: ".. filePath)
    end
  local content = file:read("w")
  file:close()
  return content
end

function Parser:writeFile(filePath, content)
    local file = io.open(filePath, "w")
    if not file then
        error("Could not write to file: ".. filePath)
    end
    file:write(content)
    file:close()
end

return Parser
