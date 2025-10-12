local command = {}
function command.run(message, mt)
local time = sw:getTime()
  print(message.author.name .. " did !pray")
  local uj = dpf.loadjson("savedata/" .. message.author.id .. ".json", defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/pray.json", "")
  
  if not message.guild then
    message.channel:send(lang.dm_message)
    return
  end
  
  local cooldown = config.cooldowns.pray
  if uj.equipped == "faithfulnecklace" then
    cooldown = config.cooldowns.pray_necklace
  end

  if not uj.lastprayer then
    uj.lastprayer = -30
  end

  if uj.lastprayer + cooldown > time:toHours() then
    --extremely jank implementation, please make this cleaner if possible
    local minutesleft = math.ceil(uj.lastprayer * 60 - time:toMinutes() + cooldown * 60)
    local durationtext = formattime(minutesleft, uj.lang)
    message.channel:send(formatstring(lang.wait_message, {durationtext}))
    return
  end
  
  uj.tokens = uj.tokens and uj.tokens + 1 or 1
  uj.timesprayed = uj.timesprayed and uj.timesprayed + 1 or 1
  uj.lastprayer = time:toHours()
  
  if uj.sodapt then
    if uj.sodapt.pray then
      uj.lastprayer = uj.lastprayer + uj.sodapt.pray
      uj.sodapt.pray = nil
      if uj.sodapt == {} then
        uj.sodapt = nil
      end
    end
  end
  
  dpf.savejson("savedata/" .. message.author.id .. ".json",uj)

  message.channel:send(lang.prayed_message)
  if not uj.togglechecktoken then
    message.channel:send(formatstring(lang.checktoken, {uj.tokens}, lang.time_plural_s))
  end
end
return command
