--- The core implementation of the Logger interface.
-- @classmod Logger
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Core.Logger = Log4g.Core.Logger or {}
local Object = Log4g.Core.Object.GetClass()
local Logger = Object:subclass("Logger")
local GetCtx = Log4g.Core.LoggerContext.Get
local StringUtil = include("log4g/core/util/StringUtil.lua")
local QualifyName, StripDotExtension = StringUtil.QualifyName, StringUtil.StripDotExtension
local pcall = pcall
local sfind = string.find
local thasvalue = table.HasValue
local HasLoggerConfig = Log4g.Core.Config.LoggerConfig.HasLoggerConfig
local GenerateParentNames = Log4g.Core.Config.LoggerConfig.GenerateParentNames
local Root = GetConVar("log4g.root"):GetString()

function Logger:Initialize(name, context)
    Object.Initialize(self)
    self:SetPrivateField("ctx", context:GetName())
    self:SetName(name)
end

function Logger:GetContext()
    return self:GetPrivateField("ctx")
end

--- Sets the LoggerConfig name for the Logger.
-- @param name String name
function Logger:SetLoggerConfig(name)
    self:SetPrivateField("lc", name)
end

function Logger:GetLoggerConfigN()
    return self:GetPrivateField("lc")
end

--- Get the LoggerConfig of the Logger.
-- @return object loggerconfig
function Logger:GetLoggerConfig()
    return GetCtx(self:GetContext()):GetConfiguration():GetLoggerConfig(self:GetLoggerConfigN())
end

function Logger:SetLevel(level)
    if not pcall(function()
        level:IsLevel()
    end) then
        return
    end

    self:GetLoggerConfig():SetLevel(level)
end

function Logger:GetLevel()
    return self:GetLoggerConfig():GetLevel()
end

function Log4g.Core.Logger.Create(name, context, loggerconfig)
    if not pcall(function()
        context:IsLoggerContext()
    end) then
        return
    end

    if context:HasLogger(name) or not QualifyName(name) then return end
    local logger = Logger(name, context)

    if sfind(name, "%.") then
        if loggerconfig and pcall(function()
            loggerconfig:IsLoggerConfig()
        end) then
            if loggerconfig:GetName() == name then
                logger:SetLoggerConfig(name)
            else
                if thasvalue(GenerateParentNames(name), loggerconfig:GetName()) then
                    logger:SetLoggerConfig(loggerconfig:GetName())
                else
                    logger:SetLoggerConfig(Root)
                end
            end
        else
            local lc = name

            while true do
                if HasLoggerConfig(lc) then
                    logger:SetLoggerConfig(lc)
                    break
                end

                lc = StripDotExtension(lc)

                if not sfind(lc, "%.") and not HasLoggerConfig(lc) then
                    logger:SetLoggerConfig(Root)
                    break
                end
            end
        end
    else
        if loggerconfig and pcall(function()
            loggerconfig:IsLoggerConfig()
        end) and loggerconfig:GetName() == name then
            logger:SetLoggerConfig(name)
        else
            logger:SetLoggerConfig(Root)
        end
    end

    context:GetLoggers()[name] = logger
end

function Log4g.Core.Logger.GetClass()
    return Logger
end