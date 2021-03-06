-- ©Grumbo'z Mall Warz ©
-- ©Created/Designed by slp13at420 of EmuDevs.com ©
-- project start date 01/09/15 :|©|: project finish date 01/09/15
-- with blood and death n stuff..©
-- another portable `Capture The Zone` system from the Mad Scientist of EmuDevs.com ©
-- For Trinity Core2 3.3.5a
-- Custom Creation FOR Public RELEASE 03/05/2015 ©
-- Required skill level beginner+ . light variable, and 3d table editing.
-- npc's will be friendly ONLY with the team that holds the flag.
-- when you setup this make sure the tele points for the mall are far 
-- enough away from npc's so they wont attack any players who teleport.
-- Team flag will respawn randomly. based on preset minimum and maximum timers.
-- find a location you wish to have your flags spawn and store the gps to table:flag_loc.
-- you then spawn your starter Zone flag id:800002 at the same GPS coordinates. this flag is permanant
-- and if you choose to move your system then you must delete this gameobject.

print("**********************")
print("* Grumbo'z Mall Warz *")

local Mall = 1; -- system operation switch. 0=system off/1=system on.
local Advertise = 5; -- how often in minutes to announce to world about this. float values work.
local minimum_flag_spawn_delay = 10; -- minimum flag spawn delay in seconds. default (60 seconds) = 1 minute.
local maximum_flag_spawn_delay = 60; -- max flag spawn delay in seconds. default (300 seconds) = 5 minutes.
local FlagAnn = 1; -- announce to world when flag spawns. 0/1 on/off no/yes.
local Global = 0; -- Effect vendors in WHOLE REALM=(1) :: or effect vendors in pre-specified location=(0) :: use (1) If your mall spans across more than 1 erea or if you just want them to be controlled ALL OVER.
local flag_id = 800000; -- (ally, horde, zone)
local time = 1000;
local set_flag_cmd = "store mall flag";
local Flag = {};

local Team_Color = {
			[0] = "|cff00FFFF", -- Alliance Blue
			[1] = "|cffFF0000", -- Horde Red
};
local NPC = {1000000,}; -- add id's here for vendors you want to add to this Zone. e.g. NPC = {100, 101, 102, 103, 108, 231, 6767};
local Zone_MALL = { --  default setup GM Island :: edit Name, Map, Zone, and Area to change the mall location.
		Name = "GM Island Custom Battle Mall", -- <-- zone name for announcements
		Map = 1, -- <-- map id
		Zone = 876, -- <-- zone id
		Area = 876, -- <-- area id
-- DO NOT EDIT ANYTHING BELOW UNLESS YOU KNOW WHAT YOU ARE DOING BUT NOTHING NEEDS EDITING BELOW THIS MARKER ECCEPT TEAM COLORS LINE 45 --
		Team = 3, -- <-- default value 3.
			Team_Name = { -- for annoucements
				[0] = "Alliance",
				[1] = "Horde",
				[2] = "World",
			},
};

local function WorldAnnounce() -- world announcement for advertising
	SendWorldMessage("Join your friends and take control of the "..Zone_MALL.Name..".")
end

if(Mall == 1)then

	WorldAnnounce()
	CreateLuaEvent(WorldAnnounce, Advertise*60000, 0) -- starts a cyclic world broadcast . in minutes
end

local function GetTeamName(team_id)

	return Zone_MALL.Team_Name[team_id]
end

local function GetApposingTeam(team_id)

	if(team_id == 0)then return 1; end
	if(team_id == 1)then return 0; end
end

local function SpawnTeamFlag()

Flag[Zone_MALL.Team]:Respawn()
Zone_MALL.Guid = Flag[Zone_MALL.Team]:GetGUIDLow();
SendWorldMessage(" The "..Zone_MALL.Team_Name[Zone_MALL.Team].." Mall Flag has been spawned.");

end

local function TagFlag(event, player, go)

