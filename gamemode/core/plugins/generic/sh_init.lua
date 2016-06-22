--[[
Name: "sh_init.lua".
Product: "EvoRP (Roleplay)".
--]]

local PLUGIN = PLUGIN_SHARED;

-- Set some information for the plugin.
PLUGIN.name = "Generic";
PLUGIN.author = "Kudomiku";

PLUGIN.citizenModels = {
	male = {
	"models/evorp/ci/citizen1.mdl",
	"models/evorp/ci/citizen3.mdl",
	"models/evorp/ci/citizen4.mdl",
	"models/evorp/ci/citizen7.mdl",
	"models/evorp/ci/citizen9.mdl",
	"models/player/eli.mdl",
	"models/player/monk.mdl",
	"models/player/odessa.mdl"
	},
	female = {
	--"models/player/chell.mdl",
	"models/evorp/ci/fcitizen1.mdl",
	"models/evorp/ci/fcitizen2.mdl",
	"models/evorp/ci/fcitizen7.mdl",
	"models/player/alyx.mdl"
	}
};

PLUGIN.rebelModels = {
	male = {
		"models/jessev92/player/hl2/rebels_carter.mdl",
		"models/jessev92/player/hl2/rebels_kurt.mdl",
		"models/jessev92/player/hl2/rebels_kurt_wounded.mdl",
        		"models/jessev92/player/hl2/rebels_tanaka.mdl",
        		"models/jessev92/player/personalskins/rusty-rebel.mdl"
	},
	female = {
		"models/jessev92/player/hl2/rebels_miko.mdl"
	}
};

PLUGIN.rebelsf = {	"models/player/Group03/Female_01.mdl",
			"models/player/Group03/Female_02.mdl",
			"models/player/Group03/Female_03.mdl",
			"models/player/Group03/Female_04.mdl",
			"models/player/Group03/Female_06.mdl",
			"models/player/Group03/Female_07.mdl"
		}
PLUGIN.rebelsm = {	"models/player/Group03/Male_01.mdl",
			"models/player/Group03/Male_02.mdl",
			"models/player/Group03/Male_03.mdl",
			"models/player/Group03/Male_04.mdl",
			"models/player/Group03/Male_05.mdl",
			"models/player/Group03/Male_06.mdl",
			"models/player/Group03/Male_07.mdl"
		}

PLUGIN.policeModels = {
	male = {
		"models/humans/nypd1940/male_09.mdl",
		        "models/humans/nypd1940/male_07.mdl",
		        "models/humans/nypd1940/male_04.mdl",
		        "models/humans/nypd1940/male_01.mdl",
		        "models/humans/nypd1940/male_02.mdl"
	}
};


PLUGIN.mafiaModels = {
	male = {
		"models/evorp/ci/mafia02.mdl",
		"models/evorp/ci/mafia04.mdl",
		"models/evorp/ci/mafia06.mdl",
		"models/evorp/ci/mafia07.mdl",
		"models/evorp/ci/mafia09.mdl"
	}
};

