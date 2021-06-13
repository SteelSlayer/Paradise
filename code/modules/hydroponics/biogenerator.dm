/obj/machinery/biogenerator
	name = "Biogenerator"
	desc = "Converts plants into biomass, which can be used to construct useful items."
	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	/// Is the biogenerator curretly grinding up grown plants.
	var/processing = FALSE
	/// The container that is used to store reagents from certain products.
	var/obj/item/reagent_containers/glass/container = null
	/// The amount of biomass stored in the machine.
	var/biomass = NONE
	/// Used to modify the cost of producing designs. A higher number means less expensive costs.
	var/efficiency = 0
	/// Used to modify how much biomass is produced by grinding plants. A higher number means more biomass.
	var/productivity = 0
	/// The amount of currently stored plants in the biogenerator.
	var/stored_items = NONE
	/// The maximum amount of plants the biogenerator can store.
	var/max_items = 40
	/// A reference to the biogenerator's research, which contains designs that it can build.
	var/datum/research/files
	/// A list which holds all categories and designs the biogenator has available. Used with the UI.
	var/list/designs
	/// The categories in which the various designs belong to.
	var/list/display_categories = list("Food", "Botany Chemicals", "Organic Materials", "Leather and Cloth")

/obj/machinery/biogenerator/New()
	..()
	files = new /datum/research/biogenerator(src)
	create_reagents(1000)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/biogenerator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	refresh_ui_designs()

/obj/machinery/biogenerator/Destroy()
	QDEL_NULL(container)
	QDEL_NULL(files)
	return ..()

/obj/machinery/biogenerator/ex_act(severity)
	if(container)
		container.ex_act(severity)
	..()

/obj/machinery/biogenerator/handle_atom_del(atom/A)
	..()
	if(A == container)
		container = null
		update_icon()
		SStgui.update_uis(src)

/obj/machinery/biogenerator/RefreshParts()
	var/E = 0
	var/P = 0
	var/max_storage = 40
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		P += B.rating
		max_storage = 40 * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E
	productivity = P
	max_items = max_storage

/obj/machinery/biogenerator/on_reagent_change()			//When the reagents change, change the icon as well.
	update_icon()

/obj/machinery/biogenerator/update_icon()
	if(panel_open)
		icon_state = "biogen-empty-o"
	else if(!container)
		icon_state = "biogen-empty"
	else if(!processing)
		icon_state = "biogen-stand"
	else
		icon_state = "biogen-work"
	return

