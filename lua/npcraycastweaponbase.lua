Hooks:PostHook(NPCRaycastWeaponBase, "init", "init_shadow", function (self)
	WeaponShadows:spawn_shadow_unit(self)
end)

Hooks:PostHook(NPCRaycastWeaponBase, "destroy", "destroy_shadow", function (self)
	WeaponShadows:remove_shadow_unit(self)
end)
