if not WeaponShadows then

	WeaponShadows = {}
	WeaponShadows.required = {}
	WeaponShadows.mod_path = ModPath
	WeaponShadows.akimbo_mappings = {}
	WeaponShadows.id_redirects = {
		aa12 = Idstring("s_assault_rifle"),
		arbiter = Idstring("s_bullpup"),
		ching = Idstring("s_shotgun"),
		flamethrower = Idstring("s_flamethrower"),
		flamethrower_mk2 = Idstring("s_flamethrower"),
		judge = Idstring("s_revolver"),
		mossberg = Idstring("s_revolver"),
		mp9 = Idstring("s_uzi"),
		saiga = Idstring("s_assault_rifle"),
		sbl = Idstring("s_shotgun"),
		system = Idstring("s_flamethrower"),
		tecci = Idstring("s_lmg"),
		winchester1874 = Idstring("s_shotgun")
	}
	WeaponShadows.hold_redirects = {
		uzi = Idstring("s_uzi"),
		bullpup = Idstring("s_bullpup")
	}
	WeaponShadows.shield_redirects = {
		[("units/payday2/characters/ene_acc_shield_small/ene_acc_shield_small"):key()] = Idstring("s_shield_small"),
		[("units/pd2_dlc_mad/characters/ene_acc_shield_akan_shield/ene_acc_shield_akan"):key()] = Idstring("s_shield_akan"),
		[("units/pd2_dlc_vip/characters/ene_acc_shield_phalanx/ene_acc_shield_phalanx"):key()] = Idstring("s_shield_phalanx"),
		[("units/pd2_dlc_vip/characters/ene_acc_shield_vip/ene_acc_shield_vip"):key()] = Idstring("s_shield_phalanx")
	}

	function WeaponShadows:setup(weapon_tweak_data)
		self.npc_mappings = weapon_tweak_data:get_npc_mappings()
		for k, v in pairs(weapon_tweak_data:get_akimbo_mappings()) do
			self.akimbo_mappings[v] = k
		end
	end

	local ids_shadow_unit = Idstring("units/payday2/weapons/shadow/shadow")
	function WeaponShadows:spawn_shadow_unit(extension)
		-- Check if this is a valid weapon base (More Weapon Stats makes "fake" bases to calculate stats)
		if not alive(extension._unit) then
			return
		end

		if alive(extension._shadow_unit) then
			return
		end

		-- Disable existing shadows if there are any for some reason
		extension._unit:set_shadows_disabled(true)

		extension._shadow_unit = World:spawn_unit(ids_shadow_unit, extension._unit:position(), extension._unit:rotation())
		extension._unit:link(extension._unit:orientation_object():name(), extension._shadow_unit, extension._shadow_unit:orientation_object():name())

		local name_id = extension._original_id or extension._name_id
		local short_name = name_id:gsub("_npc$", ""):gsub("_crew$", "")
		local name = self.npc_mappings[self.akimbo_mappings[short_name]] or name_id
		local tweak = tweak_data.weapon[name] or extension:weapon_tweak_data()

		 -- Check for a weapon specific shadow object first
		local shadow_obj = extension._shadow_unit:get_object(self.id_redirects[short_name] or Idstring("s_" .. short_name))

		-- If there's no weapon specific shadow object, check for a hold specific shadow object
		if not shadow_obj and tweak.hold then
			if self.hold_redirects[tweak.hold] then
				shadow_obj = extension._shadow_unit:get_object(self.hold_redirects[tweak.hold])
			elseif type(tweak.hold) == "table" then
				for _, v in ipairs(tweak.hold) do
					if self.hold_redirects[v] then
						shadow_obj = extension._shadow_unit:get_object(self.hold_redirects[v])
						break
					end
				end
			end
		end

		-- If we still don't have a shadow object, check for a shadow object based on weapon category
		if not shadow_obj then
			shadow_obj = extension._shadow_unit:get_object(Idstring("s_assault_rifle"))
			for _, category in ipairs(tweak.categories) do
				if category == "smg" and tweak.hold == "pistol" then
					category = "uzi"
				end
				shadow_obj = extension._shadow_unit:get_object(Idstring("s_" .. category)) or shadow_obj
			end
		end

		-- Make chosen shadow object visible
		if shadow_obj then
			shadow_obj:set_visibility(true)
		end
	end

	function WeaponShadows:spawn_shield_shadow_unit(extension)
		if not extension or alive(extension._shadow_unit) then
			return
		end

		-- Disable existing shadows if there are any for some reason
		extension._unit:set_shadows_disabled(true)

		extension._shadow_unit = World:spawn_unit(ids_shadow_unit, extension._unit:position(), extension._unit:rotation())
		extension._unit:link(extension._unit:orientation_object():name(), extension._shadow_unit, extension._shadow_unit:orientation_object():name())

		local shadow_obj = extension._shadow_unit:get_object(WeaponShadows.shield_redirects[extension._unit:name():key()] or Idstring("s_shield_lights"))

		-- Make chosen shadow object visible
		if shadow_obj then
			shadow_obj:set_visibility(true)
		end

		Hooks:PostHook(extension, "destroy", "destroy_shadow" .. extension._unit:name():key(), function (self)
			WeaponShadows:remove_shadow_unit(self)
		end)
	end

	function WeaponShadows:set_shadow_unit_visibile(extension, state)
		if alive(extension._shadow_unit) then
			extension._shadow_unit:set_visible(state)
		end
	end

	function WeaponShadows:remove_shadow_unit(extension)
		if alive(extension._shadow_unit) then
			extension._shadow_unit:set_slot(0)
		end
	end

end

if RequiredScript and not WeaponShadows.required[RequiredScript] then

	local fname = WeaponShadows.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	WeaponShadows.required[RequiredScript] = true

end
