--- The Level (Log Level).
-- @classmod Level
Log4g.Inst._Levels = Log4g.Inst._Levels or {}
local HasKey = Log4g.Util.HasKey
local Class = include("log4g/core/impl/MiddleClass.lua")
local Level = Class("Level")

function Level:Initialize(name, int, standard)
    self.name = name or ""
    self.int = int or 0
    self.standard = standard or false
end

Log4g.Inst._Levels.ALL = Level:New("ALL", math.huge, true)
Log4g.Inst._Levels.TRACE = Level:New("TRACE", 600, true)
Log4g.Inst._Levels.DEBUG = Level:New("DEBUG", 500, true)
Log4g.Inst._Levels.INFO = Level:New("INFO", 400, true)
Log4g.Inst._Levels.WARN = Level:New("WARN", 300, true)
Log4g.Inst._Levels.ERROR = Level:New("ERROR", 200, true)
Log4g.Inst._Levels.FATAL = Level:New("FATAL", 100, true)
Log4g.Inst._Levels.OFF = Level:New("OFF", 0, true)

function Level:__tostring()
    return "Level: [name:" .. self.name .. "]" .. "[int:" .. self.int .. "]" .. "[standard:" .. tostring(self.standard) .. "]"
end

--- Delete the Level.
function Level:Delete()
    Log4g.Inst._Levels[self.name] = nil
end

--- Get the Level's name.
-- @return string name
function Level:Name()
    return self.name
end

--- Get the Level's intlevel.
-- @return int intlevel
function Level:IntLevel()
    return self.int
end

--- Check if the Level is a Standard Level.
-- @return bool standard
function Level:Standard()
    return self.standard
end

--- Calculate the Level's SHA256 Hash Code.
-- Convert the Level object to string then use util.SHA256().
-- @return string hashcode
function Level:HashCode()
    return util.SHA256(tostring(self))
end

--- Compares the Level against the Levels passed as arguments and returns true if this level is in between the given levels.
-- @param minlevel The Level with minimal intlevel
-- @param maxlevel The Level with maximal intlevel
-- @return bool isinrange
function Level:IsInRange(minlevel, maxlevel)
    if self.int >= minlevel.int and self.int <= maxlevel.int then
        return true
    else
        return false
    end
end

--- Get the Level.
-- Return the Level associated with the name or nil if the Level cannot be found.
-- @param name The Level's name
-- @return object level
function Log4g.Level.GetLevel(name)
    for k, v in pairs(Log4g.Inst._Levels) do
        if k == name then return v end
    end

    return nil
end

--- Register a Custom Level.
-- If the Level already exists, it's intlevel will be overrode, and standard will be set to false.
-- @param name The Level's name
-- @param int The Level's intlevel
-- @return object level
function Log4g.Level.RegisterCustomLevel(name, int)
    if name == "" or int < 0 then return end

    if not HasKey(Log4g.Inst._Levels, name) then
        local level = Level:New(name, int, false)
        Log4g.Inst._Levels[name] = level

        return level
    else
        Log4g.Inst._Levels[name].int = int
        Log4g.Inst._Levels[name].standard = false

        return Log4g.Inst._Levels[name]
    end
end