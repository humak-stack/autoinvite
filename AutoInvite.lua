AutoInviteOptions = {};
local Realm;
local Player;
local version = "0.5";
local default_invite = "invite";
local convertRaidTimer = nil;
local timerFrame = CreateFrame("Frame");

timerFrame:SetScript("OnUpdate", function()
	if convertRaidTimer then
		convertRaidTimer = convertRaidTimer - arg1;
		if convertRaidTimer <= 0 then
			convertRaidTimer = nil;
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: converting party to raid.");
			ConvertToRaid();
		end
	end
end);

function AutoInvite_OnLoad()
	this:RegisterEvent("CHAT_MSG_WHISPER");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");

	SlashCmdList["AutoInvite"] = AutoInvite_SlashHandler;
	SLASH_AutoInvite1 = "/AutoInvite";
	SLASH_AutoInvite2 = "/ai";

	DEFAULT_CHAT_FRAME:AddMessage("AutoInvite (redux) v"..version.." loaded. Type /ai for usage.",0,0,1);
	DEFAULT_CHAT_FRAME:AddMessage("Type \'/ai alist\' to auto invite everyone in the A-list",0,0,1);
	DEFAULT_CHAT_FRAME:AddMessage("Type \'/ai blist\' to auto invite everyone in the B-list",0,0,1);
end

function AutoInvite_InitializeSetup()
	Player = UnitName("player");
	Realm = GetRealmName();
	if AutoInviteOptions == nil then AutoInviteOptions = {} end;
	if(AutoInviteOptions[Realm] == nil) then AutoInviteOptions[Realm] = {} end;
	if(AutoInviteOptions[Realm][Player] == nil) then AutoInviteOptions[Realm][Player] = {} end;
	if(AutoInviteOptions[Realm][Player]["Invite"] == nil) then AutoInviteOptions[Realm][Player]["Invite"] = default_invite end;
	if(AutoInviteOptions[Realm][Player]["InviteExact"] == nil) then AutoInviteOptions[Realm][Player]["InviteExact"] = "" end;
	if(AutoInviteOptions[Realm][Player]["Status"] == nil) then AutoInviteOptions[Realm][Player]["Status"] = "On" end;
	if(AutoInviteOptions[Realm][Player]["Type"] == nil) then AutoInviteOptions[Realm][Player]["Type"] = "Party" end;
	if(AutoInviteOptions[Realm][Player]["GuildScan"] == nil) then AutoInviteOptions[Realm][Player]["GuildScan"] = "Off" end;
	if(AutoInviteOptions[Realm][Player]["VIPList"] == nil) then AutoInviteOptions[Realm][Player]["VIPList"] = {} end;
	if(AutoInviteOptions[Realm][Player]["AutoRaid"] == nil) then AutoInviteOptions[Realm][Player]["AutoRaid"] = "Off" end;
	AutoInvite_UpdateGuildScan();
end

function AutoInvite_OnEvent(event)
	if(event == "PLAYER_ENTERING_WORLD") then
		AutoInvite_InitializeSetup();
	elseif(event == "CHAT_MSG_WHISPER") then
		if(AutoInviteOptions[Realm][Player]["Status"] == "On") then
			local what = arg1;
			local who = arg2;
			local invite = AutoInvite_CheckMessage(what);
			if(invite) then AutoInvite_Invite(who) end;
		end
	elseif(event == "CHAT_MSG_GUILD") then
		if(AutoInviteOptions[Realm][Player]["Status"] == "On" and AutoInviteOptions[Realm][Player]["GuildScan"] == "On") then
			local what = arg1;
			local who = arg2;
			local invite = AutoInvite_CheckMessage(what);
			if(invite) then AutoInvite_Invite(who) end;
		end
	elseif(event == "PARTY_MEMBERS_CHANGED") then
		AutoInvite_CheckAutoRaid();
		if(AutoInviteOptions[Realm][Player] and AutoInviteOptions[Realm][Player]["Status"] == "On") then
			AutoInvite_CheckRaidForVIPs();
		end
	elseif(event == "RAID_ROSTER_UPDATE") then
		if(AutoInviteOptions[Realm][Player]["Status"] == "On") then
			AutoInvite_CheckRaidForVIPs();
		end
	end
end

