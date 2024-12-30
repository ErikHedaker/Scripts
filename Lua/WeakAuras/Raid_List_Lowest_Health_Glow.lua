-- TRIGGER
trigger1 = function()
    local now = GetTime()

    if (now - aura_env.timeLastExecution) >= aura_env.throttle then
        aura_env.timeLastExecution = now
        aura_env.RaidListUpdate()
        aura_env.AttachGlows()

        if aura_env.debug.enabled then
            print("update = " .. GetTime())
        end

        return aura_env.debug.enabled
    end
end
untrigger1 = function()
    return false
end
trigger1_Name = function()
    if not aura_env.debug.enabled or WeakAuras.IsOptionsOpen() then
        return string.format("(%s)\n[Debugging text window]", aura_env.id)
    else
        return aura_env.debug.GenerateString()
    end
end

trigger2_Events = PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE
trigger2 = function()
    aura_env.RaidListRebuild()
    return false
end
untrigger2 = function()
    return true
end
 --

-- ACTIONS
-- On Init
--[[
TEST WA IF TRIGGER BEFORE ADDON FRAME LOAD
ADD MESSAGES
DD MORE OPTIONS
]] local UnitHealth,
    UnitHealthMax,
    WA_ClassColorName = UnitHealth, UnitHealthMax, WA_ClassColorName
local LCG = LibStub("LibCustomGlow-1.0")
local LGF = LibStub("LibGetFrame-1.0")
LGF.GetFrame("player") -- first call often returns nil, initializes lib cache
aura_env.timeLastExecution = 0.0
aura_env.throttle = aura_env.config["Throttle"]
aura_env.healthThreshold = aura_env.config["HealthThreshold"]
aura_env.outOfRange = false
aura_env.raidList = {}
aura_env.glow = {
    frames = {},
    limit = 2,
    type = "autoCast"
}
local glowTypes = {
    pixel = {
        start = LCG.PixelGlow_Start,
        stop = LCG.PixelGlow_Stop,
        args = {
            color = {0.95, 0.95, 0.32, 1},
            N = 8,
            frequency = 0.25,
            length = 20,
            th = 2,
            xOffset = 0,
            yOffset = 0,
            border = 1,
            key = aura_env.id
        }
    },
    autoCast = {
        start = LCG.AutoCastGlow_Start,
        stop = LCG.AutoCastGlow_Stop,
        args = {
            color = {0.95, 0.95, 0.32, 1},
            N = 4,
            frequency = 0.125,
            scale = 1,
            xOffset = 0,
            yOffset = 0,
            key = aura_env.id
        }
    },
    button = {
        start = LCG.ButtonGlow_Start,
        stop = LCG.ButtonGlow_Stop,
        args = {
            color = {0.95, 0.95, 0.32, 1},
            frequency = 0.125
        }
    }
}
local statusENUM = {
    [1] = "glowing",
    [2] = "eligible",
    [3] = "excluded",
    [4] = "healthy",
    [5] = "reset"
}

local UnitHealthPercent = function(unit)
    local health = UnitHealth(unit)
    local max = UnitHealthMax(unit)

    if max == 0 then
        return 100
    end

    return (health / max) * 100
end

local GetUnitStatus = function(unitObj)
    if unitObj.health > aura_env.healthThreshold then
        return 4
    end

    if aura_env.glow.frames[unitObj] then
        return 1
    end

    --C_Spell.IsSpellInRange(spellIdentifier, optional, targetUnit)
    --UnitInRange(unit)

    return 2
end

aura_env.RaidListRebuild = function()
    aura_env.raidList = {}

    for unit in WA_IterateGroupMembers() do
        table.insert(aura_env.raidList, {id = unit, health = 100, status = 5})
    end

    if aura_env.debug.enabled then
        print("RaidListRebuild")
    end
end

aura_env.RaidListUpdate = function()
    for i = 1, #aura_env.raidList do
        local unitObj = aura_env.raidList[i]
        unitObj.health = UnitHealthPercent(unitObj.id)
        unitObj.status = GetUnitStatus(unitObj)
    end

    table.sort(
        aura_env.raidList,
        function(left, right)
            if left.health == right.health then
                return left.id < right.id
            else
                return left.health < right.health
            end
        end
    )
end

aura_env.AttachGlows = function()
    local remaining = aura_env.glow.limit
    local glowNext = {}

    for i = 1, #aura_env.raidList do
        local unitObj = aura_env.raidList[i]

        if remaining <= 0 then
            break
        end

        if unitObj.status == 1 or unitObj.status == 2 then
            local frame = aura_env.glow.frames[unitObj]

            if not frame then
                local glowType = glowTypes[aura_env.glow.type]

                frame = LGF.GetFrame(unitObj.id)
                glowType.start(frame, unpack(glowType.args))
                unitObj.status = 1

                if aura_env.debug.enabled then
                    print("Start glow = " .. (frame and frame:GetName() or "nil"))
                end

                if not frame then
                    print(
                        string.format(
                            "frame[false], unitObj[%s], raidList[%s]",
                            tostring(unitObj ~= nil),
                            tostring(aura_env.raidList ~= nil)
                        )
                    )
                end
            end

            glowNext[unitObj] = frame
            remaining = remaining - 1
        end
    end

    for unitObj, frame in pairs(aura_env.glow.frames) do
        if not glowNext[unitObj] then
            glowTypes[aura_env.glow.type].stop(frame)

            if aura_env.debug.enabled then
                print("Stop glow = " .. (frame and frame:GetName() or "nil"))
            end

            frame = nil
            unitObj.status = GetUnitStatus(unitObj)
        end
    end

    aura_env.glow.frames = glowNext
end

-- DEBUGGING
aura_env.debug = {
    enabled = aura_env.config["DebugEnable"],
    messagesMax = 5,
    messages = {}
}

aura_env.debug.GenerateString = function()
    local result = string.format("(%s)\n(%s)", aura_env.id, date("%a %b %d %H:%M:%S %Y"))
    local output = {}

    for i = 1, #statusENUM do
        output[i] = {}
    end

    for i = 1, #aura_env.raidList do
        local unitObj = aura_env.raidList[i]

        table.insert(output[unitObj.status], string.format("[%d] %s", unitObj.health, WA_ClassColorName(unitObj.id)))
    end

    for i = 1, #statusENUM do
        local array = output[i]

        if #array > 0 then
            result = result .. string.format("\n\n(%s) num[%d]\n", statusENUM[i], #array) .. table.concat(array, "\n")
        end
    end

    return result
end

if aura_env.debug.enabled then
    print(string.format("(%s) On Init", aura_env.id))
end

-- On Show
if aura_env.debug.enabled then
    print(string.format("(%s) On Show", aura_env.id))
end

-- On Hide
if aura_env.debug.enabled then
    print(string.format("(%s) On Hide", aura_env.id))
end
