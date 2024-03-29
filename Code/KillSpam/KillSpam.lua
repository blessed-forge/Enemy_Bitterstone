local Enemy = Enemy
local tinsert = table.insert

local ORDER = SystemData.ChatLogFilters.RVR_KILLS_ORDER
local DESTR = SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION

local ORDER_COLOR = {r = 0, g = 180, b = 255}
local DESTR_COLOR = {r = 255, g = 100, b = 100}
local CURRENT_COLOR = {r = 255, g = 255, b = 0}

local g = {}

function Enemy.KillSpamInitialize ()

	Enemy.killSpam = g
	
	-- UI: killspam window
	CreateWindow ("EnemyKillSpamDialog", true)
	WindowSetDimensions ("EnemyKillSpamDialog", 375, 240)	-- force new size
	LayoutEditor.RegisterWindow ("EnemyKillSpamDialog", L"Enemy kills", L"Enemy kills", false, false, true, nil)
	
	LabelSetText ("EnemyKillSpamDialogTotal", L"Total")
	LabelSetTextColor ("EnemyKillSpamDialogTotalDestr", DESTR_COLOR.r, DESTR_COLOR.g, DESTR_COLOR.b)
	LabelSetTextColor ("EnemyKillSpamDialogTotalOrder", ORDER_COLOR.r, ORDER_COLOR.g, ORDER_COLOR.b)
	
	WindowSetTintColor ("EnemyKillSpamDialogBackground", 0, 0, 0)
	WindowSetAlpha ("EnemyKillSpamDialogBackground", 0)
	
	-- UI: killspam area stats
	CreateWindow ("EnemyKillSpamAreaStatsDialog", false)
	
	-- UI: player KDR window
	CreateWindow ("EnemyPlayerKDR", true)
	LayoutEditor.RegisterWindow ("EnemyPlayerKDR", L"Enemy KDR", L"Enemy kill/death ratio", true, true, true, nil)
	
	-- UI: killed by window
	CreateWindow ("EnemyKilledBy", true)
	LayoutEditor.RegisterWindow ("EnemyKilledBy", L"Enemy 'Killed by'", L"Enemy 'killed by' window", true, true, true, nil)
	
	-- static events
	Enemy.AddEventHandler ("KillSpam", "SettingsChanged", Enemy.KillSpam_OnSettingsChanged)
	
	Enemy.AddEventHandler ("KillSpam", "ConfigDialogInitializeSections", function (sections)
		table.insert (sections,
		{
			name = "KillSpam",
			title = L"Killspam",
			templateName = "EnemyKillSpamConfiguration",
			onInitialize = Enemy.KillSpamUI_ConfigDialog_OnInitialize,
			onLoad = Enemy.KillSpamUI_ConfigDialog_OnLoad,
			onSave = Enemy.KillSpamUI_ConfigDialog_OnSave,
			onReset = Enemy.KillSpamUI_ConfigDialog_OnReset
		})
	end)
	
	Enemy.localization.killSpamParse =
	{
		enUS = function (str)
			local victim, player, location = str:match (L"(%a+) has been .- by (%a+)'s .- in (.-)%..*")
			return victim, player, location
		end,
		
		deDE = function (str)
			--Muzrok wurde von Hellomababy bei der Nordland XI mit seiner Chraceaxt der Rachsucht zerhackt.
			--Naryrs wurde von Domigni auf dem Festplatz mit seiner Musketensalve vernichtet.
			--Dorunor wurde von Lasall auf dem Festplatz mit seinem schnellen Einschnitt vernichtet.
			--Sallandra wurde von Dugrond auf dem Festplatz mit seiner Musketensalve vernichtet.
			--Bendip wurde von Skalartik auf dem Festplatz mit seiner Musketensalve ausgelöscht. Skalartik verfällt in Raserei!
			--Anoriella wurde von Marhin auf dem Festplatz mit seinem Bihänder der Rachsucht zerschnitten.
			--Tondert wurde von Marhin auf dem Festplatz mit seinem behexten Hieb vernichtet.
			--Thiqo wurde von Skalartik auf dem Festplatz mit seinem Brandschuss ausgelöscht. Skalartik verfällt in einen Amoklauf!
			
			local victim, player, location = str:match (L"(%a+) wurde von (%a+) auf de[mnr] (.-) mit .*")
			if (victim == nil or player == nil or location == nil)
			then
				victim, player, location = str:match (L"(%a+) wurde von (%a+) bei de[mnr] (.-) mit .*")
				if (victim == nil or player == nil or location == nil)
				then
					victim, player, location = str:match (L"(%a+) wurde von (%a+) [ai]n de[mnr] (.-) mit .*")
					if (victim == nil or player == nil or location == nil)
					then
						victim, player, location = str:match (L"(%a+) wurde von (%a+) inmitten de[rs] (.-) mit .*")
						if (victim == nil or player == nil or location == nil)
						then
							victim, player, location = str:match (L"(%a+) wurde von (%a+) [ai][nm] (.-) mit .*")
							if (victim == nil or player == nil or location == nil)
							then
								victim, player, location = str:match (L"(%a+) wurde von (%a+) beim? (.-) mit .*")
								if (victim == nil or player == nil or location == nil)
								then
									victim, player, location = str:match (L"(%a+) wurde von (%a+) auf (.-) mit .*")
									if (victim == nil or player == nil or location == nil)
									then
										victim, player, location = str:match (L"(%a+) wurde von (%a+) inmitten (.-) mit .*")
									end
								end
							end
						end
					end
				end
			end
			
			return victim, player, location
		end,
		
		frFR = function (str)
			--Galathe s'est fait anéantir par le Couperet de l'âme de Killhan dans Vallée de Jure-serment.
			--Célina s'est fait anéantir par les Douleurs lancinantes de Sheneri dans Vallée de Jure-serment.
			--Harell s'est fait anéantir par la Toxine cardiaque de Limpide dans Vallée de Jure-serment.
			--Cerbhair a été détruit par l'Affolement de Diskar dans Vallée de Jure-serment. Diskar fait un carnage !
			--Gedadriel a été détruit par le Souffle de feu de Lurgic dans Vallée de Jure-serment. Lurgic fait un carnage !
			--Lurgic a été taillé en pièces par le Krogenz, latte du Destin de Stunk dans Vallée de Jure-serment. Stunk fait un carnage !
			--Duregart a été détruit par le Couperet de l'âme de Killhan dans Vallée de Jure-serment.
			--Angelhus s'est fait anéantir par l'Afflux de douleur d'Elhodia dans Vallée de Jure-serment. Elhodia se déchaîne !
			--Wok a été haché menu par le kikoup d'anathème du titan d'Irock dans Vallée de Jure-serment. Irock fait un carnage !
			--Gnedo a été détruit par la Cascade désastreuse d'Evince dans Vallée de Jure-serment. Evince fait un carnage !
			--Willounet a été détruit par le Puits des ombres de Bernik dans Vallée de Jure-serment.
			--Loseline s'est fait anéantir par la Cascade désastreuse de Shinmen dans Vallée de Jure-serment. Shinmen fait un carnage !
			--Elhodia a été détruit par la Fin inexorable de Diskar dans Vallée de Jure-serment. Diskar fait un carnage !
			--Arson a été détruit par l'Afflux de douleur d'Evince dans Vallée de Jure-serment. Evince fait un carnage !
			--Nainportout s'est fait anéantir par Libérer les vents de Gristonas dans Vallée de Jure-serment. Gristonas se déchaîne !
			--Vendêtto s'est fait anéantir par l'Affolement de Diskar dans Vallée de Jure-serment. Diskar fait un carnage !
			--Wothan s'est fait anéantir par la Répulsion de Gwahyr dans Vallée de Jure-serment. Gwahyr fait un carnage !
			
			--Pandorus s'est fait anéantir par l'Explosion de Pandorus dans Vallée de Jure-serment.
			--Pandorus has been annihilated by the explosion in Pandorus Valley Swear oath.
			
			--Thaddee s'est fait anéantir par le Mot de douleur de Spykked dans Kazad Dammaz.
			--Thaddee has been annihilated by the Word of pain in Spykked Kazad Dammaz.
			
			--Ghep s'est fait écraser par l'écraseur d'hors-la-loi de Vendêtto dans Vallée de Jure-serment.
			--GheP was crushed by the crusher of off-the-law in Vendêtto Valley Swear oath.
			
			--Amaurea s'est fait anéantir par l'Afflux de douleur d'Evince dans Vallée de Jure-serment. Evince fait un carnage !
			--Amauri has been annihilated by the Influx of pain in Evince Valley Swear oath. Evince is a massacre!
			
			local victim, player, location = str:match (L"(%a+) .*[%s%'](%a+) dans (.+)%..*")
			if (victim == nil or player == nil or location == nil)
			then
				victim, player, location = str:match (L"(%a+) .-(%a+) dans (.+)%..*")
			end
			
			return victim, player, location
		end,
		
		ruRU = function (str)
			--Игрок Мурбаг растерзан игроком Сквирес (Точный удар) на территории Путь Змеи.
			--Игрок Брост растерзан игроком Барракуда (Уничтожение мысли) на территории Путь Змеи.
			--Игрок Мурбаг уничтожен игроком Карго (Пламя Рхайна) на территории Путь Змеи.
			--Игрок Барракуда уничтожен игроком Брост (Сверхновая) на территории Путь Змеи.
			--Игрок Ретурн зарублен игроком Карго (секира Песчаной бури) на территории Путь Змеи. Карго впадает в ярость!
			--Игрок Верзиул уничтожен игроком Таир (Просачивающаяся сила) на территории Путь Змеи.
			--Игрок Сугби разрублен на куски игроком Сквирес (клеймор натиска) на территории Путь Змеи. Сквирес впадает в ярость!
			--Игрок Смокерз растерзан игроком Ромео (Выжигание лжи) на территории Путь Змеи. Ромео впадает в ярость!
			--Игрок Морриол пристукнут игроком Брост (Акире, создатель) на территории Путь Змеи. Брост впадает в ярость!
			--Игрок Вратарь растерзан игроком Гиперион (Пламя Рхайна) на территории рейкландская фабрика.
			local victim, player, location = str:match (L"Игрок (%a+) .+ игроком (%a+) .+ на территории (.+)%..*")
			return victim, player, location
		end,
		
		koKR = function (str)
			local victim, location, player = str:match (L"(%a+) 님이 (.-)에서 (%a+)의 .*")
			return victim, location, player
		end
	}
	
	Enemy.TriggerEvent ("KillSpamInitialized")