function AutoInvite_UpdateGuildScan()
	if(AutoInviteOptions[Realm][Player]["GuildScan"] == "On") then
		AutoInviteFrame:RegisterEvent("CHAT_MSG_GUILD");
	else
		AutoInviteFrame:UnregisterEvent("CHAT_MSG_GUILD");
	end
end

function AutoInvite_CheckAutoRaid()
	if(AutoInviteOptions[Realm][Player]["AutoRaid"] ~= "On") then 
		return 
	end;
	if(GetNumRaidMembers() > 0) then 
		
		return 
	end;
	if(GetNumPartyMembers() == 0) then 
		return end;
	-- check leader via name comparison
	local isLeader = false;
	if UnitIsPartyLeader("player") then
		isLeader = true;
	else
		for i = 1, GetNumPartyMembers() do
			if UnitIsPartyLeader("party"..i) then
				-- someone else is leader
			end
		end
	end
	if(not isLeader) then 
		return 
	
	end;

	-- delay the conversion slightly to let the client settle
	convertRaidTimer = 0.5;
	AutoInviteFrame:SetScript("OnUpdate", function()
		if convertRaidTimer then
			convertRaidTimer = convertRaidTimer - arg1;
			if convertRaidTimer <= 0 then
				convertRaidTimer = nil;
				AutoInviteFrame:SetScript("OnUpdate", nil);
				DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: converting party to raid.");
				ConvertToRaid();
			end
		end
	end);

end

function AutoInvite_IsVIP(name)
	local vip = AutoInviteOptions[Realm][Player]["VIPList"];
	local nameLower = string.lower(name);
	for i = 1, table.getn(vip) do
		if(string.lower(vip[i]) == nameLower) then
			return true;
		end
	end
	return false;
end

function AutoInvite_CheckRaidForVIPs()
	if(not IsRaidLeader() and not IsPartyLeader()) then return end;

	for i = 1, GetNumRaidMembers() do
		local name, rank = GetRaidRosterInfo(i);
		if(name and rank == 0 and AutoInvite_IsVIP(name)) then
			PromoteToAssistant(name);
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: promoted VIP |c00ffff00"..name.."|r to assistant.");
		end
	end
end

function InviteAList()
	for j = 1, 50 do
		if (AList[j]) then
			numgroup = GetNumRaidMembers();
			if(numgroup == 0) then
				numparty = GetNumPartyMembers();
				if(numparty == 0) then InviteByName(AList[j])
				elseif(numparty < 4) then
					if(IsPartyLeader()) then InviteByName(AList[j])
					else return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..AList[j].." right now, you're not the party leader.") end;
				elseif(GetNumPartyMembers() == 4)then
					if(IsPartyLeader()) then
						DEFAULT_CHAT_FRAME:AddMessage("Raid mode enabled: Converting your group to a raid.")
						ConvertToRaid();
						InviteByName(AList[j]);
					else
						DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..AList[j].." right now, you're not the party leader.");
					end
				end
			elseif((IsRaidLeader() or IsRaidOfficer()) and numgroup < 40) then InviteByName(AList[j])
			else
				if(numgroup > 39) then return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..AList[j].." right now, raid is full.");
				else return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..AList[j].." right now, you're not the raid leader.") end;
			end
		end
	end
end

function InviteBList()
	for j = 1, 39 do
		if (BList[j]) then
			numgroup = GetNumRaidMembers();
			if(numgroup == 0) then
				numparty = GetNumPartyMembers();
				if(numparty == 0) then InviteByName(BList[j])
				elseif(numparty < 4) then
					if(IsPartyLeader()) then InviteByName(BList[j])
					else return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..BList[j].." right now, you're not the party leader.") end;
				elseif(GetNumPartyMembers() == 4)then
					if(IsPartyLeader()) then
						DEFAULT_CHAT_FRAME:AddMessage("Raid mode enabled: Converting your group to a raid.")
						ConvertToRaid();
						InviteByName(BList[j]);
					else
						DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..BList[j].." right now, you're not the party leader.");
					end
				end
			elseif((IsRaidLeader() or IsRaidOfficer()) and numgroup < 40) then InviteByName(BList[j])
			else
				if(numgroup > 39) then return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..BList[j].." right now, raid is full.");
				else return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..BList[j].." right now, you're not the raid leader.") end;
			end
		end
	end
end

