--[[
Name: "sh_police_car.lua".
Product: "EvoRP (Roleplay)".
--]]
 
if ( !evorp.plugin.get("Generic") ) then return; end;

function AddCar(unique, cost, description)
	local ITEM = {};

	ITEM.name = list.Get( "Vehicles" )[ unique ].Name;
	ITEM.plural = ITEM.name.."s";
	ITEM.uniqueID = unique;
	ITEM.description = description;
	ITEM.cost = cost;
	ITEM.model = list.Get( "Vehicles" )[ unique ].Model;
	ITEM.size = 2;
	ITEM.batch = 1;
	ITEM.store = true;
	ITEM.category = "Vehicles"; 
	ITEM.onUse = function() end
	ITEM.onPickup = function() end
	ITEM.onDrop = function() end
	ITEM.onSell = function() end

	evorp.item.register(ITEM);
end

AddCar("volvo_s60", 60000, "The classic volvo.")
AddCar("fer458comp", 390000, "1-Seater Race Car.")
--AddCar("mer_g65", 400000, "The G-Class G-Wagon.")
AddCar("mer_g65_6x6", 950000, "A monster truck by Mercedes Benz.")
AddCar("bently_pmcontinental", 225000, "The british grand tourer.")
AddCar("chev_nascar", 850000, "It's NASCAR.")
AddCar("spyker_aileron", 1350000, "0-100 in 4 seconds.")
AddCar("one77sped", 900000, "Aston Martin One-77 by Turn 10 Studio's")
AddCar("evorasped", 600000, "Lotus Evora by Turn 10 Studio's")
AddCar("asc_kz1r", 750000, "A racecar with a BMW S62 engine.")
AddCar("jaguar_xj220", 750000, "A two seater luxury supercar.")
AddCar("chev_camaro_68", 190000, "A '68 camaro with a V8 engine.")
AddCar("Citroen", 49000, "A classic.") -- $33,990
AddCar("golf3tdm", 12500, "European Car of the Year, 1992") -- $36,000
AddCar("priustdm", 24000, "A very energy efficient car.")  -- $25,000
AddCar("transittdm", 60000, "An interchangable cargo + passenger van.")
AddCar("chargersrt8tdm", 70000,  "Rear wheel, four door muscle car.") -- $44,445
AddCar("escaladetdm", 95000, "A full size luxury sport utility vehicle.")
AddCar("trucktdm", 110000, "A truck to transport goods.")
AddCar("h1tdm", 140000, "A humvee for civilians.")
AddCar("focusrstdm", 160000, "The predecessor to the Ford Fiesta. Winner of 44 world rallies.")
AddCar("camarozl1tdm", 175000, "Entry sports car.")
AddCar("300ctdm", 190000, "A high-end luxury sedan.")
AddCar("350ztdm", 190000, "Fifth generation Z-Class Nissan sport GT.")
AddCar("gtrtdm", 220000, "Pure performance.")
AddCar("dodgeramtdm", 220000, "A full-size sporty pickup truck.")
AddCar("s5tdm", 270000, "Four wheel drive sportback.")
AddCar("audir8tdm", 390000, "The best handling commercial sport car.")
AddCar("gt05tdm", 450000, "The most inspiring and famous car from Ford.")
AddCar("r34tdm", 510000, "100 HP less than the Bugatti Veyron, but still packs the same punch.")
AddCar("gallardotdm", 550000, "The most successful lamborghini ever sold.")
AddCar("dbstdm", 650000, "A high performance commercial GT sports car.")
AddCar("slsamgtdm", 675000, "A front-engine 2-seat luxury GT car.")
AddCar("eb110tdm", 700000, "A mid-engine sports car designed by Marcello & Giampaolo.")
AddCar("sl65amgtdm", 740000, "A lightweight sport GT gt.")
AddCar("murcielagotdm", 750000, "A two seat sports car. The predecessor of the Aventador.")
AddCar("458spidtdm", 850000, "A dream car, this will definitely attract many eyes.")
AddCar("reventonrtdm", 1000000, "He who seems to be about to burst.")
AddCar("veyrontdm", 1300000, "Unarguably the best grand touring car.")
AddCar("veyronsstdm", 1500000, "The super sport version of the Bugatti Veyron.")