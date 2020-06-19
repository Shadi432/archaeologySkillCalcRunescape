--A collaborative project done by Shadi432 and Sethboi.
--[[

⠄⠄⠄⠄⠄⠄⣀⣀⣀⣤⣶⣿⣿⣶⣶⣶⣤⣄⣠⣴⣶⣿⣿⣿⣿⣶⣦⣄⠄⠄
⠄⠄⣠⣴⣾⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦
⢠⠾⣋⣭⣄⡀⠄⠄⠈⠙⠻⣿⣿⡿⠛⠋⠉⠉⠉⠙⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿
⡎⣾⡟⢻⣿⣷⠄⠄⠄⠄⠄⡼⣡⣾⣿⣿⣦⠄⠄⠄⠄⠄⠈⠛⢿⣿⣿⣿⣿⣿
⡇⢿⣷⣾⣿⠟⠄⠄⠄⠄⢰⠁⣿⣇⣸⣿⣿⠄⠄⠄⠄⠄⠄⠄⣠⣼⣿⣿⣿⣿
⢸⣦⣭⣭⣄⣤⣤⣤⣴⣶⣿⣧⡘⠻⠛⠛⠁⠄⠄⠄⠄⣀⣴⣿⣿⣿⣿⣿⣿⣿
⠄⢉⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣦⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⢰⡿⠛⠛⠛⠛⠻⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠸⡇⠄⠄⢀⣀⣀⠄⠄⠄⠄⠄⠉⠉⠛⠛⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠄⠈⣆⠄⠄⢿⣿⣿⣿⣷⣶⣶⣤⣤⣀⣀⡀⠄⠄⠉⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠄⠄⣿⡀⠄⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠂⠄⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠄⠄⣿⡇⠄⠄⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠄⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠄⠄⣿⡇⠄⠠⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠄⠄⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠄⠄⣿⠁⠄⠐⠛⠛⠛⠛⠉⠉⠉⠉⠄⠄⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿
⠄⠄⠻⣦⣀⣀⣀⣀⣀⣀⣤⣤⣤⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠄
We are sorry for anyone trying to read this.
]]--

local p = {}
local data = mw.loadData('Module:Skill_calc/Archaeology/data') -- mw.loadData parses the specified module and returns it's table.
local gemw = require('Module:ExchangeLite')
local xp = require('Module:Experience').xp_at_level
local level = require('Module:Experience').level_at_xp
local coins = require('Module:Currency')._amount
local commas = require('Module:Addcommas')._add
local round = require("Module:Round").round

local lang = mw.getContentLanguage() -- Number format helper function.

local test

local function fnum(x) -- Formats numbers in the default language.
	if type(x) == 'number' then
		return lang:formatNum(x)
	end
	return nil -- You tried to format a number and it wasn't a number, return nil
end

local function artefactXP(artefactName)  --returns restoration xp of an artefact from a specific hotspot
  for i,v in ipairs(data.artefacts) do
    for j,k in pairs(v["mats"]) do
      if j == artefactName then
        return v["xp"]
      end
    end
  end
end


local function FindProfits(h,hotspot)  --returns the total value of all materials gained from one specific hotspot
	local numMaterialsTable = {}
	local totalprofits = 0
	local numMaterials = 0

	
	for i,v in ipairs (hotspot.materials) do
		local chance = v[2]
		
		local materialsGained = h * (chance/10000)
		numMaterialsTable[v[1]] = materialsGained
		numMaterials = numMaterials + 1
	end

  
	for i,v in pairs(numMaterialsTable) do
		totalprofits = totalprofits + (gemw.price(i))
	end
	totalprofits = totalprofits / numMaterials
	
	return totalprofits
end

local function GetNumArtefactMaterials(havg,r)
	local numMaterialsTable = {}
	-- take MPH divide by each materials' chance.
	-- Take MPH

	for i,v  in pairs (r.materials) do
		local chance = v[2]
		numMaterialsTable[v[1]] = chance/10000
	end
	
	return numMaterialsTable -- Return dictionary with materials name as index
end