function AutoInvite_SlashHandler(msg)
	if(msg ~= "") then msg = string.lower(msg) end;
	if(msg == "" or msg == "status") then
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite status: |c00ffff00"..AutoInviteOptions[Realm][Player]["Status"].."|r (change with /ai on | off)");
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite exists keyword[s]: |c00ffff00"..AutoInviteOptions[Realm][Player]["Invite"].."|r (change with /ai exists <keywords>)");
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite exact keyword[s]: |c00ffff00"..AutoInviteOptions[Realm][Player]["InviteExact"].."|r (change with /ai exact <keywords>)");
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite party type: |c00ffff00"..AutoInviteOptions[Realm][Player]["Type"].."|r (change with /ai party | raid)");
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite guild chat scan: |c00ffff00"..AutoInviteOptions[Realm][Player]["GuildScan"].."|r (change with /ai guild on | off | toggle)");
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite auto-raid: |c00ffff00"..AutoInviteOptions[Realm][Player]["AutoRaid"].."|r (change with /ai autoraid on | off | toggle)");
	elseif(msg == "on") then
		AutoInviteOptions[Realm][Player]["Status"] = "On";
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: enabled.");
	elseif(msg == "off") then
		AutoInviteOptions[Realm][Player]["Status"] = "Off";
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: disabled.",1,1,1);
	elseif(msg == "party") then
		AutoInviteOptions[Realm][Player]["Type"] = "Party";
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: Invite checking for 5-man party only.",1,1,1);
	elseif(msg == "raid") then
		AutoInviteOptions[Realm][Player]["Type"] = "Raid";
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: Invite checking for 40-man raid groups.",1,1,1);
	elseif(msg == "guild on") then
		AutoInviteOptions[Realm][Player]["GuildScan"] = "On";
		AutoInvite_UpdateGuildScan();
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: guild chat scanning enabled.",1,1,1);
	elseif(msg == "guild off") then
		AutoInviteOptions[Realm][Player]["GuildScan"] = "Off";
		AutoInvite_UpdateGuildScan();
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: guild chat scanning disabled.",1,1,1);
	elseif(msg == "guild toggle") then
		if(AutoInviteOptions[Realm][Player]["GuildScan"] == "On") then
			AutoInviteOptions[Realm][Player]["GuildScan"] = "Off";
			AutoInvite_UpdateGuildScan();
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: guild chat scanning disabled.",1,1,1);
		else
			AutoInviteOptions[Realm][Player]["GuildScan"] = "On";
			AutoInvite_UpdateGuildScan();
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: guild chat scanning enabled.",1,1,1);
		end
	elseif(msg == "autoraid on") then
		AutoInviteOptions[Realm][Player]["AutoRaid"] = "On";
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: auto-raid conversion enabled.",1,1,1);
	elseif(msg == "autoraid off") then
		AutoInviteOptions[Realm][Player]["AutoRaid"] = "Off";
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: auto-raid conversion disabled.",1,1,1);
	elseif(msg == "autoraid toggle") then
		if(AutoInviteOptions[Realm][Player]["AutoRaid"] == "On") then
			AutoInviteOptions[Realm][Player]["AutoRaid"] = "Off";
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: auto-raid conversion disabled.",1,1,1);
		else
			AutoInviteOptions[Realm][Player]["AutoRaid"] = "On";
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: auto-raid conversion enabled.",1,1,1);
		end
	elseif(string.sub(msg, 1, 7) == "exists ") then
		local keywords = string.sub(msg, 8);
		AutoInviteOptions[Realm][Player]["Invite"] = keywords;
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: exists keyword[s] set to: |c00ffff00"..keywords.."|r");
	elseif(string.sub(msg, 1, 6) == "exact ") then
		local keywords = string.sub(msg, 7);
		AutoInviteOptions[Realm][Player]["InviteExact"] = keywords;
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: exact keyword[s] set to: |c00ffff00"..keywords.."|r");
	elseif(string.sub(msg, 1, 8) == "vip add ") then
		local name = string.sub(msg, 9);
		name = string.gsub(name, "^%s*(.-)%s*$", "%1");
		if(name ~= "") then
			name = string.upper(string.sub(name, 1, 1))..string.sub(name, 2);
			local vip = AutoInviteOptions[Realm][Player]["VIPList"];
			if(AutoInvite_IsVIP(name)) then
				DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: |c00ffff00"..name.."|r is already on the VIP list.");
			else
				table.insert(vip, name);
				DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: added |c00ffff00"..name.."|r to VIP list.");
			end
		end
	elseif(string.sub(msg, 1, 11) == "vip remove ") then
		local name = string.sub(msg, 12);
		name = string.gsub(name, "^%s*(.-)%s*$", "%1");
		name = string.upper(string.sub(name, 1, 1))..string.sub(name, 2);
		local vip = AutoInviteOptions[Realm][Player]["VIPList"];
		local found = false;
		for i = 1, table.getn(vip) do
			if(string.lower(vip[i]) == string.lower(name)) then
				table.remove(vip, i);
				DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: removed |c00ffff00"..name.."|r from VIP list.");
				found = true;
				break;
			end
		end
		if(not found) then
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: |c00ffff00"..name.."|r was not on the VIP list.");
		end
	elseif(msg == "vip list") then
		local vip = AutoInviteOptions[Realm][Player]["VIPList"];
		if(table.getn(vip) == 0) then
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: VIP list is empty.");
		else
			DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: VIP list:");
			for i = 1, table.getn(vip) do
				DEFAULT_CHAT_FRAME:AddMessage("  |c00ffff00"..vip[i].."|r");
			end
		end
	elseif(msg == "vip clear") then
		AutoInviteOptions[Realm][Player]["VIPList"] = {};
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: VIP list cleared.");
	elseif(msg == "alist") then
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: Starting Invites of Priority List.",1,1,1);
		InviteAList();
	elseif(msg == "blist") then
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: Starting Invites of Secondary List.",1,1,1);
		InviteBList();
	else
		DEFAULT_CHAT_FRAME:AddMessage("AutoInvite: unknown command. Type /ai status for info.",1,0,0);
	end
