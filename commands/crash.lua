
local command = {}
function command.run(message, mt)
  print("lmao someone did c!crash")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/crash.json", "")
  if isauthoradmin(message) then
    message.channel:send(lang.message)
    print("string string stringity string" .. nilvalue)
  else
    message.channel:send(lang.modsonly)
  end
end
return command
  
