local Enemy = Enemy
local g
local tinsert = table.insert
local tsort = table.sort
local ipairs = ipairs
local pairs = pairs

local properties =
{
	texture =	{ key = "texture",		order = 1,		name = L"Texture",				type = "select",	default = "default",		values = Enemy.UnitFramePart_GetTexturesSelectValues }
}


function Enemy.UnitFramesParts_PanelInitialize ()
	g = Enemy.unitFramesParts
	
	g.types["panel"] =
	{
		key = "panel",
		name = L"Panel",
		properties = properties,
		
		CreateConfigurationWindow = function (wn, root)
			Enemy.CreateConfigurationWindow (wn, root, properties, Enemy.UnitFramesUI_UnitFramePartDialog_UpdateExample)
		end,
		
		LoadConfigurationWindow = function (wn, part)
			Enemy.ConfigurationWindowLoadData (wn, part.data)
		end,
		
		SaveConfigurationWindow = function (wn, part)
			Enemy.ConfigurationWindowSaveData (wn, part.data)
		end,
		
		OnRemove = Enemy.UnitFramePart_OnRemove,
		
		OnBind = function (part)
		
			local t = part._t
			local data = part.data
			
			t.cache = {}
		
			t.windowName = part._frame.windowName..Enemy.NewId ()
			CreateWindowFromTemplate (t.windowName, "EA_DynamicImage_DefaultSeparatorRight", part._frame.windowName)

			Enemy.UnitFramePart_OnUpdate_ProceedWindowInitialization (part, player)
			Enemy.UnitFramePart_ApplyTexture (data.texture, t.windowName)
		end,
		
		OnUpdate = Enemy.UnitFramePart_OnUpdate_ProceedState
	}
end