end


function Enemy._KillSpamEnabledChanged (enable)

	if (g.isPluginEnabled == enable) then return end
	g.isPluginEnabled = enable
	
	if (g.isPluginEnabled)
	then
		g.killSpamParse = Enemy.Localize ("killSpamParse")
		
		RegisterEventHandler (SystemData.Events.PLAYER_AREA_NAME_CHANGED, "Enemy.KillSpam_OnPlayerAreaNameChanged")
		RegisterEventHandler (SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.KillSpam_OnPlayerZoneChanged")
		RegisterEventHandler (TextLogGetUpdateEventId ("Combat"), "Enemy.KillSpam_OnCombatLog")
		RegisterEventHandler (SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.KillSpamUI_PlayerKDR_Update")
		RegisterEventHandler (SystemData.Events.LOADING_END, "Enemy.KillSpamUI_PlayerKDR_Update")
		
		Enemy.AddEventHandler ("KillSpam", "IconCreateContextMenu", function (data)
		
			table.insert (data, { text = L"", callback = nil })

			if (Enemy.KillSpamUI_KillSpamDialog_IsOpen ())
			then
				table.insert (data,
					{
						text = L"Hide zone kills stats window",
						callback = Enemy.KillSpamUI_KillSpamDialog_Hide
					})
			else
				table.insert (data,
					{
						text = L"Show zone kills stats window",
						callback = Enemy.KillSpamUI_KillSpamDialog_Open
					})
			end

			if (Enemy.KillSpamUI_PlayerKDR_IsOpen ())
			then
				table.insert (data,
					{
						text = L"Hide your kill/death ratio",
						callback = Enemy.KillSpamUI_PlayerKDR_Hide
					})
			else
				table.insert (data,
					{
						text = L"Show your kill/death ratio",
						callback = Enemy.KillSpamUI_PlayerKDR_Open
					})
			end
			
			if (Enemy.KillSpamUI_KilledBy_IsOpen ())
			then
				table.insert (data,
					{
						text = L"Hide 'Killed by' window",
						callback = Enemy.KillSpamUI_KilledBy_Hide
					})
			else
				table.insert (data,
					{
						text = L"Show 'Killed by' window",
						callback = Enemy.KillSpamUI_KilledBy_Open
					})
			end
		end)
							
		g.wasEnabled = true
	else
		if (g.wasEnabled)
		then
			UnregisterEventHandler (SystemData.Events.PLAYER_AREA_NAME_CHANGED, "Enemy.KillSpam_OnPlayerAreaNameChanged")
			UnregisterEventHandler (SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.KillSpam_OnPlayerZoneChanged")
			UnregisterEventHandler (TextLogGetUpdateEventId ("Combat"), "Enemy.KillSpam_OnCombatLog")
			UnregisterEventHandler (SystemData.Events.PLAYER_ZONE_CHANGED, "Enemy.KillSpamUI_PlayerKDR_Update")
			UnregisterEventHandler (SystemData.Events.LOADING_END, "Enemy.KillSpamUI_PlayerKDR_Update")
		end
			
		Enemy.RemoveEventHandler ("KillSpam", "IconCreateContextMenu")
	end
end


function Enemy.KillSpam_OnSettingsChanged (settings)

	g.settings = settings
	
	if (not g.settings.playerKDRDisplayMode)
	then
		g.settings.playerKDRDisplayMode = Enemy.DefaultSettings.playerKDRDisplayMode
	end
	
	Enemy._KillSpamEnabledChanged (g.settings.killSpamEnabled);
	
	if (not g.initialized)
	then
		Enemy.KillSpam_OnPlayerZoneChanged ()
		g.initialized = true
	end
	
	if (g.settings.killSpamEnabled)
	then
		Enemy.KillSpamUI_KillSpamDialog_Update ()
		Enemy.KillSpamUI_PlayerKDR_Update ()
	end
end


function Enemy.KillSpamReset ()
	
	Enemy.killSpamListData = {}
	Enemy.killSpamListIndexes = {}
	g.data = {}
	g.playerStats = {}
	g.playerZoneKills = 0
	g.playerZoneDeaths = 0
	
	Enemy.KillSpamUI_KillSpamDialog_Update ()
	Enemy.KillSpamUI_PlayerKDR_Update ()
	Enemy.KillSpamUI_KilledBy_Reset ()
end

function Enemy.KillSpamReparse ()

	if (g.isReparsing) then return end

	Enemy.Print ("Killspam reparsing started ...")

	Enemy.KillSpamReset ()	
	g.reparseIndex = 0
	g.isReparsing = true

	Enemy.AddTaskAction ("killspam reparse",
		function ()
		
			local n = TextLogGetNumEntries ("Combat") - 1
			local max = math.min (n, g.reparseIndex + Enemy.Settings.killSpamReparseChunkSize)
			
			for k = g.reparseIndex, max do
    			Enemy.KillSpam_Parse (k)
			end
			
			g.reparseIndex = max

			if (g.reparseIndex == n)
			then
				g.reparseIndex = nil
				g.isReparsing = false
				
				Enemy.Print ("Killspam reparsing completed.")
				Enemy.KillSpamUI_KillSpamDialog_Update ()
				
				return true
			end
		
			return false
		end
	)
end

function Enemy.KillSpamReparseEnd ()
	Enemy.RemoveTask ("killspam reparse")
	Enemy.Print ("Killspam reparsing canceled.")
	Enemy.KillSpamUI_KillSpamDialog_Update ()
end

function Enemy.KillSpam_OnPlayerAreaNameChanged ()

	Enemy.areaName = GameData.Player.area.name
	
    if (Enemy.areaName == L"")
    then
        Enemy.areaName = GetZoneName (GameData.Player.zone)
    end
    
    if (Enemy.areaName == L"")
    then
        Enemy.areaName = L"Zone "..GameData.Player.zone
    end
    
    Enemy.areaName = Enemy.FixString (Enemy.areaName)
    
	Enemy.KillSpamUI_KillSpamDialog_Update ()
end

function Enemy.KillSpam_OnPlayerZoneChanged ()
	Enemy.KillSpamReset ()
	Enemy.KillSpam_OnPlayerAreaNameChanged ()
	Enemy.KillSpamUI_KillSpamDialog_Update ()
end

function Enemy.KillSpam_OnCombatLog (updateType, filterType)

	if (
		updateType ~= SystemData.TextLogUpdate.ADDED
		or
		g.isReparsing
		or
		(
			filterType ~= SystemData.ChatLogFilters.RVR_KILLS_ORDER
			and
			filterType ~= SystemData.ChatLogFilters.RVR_KILLS_DESTRUCTION
		))
	then
		return
	end

    Enemy.KillSpam_Parse (TextLogGetNumEntries ("Combat") - 1)
    Enemy.KillSpamUI_KillSpamDialog_Update ()
end

function Enemy.KillSpam_GetPlayerStats (areaData, playerName, side)
	
	local area_stats = areaData.playerStats[playerName]
	if (area_stats == nil)
	then
		area_stats =
		{
			name = playerName,
			side = side,
			kills = 0,
			deaths = 0
		}
		
		areaData.playerStats[playerName] = area_stats
	end
	
	local global_stats = g.playerStats[playerName]
	if (global_stats == nil)
	then
		global_stats =
		{
			name = playerName,
			side = side,
			kills = 0,
			deaths = 0
		}
		
		g.playerStats[playerName] = global_stats
	end
	
	return area_stats, global_stats
end

function Enemy.KillSpam_OtherSide (side)
	if (side == ORDER) then return DESTR end
	return ORDER
end

function Enemy.KillSpam_Parse (index)

	local _, t, msg = TextLogGetEntry ("Combat", index)
	if (t ~= ORDER and t ~= DESTR) then return end

	local victim, player, location = g.killSpamParse (msg)

	if (victim == nil or player == nil or location == nil)
	then
		d (L"Failed to parse: "..msg)
		return
	end
	
	Enemy.KillSpam_ParseInternal (location, player, victim, t)
end

function Enemy.KillSpam_ParseInternal (location, player, victim, t)

	-- get area data
	local area_data = g.data[location]
	
	if (area_data == nil)
	then
		area_data =
		{
			name = location,
			playerStats = {},
			time = Enemy.time,
			total = 0,
			orderTotal = 0,
			destrTotal = 0
		}
		
		g.data[location] = area_data
	end
	
	-- update area stats
	area_data.total = area_data.total + 1
	area_data.time = Enemy.time
	
	if (Enemy.KillSpamUI_KillSpamDialog_IsOpen ())
	then
		area_data.flash = t
	end
		
	if (t == ORDER)
	then
		area_data.orderTotal = area_data.orderTotal + 1
	else
		area_data.destrTotal = area_data.destrTotal + 1
	end
	
	-- update player stats
	if (victim ~= player)
	then
		local area_stats, global_stats = Enemy.KillSpam_GetPlayerStats (area_data, player, t)
		area_stats.kills = area_stats.kills + 1
		global_stats.kills = global_stats.kills + 1
		
		if (Enemy.KillSpamUI_KillSpamAreaStatsDialog_IsOpen (area_data))
		then
			area_stats.flash = area_stats.side
		end
	end
	
	-- update victim stats
	local area_stats, global_stats = Enemy.KillSpam_GetPlayerStats (area_data, victim, Enemy.KillSpam_OtherSide (t))
	area_stats.deaths = area_stats.deaths + 1
	global_stats.deaths = global_stats.deaths + 1
	
	-- update player stats
	if (player == Enemy.playerName and victim ~= player)
	then
		Enemy.Settings.playerKills = Enemy.Settings.playerKills + 1
		g.playerZoneKills = g.playerZoneKills + 1
		g.playerKDRUpdated = true
	end
	
	if (victim == Enemy.playerName)
	then
		Enemy.Settings.playerDeaths = Enemy.Settings.playerDeaths + 1
		g.playerZoneDeaths = g.playerZoneDeaths + 1
		g.playerKDRUpdated = true
	end
	
	if (g.playerKDRUpdated)
	then
		Enemy.KillSpamUI_PlayerKDR_Update ()
	end
	
	TargetInfo:UpdateFromClient ()
	
	local current_enemy = Enemy.FixString (TargetInfo:UnitName (TargetInfo.HOSTILE_TARGET))
	if (current_enemy == victim)
	then
		Enemy.KillSpamUI_KilledBy_NewKill (victim, player)
	end
end

function Enemy.KillSpamTest ()

	Enemy.KillSpamReset ()
	
	math.randomseed (Enemy.time)

	Enemy.AddTaskAction ("killspam reparse",
		function ()
		
			local t = ORDER
			if (math.random (2) == 1) then t = DESTR end
			
			local zone = Enemy.toWString (Enemy.GetRandomString (3, 15))
			local player = Enemy.toWString (Enemy.GetRandomString (5, 5))
			local victim = Enemy.toWString (Enemy.GetRandomString (5, 5))
			
			Enemy.KillSpam_ParseInternal (zone, player, victim, t)
			Enemy.KillSpamUI_KillSpamDialog_Update ()
		
			return false
		end
	)
end

function Enemy.KillSpamTestEnd ()
	Enemy.RemoveTask ("killspam reparse")
end

function Enemy.PlayerKDRReset ()
	Enemy.Settings.playerKills = 0
	Enemy.Settings.playerDeaths = 0
	g.playerZoneKills = 0
	g.playerZoneDeaths = 0
	Enemy.KillSpamUI_PlayerKDR_Update ()
end

--------------------------------------------------------------- UI: Killspam dialog
local killspam_dlg = {}

function Enemy.KillSpamUI_KillSpamDialog_Open ()
	WindowSetShowing ("EnemyKillSpamDialog", true)
	Enemy.KillSpamUI_KillSpamDialog_Update ()
end

function Enemy.KillSpamUI_KillSpamDialog_IsOpen ()
	return WindowGetShowing ("EnemyKillSpamDialog")
end

function Enemy.KillSpamUI_KillSpamDialog_Hide ()
	WindowSetShowing ("EnemyKillSpamDialog", false)
end

function Enemy.KillSpamUI_KillSpamDialog_OnLButtonDown ()
	killspam_dlg.isDragged = true
end

function Enemy.KillSpamUI_KillSpamDialog_OnLButtonUp ()
	killspam_dlg.isDragged = false
end

function Enemy.KillSpamUI_KillSpamDialog_OnMouseOver ()
	if (killspam_dlg.isDragged) then return end
	WindowStartAlphaAnimation ("EnemyKillSpamDialogBackground", Window.AnimationType.SINGLE_NO_RESET, 0, 0.5, 0.3, true, 0, 1)
end

function Enemy.KillSpamUI_KillSpamDialog_OnMouseOverEnd ()
	if (killspam_dlg.isDragged) then return end
	WindowStartAlphaAnimation ("EnemyKillSpamDialogBackground", Window.AnimationType.SINGLE_NO_RESET, 0.5, 0, 0.3, true, 0, 1)
end

function Enemy.KillSpamUI_KillSpamDialog_OnListPopulate ()

	if (EnemyKillSpamDialogList.PopulatorIndices == nil) then return end
	
	local row_window_name
	local data
	
	for k, v in ipairs (EnemyKillSpamDialogList.PopulatorIndices)
	do
		row_window_name = "EnemyKillSpamDialogListRow"..k
		data = Enemy.killSpamListData[v]
		
		LabelSetTextColor (row_window_name.."DestrCount", DESTR_COLOR.r, DESTR_COLOR.g, DESTR_COLOR.b)
		LabelSetTextColor (row_window_name.."OrderCount", ORDER_COLOR.r, ORDER_COLOR.g, ORDER_COLOR.b)
		
		if (data.name == Enemy.areaName)
		then
			LabelSetTextColor (row_window_name.."Name", CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b)
		else
			LabelSetTextColor (row_window_name.."Name", 255, 255, 255)
		end
		
		local flash_window_name = row_window_name.."Flash"
		WindowSetAlpha (flash_window_name, 0)
		
		if (data.flash ~= nil)
		then
			WindowStopAlphaAnimation (flash_window_name)
		
			if (data.flash == ORDER)
			then
				WindowSetTintColor (flash_window_name, ORDER_COLOR.r, ORDER_COLOR.g, ORDER_COLOR.b)
			else
				WindowSetTintColor (flash_window_name, DESTR_COLOR.r, DESTR_COLOR.g, DESTR_COLOR.b)
			end
			
			WindowStartAlphaAnimation (flash_window_name, Window.AnimationType.SINGLE_NO_RESET, 0.5, 0, 2, true, 0, 1)
			data.flash = nil
		end
	end
end

function Enemy.KillSpamUI_KillSpamDialog_SortCallback (index1, index2)
	if (index2 == nil) then return false end
	
	local a = Enemy.killSpamListData[index1]
	local b = Enemy.killSpamListData[index2]
	
	return a.name < b.name
end

function Enemy.KillSpamUI_KillSpamDialog_Update ()

	if (not Enemy.KillSpamUI_KillSpamDialog_IsOpen ()) then return end

	Enemy.killSpamListData = {}
	Enemy.killSpamListIndexes = {}
	
	local total_kills_destr = 0
	local total_kills_order = 0
	
	local k = 1
	for _, data in pairs (g.data)
	do
		total_kills_destr = total_kills_destr + data.destrTotal
		total_kills_order = total_kills_order + data.orderTotal
	
		tinsert (Enemy.killSpamListData, data)
		tinsert (Enemy.killSpamListIndexes, k)
		
		k = k + 1
	end
	
	local visible_items = 10
	local offset_x = 5
	local offset_y = 5
	local item_height = 20
	local num = #Enemy.killSpamListData
	
	if (g.settings.killSpamListBottomUp and num < visible_items)
	then
		offset_y = offset_y + item_height * (visible_items - num)
	end
	
	WindowClearAnchors ("EnemyKillSpamDialogList")
	WindowAddAnchor ("EnemyKillSpamDialogList", "topleft", "EnemyKillSpamDialog", "topleft", offset_x, offset_y)
	
	table.sort (Enemy.killSpamListIndexes, Enemy.KillSpamUI_KillSpamDialog_SortCallback)
	ListBoxSetDisplayOrder ("EnemyKillSpamDialogList", Enemy.killSpamListIndexes)
	
	LabelSetText ("EnemyKillSpamDialogTotalDestr", towstring (total_kills_destr))
	LabelSetText ("EnemyKillSpamDialogTotalOrder", towstring (total_kills_order))
	
	Enemy.KillSpamUI_KillSpamAreaStatsDialog_Update ()
end

function Enemy.KillSpamUI_KillSpamDialog_OnRButtonUp ()
	EA_Window_ContextMenu.CreateContextMenu ("EnemyKillSpamDialog")
    
    if (g.isReparsing)
    then
    	EA_Window_ContextMenu.AddMenuItem (L"Stop reparsing", Enemy.KillSpamReparseEnd, false, true)
    else
		EA_Window_ContextMenu.AddMenuItem (L"Reset all", Enemy.KillSpamUI_KillSpam_ContextMenuResetAll, false, true)
		EA_Window_ContextMenu.AddMenuItem (L"Reparse all", Enemy.KillSpamReparse, false, true)
    end
    
    EA_Window_ContextMenu.Finalize ()
end


function Enemy.KillSpamUI_KillSpamDialog_OnTotalLButtonUp ()

	local area_data =
	{
		name = L"Total",
		playerStats = {},
		time = Enemy.time,
		total = 0,
		orderTotal = 0,
		destrTotal = 0
	}
	
	for k, v in pairs (g.playerStats)
	do
		local player_stats = area_data.playerStats[k]
		if (player_stats == nil)
		then
			area_data.playerStats[k] = v
		else
			player_stats.kills = player_stats.kills + v.kills
			player_stats.deaths = player_stats.deaths + v.deaths
		end
	end
	
    Enemy.KillSpamUI_KillSpamAreaStatsDialog_Open (area_data)
end


function Enemy.KillSpamUI_KillSpamDialog_OnRowLButtonUp ()
    local data_index = ListBoxGetDataIndex ("EnemyKillSpamDialogList", WindowGetId (SystemData.ActiveWindow.name))
    Enemy.KillSpamUI_KillSpamAreaStatsDialog_Open (Enemy.killSpamListData[data_index])
end

function Enemy.KillSpamUI_KillSpamDialog_OnRowRButtonUp ()

    local data_index = ListBoxGetDataIndex ("EnemyKillSpamDialogList", WindowGetId (SystemData.ActiveWindow.name))
    g.contextMenuData = Enemy.killSpamListData[data_index]
    
    EA_Window_ContextMenu.CreateContextMenu (SystemData.ActiveWindow.name)
    
    if (g.isReparsing)
    then
    	EA_Window_ContextMenu.AddMenuItem (L"Stop reparsing", Enemy.KillSpamReparseEnd, false, true)
    else
    	EA_Window_ContextMenu.AddMenuItem (L"Reset '"..g.contextMenuData.name..L"'", Enemy.KillSpamUI_KillSpam_ContextMenuResetCurrent, false, true)
		EA_Window_ContextMenu.AddMenuItem (L"Reset all", Enemy.KillSpamUI_KillSpam_ContextMenuResetAll, false, true)
		EA_Window_ContextMenu.AddMenuItem (L"Reparse all", Enemy.KillSpamReparse, false, true)
    end
    
    EA_Window_ContextMenu.Finalize ()
end

function Enemy.KillSpamUI_KillSpam_ContextMenuResetCurrent ()

	local new_data = {}

	for _, data in pairs (g.data)
	do
		if (data.name ~= g.contextMenuData.name)
		then
			tinsert (new_data, data)
		end
	end
	
	g.data = new_data
	Enemy.KillSpamUI_KillSpamDialog_Update ()
end

function Enemy.KillSpamUI_KillSpam_ContextMenuResetAll ()
	g.data = {}
	Enemy.KillSpamUI_KillSpamDialog_Update ()
end

function Enemy.KillSpamUI_KillSpamDialog_OnRowMouseOver ()
	
	local data_index = ListBoxGetDataIndex ("EnemyKillSpamDialogList", WindowGetId (SystemData.MouseOverWindow.name))
	local area_data = Enemy.killSpamListData[data_index]
	
	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	Tooltips.SetTooltipText (1, 1, area_data.name)
	
	local t = Enemy.time - area_data.time
	local h = math.floor (t / 3600.0)
	t = t - (h * 3600)
	local m = math.floor (t / 60.0)
	t = t - (m * 60)
	local s = math.floor (t + 0.5)
	
	local str_time = L""
	if (h > 0) then str_time = str_time..L" "..h..L" hours" end
	if (m > 0) then str_time = str_time..L" "..m..L" minutes" end
	str_time = str_time..L" "..s..L" seconds"
	
	Tooltips.SetTooltipText (2, 1, L"Last kill was"..str_time..L" ago")

	-- count destro/order players	
	local destr_players = 0
	local order_players = 0
	
	for _, player_stats in pairs (area_data.playerStats)
	do
		if (player_stats.side == DESTR)
		then
			destr_players = destr_players + 1
		else
			order_players = order_players + 1
		end
	end
	
	Tooltips.SetTooltipText (3, 1, L" ")
	Tooltips.SetTooltipText (4, 1, L"Destruction players: "..towstring (destr_players))
	Tooltips.SetTooltipText (5, 1, L"Order players: "..towstring (order_players))
	
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


function Enemy.KillSpamUI_KillSpamDialog_OnTotalMouseOver ()
	
	local t = Enemy.time
	local destr_players = 0
	local order_players = 0
	
	for _, data in pairs (g.data)
	do
		if (data.time < t) then t = data.time end
		
		for _, player_stats in pairs (data.playerStats)
		do
			if (player_stats.side == DESTR)
			then
				destr_players = destr_players + 1
			else
				order_players = order_players + 1
			end
		end
	end
	
	local h = math.floor (t / 3600.0)
	t = t - (h * 3600)
	local m = math.floor (t / 60.0)
	t = t - (m * 60)
	local s = math.floor (t + 0.5)
	
	local str_time = L""
	if (h > 0) then str_time = str_time..L" "..h..L" hours" end
	if (m > 0) then str_time = str_time..L" "..m..L" minutes" end
	str_time = str_time..L" "..s..L" seconds"
	
	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	Tooltips.SetTooltipText (1, 1, L"Total")
	Tooltips.SetTooltipText (2, 1, L"Last kill was"..str_time..L" ago")
	Tooltips.SetTooltipText (3, 1, L" ")
	Tooltips.SetTooltipText (4, 1, L"Destruction players: "..towstring (destr_players))
	Tooltips.SetTooltipText (5, 1, L"Order players: "..towstring (order_players))
	
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end

--------------------------------------------------------------- UI: Killspam area stats

function Enemy.KillSpamUI_KillSpamAreaStatsDialog_IsOpen (data)
	return (g.areaStatsData ~= nil and g.areaStatsData.name == data.name)
end

function Enemy.KillSpamUI_KillSpamAreaStatsDialog_Open (data)

	if (Enemy.KillSpamUI_KillSpamAreaStatsDialog_IsOpen (data)) then return end

	g.areaStatsData = data
	
	LabelSetText ("EnemyKillSpamAreaStatsDialogTitleBarText", Enemy.toWString (data.name))
    WindowSetShowing ("EnemyKillSpamAreaStatsDialog", true)
    
	Enemy.KillSpamUI_KillSpamAreaStatsDialog_Update ()
end

function Enemy.KillSpamUI_KillSpamAreaStatsDialog_Hide ()
	WindowSetShowing ("EnemyKillSpamAreaStatsDialog", false)
	g.areaStatsData = nil
end

function Enemy.KillSpamUI_KillSpamAreaStatsDialog_SortCallback (index1, index2)
	if (index2 == nil) then return false end
	
	local a = Enemy.killSpamAreaStatsListData[index1]
	local b = Enemy.killSpamAreaStatsListData[index2]
	
	if (a.kills == b.kills)
	then
		return a.name < b.name
	else
		return (a.kills > b.kills)
	end
end

function Enemy.KillSpamUI_KillSpamAreaStatsDialog_Update ()

	if (not WindowGetShowing ("EnemyKillSpamAreaStatsDialog")) then return end
	
	Enemy.killSpamAreaStatsListData = {}
	Enemy.killSpamAreaStatsListIndexes = {}
	
	local k = 1
	for _, data in pairs (g.areaStatsData.playerStats)
	do
		tinsert (Enemy.killSpamAreaStatsListData, data)
		tinsert (Enemy.killSpamAreaStatsListIndexes, k)
		
		k = k + 1
	end
	
	table.sort (Enemy.killSpamAreaStatsListIndexes, Enemy.KillSpamUI_KillSpamAreaStatsDialog_SortCallback)
	ListBoxSetDisplayOrder ("EnemyKillSpamAreaStatsDialogList", Enemy.killSpamAreaStatsListIndexes)
end

function Enemy.KillSpamUI_KillSpamAreaStatsDialog_OnListPopulate ()

	if (EnemyKillSpamAreaStatsDialogList.PopulatorIndices == nil) then return end
	
	local row_window_name
	local data
	
	for k, v in ipairs (EnemyKillSpamAreaStatsDialogList.PopulatorIndices)
	do
		row_window_name = "EnemyKillSpamAreaStatsDialogListRow"..k
		data = Enemy.killSpamAreaStatsListData[v]
		
		if (data.side == DESTR)
		then
			LabelSetTextColor (row_window_name.."Kills", DESTR_COLOR.r, DESTR_COLOR.g, DESTR_COLOR.b)
			LabelSetTextColor (row_window_name.."Deaths", DESTR_COLOR.r, DESTR_COLOR.g, DESTR_COLOR.b)
		else
			LabelSetTextColor (row_window_name.."Kills", ORDER_COLOR.r, ORDER_COLOR.g, ORDER_COLOR.b)
			LabelSetTextColor (row_window_name.."Deaths", ORDER_COLOR.r, ORDER_COLOR.g, ORDER_COLOR.b)
		end
		
		if (data.name == Enemy.playerName)
		then
			LabelSetTextColor (row_window_name.."Name", CURRENT_COLOR.r, CURRENT_COLOR.g, CURRENT_COLOR.b)
		else
			LabelSetTextColor (row_window_name.."Name", 255, 255, 255)
		end

		local flash_window_name = row_window_name.."Flash"
		WindowSetAlpha (flash_window_name, 0)
		
		if (data.flash ~= nil)
		then
			WindowStopAlphaAnimation (flash_window_name)
		
			if (data.flash == ORDER)
			then
				WindowSetTintColor (flash_window_name, ORDER_COLOR.r, ORDER_COLOR.g, ORDER_COLOR.b)
			else
				WindowSetTintColor (flash_window_name, DESTR_COLOR.r, DESTR_COLOR.g, DESTR_COLOR.b)
			end
			
			WindowStartAlphaAnimation (flash_window_name, Window.AnimationType.SINGLE_NO_RESET, 0.5, 0, 2, true, 0, 1)
			data.flash = nil
		end
	end
end

function Enemy.KillSpamUI_KillSpamAreaStatsDialog_OnRowMouseOver ()

	local data_index = ListBoxGetDataIndex ("EnemyKillSpamAreaStatsDialogList", WindowGetId (SystemData.MouseOverWindow.name))
	local area_stats = Enemy.killSpamAreaStatsListData[data_index]
	local global_stats = g.playerStats[area_stats.name]
	local area_data = g.areaStatsData
	
	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	Tooltips.SetTooltipText (1, 1, area_stats.name)
	Tooltips.SetTooltipText (2, 1, L" ")
	Tooltips.SetTooltipText (3, 1, L"Kills in current area: "..area_stats.kills)
	Tooltips.SetTooltipText (4, 1, L"Deaths in current area: "..area_stats.deaths)
	Tooltips.SetTooltipText (5, 1, L"Kill/death ratio in current area: "..Enemy.Round (area_stats.kills / math.max (1, area_stats.deaths), 1))
	Tooltips.SetTooltipText (6, 1, L" ")
	Tooltips.SetTooltipText (7, 1, L"Total kills in current zone: "..global_stats.kills)
	Tooltips.SetTooltipText (8, 1, L"Total deaths in current zone: "..global_stats.deaths)
	Tooltips.SetTooltipText (9, 1, L"Kill/death ratio in current zone: "..Enemy.Round (global_stats.kills / math.max (1, global_stats.deaths), 1))
	
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


--------------------------------------------------------------- UI: Player kill/death
function Enemy.KillSpamUI_PlayerKDR_Hide ()
	WindowSetShowing ("EnemyPlayerKDR", false)
end

function Enemy.KillSpamUI_PlayerKDR_IsOpen ()
	return WindowGetShowing ("EnemyPlayerKDR")
end

function Enemy.KillSpamUI_PlayerKDR_Open ()
	WindowSetShowing ("EnemyPlayerKDR", true)
	Enemy.KillSpamUI_PlayerKDR_Update ()
end

function Enemy.KillSpamUI_PlayerKDR_Update ()

	Enemy.playerKillsDeathsUpdated = false
	if (not WindowGetShowing ("EnemyPlayerKDR")) then return end
	
	local kills
	local deaths
	
	if (g.settings.playerKDRDisplayMode == 1
		or g.settings.playerKDRDisplayMode == 3
		or g.settings.playerKDRDisplayMode == 5)
	then
		kills = g.playerZoneKills
		deaths = g.playerZoneDeaths
	else
		kills = Enemy.Settings.playerKills
		deaths = Enemy.Settings.playerDeaths
	end
	
	local kdr = Enemy.Round (kills / math.max (1, deaths), 1)
	local balance = kills - deaths
	
	if (g.settings.playerKDRDisplayMode == 1 or g.settings.playerKDRDisplayMode == 2)
	then
		LabelSetText ("EnemyPlayerKDRText", towstring (kdr))
			
	elseif (g.settings.playerKDRDisplayMode == 3 or g.settings.playerKDRDisplayMode == 4)
	then
		LabelSetText ("EnemyPlayerKDRText", towstring (kills)..L" / "..towstring (deaths))
	else
		local sign = L""
		
		if (balance > 0)
		then
			sign = L"+"
		end
		
		LabelSetText ("EnemyPlayerKDRText", sign..towstring (balance))
	end
	
	if (balance == 0)
	then
		LabelSetTextColor ("EnemyPlayerKDRText", 255, 255, 255)
	elseif (balance > 0)
	then
		LabelSetTextColor ("EnemyPlayerKDRText", 100, 255, 100)
	else
		LabelSetTextColor ("EnemyPlayerKDRText", 255, 100, 100)
	end
end

function Enemy.KillSpamUI_PlayerKDR_OnRButtonUp ()
	
	EA_Window_ContextMenu.CreateContextMenu ("EnemyPlayerKDR")
    
    EA_Window_ContextMenu.AddMenuItem (L"Hide", Enemy.KillSpamUI_PlayerKDR_Hide, false, true)
    EA_Window_ContextMenu.AddMenuItem (L"Reset", Enemy.PlayerKDRReset, false, true)
        
	EA_Window_ContextMenu.Finalize ()
end

function Enemy.KillSpamUI_PlayerKDR_OnMouseOver ()

	Tooltips.CreateTextOnlyTooltip (SystemData.MouseOverWindow.name)
	Tooltips.SetTooltipText (1, 1, L"Enemy Addon")
	
	local mode_names =
	{
		L"Your kill/death ratio (current zone)",
		L"Your kill/death ratio (global)",
		L"Your kills/deaths (current zone)",
		L"Your kills/deaths (global)",
		L"Your kills/deaths balance (current zone)",
		L"Your kills/deaths balance (global)"
	}
	
	Tooltips.SetTooltipText (2, 1, mode_names[g.settings.playerKDRDisplayMode])
	Tooltips.SetTooltipText (3, 1, L"Right-click to show the menu")
	Tooltips.SetTooltipText (4, 1, L" ")
	Tooltips.SetTooltipText (5, 1, L"Kills: "..Enemy.Settings.playerKills)
	Tooltips.SetTooltipText (6, 1, L"Deaths: "..Enemy.Settings.playerDeaths)
	Tooltips.SetTooltipText (7, 1, L" ")
	Tooltips.SetTooltipText (8, 1, L"Kills in current zone: "..g.playerZoneKills)
	Tooltips.SetTooltipText (9, 1, L"Deaths in current zone: "..g.playerZoneDeaths)	
	
	Tooltips.AnchorTooltip (Tooltips.ANCHOR_CURSOR)
	Tooltips.Finalize()
end


--------------------------------------------------------------- UI: Player killed by
local killedby_window = {}

function Enemy.KillSpamUI_KilledBy_Hide ()
	WindowSetShowing ("EnemyKilledBy", false)
end


function Enemy.KillSpamUI_KilledBy_IsOpen ()
	return WindowGetShowing ("EnemyKilledBy")
end


function Enemy.KillSpamUI_KilledBy_Open ()
	WindowSetShowing ("EnemyKilledBy", true)
end


function Enemy.KillSpamUI_KilledBy_NewKill (victim, player)

	if (not Enemy.KillSpamUI_KilledBy_IsOpen ()) then return end
	
	local text = victim..L" killed by "
	if (player == Enemy.playerName)
	then
		text = text..L"YOU"
		
		if (g.settings.killSpamKilledByYouSound)
		then
			PlaySound (g.settings.killSpamKilledByYouSound)
		end
	else
		text = text..player
	end
	
	WindowStopAlphaAnimation ("EnemyKilledBy")
	WindowStartAlphaAnimation ("EnemyKilledBy", Window.AnimationType.SINGLE_NO_RESET, 1, 0, 0, true, 0, 1)
	WindowStartAlphaAnimation ("EnemyKilledBy", Window.AnimationType.SINGLE_NO_RESET, 0, 1, 0.2, true, 0, 1)
	
	WindowSetShowing ("EnemyKilledByText", true)
	LabelSetText ("EnemyKilledByText", text)
	
	killedby_window.hideTimer = EnemyTimer.New ("killed by hide", 5, function ()
		WindowStopAlphaAnimation ("EnemyKilledBy")
		WindowStartAlphaAnimation ("EnemyKilledBy", Window.AnimationType.SINGLE_NO_RESET, 1, 1, 0, true, 0, 1)
		WindowStartAlphaAnimation ("EnemyKilledBy", Window.AnimationType.SINGLE_NO_RESET, 1, 0, 1, true, 0, 1)
		return true
	end)
end


function Enemy.KillSpamUI_KilledBy_Reset ()

	if (killedby_window.hideTimer)
	then
		killedby_window.hideTimer:Remove ()
		killedby_window.hideTimer = nil
	end
	
	WindowStopAlphaAnimation ("EnemyKilledByText")
	WindowSetAlpha ("EnemyKilledByText", 1)
	LabelSetText ("EnemyKilledByText", L"")
end


--------------------------------------------------------------- UI: Configuration
local config_dlg = {}

config_dlg.properties =
{
	killSpamEnabled =
	{
		key = "killSpamEnabled",
		order = 10,
		name = L"Enable killspam parsing",
		type = "bool",
		default = Enemy.DefaultSettings.killSpamEnabled
	},
	killSpamListBottomUp =
	{
		key = "killSpamListBottomUp",
		order = 20,
		name = L"Show list bottom-up",
		tooltip = L"Show first rows of the killspam list at the bottom (near the Total row)",
		type = "bool",
		default = Enemy.DefaultSettings.killSpamListBottomUp
	},
	playerKDRDisplayMode =
	{
		key = "playerKDRDisplayMode",
		order = 30,
		name = L"Display",
		type = "select",
		values =
		{
			{ text = L"Current zone ratio", value = 1 },
			{ text = L"Global ratio", value = 2 },
			{ text = L"Current zone K/D", value = 3 },
			{ text = L"Global K/D", value = 4 },
			{ text = L"Current zone +/-", value = 5 },
			{ text = L"Global zone +/-", value = 6 },
		},
		default = Enemy.DefaultSettings.playerKDRDisplayMode
	},
	killSpamKilledByYouSound =
	{
		key = "killSpamKilledByYouSound",
		order = 40,
		name = L"Sound on your kills",
		type = "select",
		values = Enemy.ConfigurationWindowGetSoundsSelectValues (L"No sound"),
		default = Enemy.DefaultSettings.killSpamKilledByYouSound,
		onChange = function (wn)
		
			Enemy.KillSpamUI_ConfigDialog_TestSettings ()
			
			if (config_dlg.killSpamKilledByYouSound)
			then
				PlaySound (config_dlg.killSpamKilledByYouSound)
			end
		end
	},
}


function Enemy.KillSpamUI_ConfigDialog_OnInitialize (section)

	config_dlg.section = section

	local root = config_dlg.section.windowName.."ContentScrollChild"
	config_dlg.cwn = root.."Config"
	Enemy.CreateConfigurationWindow (config_dlg.cwn, root, config_dlg.properties, Enemy.KillSpamUI_ConfigDialog_TestSettings)
	
	ScrollWindowUpdateScrollRect (config_dlg.section.windowName.."Content")
end


function Enemy.KillSpamUI_ConfigDialog_OnLoad (section)

	config_dlg.isLoading = true

	config_dlg.killSpamEnabled = Enemy.Settings.killSpamEnabled
	config_dlg.killSpamListBottomUp = Enemy.Settings.killSpamListBottomUp
	config_dlg.playerKDRDisplayMode = Enemy.Settings.playerKDRDisplayMode
	config_dlg.killSpamKilledByYouSound = Enemy.Settings.killSpamKilledByYouSound
		
	Enemy.ConfigurationWindowLoadData (config_dlg.cwn, config_dlg)
	config_dlg.isLoading = false
	Enemy.KillSpamUI_ConfigDialog_TestSettings ()
end


function Enemy.KillSpamUI_ConfigDialog_OnReset (section)

	Enemy.Settings.killSpamEnabled = nil
	Enemy.Settings.killSpamListBottomUp = nil
	Enemy.Settings.playerKDRDisplayMode = nil
	Enemy.Settings.killSpamKilledByYouSound = nil
	
	Enemy.Print ("Kill spam settings has been reset")
	InterfaceCore.ReloadUI ()
end


function Enemy.KillSpamUI_ConfigDialog_TestSettings ()

	if (config_dlg.isLoading) then return end
	
	Enemy.ConfigurationWindowSaveData (config_dlg.cwn, config_dlg)
	Enemy.KillSpam_OnSettingsChanged (config_dlg)
end


function Enemy.KillSpamUI_ConfigDialog_OnSave (section)

	Enemy.KillSpamUI_ConfigDialog_TestSettings ()

	Enemy.Settings.killSpamEnabled = config_dlg.killSpamEnabled
	Enemy.Settings.killSpamListBottomUp = config_dlg.killSpamListBottomUp
	Enemy.Settings.playerKDRDisplayMode = config_dlg.playerKDRDisplayMode
	Enemy.Settings.killSpamKilledByYouSound = config_dlg.killSpamKilledByYouSound
	
	return true
end






