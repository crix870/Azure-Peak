/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = ""
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/obj/effect/proc_holder/spell/targeted/touch/attached_spell
	icon = 'icons/obj/balloons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "syndballoon"
	item_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charges = 1

/obj/item/melee/touch_attack/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("I can't reach out!"))
		return
	..()

/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	user.say(catchphrase, forced = "spell")
	playsound(get_turf(user), on_use_sound,50,TRUE)
	charges--
	if(charges <= 0)
		var/mob/living/gamer = user
		var/verbu = "hits"
		verbu = pick(gamer.used_intent.attack_verb)
		user.visible_message(span_warning("[user] [verbu] with \the [user.p_their()] [src] for the last time! It smashes into a million pieces, which soon disintegrate..."), \
			span_notice("My [src] smashes in my hand, disintegrating into the wind!."))
		qdel(src)

/obj/item/melee/touch_attack/Destroy()
	if(attached_spell)
		attached_spell.on_hand_destroy(src)
	return ..()

/obj/item/melee/touch_attack/disintegrate
	name = "\improper smiting touch"
	desc = ""
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/blank.ogg'
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/touch_attack/disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //exploding after touching myself would be bad
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_warning("I can't get the words out!"))
		return
	var/mob/M = target
	do_sparks(4, FALSE, M.loc)
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = M.anti_magic_check()
	if(A)
		if(isitem(A))
			target.visible_message(span_warning("[target]'s [A] glows brightly as it wards off the spell!"))
		user.visible_message(span_warning("The feedback blows [user]'s arm off!"),span_danger("The spell bounces from [M]'s skin back into your arm!"))
		user.flash_act()
		var/obj/item/bodypart/part = user.get_holding_bodypart_of_item(src)
		if(part)
			part.dismember()
		return ..()
	var/obj/item/clothing/suit/hooded/bloated_human/suit = M.get_item_by_slot(SLOT_ARMOR)
	if(istype(suit))
		M.visible_message(span_danger("[M]'s [suit] explodes off of them into a puddle of gore!"))
		M.dropItemToGround(suit)
		qdel(suit)
		new /obj/effect/gibspawner(M.loc)
		return ..()
	M.gib()
	return ..()

/obj/item/melee/touch_attack/fleshtostone
	name = "\improper petrifying touch"
	desc = ""
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/blank.ogg'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/obj/item/melee/touch_attack/fleshtostone/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user)) //getting hard after touching myself would also be bad
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("I can't reach out!"))
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_warning("I can't get the words out!"))
		return
	var/mob/living/M = target
	if(M.anti_magic_check())
		to_chat(user, span_warning("The spell can't seem to affect [M]!"))
		to_chat(M, span_warning("I feel your flesh turn to stone for a moment, then revert back!"))
		..()
		return
	M.Stun(40)
	M.petrify()
	return ..()