end

function AutoInvite_CheckMessage(what)
	local msg = string.lower(what);

	-- check exists list
	local existsKeywords = AutoInviteOptions[Realm][Player]["Invite"];
	if(existsKeywords ~= nil and existsKeywords ~= "") then
		for keyword in string.gfind(existsKeywords, "[^,]+") do
			keyword = string.gsub(keyword, "^%s*(.-)%s*$", "%1");
			if(keyword ~= "" and string.find(msg, keyword, 1, true)) then
				return true;
			end
		end
	end

	-- check exact list
	local exactKeywords = AutoInviteOptions[Realm][Player]["InviteExact"];
	if(exactKeywords ~= nil and exactKeywords ~= "") then
		for keyword in string.gfind(exactKeywords, "[^,]+") do
			keyword = string.gsub(keyword, "^%s*(.-)%s*$", "%1");
			if(keyword ~= "" and msg == keyword) then
				return true;
			end
		end
	end

	return false;
end

function AutoInvite_Invite(who)
	local numgroup;
	local gtype = AutoInviteOptions[Realm][Player]["Type"];
	if(gtype == "Party") then
		numgroup = GetNumPartyMembers();
		if((IsPartyLeader() and numgroup < 4) or (numgroup == 0)) then InviteByName(who)
		else
			if(numgroup >= 4) then return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..who.." right now, party is full.");
			else return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..who.." right now, you're not the party leader.") end;
		end
	elseif(gtype == "Raid") then
		numgroup = GetNumRaidMembers();
		if(numgroup == 0) then
			numparty = GetNumPartyMembers();
			if(numparty == 0) then InviteByName(who)
			elseif(numparty < 4) then
				if(IsPartyLeader()) then InviteByName(who)
				else return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..who.." right now, you're not the party leader.") end;
			elseif(GetNumPartyMembers() == 4)then
				if(IsPartyLeader()) then
					DEFAULT_CHAT_FRAME:AddMessage("Raid mode enabled: Converting your group to a raid.")
					ConvertToRaid();
					InviteByName(who);
				else
					DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..who.." right now, you're not the party leader.");
				end
			end
		elseif((IsRaidLeader() or IsRaidOfficer()) and numgroup < 40) then InviteByName(who)
		else
			if(numgroup > 39) then return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..who.." right now, raid is full.");
			else return DEFAULT_CHAT_FRAME:AddMessage("Can't invite "..who.." right now, you're not the raid leader.") end;
		end
	end
end