local Tguid = Zone_MALL.Guid;
local team_id = player:GetTeam();
local not_team_id = GetApposingTeam(team_id)
local team_name = GetTeamName(team_id);

	go:Despawn();	

	if(Tguid == go:GetGUIDLow())then

		Zone_MALL.Guid = nil;
		Zone_MALL.Team = team_id;
		
			if(minimum_flag_spawn_delay > 0)and(maximum_flag_spawn_delay > 0)then
				time = (math.random(minimum_flag_spawn_delay, maximum_flag_spawn_delay)*1000)
			else
				time = 1000;
			end
		SendWorldMessage("The "..Team_Color[Zone_MALL.Team]..""..Zone_MALL.Team_Name[Zone_MALL.Team].."|r have claimed the "..Zone_MALL.Name..".")
		CreateLuaEvent(SpawnTeamFlag, time, 1)
	end
end

if(Mall == 1)then

	for tag=0,2 do
		RegisterGameObjectGossipEvent(flag_id+tag, 1, TagFlag)
	end
end

local function ReFreshNPCFaction(event, unit)

local Gmap = unit:GetMapId();
local Gzone = unit:GetZoneId();
local Garea = unit:GetAreaId();

	if(Global == 1)or((Gmap == Zone_MALL.Map)and(Gzone == Zone_MALL.Zone)and(Garea == Zone_MALL.Area))then

		if(Zone_MALL.Team == 2)then

			unit:SetFaction(16) -- 16 is creature . so agro to both teams.
		else
	
			local faction = (83+GetApposingTeam(Zone_MALL.Team));
			unit:SetFaction(faction); -- sets faction so npc is friendly to only 1 team.
		end
	end
end

if(Mall == 1)then

	for rfs=1,#NPC do
		RegisterCreatureEvent(NPC[rfs], 5, ReFreshNPCFaction)
		RegisterCreatureEvent(NPC[rfs], 27, ReFreshNPCFaction)
	end
end 
 
local function GO_LOS(event, go)

local Gmap = go:GetMapId();
local Gzone = go:GetZoneId();
local Garea = go:GetAreaId();
local Fteam_id = go:GetEntry()-flag_id;

	if(Global == 1)or((Gmap == Zone_MALL.Map)and(Gzone == Zone_MALL.Zone)and(Garea == Zone_MALL.Area))then
		
		Flag[Fteam_id] = go;
		
		if(Zone_MALL.Team == 2)and(Fteam_id == Zone_MALL.Team)then
		
			Zone_MALL.Guid = go:GetGUIDLow();
			
				if not(go:IsSpawned())then
					go:Respawn();
				end
		end
		
		if(Zone_MALL.Team ~= Fteam_id)then
			
			if(go:IsSpawned())then
				go:Despawn()
			end
		else
			if(Zone_MALL.Team == Fteam_id)and(Zone_MALL.Guid == go:GetGUIDLow())then
			
				if not(go:IsSpawned())then
					go:Respawn();
				end
			end
		end

	end
end

for go=flag_id,flag_id+2 do

	RegisterGameObjectEvent(go, 1, GO_LOS)
end

local function Message(event, player)
 
 local pre = nil;
 local map = player:GetMapId();
 local zone = player:GetZoneId();

	if((map == Zone_MALL.Map )and(zone == Zone_MALL.Zone))then
	
		if(Zone_MALL.Team == 1)then  pre = "an "..Team_Color[0]..""..Zone_MALL.Team_Name[0].."|r "; end
		if(Zone_MALL.Team == 2)then  pre = "a "..Team_Color[1]..""..Zone_MALL.Team_Name[1].."|r "; end
		if(Zone_MALL.Team == 3)then  pre = "an un-"; end
		
		player:SendBroadcastMessage("You have entered "..pre.."controlled Mall.")
	end
end
 
RegisterPlayerEvent(27, Message)

local function SetFlags(event, player, command)

	if(command == set_flag_cmd)then

		local m = player:GetMapId();
		local x = player:GetX();
		local y = player:GetY();
		local z = player:GetZ();
		local o = player:GetO();
		
			for flg=0,3 do
				PerformIngameSpawn(2, (flag_id+flg), m, 0, x, y, z, o, 1, 0, 1);
			end
	end
end

RegisterPlayerEvent(42, SetFlags) 

if(Mall == 0)then
	print("*        Idle        *")
end

if(Mall == 1)then
	print("*       Loaded       *")
end
print("**********************")