/obj/machinery/biogenerator/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(processing)
		to_chat(user, "<span class='warning'>The biogenerator is currently processing.</span>")
		return

	if(default_deconstruction_screwdriver(user, "biogen-empty-o", "biogen-empty", O))
		if(container)
			var/obj/item/reagent_containers/glass/B = container
			B.forceMove(loc)
			container = null
		update_icon()
		return

	if(exchange_parts(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(istype(O, /obj/item/reagent_containers/glass))
		. = TRUE // No afterattack.
		if(panel_open)
			to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
			return

		if(container)
			to_chat(user, "<span class='warning'>A container is already loaded into the machine.</span>")
			return

		if(!user.drop_item())
			return

		O.forceMove(src)
		container = O
		to_chat(user, "<span class='notice'>You add the container to the machine.</span>")
		update_icon()
		SStgui.update_uis(src)

	else if(istype(O, /obj/item/storage/bag/plants))
		. = TRUE // No afterattack.
		var/obj/item/storage/bag/plants/PB = O
		if(stored_items >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is already full! Activate it.</span>")
			return

		for(var/obj/item/reagent_containers/food/snacks/grown/G in PB.contents)
			if(stored_items >= max_items)
				break
			PB.remove_from_storage(G, src)
			stored_items++

		if(stored_items < max_items)
			to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator.</span>")
		else
			to_chat(user, "<span class='info'>You fill the biogenerator to its capacity.</span>")

	else if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		. = TRUE // No afterattack.
		if(stored_items >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is full! Activate it.</span>")
			return

		user.unEquip(O)
		O.forceMove(src)
		to_chat(user, "<span class='info'>You put [O] in [src]</span>")

	else if(istype(O, /obj/item/disk/design_disk))
		user.visible_message("[user] begins to load [O] in [src]...",
			"You begin to load a design from [O]...",
			"You hear the chatter of a floppy drive.")
		processing = TRUE
		SStgui.update_uis(src)

		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 1 SECONDS, target = src))
			files.AddDesign2Known(D.blueprint)

		processing = FALSE
		SStgui.update_uis(src)
		return TRUE // No afterattack.
	else
		to_chat(user, "<span class='warning'>You cannot put this in [name]!</span>")


/obj/machinery/biogenerator/proc/refresh_ui_designs()
	designs = list()

	for(var/V in files.known_designs)
		var/datum/design/D = files.known_designs[V]
		for(var/category in display_categories)
			if(!(category in D.category))
				continue
			designs += list(list(
				"name" = D.name,
				"id" = D.id,
				"cost" = D.materials[MAT_BIOMASS],
				"category" = category
			))

/obj/machinery/biogenerator/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/biogenerator/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/biogenerator/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Biogenerator", "Biogenerator", 371, 600, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/biogenerator/ui_data(mob/user)
	var/list/data = list(
		"processing" = processing,
		"container" = container,
		"biomass" = biomass,
		"efficiency" = efficiency,
		"stored_items" = stored_items,
		"max_items" = max_items
	)
	return data

/obj/machinery/biogenerator/ui_static_data(mob/user)
	var/list/static_data = list(
		"designs" = designs,
		"display_categories" = display_categories
	)
	return static_data

/obj/machinery/biogenerator/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("activate")
			activate(usr)
		if("detach")
			detach()
		if("create")
			var/datum/design/D = files.known_designs[params["id"]]
			if(!D)
				return
			var/amount = clamp(text2num(params["amount"]), 1, 10)
			create_product(usr, D, amount)

/obj/machinery/biogenerator/proc/activate(mob/user)
	if(stat != 0) // NOPOWER etc
		return
	if(processing)
		to_chat(user, "<span class='warning'>The biogenerator is in the process of working.</span>")
		return

	var/S = 0
	for(var/obj/item/reagent_containers/food/snacks/grown/I in contents)
		S += 5
		if(I.reagents.get_reagent_amount("nutriment")+I.reagents.get_reagent_amount("plantmatter") < 0.1)
			biomass += 1*productivity
		else
			biomass += (I.reagents.get_reagent_amount("nutriment")+I.reagents.get_reagent_amount("plantmatter"))*10*productivity
		qdel(I)

	if(!S)
		return

	processing = TRUE
	SStgui.update_uis(src)
	update_icon()

	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(S * 30)
	sleep(S + 15 / productivity)

	processing = FALSE
	SStgui.update_uis(src)
	update_icon()


/obj/machinery/biogenerator/proc/check_cost(list/materials, multiplier = 1, remove_biomass = TRUE)
	if(length(materials) != 1 || materials[1] != MAT_BIOMASS)
		return FALSE

	if(materials[MAT_BIOMASS] * multiplier / efficiency > biomass)
		return FALSE

	if(remove_biomass)
		biomass -= materials[MAT_BIOMASS] * multiplier / efficiency
	update_icon()
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/biogenerator/proc/check_container_volume(list/reagents, multiplier = 1)
	var/sum_reagents = 0
	for(var/R in reagents)
		sum_reagents += reagents[R]
	sum_reagents *= multiplier

	if(container.reagents.total_volume + sum_reagents > container.reagents.maximum_volume)
		return FALSE

	return TRUE

/obj/machinery/biogenerator/proc/create_product(datum/design/D, amount)
	if(!container || !loc)
		return FALSE

	// Creating stack-based items like cloth or cardboard.
	if(ispath(D.build_path, /obj/item/stack))
		if(!check_container_volume(D.make_reagents, amount))
			return FALSE
		if(!check_cost(D.materials, amount))
			return FALSE

		var/obj/item/stack/product = new D.build_path(loc)
		product.amount = amount
		for(var/R in D.make_reagents)
			container.reagents.add_reagent(R, D.make_reagents[R]*amount)
		return

	// Creating items such as monkey cubes, or filling the `container` with reagents.
	for(var/i in 1 to amount)
		if(!check_container_volume(D.make_reagents))
			return
		if(!check_cost(D.materials))
			return
		if(D.build_path)
			new D.build_path(loc)
		for(var/R in D.make_reagents)
			container.reagents.add_reagent(R, D.make_reagents[R])

	update_icon()

/obj/machinery/biogenerator/proc/detach()
	if(!container)
		return
	container.forceMove(loc)
	container = null
	update_icon()