local function SoilPrice(havg,r)  --returns total profit of all soil collected, checks soil type from specific hotspot
  soilNum = havg * 0.14
  return gemw.price(r.soil) * soilNum
 end

local avgRestore = 0
local function TotalRestoringPrice(havg,r,precision) --returns avg price of restoring one artefact from a specific hotspot
  local numArtefacts = 0
  local artefactsToRestore = r.artefacts
  local costTable = {}
  for l,m in ipairs(artefactsToRestore) do
    for i,v in ipairs(data.artefacts) do
    	if string.find(m[1], v.name, 1, true) then
        	for j,k in pairs (v.mats) do
        		if not string.match(j,"damaged") and not string.match(j,"Phoenix") and not string.match(j,"mushroom ink") then
        			costTable[#costTable + 1] = k * gemw.price(j)
				end
			end
        end
	end
  end
  
  for i,v in ipairs (r.artefacts) do
		numArtefacts = numArtefacts + 1
	end
  
  local sumSingularPrice = 0
  for i=1, #costTable do
    sumSingularPrice = sumSingularPrice + costTable[i]
  end
  
  avgRestore = sumSingularPrice / numArtefacts
  return avgRestore
end


local function GetChronoteValue(hotspotName) -- index; gets chronote value of artefacts from a specific hotspot
  local artefactName = data.hotspots[hotspotName].artefacts[1][1]
  
  for i,v in ipairs (data.artefacts) do
    for j,k in pairs (v["mats"]) do
      if j == artefactName then
        return v["chronotes"]
      end
    end
  end
end


local function getMattockName(t, mattockLevel, mattockAugmentable)
	for k,v in pairs(t) do
		if v.Level == mattockLevel and v.Augmentable == mattockAugmentable then
			return k
		end
	end
	return nil
end

function remainingExp(curLvl, curXP, tgtLvl, tgtXP)
	local remaining

	if curLvl > 120 and curXP == 1 then
		curXP = curLvl
	elseif curXP <= 120 and curLvl == 1 then
		curLvl = curXP
		curXP = 1
	end
	
	if tgtLvl > 120 and tgtXP == 0 then
		tgtXP = tgtLvl
	elseif tgtXP <= 120 and tgtLvl == 0 then
		tgtLvl = tgtXP
		tgtXP = 0
	end

	if curXP == 1 then
		curXP = xp({args = {curLvl, elite = 0}})
	else
		curLvl = level({args = {curXP, elite = 0}})
	end

	if tgtLvl > 0 or tgtXP > 0 then
		if tgtXP == 0 then
			tgtXP = xp({args = {tgtLvl, elite = 0}})
		else
			tgtLvl = level({args = {tgtXP, elite = 0}})
		end
	end
    
    -- Prevent negative values
    local remaining = math.ceil(tgtXP - curXP)
    if remaining < 0 then
        remaining = 0
    end
    
    return curLvl, curXP, tgtLvl, tgtXP, remaining
end

		
function p.main(frame)
	local args = frame:getParent().args
	local archaeology_level = tonumber(args.archaeology_level) or 1		-- Arch level
	local archaeology_xp = tonumber(args.archaeology_xp) or 1				-- Arch xp
	local target_lvl = tonumber(args.target_level) or 0			-- Target Arch level
	local target_xp = tonumber(args.target_xp) or 0				-- Target Arcb xp
	local mattock = data.mattocks[args.mattock]						-- Mattock
	local methodtmp = args.method or 'AFK'
	local method = data.method[methodtmp]						-- Method chosen
	local gmo = data.pieces[args.pieces] or 0					-- outfit pieces unlocked
	local outfittmp = args.outfit or 'None'
	local outfit = data.outfit_m[outfittmp]						-- Outfit selected
	local pieces = data.pieces[args.pieces]
	local fullmasteroutfit = 0
		if tonumber(pieces) == 1.06 and outfittmp == "Master Archaeologists Outfit" then
			fullmasteroutfit = 1
		end
	local lvl20 = tonumber(args.lvl20) or 1						-- Mattock item level 20
	local upgrade = data.upgrade[args.upgrade]
	local honed = data.honed[args.honed]  or 0				-- Honed perk
	honed = (100+(honed * lvl20))/100
	local fortune = data.fortune[args.fortune]  or 0				-- Honed perk
	fortune = (100+(fortune * lvl20))/100
	local furnace = data.furnace[args.furnace] or 0				-- Furnace perk
	furnace = (100+(furnace * lvl20))/100
	local skillctmp = args.skillchompa or 'None'
	local skillchompa = data.skillchompa[skillctmp]				-- Skillchompas
	local masteroutfitbuff = data.masteroutfitbuff
	local crit_chance = data.critchance
	local tick = .8
	local tea = args.tea or 0
	local monocle = args.monocle or 0
	local crit_bonus = 0
	local s = .21  --s is for successchance, finally using a letter related to the word ;p
	local precision = mattock.Precision + upgrade  --ironically this isn't precision.
		if skillchompa.Level > mattock.Level then
			precision = skillchompa.Precision + upgrade
		end
	local chronoteprice = gemw.price("Chronotes") --price of chronotes for profit calc
	local teaused = 0  --is arch tea buff used
	local skillchompaprice = 0  --are skillchompas used
	local monocleused = 0  --is hi spec monocle buff used
	local hmin = 1100  --minimum hits/h, theoretical maximum is 1500. 1100/1500 is 27% inactivity
	local hmax = 1500
	local havg = 1300
	local autoscreener = args.autoscreener or 0
	local charge = (gemw.price("Divine charge"))/900
	local portablePrice = 0
	local soilchance = .14  --current calculated percentage of gaining soil
	local soilgained = (soilchance * havg)  --total soil gained/h
	local chargeprice = 0
		if tonumber(autoscreener) == 1 then
			chargeprice = charge*soilgained
		end
	local n = furnace  --furnace xp boost, if no furnace then n=1
	local z = (1-s) -- fail chance
	-- Levels and targets
	local alevel, axp, tlvl, txp, remaining = remainingExp(archaeology_level, archaeology_xp, target_lvl, target_xp)
	local has_target = false									-- Has a target
	-- Arch level boosts
	local damage_bonus = upgrade		-- Total damage bonus
	local outputTableData = {}
	local waterfiend = args.waterfiend or 0
	local portable = data.portable[args.portable] or "None"
	local skillcape = args.skillcape or 0
	local spritesuccesschance = .05
		if tonumber(skillcape) == 1 then
			spritesuccesschance = .06978
		end
	local hide = args.hide or 1
	local difference = 120
	local statsForNerds = tonumber(args.statsfornerds)
	
		if tonumber(hide) == 1 then
			difference = 10
		end
	
	if portable ~= "None" then
		if portable == "Pale energy" then
		portablePrice = (30*gemw.price(portable) + gemw.price("Sapphire necklace"))/5
		elseif portable == "Bright energy" then
		portablePrice = (35*gemw.price(portable) + gemw.price("Sapphire necklace"))/10
		elseif portable == "Sparkling energy" then
		portablePrice = (40*gemw.price(portable) + gemw.price("Emerald necklace"))/15
		elseif portable == "Vibrant energy" then
		portablePrice = (45*gemw.price(portable) + gemw.price("Emerald necklace"))/20
		elseif portable == "Radiant energy" then
		portablePrice = (60*gemw.price(portable) + gemw.price("Ruby necklace"))/25
		elseif portable == "Incandescent energy" then
		portablePrice = (80*gemw.price(portable) + gemw.price("Diamond necklace"))/30
		elseif portable == "Magic notepaper" then
		portablePrice = gemw.price(portable) 
		end
	end
	
	local waterfiendprice = 0
	local waterfiendchance = 1
	
	if tonumber(waterfiend) == 1 then
		waterfiendprice = gemw.price("Binding contract (waterfiend)")
		waterfiendchance = 1.05
	end
	

	local xp_boosts = 1 * furnace
	
	for i = 1,4 do -- Getting their appropriate crit_bonus_level for their archaeology level.
		if archaeology_level >= data.crit_bonus_level[i] then
			crit_bonus = data.crit_bonus[i]
		else 
			break
		end
	end
	
	if remaining > 0 then has_target = true end					-- Has target true if remaing xp > 0
	
	local spriteprecision = (19 + (crit_bonus))/20
		if skillcape == 1 then
			spriteprecision = (13.33 + (crit_bonus))/14
		end
	
	local spritexpboost = 1
		if methodtmp == "Time Sprite Medium Intensity" or "Time Sprite High Intensity" then
			spritexpboost = 1.2
		end
										--jk. it is.
	if methodtmp == "AFK" then -- Getting their precision values accurate based on their method and equips
		if fullmasteroutfit == 1 and tonumber(monocle) == 1 then
			precision = precision*masteroutfitbuff*1.2
		elseif fullmasteroutfit == 1 then
			precision = precision*masteroutfitbuff
		elseif tonumber(monocle) == 1 then
			precision = precision*1.2
		end
	elseif methodtmp == "Time Sprite Medium Intensity" then
		if fullmasteroutfit == 1 and tonumber(monocle) == 1 then
			precision = precision*masteroutfitbuff*1.2*1.1
		elseif fullmasteroutfit == 1 then
			precision = precision*masteroutfitbuff*1.1
		elseif tonumber(monocle) == 1 then
			precision = precision*1.2*1.1
		else
			precision = precision*1.1
		end
	elseif methodtmp == "Time Sprite High Intensity" then
		if fullmasteroutfit == 1 and tonumber(monocle) == 1 then
			precision = precision*masteroutfitbuff*1.1*1.2*spriteprecision
		elseif fullmasteroutfit == 1 then
			precision = precision*masteroutfitbuff*1.1*spriteprecision
		elseif tonumber(monocle) == 1 then
			precision = precision*1.1*1.2*spriteprecision
		else
			precision = precision*1.1*spriteprecision
		end
	end
	
	if methodtmp == "Time Sprite High Intensity" then  --calculating success chance
		if honed > 1 and fullmasteroutfit == 1 then
			s = (s+spritesuccesschance) * honed * masteroutfitbuff
		elseif honed > 1 then
			s = (s+spritesuccesschance) * honed
		elseif fullmasteroutfit == 1 then
			s = (s+spritesuccesschance) * masteroutfitbuff
		else
			s = (s+spritesuccesschance)
		end
	else
		if honed > 1 and fullmasteroutfit == 1 then
			s = s * honed * masteroutfitbuff
		elseif honed > 1 then
			s = s * honed
		elseif fullmasteroutfit == 1 then
			s = s * masteroutfitbuff
		end
	end
	
	if tonumber(tea) == 1 and fullmasteroutfit == 1 then
		teaused = chronoteprice * 2 * 2000  --the *3 is 3 used to get an hour buff.
		elseif tonumber(tea) == 1 then
		teaused = chronoteprice * 3 * 2000
	end
	
	if tonumber(monocle) == 1 and fullmasteroutfit == 1 then
		monocleused = chronoteprice * 2 * 2000  --the *3 is 3 used to get an hour buff.
		elseif tonumber(monocle) == 1 then
		monocleused = chronoteprice * 3 * 2000
	end
	
	if skillchompa.Level > mattock.Level then
		skillchompaprice = gemw.price(skillctmp.." skillchompa")
	end

	if outfit.gmo == 1 then xp_boosts = xp_boosts + pieces end -- If the selected outfit applies the archaeology outfit bonus then add it to xp boosts.
-- Quick note: I will be using group1 as it ony has the xp% increase. Group2 (master outfit) will be included in later in the module.
	

	local t = mw.html.create('table')	-- Creates an mw.html object for us, creates a table html element.
	t:addClass('wikitable sortable') -- Adding the wikitable sortable class means I can sort the entire class
	
	if true then -- if has_target then
		local r = t:tag('tr') :addClass(row_classes) -- Creates new row in the table 
		
		r:tag('th')  :wikitext('Level')		:attr('rowspan', 2) :done()
		:tag("th")	:wikitext("Image")	:attr("rowspan", 2)	:done()
		:tag('th')  :wikitext('Excavation Hotspot')		:attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Materials')	:attr('rowspan', 2) :done()
		:tag('th')  :wikitext('Artefacts')	:attr('rowspan', 2) :done()
		:tag('th')  :wikitext('XP/H')	:attr("rowspan",2) :done()
		
		if statsForNerds == 1 then
			r:tag("th")	:wikitext("Artefacts/H") :attr("rowspan", 2) :done()
		end
		
		r:tag("th")	:wikitext("Average Restore Cost") :attr("rowspan", 2) :done()
		:tag('th')  :wikitext('Materials/H')		:attr('rowspan', 2) :done()
		
		if statsForNerds == 1 then
			r:tag('th')  :wikitext('Materials Value')	:attr('rowspan', 2) :done()
			:tag('th')  :wikitext('GP Per Hour')	:attr('rowspan', 2) :done()
		end
		
		r:tag("th")	:wikitext("GP/XP")	:attr("rowspan",2)	:done()
		:tag("th")	:wikitext("Hours to Target")	:attr("rowspan", 2)	:done()
		

		r:done()
	end
	
	for index, r in pairs(data.hotspots) do -- For every hotspot
		
			
		
		if tlvl +5 >= r.level and alevel - difference <= r.level then	-- Remove excavations that cannot be done at the selected arch level
			
			
					
			
			
			local Tminxp = 0 -- Total min xp
			local Tavgxp = 0 -- Total avg xp
			local Tmaxxp = 0 -- Totalmaxxp
			local Tprofit = 0
			local mValue
			local artefactNum = 0
			local tRestoreCost
				if args.method == 'AFK' or 'Time Sprite Medium Intensity' or 'Time Sprite High Intensity' then
					
					
					
					local d = r.failxp or 2 --finding the value of failure xp
					local a = (r.successxp or d*10)   --xp for successfully getting a material
					local b = 7 * a  --xp for finding an artefact
					local c = artefactXP(r.artefacts[1][1])  --returns function, finds average experience of restoring one artefact
					
					local e = r.hitpoints  --returns the hitpoints of one hotspot
					local g = r.artefacts  --returns list of artefacts from one hotspot
					local ggained = waterfiendchance * (havg)/(e/precision)  --total avg artefacts gained per hour, calculated by taking hitpoints / precision (which is damage dealt)
					local sp = SoilPrice(havg,r)  --gets average profits for collecting soil
						if tonumber(autoscreener) == 1 then
							sp = 0
						end
					local mph = GetNumArtefactMaterials(havg,r)
					local chronoteX = GetChronoteValue(index)  --Gets average chronote value of one artefact from one hotspot
					local totalPrice = TotalRestoringPrice(havg, r, precision)  --average price for restoring one artefact
					local x = ggained * (totalPrice)  --calculating the average cost of all materials required for restoring artefacdts
					local i = ggained * b * spritexpboost --i stands for total xp gained from finding artefacts
				    if tonumber(tea) > 0 then
				        i = i * 1.5
				    end
					local j = ggained * c --j stands for total xp gained from restoring artefacts
					local f = havg * s  --f stands for total raw materials gained, before fiend and furnace apply. drop an f in the chat
					local q = ((n-1)+1)*f*a*spritexpboost  --q stands for total xp for finding mats with + without furnace perk. no furnace perk, remember n=1. cancels.
					    if tonumber(tea) > 0 then
					        q = q * 1.5
					    end
					local l = havg * z * d * spritexpboost --l stands for total failure xp. make sense? get that L? hahahaha... good one Pog
					    if tonumber(tea) > 0 then
					        l = l * 1.5
					    end
					    
					local mp = FindProfits(havg,r) --gets average profits for collecting materials
					    
					    
					    
					    
					    
					    --    Total xp and gp calculation
					    
					    
					    
					    
					local MAFKavg = l + q + j + i  --M means raw total xp/h without xp boosts. everything that follows the variable is logical.
					local TAFKavg = MAFKavg * gmo  --T means total xp/h including boosts.
					if skillchompa.Level>mattock.Level then
						TAFKavg = MAFKavg * gmo * skillchompa.Boost
					end
				
					
					local AFKProfit = ((1-(n-1))*f + (waterfiendchance*f - f) + (f*fortune - f))*mp + (ggained * chronoteX) - chargeprice  + sp -  x   - (portablePrice*(1-(n-1))*f) - teaused - monocleused - (2000 * skillchompaprice) - waterfiendprice --TOTAL profit/loss calculation for the afk method!!! surprise surprise, arch makes you lose money. :P
					mphValue = mph
					Tavgxp = TAFKavg
					Tprofit = AFKProfit
					mValue = (1-(n-1))*f + (waterfiendchance*f - f) + (f*fortune - f)
					artefactNum = ggained
					tRestoreCost = totalPrice
					
					testingg = mphValue
				end
				
				local materialsList = {}
				local artefactsList = {}
				local testVar = nil
				local numMaterials = 0
				local numArtefacts = 0
				
				for i,v in ipairs (r.materials) do
					numMaterials = numMaterials + 1
				end
				
				for i,v in ipairs (r.artefacts) do
					numArtefacts = numArtefacts + 1	
				end
				
				for i,v in ipairs (r.materials) do
					local endValue = ""
					
				
					testVar = (tostring(#r.materials))
					if i == numMaterials then
						endValue = ""	
					end
					
					table.insert(materialsList , "[[File:" .. v[1] .. ".png|" .. v[1] .. "|25x25px|link=" .. v[1] .. "]]" .. " [[" .. v[1] .. "]]" .. endValue)
				end
				
				for i,v in ipairs (r.artefacts) do
					local endValue = ""
					
					if i == numArtefacts then
						endValue = ""	
					end
					
					table.insert(artefactsList,"[[File:" .. v[1] .. ".png|" .. v[1] .. "|25x25px|link=" .. v[1] .. "]]" .. " [[" .. v[1] .. "]]" .. endValue)
				end
				
				
				local hotspot1 = "[[File:" .. index .. ".png|" .. index .. "|50x50px|link=" .. index .. "]]"
				
				if index == "Kyzaj champion's boudoir" then
					nIndex = "Kyzaj champions boudoir"
					hotspot1 = "[[File:" .. nIndex .. ".png|" .. nIndex .. "|50x50px|link=" .. nIndex .. "]]"
				end
				
				local displayList = ("")
				
				for i,v in pairs (testingg) do
					displayList = (displayList .. "[[File:" .. i .. ".png|" .. i .. "|25x25px|link=" .. i .. "]]"  .. " "  .. tostring(math.floor(v * mValue))	.. "<br>")
				end
				
				local mValueColumn = ("")
				local mValueColumnPrice = 0
				
				for i,v in pairs (testingg) do
					mValueColumn = (mValueColumn .. "[[File:" .. i .. ".png|" .. i .. "|25x25px|link=" .. i .. "]]"  .. " "  .. commas(math.floor(gemw.price(i) * (v*mValue)))	.. "<br>")
					mValueColumnPrice = mValueColumnPrice + gemw.price(i)*(v*mValue)
				end
				mValueColumnPrice = math.floor(mValueColumnPrice)
				
				mValueColumn = mValueColumn .. coins(mValueColumnPrice,"coins")
				
				
				-- local start, end = string.find(index)
				outputTableData[index] = {
					["Level"] = r.level,
					["Img"] = hotspot1,
					["Materials"] = table.concat(materialsList, '<br>'),
					["Artefacts"] = table.concat(artefactsList, '<br>'),
					["XP/H"] = Tavgxp,
					["Artefacts/H"] = tostring(artefactNum),
					["Restore Cost"] = tRestoreCost,
					["Materials/H"] = displayList,
					["MaterialsValue"] = mValueColumn,
					["GP/H"] = Tprofit,
					["GP/XP"] = Tprofit / Tavgxp,	
					["HoursToTarget"] = remaining / Tavgxp,
					["Test"] = statsForNerds,
				} 
			
			-----------------------------------------------------------------------------------------------------------------------------------------------------------
		end
		
		
					
	end
	
	local outputOrder = {}
	
	for i,v in pairs (outputTableData) do
		table.insert(outputOrder,i)	
	end
		
	for x=1, #outputOrder-2 do
		for i=1, #outputOrder-1 do
			currentNodeLevel = outputTableData[outputOrder[i]].Level
			nextNodeLevel = outputTableData[outputOrder[i + 1]].Level
			
			if currentNodeLevel > nextNodeLevel then
				local temp = outputOrder[i+1]
				outputOrder[i+1] = outputOrder[i]
				outputOrder[i] = temp
			end
		end
	end
	

	
	
	for i=1, #outputOrder do
		v = outputTableData[outputOrder[i]]
		
		local row_classes = 'table-bg-yellow sortbottom'
	    if tonumber(alevel) >= tonumber(outputTableData[outputOrder[i]].Level) then
	        row_classes = 'table-bg-green'
	    else
	        row_classes ='table-bg-yellow sortbottom'
	    end
	    
		local row = t:tag("tr") :addClass(row_classes)
	    
		row:tag("td")	:wikitext(v["Level"])	:done()
		:tag("td")	:wikitext(v["Img"])		:done()
		:tag("td")	:wikitext("[["..outputOrder[i].."]]") :css("table-layout", "fixed")    :done()
		:tag("td")	:wikitext(v["Materials"]) :css("table-layout", "fixed")	:css('text-align', 'center')	:done()
		:tag("td")	:wikitext(v["Artefacts"]) :css('text-align', 'center')	:done()
		:tag("td")	:wikitext(fnum(math.ceil(v["XP/H"])))	:css('text-align', 'center')	:done()
		
		if statsForNerds == 1 then
			row:tag("td")	:wikitext(string.format("%.1f", math.floor(v["Artefacts/H"] * 10 + 0.5) / 10))	:css("text-align", "center") :done()
		end
		row:tag("td")	:wikitext(tostring(coins(math.floor(v["Restore Cost"]),"coins")))	:css("text-align", "center")	:done()
		:tag("td")	:wikitext(v["Materials/H"]) :css('text-align', 'center')	:done()
		
		if statsForNerds == 1 then
			row:tag("td")	:wikitext(v["MaterialsValue"])	:css('text-align', 'center')	:done()
			:tag("td")	:wikitext(coins(string.format("%.1f", math.floor(math.floor(v["GP/H"] * 10 + 0.5) / 10)),'coins')) :css('text-align', 'center')	:done()
		end
		row:tag("td")	:wikitext(coins(string.format("%.2f", ((v["GP/XP"] * 10 + 0.5) / 10)),'coins'))	:css("text-align", "center")	:done()
		:tag("td")	:wikitext("[[File:" .. "Hourglass".. ".png|" .. "Hourglass" .. "|20x20px|link=" .. "Hourglass" .. "]]"  .. " " .. string.format("%.0f", v["HoursToTarget"] * 10 + 0.5) / 10)	:css("text-align", "center") :css("table-layout", "fixed")	:done()
		--[[local nerdColumn =--]]
	--[[	if statsForNerds == 1 then
			nerdColumn	:css("visibility", "collapse")
		else 
			nerdColumn :css("visibility", "visible")
		end--]]
	end
	

	
	local msg = mw.html.create('div')

	-- Add message of xp needed to reach target
	if has_target then
		local msgtxt = 'To train archaeology from '..commas(axp)..' experience (level '..alevel..') to '..commas(txp)..' experience (level '..tlvl..'), '..commas(remaining)..' experience is required.'
		msg:tag('p'):css({['font-size'] = "1.1em", ['font-weight'] = "bold"}):wikitext(msgtxt):done()
	end
	
	
	return tostring(msg)..tostring(t) -- Final return of this function, should tell them the amount of xp they need to get from certain level to certain level.
end


return p
