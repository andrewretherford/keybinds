_addon.name = 'KeyBinds'
_addon.author = 'Picklepants'
_addon.version = '0.0.0'
_addon.commands = {'kb', 'keybinds'}
_addon.language = 'english'

----------------------------------
-- Imports and Globals
----------------------------------

-- Windower Libraries
require('logger')
require('tables')
require('strings')
config = require('config')


local defaults = {
   multibox = true,
   weaponskill = {}
}

settings = config.load(defaults)
settings:save('all')

-- General Trackers
attacking = false
following = false

----------------------------------
-- Keybinds
----------------------------------

windower.register_event('load', function()
   if settings.multibox then
      multibox_binds()
   else
      solo_binds()
   end
end)

----------------------------------
-- Command Switch
----------------------------------

windower.register_event('addon command', function(command, ...)
   local args = table.concat({...}, " ")
   command = command and command:lower()

   if command == 'mount' then
      mount()

   elseif command == 'warp' then
      warp()

   elseif command == 'mb' or command == 'multibox' then
      toggle_multibox(args)

   elseif command == 'sws' or command == 'setws' then
      set_weaponskill({...})

   elseif command == 'attack' then
      attack_toggle()

   elseif command == 'follow' then
      follow_toggle()
   end

end)

----------------------------------
-- Utility
----------------------------------

function toggle_multibox(toggle)
   if toggle == 'on' then
      settings.multibox = true
      log('Multiboxing mode enabled')
   elseif toggle == 'off' then
      settings.multibox = false
      log('Multiboxing mode disabled')
   elseif toggle == '' then
      settings.multibox = not settings.multibox
      if settings.multibox == true then
         log('Multiboxing mode enabled')
      else
         log('Multiboxing mode disabled')
      end
   else
      log('You must enter either "on" or "off" ')
   end
   
   settings:save('all')

   if settings.multibox == true then
      multibox_binds()
   else
      solo_binds()
   end
end

function warp()
   local equipment = windower.ffxi.get_items('equipment')
   local bag = equipment['right_ring_bag']
   local index = equipment['right_ring']
   local item_data = windower.ffxi.get_items(bag, index)

   if item_data.id == 28540 then
      windower.send_command("input /item 'warp ring' <me>")
   else
      windower.send_command("input /equip ring2 'warp ring'; wait 11; input /item 'warp ring' <me>")
   end   
end

function mount()
   local player = windower.ffxi.get_player()
   local mounted = false

   for _, buff in pairs(player.buffs) do
      if buff == 252 then
         mounted = true
      end
   end

   if mounted then
      windower.send_command('input /dismount')
   else   
      windower.send_command('input /mount raptor')
   end
end

function set_weaponskill(args)
   local name = args[1]
   local skill = (table.concat(args, ' ')):gsub(name..' ', '')

   settings.weaponskill[name] = skill
   settings:save('all')
   log(skill..' has been saved for '..name)
end

function attack_toggle()
   if not attacking then
      attacking = true
      windower.send_command("send picklepants /attack; wait 1; send @others /assist picklepants; wait 2; send @others /attack;")
   else
      attacking = false
      windower.send_command("send picklepants /attack; send @others /attack; wait 1; send @others /follow picklepants;")
   end
end

function follow_toggle()
   if not following then
      following = true
      windower.send_command("send skookum /follow picklepants")
   else
      following = false
      windower.send_command("send skookum setkey numpad7 down; wait 0.1; send skookum setkey numpad7 up")
   end
end

function multibox_binds()
   windower.send_command("bind ~numpad7 send @all kb mount")
   windower.send_command("bind ~numpad9 tm summontrusts")
   windower.send_command("bind ~numpad3 kb warp")
   windower.send_command("bind home kb follow")
   windower.send_command("bind ~home send skookum /ma protectra picklepants; wait 6; send skookum /ma shellra picklepants;")
   windower.send_command("bind pageup send skookum /ma 'blindna' picklepants")
   windower.send_command("bind ~pageup send skookum /ma 'paralyna' picklepants")
   windower.send_command("bind ^pageup send skookum /ma 'poisona' picklepants")
   windower.send_command("bind delete send skookum /ma 'cure' picklepants")
   windower.send_command("bind ~delete send skookum /ma 'cure' skookum")
   windower.send_command("bind ^numpad* send skookum /ws "..settings.weaponskill.skookum.." <t>")
   windower.send_command("bind ~numpad* kb attack")
end

function solo_binds()
   windower.send_command("bind ~numpad7 kb mount")
   windower.send_command("bind ~numpad3 kb warp")
   windower.send_command("unbind delete")
   windower.send_command("unbind home")
end