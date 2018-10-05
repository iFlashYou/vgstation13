//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/game_mode/blob/send_intercept(var/report = 1)
	var/intercepttext = ""
	var/interceptname = "Error"
	switch(report)
		if(0)
			..()
			return
		if(1)
			interceptname = "Biohazard Alert"
			intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
Reports indicate the probable transfer of a biohazardous agent onto [station_name()] during the last crew deployment cycle.
Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.
Nanotrasen has issued a directive 7-10 for [station_name()]. The station is to be considered quarantined.
Orders for all [station_name()] personnel follows:
<ol>
	<li>Do not leave the quarantine area.</li>
	<li>Locate any outbreaks of the organism on the station.</li>
	<li>If found, use any neccesary means to contain the organism.</li>
	<li>Avoid damage to the capital infrastructure of the station.</li>
</ol>
Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12.
Message ends."}
			for (var/mob/living/silicon/ai/aiPlayer in player_list)
				var/law = "The station is under quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving."
				aiPlayer.set_zeroth_law(law)
				to_chat(aiPlayer, "Laws Updated: [law]")
		if(2)
			var/nukecode = "ERROR"
			for(var/obj/machinery/nuclearbomb/bomb in machines)
				if(bomb && bomb.r_code)
					if(bomb.z == map.zMainStation)
						nukecode = bomb.r_code
			interceptname = "Directive 7-12"
			intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
Directive 7-12 has been issued for [station_name()].
The biohazard has grown out of control and will soon reach critical mass.
Your orders are as follows:
<ol>
	<li>Secure the Nuclear Authentication Disk.</li>
	<li>Detonate the Nuke located in the Station's Vault.</li>
</ol>
<b>Nuclear Authentication Code:</b> [nukecode]
Message ends."}
			for (var/mob/living/silicon/ai/aiPlayer in player_list)
				var/law = "Directive 7-12 has been authorized. Allow no sentient being to escape the purge. The nuclear failsafe must be activated at any cost, the code is: [nukecode]."
				aiPlayer.set_zeroth_law(law)
				to_chat(aiPlayer, "Laws Updated: [law]")

	for (var/obj/machinery/computer/communications/comm in machines)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext

			comm.messagetitle.Add("[interceptname]")
			comm.messagetext.Add(intercepttext)
	return



/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0


	proc/count()
		for(var/turf/T in world)
			if(T.z != map.zMainStation)
				continue

			if(istype(T,/turf/simulated/floor))
				if(!(T:burnt))
					src.floor += 12
				else
					src.floor += 1

			if(istype(T, /turf/simulated/wall))
				if(T:intact)
					src.wall += 2
				else
					src.wall += 1

			if(istype(T, /turf/simulated/wall/r_wall))
				if(T:intact)
					src.r_wall += 2
				else
					src.r_wall += 1

		for(var/obj/O in world)
			if(O.z != map.zMainStation)
				continue

			if(istype(O, /obj/structure/window))
				src.window += 1
			else if(istype(O, /obj/structure/grille))
				var/obj/structure/grille/G = O
				if(!G.broken)
					src.grille += 1
			else if(istype(O, /obj/machinery/door))
				src.door += 1
			else if(istype(O, /obj/machinery))
				src.mach += 1
		return


	proc/score(var/datum/station_state/result)
		if(!result)
			return 0
		var/output = 0
		output += (result.floor / max(floor,1))
		output += (result.r_wall/ max(r_wall,1))
		output += (result.wall / max(wall,1))
		output += (result.window / max(window,1))
		output += (result.door / max(door,1))
		output += (result.grille / max(grille,1))
		output += (result.mach / max(mach,1))
		return (output/7)