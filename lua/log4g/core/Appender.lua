--- Appends LogEvents. An Appender can contain a Layout if applicable.
-- Subclassing `LifeCycle`.
-- @classmod Appender
local LifeCycle = Log4g.GetPkgClsFuncs("log4g-core", "LifeCycle").getClass()
local Appender = LifeCycle:subclass"Appender"

function Appender:Initialize(name, layout)
    LifeCycle.Initialize(self)
    self:SetPrivateField("layout", layout)
    self:SetName(name)
end

function Appender:__tostring()
    return "Appender: [name:" .. self:GetName() .. "]"
end

--- Returns the Layout used by this Appender if applicable.
-- @return object Layout
function Appender:GetLayout()
    return self:GetPrivateField"layout"
end

function Appender:Append()
    return true
end

--- Get Appender class.
-- @lfunction GetClass
local function GetClass()
    return Appender
end

--- Appends log events to console using a layout specified by the user.
-- @type ConsoleAppender
local ConsoleAppender = Appender:subclass"ConsoleAppender"
local TypeUtil = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil")
local IsLogEvent, IsLayout = TypeUtil.IsLogEvent, TypeUtil.IsLayout
local print = print

function ConsoleAppender:Initialize(name, layout)
    Appender.Initialize(self, name, layout)
end

--- Append a LogEvent to Console.
-- @param event LogEvent
function ConsoleAppender:Append(event)
    if not IsLogEvent(event) then return end
    local layout = self:GetLayout()
    if not IsLayout(layout) then return end

    if gmod then
        MsgC(layout:Format(event, true))
    else
        print(layout:Format(event, false))
    end
end

--- Create a default ConsoleAppender.
-- @lfunction CreateConsoleAppender
local function CreateConsoleAppender(name, layout)
    return ConsoleAppender(name, layout)
end

Log4g.RegisterPackageClass("log4g-core", "Appender", {
    getClass = GetClass,
    createConsoleAppender = CreateConsoleAppender
})