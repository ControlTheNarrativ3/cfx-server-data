return { 
	{
		items = {
			{
				name = 'scrapmetal',
				ingredients = {
					WEAPON_HAMMER = 1.00
				},
				duration = 5000,
				count = 5,
			},
			{
				name = 'lockpick',
				ingredients = {
					scrapmetal = 5,
					WEAPON_HAMMER = 0.05
				},
				duration = 7000,
				count = 1,
			},
			{
				name = 'blowpipe',
				ingredients = {
					scrapmetal = 25,
					WEAPON_HAMMER = 0.25
				},
				duration = 7000,
				count = 1,
			},
			{
				name = 'WEAPON_PIPEBOMB',
				ingredients = {
					scrapmetal = 25,
					WEAPON_STICKYBOMB = 2,
					WEAPON_HAMMER = 0.85
				},
				duration = 15000,
				count = 1,
			},
			{
				name = 'bomb_exps',
				ingredients = {
					WEAPON_STICKYBOMB = 2,
					WEAPON_HAMMER = 0.85
				},
				duration = 15000,
				count = 1,
			},
			{
				name = 'bomb_gas',
				ingredients = {
					WEAPON_STICKYBOMB = 2,
					WEAPON_BZGAS = 1,
					WEAPON_HAMMER = 0.85
				},
				duration = 25000,
				count = 1,
			},
		},
		points = {
			vec3(-1147.083008, -2002.662109, 13.180260),
			vec3(1993.5759, 3792.1362, 32.1808)
		},
		zones = {
			{
				coords = vec3(-1146.2, -2002.05, 13.2),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 315.0,
			},
			{
				coords = vec3(1993.5759, 3792.1362, 32.1808),
				size = vec3(3.8, 1.05, 0.15),
				distance = 1.5,
				rotation = 70.0,
			},
		},
		blip = { id = 566, colour = 31, scale = 0.4 },
	},
}
