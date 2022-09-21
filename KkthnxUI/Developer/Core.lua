local K = unpack(KkthnxUI)

K.Devs = {
	["Kkthnx-Sulfuras"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end
