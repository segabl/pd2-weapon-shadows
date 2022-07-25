Hooks:PostHook(NewNPCRaycastWeaponBase, "init", "init_shadow", function (self)
	WeaponShadows:spawn_shadow_unit(self)
end)

Hooks:PostHook(NewNPCRaycastWeaponBase, "destroy", "destroy_shadow", function (self)
	WeaponShadows:remove_shadow_unit(self)
end)
