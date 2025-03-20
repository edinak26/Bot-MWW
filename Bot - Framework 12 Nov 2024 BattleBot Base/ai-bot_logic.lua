require("ai/helper_library")
require("ai/abilities")

---All bot edits should be done in this file or new files you create
local Bot = {}

Bot.input_controller = require("scripts/input_controller")
Bot.stop_watch = require("scripts/stopwatch_controller")

local unit_utilities = SE.unit_utilities
local spell_utilities = SE.spell_utilities
local math_utilities = SE.math_utilities

local helper = HelperLibrary
local spells = HelperLibrary.spells
local available_magicks = HelperLibrary.available_magicks
local action = ActionController
local activation_conditions = action.activation_conditions
local on_update = action.on_update
local abilities = BotAbilities

-- Define elements for ease of use
local q = "water"
local w = "life"
local e = "shield"
local r = "cold"
local a = "lightning"
local s = "arcane"
local d = "earth"
local f = "fire"

---add targeting logic here
---@param self table
function Bot:init()
    local ai_data = self.ai_data
    self.updates = 0
end

---add targeting logic here
---@param self table
function Bot:select_target()
    local ai_data = self.ai_data
    
    -- Default target is any enemy ai unit, the closest enemy, or the bot unit itself
    ai_data.target_unit = ai_data.enemy_ai_units[1] or ai_data.closest_enemy.unit or ai_data.bot_unit
end

--- General bot update stuff like pathing should be added here
---@param self table
function Bot:update()
    print("Phoenix was here!")
    local ai_data = self.ai_data
    local dt = self.dt or 0
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update

    local target_data = unit_utilities.get_unit_data_from_unit(ai_data.target_unit)
    local function dump(o)
        if type(o) == 'table' then
           local s = '{ '
           for k,v in pairs(o) do
              if type(k) ~= 'number' then k = '"'..k..'"' end
              s = s .. '['..k..'] = ' .. dump(v) .. ','
           end
           return s .. '} '
        else
           return tostring(o)
        end
     end
    pdDebug.text("-----------------Position: %s", tostring(dump(ai_data.self_data.position_table)))
    pdDebug.text("-----------------GLOBAL_CANE_NAVMESHQUERY: %s", tostring(dump(GLOBAL_CANE_NAVMESHQUERY)))

    local target_location = unit_utilities.get_unit_position(ai_data.target_unit)
    local desired_location = math_utilities.offset_point_towards_point(target_location, ai_data.self_data.position_table, 4)
    pdDebug.text("-----------------=T=: %s", tostring(target_location))
    pdDebug.text("-----------------=D=: %s", tostring(desired_location))

    local debug_markup = {
        UIFunc.new_text_markup("=X=", WORLD_TO_SCREEN({0,0,0}), 50, {255,255,255,255}, true),
        UIFunc.new_text_markup("=T=", WORLD_TO_SCREEN(target_location), 50, {255,255,255,255}, true),
        UIFunc.new_text_markup("=D=", WORLD_TO_SCREEN(desired_location), 50, {255,255,255,255}, true),
    }

    --manually send the markup to be drawn (without using UIFunc to manage)
    DRAW_MARKUP(dt, debug_markup)
end

--- Bot general logic and actions/routines should be placed here
--- This function is called every frame unless the bot is disabled (e.g., round resetting)
--- and only when the queue is empty
---@param self table
function Bot:update_logic()
    local ai_data = self.ai_data
    local dt = self.dt
    local queue = self.queue or QueueController -- this "or QueueController" is here just make autofill work
    local action = self.action or ActionController
    local combos = self.combo or BotCombos
    local activation_condition = action.activation_conditions
    local on_update = action.on_update
    self.updates=1+self.updates
    
    --add actions/combos here
    --if ai_data.target_unit and ai_data.target_unit ~= ai_data.bot_unit and ai_data.self_data.health_p >= 90 then
    --    if unit_utilities.distance_between_units(ai_data.bot_unit, ai_data.target_unit) < 4 then
    --        queue:new_action(abilities.weapon.charge)
    --    else
    --        queue:new_combo(combos.water_beam_cold_shatter(ai_data))
    --    end
    --elseif ai_data.self_data.health_p < 90 then
    --    queue:new_combo(combos.heal_turtle(ai_data))
    --end
--
    local target_location = unit_utilities.get_unit_position(ai_data.target_unit)
    local desired_location = math_utilities.offset_point_towards_point(target_location, ai_data.self_data.position_table, 4)
    local function dump(o)
        if type(o) == 'table' then
           local s = '{ \n'
           for k,v in pairs(o) do
            if type(k) ~= 'table' then
              if type(k) ~= 'number' then k = '"'..k..'"' end
              s = s .. '['..k..'] = ' .. tostring(v) .. ',\n'
           end
           end
           for k,v in pairs(o) do
            if type(k) == 'table' then
              if type(k) ~= 'number' then k = '"'..k..'"' end
              s = s .. '['..k..'] = ' .. tostring(v) .. ',\n'
           end
           end
           return s .. '} \n'
        else
           return tostring(o)
        end
     end
    APPEND_FILE("C:\\Users\\edina\\OneDrive\\Desktop\\MWW-Bot-Framework-main\\BotData.txt", tostring(self.updates))
    queue:new_action(action.face_point(target_location))
    queue:new_action(action.face_point(desired_location))
    queue:new_action(action.move_to_point(desired_location))
    queue:new_action(action.face_point(target_location))
    queue:new_action(action.spell(target_location, {e,s,s}, false))
    APPEND_FILE("C:\\Users\\edina\\OneDrive\\Desktop\\MWW-Bot-Framework-main\\BotData.txt", dump(self.ai_data.obstructions))
    if self.ai_data.obstructions ~= nil then
        APPEND_FILE("C:\\Users\\edina\\OneDrive\\Desktop\\MWW-Bot-Framework-main\\BotData.txt", dump(self.ai_data.obstructions.mines))
        APPEND_FILE("C:\\Users\\edina\\OneDrive\\Desktop\\MWW-Bot-Framework-main\\BotData.txt", dump(self.ai_data.obstructions.mines[1]))
        APPEND_FILE("C:\\Users\\edina\\OneDrive\\Desktop\\MWW-Bot-Framework-main\\BotData.txt", dump(self.ai_data.obstructions.mines[1].name))
        APPEND_FILE("C:\\Users\\edina\\OneDrive\\Desktop\\MWW-Bot-Framework-main\\BotData.txt", dump(self.ai_data.obstructions.mines[1].value))
    end



end

return Bot
