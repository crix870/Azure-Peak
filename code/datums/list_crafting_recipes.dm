var/global/list/preprocessed_recipes

/proc/load_recipe_list()
	preprocessed_recipes = list()

	var/list/crafting_trees = list(
		"Alchemy" = /datum/crafting_recipe/roguetown/alchemy,
		"Cooking" = /datum/crafting_recipe/roguetown/cooking,
		"Farming" = /datum/crafting_recipe/roguetown/farming,
		"Leather" = /datum/crafting_recipe/roguetown/leather,
		"Sewing" = /datum/crafting_recipe/roguetown/sewing,
		"Structure" = /datum/crafting_recipe/roguetown/structure,
		"Turfs" = /datum/crafting_recipe/roguetown/turfs,
		"Weaving" = /datum/crafting_recipe/roguetown/weaving,

	)

	for (var/type in typesof(/datum/crafting_recipe/roguetown))
		var/datum/crafting_recipe/recipe = new type

		var/list/reqs = simplify_reqs_with_amounts(recipe.reqs)
		if((reqs.len == 0) || !recipe.skillcraft)
			continue

		preprocessed_recipes[recipe.skillcraft] = preprocessed_recipes[recipe.skillcraft] || list()

		preprocessed_recipes[recipe.skillcraft] += list(list(
			"name" = recipe.name,
			"reqs" = reqs,
			"structures" = recipe.structurecraft,
			"craftdiff" = recipe.craftdiff
		))

	// Then process the subtrees
	for (var/craft_name in crafting_trees)
		var/typepath = crafting_trees[craft_name]
        
		// Loop through each type in the type path
		for (var/type in typesof(typepath))
			if (type == typepath)
				continue

			var/datum/crafting_recipe/recipe = new type
			var/list/reqs = simplify_reqs_with_amounts(recipe.reqs)

			preprocessed_recipes[recipe.skillcraft] = preprocessed_recipes[recipe.skillcraft] || list()

			preprocessed_recipes[recipe.skillcraft] += list(list(
				"name" = recipe.name,
				"reqs" = reqs,
				"structures" = recipe.structurecraft,
				"craftdiff" = recipe.craftdiff
			))

	 // Sort the recipes
	for(var/skill_recipes in preprocessed_recipes)
		preprocessed_recipes[skill_recipes] = sortTim(preprocessed_recipes[skill_recipes], /proc/cmp_preprocessed_recipes)
	generate_recipe_html()

/proc/generate_recipe_html()
	if (!preprocessed_recipes)
		return "No recipes available"

	var/text = "<html><body><h1>Crafting Recipes</h1>"

	for (var/skillcraft in preprocessed_recipes)
		var/skillname = "[skillcraft]" // Convert the type path to a string
		var/last_slash_pos = findlasttext(skillname, "/") // Find the position of the last "/"
		skillname = copytext(skillname, last_slash_pos + 1) // Extract the part after the last "/"
		
		for (var/craft in preprocessed_recipes[skillcraft])
		// Output the recipe name (Item name)
			text += "<div><h3>" + craft["name"] + "</h3>"

            // Output the Structures required
			if(craft["structures"])
				var/structure_name = "[craft["structures"]]" // Convert the type path to a string
				var/last_slash_pos_two = findlasttext(structure_name, "/") 
				structure_name = copytext(structure_name, last_slash_pos_two + 1) 
				text += "<p><strong>Structures:</strong> " + structure_name + "</p>"


			text += "<strong>Requirements:</strong><br>"
			for (var/req_name in craft["reqs"])
				
				text += "  " + req_name + ": " + num2text(craft["reqs"][req_name]) + "<br>"

            // Output the Crafting Difficulty
			text += "<strong>" + skillname + " difficulty:</strong> " + slevel_to_skill(trim_right(num2text(craft["craftdiff"]))) + ""

			text += "</div><br>"  // End of a single recipe block

	text += "</body></html>"  // Close HTML tags

	preprocessed_recipes = text
	return

/proc/slevel_to_skill(var/skillnum_str)
	var/skillnum = text2num(skillnum_str)
	switch(skillnum)
		if (SKILL_LEVEL_NONE)
			return "None"
		if (SKILL_LEVEL_NOVICE)
			return "Novice"
		if (SKILL_LEVEL_APPRENTICE)
			return "Apprentice"
		if (SKILL_LEVEL_JOURNEYMAN)
			return "Journeyman"
		if (SKILL_LEVEL_EXPERT)
			return "Expert"
		if (SKILL_LEVEL_MASTER)
			return "Master"
		if (SKILL_LEVEL_LEGENDARY)
			return "Legendary"
		else
			return "Unknown Skill Level"

/proc/cmp_preprocessed_recipes(var/list/a, var/list/b)
    //compare by craftdiff (descending order)
	return b["craftdiff"] - a["craftdiff"]

/proc/simplify_reqs_with_amounts(list/reqs)
	var/list/simplified = list()
	for (var/type in reqs)
		var/item_name = "[type]" // Convert the type path to a string
		var/last_slash_pos = findlasttext(item_name, "/") // Find the position of the last "/"
		item_name = copytext(item_name, last_slash_pos + 1) // Extract the part after the last "/"
		switch(item_name)
			if("small")
				item_name = "small-log"
			if("rogue")
				item_name = "rogueberries"
			if("blessed")
				item_name = "blessed water"
			if("bloodied")
				item_name = "bloodied fyritius"
		if(reqs[type] == 0)
			reqs[type] = 1
		simplified[item_name] = reqs[type] // Preserve the amount
	return simplified
