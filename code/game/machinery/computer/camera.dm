//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/list/tv_monitors = list()

/obj/machinery/computer/security
	name = "Security Cameras"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	circuit = "/obj/item/weapon/circuitboard/security"
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/list/network = list(CAMERANET_SS13)
	var/mapping = 0//For the overview file, interesting bit of code.

	var/list/datum/action/camera/our_actions = list()
	var/static/list/obj/machinery/camera/sorted_cams = list()
	var/static/list/obj/machinery/camera/deactivated_cams = list()

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/security/New()
	..()
	var/datum/action/camera/previous/P = new(src)
	var/datum/action/camera/cancel/C = new(src)
	var/datum/action/camera/listing/L = new(src)
	var/datum/action/camera/next/N = new(src)
	our_actions = list(P, C, L, N)

	if (ticker && ticker.mode == GAME_STATE_PLAYING)
		initialize()

	tv_monitors += src

/obj/machinery/computer/security/initialize()
	. = ..()
	sorted_cams = get_cameras()
	if (sorted_cams.len)
		current = sorted_cams[1]

/obj/machinery/computer/security/Destroy()
	tv_monitors -= src
	our_actions.Cut() // removes our actions
	..()

/obj/machinery/computer/security/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)


/obj/machinery/computer/security/attack_paw(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/security/check_eye(var/mob/user as mob)
	if ((!Adjacent(user) || user.isStunned() || user.blinded || !( current ) || !( current.status )) && (!istype(user, /mob/living/silicon)))
		user.cancel_camera()
		return null
	user.reset_view(current)
	return 1


/obj/machinery/computer/security/attack_hand(var/mob/user as mob)

	if (src.z > 6)
		to_chat(user, "<span class='danger'>Unable to establish a connection: </span>You're too far away from the station!")
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if(!isAI(user))
		user.set_machine(src)

	for (var/datum/action/camera/action in our_actions)
		action.Grant(user)

/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching arena fights and variety shows."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = list(CAMERANET_THUNDER)
	density = 0
	circuit = null

	light_color = null

/obj/machinery/computer/security/telescreen/examine(mob/user)
	..()
	to_chat(user, "Looks like the current channel is \"<span class='info'>[current.c_tag]</span>\"")

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have chicken-channel on these things."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	network = list(CAMERANET_THUNDER, CAMERANET_COURTROOM)
	density = 0
	circuit = null

	light_color = null

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"

	light_color = null

/obj/machinery/computer/security/mining
	name = "Outpost Cameras"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list(CAMERANET_MINE)
	circuit = "/obj/item/weapon/circuitboard/mining"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/security/engineering
	name = "Engineering Cameras"
	desc = "Used to monitor engineering silicons and alarms."
	icon_state = "engineeringcameras"
	network = list(CAMERANET_ENGI,CAMERANET_POWERALARMS,CAMERANET_ATMOSALARMS,CAMERANET_FIREALARMS)
	circuit = "/obj/item/weapon/circuitboard/security/engineering"

	light_color = LIGHT_COLOR_YELLOW

/obj/machinery/computer/security/proc/set_camera(var/mob/living/user, var/obj/machinery/camera/C)
	if(C)
		if ((!Adjacent(user) || user.machine != src || user.blinded || user.isStunned() || !( C.can_use() )) && (!istype(user, /mob/living/silicon/ai)))
			if(!C.can_use() && !isAI(user))
				src.current = null
			user.cancel_camera()
			return 0
		else
			if(isAI(user))
				var/mob/living/silicon/ai/A = user
				A.eyeobj.forceMove(get_turf(C))
				A.client.eye = A.eyeobj
			else
				src.current = C
				use_power(50)

	user.set_machine(src)

/obj/machinery/computer/security/proc/get_cameras()

	var/list/D = list()

	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!istype(C.network, /list))
			var/turf/T = get_turf(C)
			WARNING("[C] - Camera at ([T.x],[T.y],[T.z]) has a non list for network, [C.network]")
			C.network = list(C.network)
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			to_chat(world, "[src] - adding [C]")
			D.Add(C)

	D = camera_sort(D)

	return D

/obj/machinery/computer/security/proc/next(var/mob/living/user)

	var/place = sorted_cams.Find(current)

	place++
	if (place > sorted_cams.len)
		place = 1

	var/obj/machinery/camera/C = sorted_cams[place]

	set_camera(user, C)

/obj/machinery/computer/security/proc/previous(var/mob/living/user)

	var/place = sorted_cams.Find(current)

	place--
	if (place <= 0)
		place = sorted_cams.len
	var/obj/machinery/camera/C = sorted_cams[place]

	set_camera(user, C)

// Action buttons for camera cyclin

/datum/action/camera
	var/obj/machinery/computer/security/our_computer
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_LYING | AB_CHECK_CONSCIOUS

/datum/action/camera/New(var/obj/machinery/computer/security/our_computer)
	. =..()
	src.our_computer = our_computer

/datum/action/camera/next
	name = "Next camera"
	desc = "Cycle to the next camera in the camera net."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "next"

/datum/action/camera/next/Trigger()
	our_computer.next(owner)

/datum/action/camera/previous
	name = "Previous camera"
	desc = "Cycle to the previous camera in the camera net."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "previous"

/datum/action/camera/previous/Trigger()
	our_computer.previous(owner)

/datum/action/camera/listing
	name = "Camera listing"
	desc = "List all the cameras in the net, then let you choose between them."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "listing"

/datum/action/camera/listing/Trigger()
	var/mob/living/user = owner
	if(!isAI(user))
		user.set_machine(our_computer)

	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/D = list()
	D["Cancel"] = "Cancel"
	for(var/obj/machinery/camera/C in L)
		if(!istype(C.network, /list))
			var/turf/T = get_turf(C)
			WARNING("[C] - Camera at ([T.x],[T.y],[T.z]) has a non list for network, [C.network]")
			C.network = list(C.network)
		var/list/tempnetwork = C.network & our_computer.network
		if(tempnetwork.len)
			D[text("[][]", C.c_tag, (C.status ? null : " (Deactivated)"))] = C

	var/t = input(user, "Which camera should you change to?") as null|anything in D
	if(!t || t == "Cancel")
		user.cancel_camera()
		return 0
	user.set_machine(our_computer)

	var/obj/machinery/camera/C = D[t]

	our_computer.set_camera(user, C)

/datum/action/camera/cancel
	name = "Cancel camera view"
	desc = "Cancels the camera view."
	icon_icon = 'icons/obj/camera_buttons.dmi'
	button_icon_state = "cancel"

/datum/action/camera/cancel/Trigger()
	var/mob/living/user = owner
	user.cancel_camera()