TEAM_PRESIDENT = evorp.team.add("President", Color(255, 50, 25, 255), "models/evorp/ci/mayor1.mdl", "models/evorp/ci/mayor2.mdl", "Runs the city and keeps it in shape.", 500, 1, {"Misc.", "Clothing", "Class Vehicles", "Vehicles"}, "n", "R_GOV");
TEAM_HOSS = evorp.team.add("Head of Secret Service", Color(102,0,0,255), "models/evorp/ci/ga01.mdl", "models/evorp/ci/ga01.mdl", "The commander in chief of the secret service.", 300, 1, {"Misc.", "Clothing", "Class Vehicles", "Vehicles"}, "j", "R_GOV"); -- No female model!
TEAM_SS = evorp.team.add("Secret Service", Color(102,0,0,255), "models/evorp/ci/ga02.mdl", "models/evorp/ci/ga02.mdl", "The president's agents protecting him/her at all times.", 250, 3, {"Misc.", "Clothing", "Class Vehicles", "Vehicles"}, "j", "R_GOV"); -- No female model!
TEAM_COMMANDER = evorp.team.add("Commander", Color(50, 50, 255, 255), "models/humans/nypd1940/male_08.mdl", "models/humans/nypd1940/male_08.mdl", "The Chief of the EvoCity Police Department. Manages and sets     objectives for his men.", 300, 1, {"Misc.", "Clothing", "Class Vehicles", "Vehicles"}, "o", "R_GOV"); -- No female model!
TEAM_OFFICER = evorp.team.add("Police Officer", Color(50, 50, 255, 255),PLUGIN.policeModels.male, PLUGIN.policeModels.male, "A member of the EvoCity Police Department (ECPD).", 250, 7, {"Misc.", "Clothing", "Class Vehicles", "Vehicles"}, "o", "R_GOV"); -- No female model!
TEAM_SECRETARY = evorp.team.add("Nexus Assistant", Color(7,163,142,255), "models/player/Hostage/hostage_02.mdl", "models/player/Hostage/hostage_02.mdl", "Assumes the role of making appointments within the Nexus. Keeps  the security of the Nexus and keeps track of who goes in and out.", 250, 2, {"Misc.", "Clothing", "Class Vehicles", "Vehicles"}, "k", "R_GOV");
TEAM_PARAMEDIC = evorp.team.add("Paramedic", Color(7,163,93,255), "models/evorp/ci/paramedic1.mdl", "models/evorp/ci/paramedic2.mdl", "A member of EvoCity's Emergency Medical service.", 250, 3, {"Clothing", "Misc.", "Class Vehicles", "Vehicles"}, "m", "R_GOV");
TEAM_FIREMAN = evorp.team.add("Fireman", Color(225,25,25,255), "models/evorp/ci/fireman2.mdl", "models/evorp/ci/fireman2.mdl", "A member of EvoCity's Fire Department.", 250, 2, {"Clothing", "Misc.", "Class Vehicles", "Vehicles"}, "f", "R_GOV"); -- NO FEMALE MODEL
TEAM_CITIZEN = evorp.team.add("Citizen", Color(44, 129, 255, 255), PLUGIN.citizenModels.male, PLUGIN.citizenModels.female, "An average citizen of EvoCity.", 175, 60, {"Misc.", "Contraband", "Clothing", "Class Vehicles", "Vehicles"}, "b", "R_OPEN");
TEAM_CHEF = evorp.team.add("Chef", Color(255, 125, 200, 255), "models/evorp/ci/chef1.mdl", "models/evorp/ci/chef2.mdl", "Deals food to the city's inhabitants.", 200, 3, {"Contraband", "Misc.", "Clothing", "Food", "Class Vehicles", "Vehicles"}, "z", "R_OPEN");
--TEAM_DOCTOR = evorp.team.add("Doctor", Color(0,102,102,255), "models/player/kleiner.mdl", "models/player/kleiner.mdl", "A dealer of medical supplies for the people of EvoCity.", 20, 2, {"Misc.", "Contraband", "Clothing", "Pharmaceuticals", "Class Vehicles", "Vehicles"}, "h", "R_OPEN"); --No female model
TEAM_WDEALER = evorp.team.add("Weapons Dealer", Color(255, 140, 0, 255), PLUGIN.citizenModels.male, PLUGIN.citizenModels.female, "A dealer of weaponary for the people of EvoCity.", 200, 3, {"Misc.", "Contraband", "Weaponry", "Clothing", "Class Vehicles", "Vehicles"}, "g", "R_OPEN");
TEAM_TAXI = evorp.team.add("Taxi Driver", Color(219,182,35,255), "models/player/Hostage/Hostage_01.mdl", "models/player/Hostage/Hostage_01.mdl", "A taxi driver.", 200, 2, {"Misc.", "Contraband", "Clothing", "Class Vehicles", "Vehicles"}, "x", "R_OPEN"); -- NO FEMALE MODEL
--TEAM_SECURITY = evorp.team.add("Security Guard", Color(205, 120, 100, 255), "models/player/leet.mdl", "models/player/leet.mdl", "Guards homes and shops.", 20, 2, {"Misc.", "Contraband", "Clothing", "Class Vehicles", "Vehicles"}, "q", "R_OPEN");
TEAM_SUPPLIER = evorp.team.add("Supplier", Color(157, 83, 172, 255), PLUGIN.citizenModels.male, PLUGIN.citizenModels.female, "Deals miscellaneous items to the city's inhabitants.", 200, 3, {"Misc.", "Contraband", "Clothing", "Supplies/Misc", "Class Vehicles", "Vehicles"}, "i", "R_OPEN");
TEAM_BMD = evorp.team.add("Black Market Dealer", Color(83, 99, 172, 255), PLUGIN.citizenModels.male, PLUGIN.citizenModels.female, "Deals in controlled and scarce commodities.", 200, 3, {"Misc.", "Contraband", "Clothing", "Black Market", "Class Vehicles", "Vehicles"}, "i", "R_OPEN");
TEAM_RENLEADER = evorp.team.add("Renegade Leader", Color(38, 94, 158, 255), "models/player/arctic.mdl", "models/player/arctic.mdl", "The leader of the renegades.", 250, 1, {"Misc.", "Clothing", "Contraband", "Class Vehicles", "Vehicles"}, "x", "R_RENEGADE");
TEAM_RENEGADE = evorp.team.add("Renegade", Color(38, 94, 158, 255), "models/player/phoenix.mdl", "models/player/phoenix.mdl", "Former law abiding citizens of EVOCITY, now criminals.", 200, 3, {"Misc.", "Contraband", "Clothing", "Class Vehicles", "Vehicles"}, "x", "R_RENEGADE");
TEAM_TLEADER = evorp.team.add("Rogue Leader", Color(163, 38, 38, 255), PLUGIN.rebelsm, PLUGIN.rebelsf, "The leader of the rogues.", 250, 1, {"Misc.", "Clothing", "Contraband", "Class Vehicles", "Vehicles"}, "x", "R_ROGUE");
TEAM_THIEF = evorp.team.add("Rogue", Color(163, 38, 38, 255), PLUGIN.rebelsm, PLUGIN.rebelsf, "A group of aggressive hustlers.", 200, 3, {"Misc.", "Contraband", "Clothing", "Class Vehicles", "Vehicles"}, "x", "R_ROGUE");
TEAM_RLEADER = evorp.team.add("Rebel Leader", Color(150, 150, 150, 255), PLUGIN.rebelModels.male, PLUGIN.rebelModels.female, "The leader of the rebels.", 250, 1, {"Misc.", "Clothing", "Contraband", "Class Vehicles", "Vehicles"}, "x", "R_REBEL");
TEAM_REBEL = evorp.team.add("Rebel", Color(150, 150, 150, 255), PLUGIN.rebelModels.male, PLUGIN.rebelModels.female, "A member of the rebel group.", 200, 3, {"Misc.", "Contraband", "Clothing", "Class Vehicles", "Vehicles"}, "x", "R_REBEL");
TEAM_MLEADER = evorp.team.add("Don", Color(103,103,204,255), "models/evorp/ci/don1.mdl", "models/evorp/ci/don1.mdl", "The leader of the mafia.", 250, 1, {"Misc.", "Clothing", "Contraband", "Class Vehicles", "Vehicles"}, "x", "R_MAFIA");
TEAM_MAFIA = evorp.team.add("Mafia", Color(103,103,204,255), PLUGIN.mafiaModels.male, PLUGIN.mafiaModels.male, "Businessmen who extort local businesses.", 200, 3, {"Misc.", "Clothing", "Contraband", "Class Vehicles", "Vehicles"}, "x", "R_MAFIA");

--TEAM_MECHANIC = evorp.team.add("Mechanic", Color(100,0,204,255), "models/player/Group03/male_09.mdl", "models/player/Group03/female_02.mdl", "An engineer that repairs, customizes and sells cars.", 150, 2, {"Misc.", "Clothing", "Contraband", "Class Vehicles", "Vehicles"}, "r", "R_OPEN")