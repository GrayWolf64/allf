--- Class Object is the root of the class hierarchy.
-- @classmod Object
-- @license Apache License 2.0
-- @copyright GrayWolf64
local SHA256 = util.SHA256
local tostring = tostring
local ipairs = ipairs
local tableConcat = table.concat
local type = type
local Object = include"log4g/core/impl/MiddleClass.lua""Object"

--- A table for storing private properties of an object.
-- @local
-- @table Private
local Private = Private or setmetatable({}, {
    __mode = "k"
})

--- When an Object is initialized, a private field(sub table) in the `PRIVATE` table will be dedicated to it based on `self` key.
function Object:Initialize()
    Private[self] = {}
end

function Object:__tostring()
    return "Object: [name:" .. self:GetName() .. "]"
end

--- Sets the name of the Object.
-- @param name String name
function Object:SetName(name)
    if type(name) ~= "string" then return end
    Private[self].name = name
end

--- Gets the name of the Object.
-- @return string name
function Object:GetName()
    return Private[self].name
end

--- Sets a private field for the Object.
-- @param key Of any type except nil
-- @param value Of any type except nil
function Object:SetPrivateField(key, value)
    if not key or not value then return end
    Private[self][key] = value
end

--- Gets a private field of the Object.
-- @param key Of any type except nil
-- @return anytype private value
function Object:GetPrivateField(key)
    if not key then return end

    return Private[self][key]
end

--- Destroys its private table.
function Object:DestroyPrivateTable()
    Private[self] = nil
end

--- Returns a hash code value for the object.
function Object:HashCode()
    return SHA256(tostring(self))
end

local function GetClass()
    return Object
end

--- Removes the dot extension of a string.
-- @param str String
-- @param doconcat Whether `table.concat` the result
-- @return string result
local function StripDotExtension(str, doconcat)
    if type(str) ~= "string" then return end

    --- Optimized version of [string.Explode](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/string.lua#L87-L104).
    local function stringExplode(separator, string)
        local result, currentPos = {}, 1

        for i = 1, #string do
            local startPos, endPos = string:find(separator, currentPos, true)
            if not startPos then break end
            result[i], currentPos = string:sub(currentPos, startPos - 1), endPos + 1
        end

        result[#result + 1] = string:sub(currentPos)

        return result
    end

    local result = stringExplode(".", str:sub(1, #str - str:reverse():find("%.")))

    if doconcat ~= false then
        return tableConcat(result, ".")
    else
        return result
    end
end

--- Generate all the ancestors' names of a LoggerConfig or something else.
-- The provided name must follow [Named Hierarchy](https://logging.apache.org/log4j/2.x/manual/architecture.html).
-- @lfunction EnumerateAncestors
-- @param name Object's name
-- @return table ancestors' names in a list-styled table
-- @return table parent name but with dots removed in a table
local function EnumerateAncestors(name)
    local nodes, ancestors, s = StripDotExtension(name, false), {}, ""

    for k, v in ipairs(nodes) do
        if k ~= 1 then
            s = s .. "." .. v
        else
            s = s .. v
        end

        ancestors[s] = true
    end

    return ancestors, nodes
end

--- Get and Set Context functions minxin.
-- @local
-- @table contextualMixins
local contextualMixins = {
    SetContext = function(self, ctx)
        if type(ctx) ~= "string" then return end
        self:SetPrivateField("ctx", ctx)
    end,
    GetContext = function(self) return self:GetPrivateField"ctx" end
}

Log4g.RegisterPackageClass("log4g-core", "Object", {
    getClass = GetClass,
    stripDotExtension = StripDotExtension,
    enumerateAncestors = EnumerateAncestors,
    contextualMixins = contextualMixins
})