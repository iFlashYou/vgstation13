/datum/job/trader
	title = "Trader"
	flag = TRADER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "nobody"
	selection_color = "#dddddd"
	access = list(access_trade)
	minimal_access = list(access_trade)
	alt_titles = list("Merchant")

	species_whitelist = list("Vox")
	must_be_map_enabled = 1

	no_random_roll = 1 //Don't become a vox trader randomly
	no_crew_manifest = 1

	//Don't spawn with any of the average crew member's luxuries (only an ID)
	no_starting_money = 1
	no_pda = 1

	spawns_from_edge = 1

	idtype = /obj/item/weapon/card/id/vox

	no_headset = 1

	//Both Restricted: Revolution, Revsquad
	//Merchant Restricted: Double Agent, Vampire, Cult

/datum/job/trader/equip(var/mob/living/carbon/human/H)
	if(!H)
		return 0
	H.equip_or_collect(new /obj/item/clothing/under/vox/vox_robes(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/magboots/vox(H), slot_shoes)

	switch(H.backbag) //BS12 EDIT
		if(2)
			H.equip_or_collect(new/obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new/obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new/obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)

	H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/storage/wallet/trader(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/device/radio(H), slot_belt)
	switch(H.mind.role_alt_title)
		if("Trader") //Traders get snacks and a coin
			H.equip_or_collect(new /obj/item/weapon/storage/box/donkpockets/random_amount(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/thermos/full(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/coin/trader(H.back), slot_in_backpack)

		if("Merchant") //Merchants get an implant
			var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
			L.imp_in = H
			L.implanted = 1
			var/datum/organ/external/affected = H.get_organ(LIMB_HEAD)
			affected.implants += L
			L.part = affected


	return 1

/datum/job/trader/introduce(mob/living/carbon/human/M, job_title)
	if(!job_title)
		job_title = src.title

	if(!trader_account)
		trader_account = create_trader_account
	M.mind.store_memory("<b>The joint trader account is:</b> #[trader_account.account_number]<br><b>Your shared account pin is:</b> [trader_account.remote_access_pin]<br>")

	to_chat(M, "<B>You are a [job_title].</B>")

	to_chat(M, "<b>You should do your best to sell what you can to fund new product sales. Ultimately, the mark of a good trader is profit -- but public relations are an important component of that end goal.</b>")

	if(M.mind.role_alt_title == "Merchant")
		to_chat(M, "<B><span class='info'>Your merchant's license paperwork has just cleared with Nanotrasen HQ. You have a loyalty implant and the staff has been notified that you are active in this sector.</span></B>")
		notify_crew(M)

	to_chat(M, "<b>Despite not being a member of the crew, by default you are <u>not</u> an antagonist. Cooperating with antagonists is allowed - within reason. Ask admins via adminhelp if you're not sure.</b>")

	if(req_admin_notify)
		to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")


/datum/job/trader/proc/notify_crew(mob/living/carbon/human/merchant)
	merchant.client.prefs.update_preview_icon(0) //This is necessary because if they don't check their character sheet it never generates!
	var/preview_front = fcopy_rsc(merchant.client.prefs.preview_icon_front)
	var/preview_side = fcopy_rsc(merchant.client.prefs.preview_icon_side)
	world << browse_rsc(preview_front, "previewicon.png")
	world << browse_rsc(preview_side, "previewicon2.png")
	var/full_text = {"<html><style>
					body {color: #000000; background: #ccffff;}
					h1 {color: #000000; font-size:30px;}
					fieldset {width:140px;}
					</style>
					<body>
					<center><img src="http://ss13.moe/wiki/images/1/17/NanoTrasen_Logo.png"> <h1>ATTN: Internal Affairs</h1></center>
					Nanotrasen\'s commercial arm has noted the presence of a registered merchant who holds a license for corporate commerce, a process which includes a background check and Nanotrasen loyalty implant. The associate\'s image is enclosed. Please continue to monitor trade on an ongoing basis such that Nanotrasen can maintain highest standard small business enterprise (SBE) partners.<BR>
					</body>
					<fieldset>
  					<legend>Picture</legend>
					<center><img src="previewicon.png" width="64" height="64"><img src="previewicon2.png" width="64" height="64"></center>
					</fieldset><BR>
					<body>Name: [merchant.client.prefs.real_name]<BR>
					Blood Type: [merchant.dna.b_type]<BR>
					Fingerprint: [md5(merchant.dna.uni_identity)]</body></html>"}

	SendFax(full_text, "Licensed Merchant Report - [merchant.client.prefs.real_name]", centcomm = 1) //Wow this is really cumbersome but [name] hasn't been assigned yet