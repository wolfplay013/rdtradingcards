local command = {}
function command.run(message, mt)
  print(message.author.name .. " did !fullstorage")
  local filename = "savedata/" .. message.author.id .. ".json"
  local uj = dpf.loadjson(filename, defaultjson)
  local lang = dpf.loadjson("langs/" .. uj.lang .. "/fullstorage.json", "")

  local enableShortNames = true
  local enableSeason = false
  
  local filterSeasons = {}
  local filterSeasonsCount = 0
  local filterRarities = {}
  local filterRaritiesCount = 0

  args = {}
  for substring in mt[1]:gmatch("%S+") do
    table.insert(args, substring)
  end

  for index, value in ipairs(args) do
    if value == "-s" then -- wolfplay's suggestion
      enableShortNames = true
--      print("-s enabled")
    elseif string.find(value, "-season") then
      if value == "-season" then
        enableSeason = true
  	  	print("-season enabled")
		  else
		  	local num = string.gsub(value, "-season", "") -- fuck you gsub
		  	local season = math.abs(tonumber(num))
		    if season and season <= 11 then
		      filterSeasons[season] = true
		      filterSeasonsCount = filterSeasonsCount+1
  	  	  print("filtering for season "..season)
		    end
		  end
		elseif string.find(value, "-rarity") then
		  local rarity = string.gsub(value, "-rarity", "")
		  if rarities[rarity] then
  		  filterRarities[rarity] = true
		    filterRaritiesCount = filterRaritiesCount+1
  	  	print("filtering for rarity "..rarity)
  		end
		else
			if value[0] ~= '-' then
				filename = usernametojson(value)
        uj = dpf.loadjson(filename, defaultjson)
			end
		end
  end

  local storetable = {}
  local storestring = ''
  local invfilter = uj.storage
  
  if filterSeasonsCount > 0 then
    for k,v in pairs(invfilter) do
	    if not filterSeasons[cdb[k].season] then
	      invfilter[k] = nil
	    end
	  end
  end


  if filterRaritiesCount > 0 then
    for k,v in pairs(invfilter) do
      if not filterRarities[rarities_invert[cdb[k].type]] then
        invfilter[k] = nil
      end
    end
  end

  local numkey = tablelength(invfilter)

  
  
  local seasonnum = ""
	local raritytext = ""
  local multipleSeasons = filterSeasonsCount > 1
	local multipleRarities = filterRaritiesCount > 1
  
  for season,_ in pairs(filterSeasons) do
    if #seasonnum > 0 then seasonnum = seasonnum..", " end
    seasonnum = seasonnum .. tostring(season)
  end

  for rarity_short,_ in pairs(filterRarities) do
    if #raritytext > 0 then raritytext = raritytext..", " end
    raritytext = raritytext .. rarities[rarity_short]
  end
  
  local embedtitle = lang.embed_title
  if filterSeason then
		local filtertitle = ""
		if multipleSeasons then
			if lang.needs_plural_s then
				filtertitle = lang.plural_s .. " " .. seasonnum
			else
				filtertitle = " " .. seasonnum
			end
		else
			filtertitle = " " .. seasonnum
		end
		embedtitle = embedtitle .. formatstring(lang.season, {filtertitle})
  end

	if filterRarity then
		embedtitle = embedtitle .. formatstring(lang.rarity, {raritytext})
	end
  
  local contentstring = (uj.id == message.author.id and lang.embed_your or "<@" .. uj.id .. ">" .. lang.embed_s) .. lang.embed_contains
  local prevstorestring = ''
  for k,v in pairs(invfilter) do
  	table.insert(storetable,
			"**" .. (cdb[k].name or k) .. "** x" .. v ..
			(enableShortNames and (" ("..k..") ") or "") ..
			(enableSeason and formatstring(lang.season, {cdb[k].season}) or "") .."\n"
		)
	end
  table.sort(storetable)
  for i = 1, numkey do
    storestring = storestring .. storetable[i]
    if #storestring > 4096 then
      message.author:send{
        content = contentstring,
        embed = {
          color = uj.embedc,
          title = embedtitle,
          description = prevstorestring
        },
      }
      storestring = storetable[i]
      contentstring = ''
      embedtitle = embedtitle .. lang.embed_cont
    end
    prevstorestring = storestring
  end
  message.author:send{
    content = contentstring,
    embed = {
      color = uj.embedc,
      title = embedtitle,
      description = storestring
    },
  }
end
return command
