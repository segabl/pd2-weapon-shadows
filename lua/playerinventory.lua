Hooks:PostHook(PlayerInventory, "equip_shield", "equip_shield_shadow", function (self, shield_unit)
	if alive(shield_unit) then
		WeaponShadows:spawn_shield_shadow_unit(shield_unit:damage())
	end
end)
