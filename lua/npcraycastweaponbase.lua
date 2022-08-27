Hooks:PostHook(NPCRaycastWeaponBase, "init", "init_shadow", function (self)
	WeaponShadows:spawn_shadow_unit(self)
end)

Hooks:PostHook(NPCRaycastWeaponBase, "destroy", "destroy_shadow", function (self)
	WeaponShadows:remove_shadow_unit(self)
end)

Hooks:PostHook(NPCRaycastWeaponBase, "set_visibility_state", "set_visibility_state_shadow", function (self, state)
	WeaponShadows:set_shadow_unit_visibile(self, state)
end)
