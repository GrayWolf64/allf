--- The anchor point for the Log4g logging system.
-- @script LogManager
Log4g.API.LogManager = Log4g.API.LogManager or {}
local API = Log4g.API.LogManager
local GetAllContexts = Log4g.Core.LoggerContext.GetAll

--- Detects if a Logger with the specified name exists.
-- @param name The name of the Logger
-- @return bool haslogger
function API.Exists(name)
    local ctxs = GetAllContexts()
    if #ctxs == 0 then return end

    for _, v in pairs(ctxs) do
        if v:HasLogger(name) then return true end
    end

    return false
end