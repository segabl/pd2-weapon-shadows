if not WeaponShadows then

	WeaponShadows = {}
	WeaponShadows.mod_path = ModPath
	WeaponShadows.akimbo_mappings = {}
	WeaponShadows.id_redirects = {
		aa12 = Idstring("s_assault_rifle"),
		judge = Idstring("s_revolver"),
		saiga = Idstring("s_assault_rifle"),
		tecci = Idstring("s_lmg")
	}
	WeaponShadows.hold_redirects = {
		uzi = Idstring("s_uzi"),
		bullpup = Idstring("s_bullpup")
	}

	function WeaponShadows:setup(weapon_tweak_data)
		self.npc_mappings = weapon_tweak_data:get_npc_mappings()
		for k, v in pairs(weapon_tweak_data:get_akimbo_mappings()) do
			self.akimbo_mappings[v] = k
		end
	end

	local ids_shadow_unit = Idstring("units/payday2/weapons/shadow/shadow")
	function WeaponShadows:spawn_shadow_unit(weapon_base)
		-- Check if this is a valid weapon base (More Weapon Stats makes "fake" bases to calculate stats)
		if not alive(weapon_base._unit) then
			return
		end

		weapon_base._shadow_unit = World:spawn_unit(ids_shadow_unit, weapon_base._unit:position(), weapon_base._unit:rotation())
		weapon_base._unit:link(weapon_base._unit:orientation_object():name(), weapon_base._shadow_unit, weapon_base._shadow_unit:orientation_object():name())

		local name_id = weapon_base._original_id or weapon_base._name_id
		local short_name = name_id:gsub("_npc$", ""):gsub("_crew$", "")
		local name = self.npc_mappings[self.akimbo_mappings[short_name]] or name_id
		local tweak = tweak_data.weapon[name] or weapon_base:weapon_tweak_data()

		 -- Check for a weapon specific shadow object first
		local shadow_obj = weapon_base._shadow_unit:get_object(self.id_redirects[short_name] or Idstring("s_" .. short_name))

		-- If there's no weapon specific shadow object, check for a hold specific shadow object
		if not shadow_obj and tweak.hold then
			if self.hold_redirects[tweak.hold] then
				shadow_obj = weapon_base._shadow_unit:get_object(self.hold_redirects[tweak.hold])
			elseif type(tweak.hold) == "table" then
				for _, v in ipairs(tweak.hold) do
					if self.hold_redirects[v] then
						shadow_obj = weapon_base._shadow_unit:get_object(self.hold_redirects[v])
						break
					end
				end
			end
		end

		-- If we still don't have a shadow object, check for a shadow object based on weapon category
		if not shadow_obj then
			shadow_obj = weapon_base._shadow_unit:get_object(Idstring("s_assault_rifle"))
			for _, v in ipairs(tweak.categories) do
				shadow_obj = weapon_base._shadow_unit:get_object(Idstring("s_" .. v)) or shadow_obj
			end
		end

		-- Make chosen shadow object visible
		if shadow_obj then
			shadow_obj:set_visibility(true)
		end
	end

	function WeaponShadows:remove_shadow_unit(weapon_base)
		if alive(weapon_base._shadow_unit) then
			weapon_base._shadow_unit:set_slot(0)
		end
	end

end

local required = {}
if RequiredScript and not required[RequiredScript] then

	local fname = WeaponShadows.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	required[RequiredScript] = true

end
