#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/heavy_yell3.mp3",
	"vo/heavy_laughterbig01.mp3",
	"vo/heavy_laughterbig02.mp3",
	"vo/heavy_domination09.mp3"
};

static const char g_BoomSounds[][] =
{
	"mvm/mvm_tank_explode.wav"
};

static const char g_AngerSounds[][] =
{
	"vo/heavy_domination02.mp3",
	"vo/heavy_domination04.mp3",
	"vo/heavy_domination06.mp3",
	"vo/heavy_domination08.mp3",
	"vo/heavy_domination12.mp3",
	"vo/heavy_domination13.mp3",
	"vo/heavy_domination14.mp3",
	"vo/heavy_domination16.mp3"
};

void ThePurge_MapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_BoomSounds);
	PrecacheSoundArray(g_AngerSounds);

	PrecacheSound("weapons/family_business_shoot.wav");
	PrecacheSound("weapons/tf2_backshot_shotty.wav");
	PrecacheSound("mvm/giant_heavy/giant_heavy_gunfire.wav");
	PrecacheSound("mvm/giant_heavy/giant_heavy_gunwindup.wav");
	PrecacheSound("mvm/giant_heavy/giant_heavy_gunwinddown.wav");
	PrecacheSound("mvm/giant_soldier/giant_soldier_rocket_shoot.wav");
	PrecacheSound("mvm/giant_demoman/giant_demoman_grenade_shoot.wav");
	PrecacheSoundCustom("#zombiesurvival/internius/the_purge.mp3");
}

methodmap ThePurge < CClotBody
{
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayShotgunSound()
	{
		EmitSoundToAll("weapons/family_business_shoot.wav", this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySMGSound()
	{
		EmitSoundToAll("weapons/tf2_backshot_shotty.wav", this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMinigunSound()
	{
		if(i_TimesSummoned[this.index])
			return;
		
		i_TimesSummoned[this.index] = 1;
		EmitSoundToAll("mvm/giant_heavy/giant_heavy_gunfire.wav", this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void StopMinigunSound()
	{
		i_TimesSummoned[this.index] = 0;
		StopSound(this.index, SNDCHAN_STATIC, "mvm/giant_heavy/giant_heavy_gunfire.wav");
	}
	public void PlayMinigunStartSound()
	{
		EmitSoundToAll("mvm/giant_heavy/giant_heavy_gunwindup.wav", this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMinigunStopSound()
	{
		EmitSoundToAll("mvm/giant_heavy/giant_heavy_gunwinddown.wav", this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRocketSound()
	{
		EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGrenadeSound()
	{
		EmitSoundToAll("mvm/giant_demoman/giant_demoman_grenade_shoot.wav", this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound()
	{
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound]);
		EmitSoundToAll(g_AngerSounds[sound]);
	}

	property int m_iGunType
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property float m_flSwitchCooldown	// Delay between switching weapons
	{
		public get()			{	return this.m_flGrappleCooldown;	}
		public set(float value) 	{	this.m_flGrappleCooldown = value;	}
	}

	public void SetWeaponModel(const char[] model)
	{
		if(IsValidEntity(this.m_iWearable1))
			RemoveEntity(this.m_iWearable1);
		
		if(model[0])
			this.m_iWearable1 = this.EquipItem("head", model);
	}

	public ThePurge(int client, float vecPos[3], float vecAng[3], int team)
	{
		ThePurge npc = view_as<ThePurge>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "25000", team, false, true, true, true));
		
		i_NpcInternalId[npc.index] = RAIDBOSS_THE_PURGE;
		i_NpcWeight[npc.index] = 5;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.AddGesture("ACT_MP_CYOA_PDA_OUTRO");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		/*
			Cosmetics
		*/

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		
		SetVariantColor(view_as<int>({0, 0, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr17_wingman/spr17_wingman_heavy.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_war_pants/sbox2014_war_pants.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_helm.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_chest.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop_partner/player/items/heavy/dex_sarifarm/dex_sarifarm.mdl");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);

		/*
			Variables
		*/
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bDissapearOnDeath = true;
		npc.Anger = false;
		npc.m_flSpeed = 300.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.5;
		b_thisNpcIsARaid[npc.index] = true;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iGunType = 0;
		npc.m_flSwitchCooldown = GetGameTime(npc.index) + 2.0;
		i_TimesSummoned[npc.index] = 0;
		npc.m_flMeleeArmor = 1.5;

		EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0);
		EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0);

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "The Pruge Arrived");
			}
		}

		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1) * 0.19;
		
		float amount_of_people = float(CountPlayersOnRed());
		if(amount_of_people > 12.0)
			amount_of_people = 12.0;
		
		amount_of_people *= 0.12;
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		RaidModeScaling *= 0.85;

		Music_SetRaidMusic("#zombiesurvival/internius/the_purge.mp3", 229, true, 1.5);
		
		Citizen_MiniBossSpawn();
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	ThePurge npc = view_as<ThePurge>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	if(RaidBossActive != INVALID_ENT_REFERENCE && RaidModeTime < GetGameTime())
	{
		if(npc.m_iGunType != 11)
		{
			npc.PlayAngerSound();
			npc.PlayMinigunStartSound();
			npc.m_iGunType = 11;
			npc.m_flNextMeleeAttack = gameTime + 1.0;
			npc.m_flSwitchCooldown = FAR_FUTURE;
			npc.m_flSpeed = 370.0;
			npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
			npc.SetWeaponModel("models/workshop/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl");

			if(npc.Anger)
			{
				npc.m_flRangedArmor = 0.1;
				npc.m_flMeleeArmor = 0.15;
			}
			else
			{
				npc.m_flRangedArmor = 0.25;
				npc.m_flMeleeArmor = 0.375;
			}
		}
	}

	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	//Think throttling
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	//Set raid to this one incase the previous one has died or somehow vanished
	if(IsEntityAlive(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
	{
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
		}
	}
	else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)) || IsPartnerGivingUpSilvester(EntRefToEntIndex(RaidBossActive)))
	{	
		RaidBossActive = EntIndexToEntRef(npc.index);
	}
	
	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
	{
		i_Target[npc.index] = -1;
		npc.m_flAttackHappens = 0.0;
	}
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(target > 0)
	{
		float vecMe[3]; vecMe = WorldSpaceCenterOld(npc.index);
		float vecTarget[3]; vecTarget = WorldSpaceCenterOld(target);
		float distance = GetVectorDistance(vecTarget, vecMe, true);
		if(distance < npc.GetLeadRadius()) 
		{
			vecTarget = PredictSubjectPositionOld(npc, target);
			NPC_SetGoalVector(npc.index, vecTarget);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, target);
		}

		if(npc.m_flSwitchCooldown < gameTime)
		{
			float cooldown = 10.0;

			switch(npc.m_iGunType)
			{
				case 0, 3, 6:	// Fists/Minigun/Rockets -> Shotgun
				{
					npc.StopMinigunSound();
					if(npc.m_iGunType == 3)
						npc.PlayMinigunStopSound();
					
					npc.m_iGunType++;
					npc.SetWeaponModel("models/workshop/weapons/c_models/c_russian_riot/c_russian_riot.mdl");
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_flSpeed = 300.0;
					cooldown = 8.0;

					npc.m_flRangedArmor = 1.0;
					npc.m_flMeleeArmor = 1.5;
				}
				case 1, 4, 7:	// Shotgun -> SMG
				{
					npc.m_iGunType++;
					npc.SetWeaponModel("models/workshop/weapons/c_models/c_trenchgun/c_trenchgun.mdl");
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_flSpeed = 300.0;
					cooldown = 8.0;

					npc.m_flRangedArmor = 1.0;
					npc.m_flMeleeArmor = 1.5;
				}
				case 2:	// SMG/Healing -> Minigun
				{
					npc.m_iGunType = 3;
					npc.SetWeaponModel("models/workshop/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl");
					npc.SetActivity("ACT_MP_CROUCH_DEPLOYED_IDLE");
					npc.m_flNextMeleeAttack = gameTime + (npc.Anger ? 0.5 : 1.0);
					npc.m_flSpeed = 50.0;
					cooldown = 6.0;

					npc.m_flRangedArmor = 0.5;
					npc.m_flMeleeArmor = 0.75;

					npc.PlayMinigunStartSound();
				}
				case 5:	// SMG -> Rockets
				{
					npc.m_iGunType = 6;
					npc.SetWeaponModel("");
					npc.SetActivity("taunt_burstchester_heavy", true);
					npc.m_flNextMeleeAttack = gameTime + (npc.Anger ? 1.65 : 3.25);
					npc.m_flSpeed = 1.0;
					cooldown = 5.3;

					if(npc.Anger)
						npc.SetPlaybackRate(0.5);

					npc.m_flRangedArmor = 0.25;
					npc.m_flMeleeArmor = 0.375;

					npc.PlayMinigunStopSound();
				}
				case 8:	// SMG -> Grenade
				{
					npc.m_iGunType = 9;
					npc.SetWeaponModel("models/workshop/weapons/c_models/c_quadball/c_quadball.mdl");
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_flSpeed = 250.0;
					cooldown = 10.0;

					npc.m_flRangedArmor = 1.0;
					npc.m_flMeleeArmor = 1.5;
				}
				case 9:	// Grenade -> Fists
				{
					npc.PlayBoomSound();
					TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, npc.index, _, _, _, _, _, _, _, _, _, 0.0);

					npc.m_iGunType = 0;
					npc.SetWeaponModel("");
					npc.SetActivity("ACT_MP_RUN_MELEE");
					cooldown = 3.0;

					npc.m_flRangedArmor = 1.5;
					npc.m_flMeleeArmor = 2.25;
				}
				case 10:	// Healing -> Fists
				{
					npc.m_iGunType = 0;
					npc.SetWeaponModel("");
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.m_flSpeed = 400.0;
					cooldown = 5.0;
				}
			}

			if(npc.Anger)
				cooldown *= 0.5;

			npc.m_flSwitchCooldown = gameTime + cooldown;
		}
		
		switch(npc.m_iGunType)
		{
			case 0:	// Fists
			{
				RaidModeScaling *= 1.00005;
				npc.StartPathing();
			}
			case 1, 4, 7:	// Shotgun
			{
				npc.StartPathing();

				if(distance < 160000.0 && npc.m_flNextMeleeAttack < gameTime)	// 400 HU
				{
					if(Can_I_See_Enemy(npc.index, target) == target)
					{
						KillFeed_SetKillIcon(npc.index, "family_business");
						
						npc.FaceTowards(vecTarget, 400.0);

						npc.PlayShotgunSound();
						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");

						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						float vecDirShooting[3], vecRight[3], vecUp[3];

						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];

						float damage = RaidModeScaling * 0.1;

						for(int i; i < 10; i++)
						{
							float x = GetRandomFloat(-0.1, 0.1);
							float y = GetRandomFloat(-0.1, 0.1);
							
							vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							
							FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 3000.0, DMG_BULLET, "bullet_tracer01_red");
						}

						npc.m_flNextMeleeAttack = gameTime + 0.4;

						KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
					}
				}
			}
			case 2, 5, 8:	// SMG
			{
				npc.StartPathing();

				if(distance < 360000.0 && npc.m_flNextMeleeAttack < gameTime)	// 600 HU
				{
					if(Can_I_See_Enemy(npc.index, target) == target)
					{
						KillFeed_SetKillIcon(npc.index, "panic_attack");
						
						npc.PlaySMGSound();
						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");

						float eyePitch[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
						float vecDirShooting[3], vecRight[3], vecUp[3];

						vecTarget[2] += 15.0;
						MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
						GetVectorAngles(vecDirShooting, vecDirShooting);
						vecDirShooting[1] = eyePitch[1];
						GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
						
						float vecDir[3];

						float damage = RaidModeScaling * 0.1;

						for(int i; i < 2; i++)
						{
							float x = GetRandomFloat(-0.05, 0.05);
							float y = GetRandomFloat(-0.05, 0.05);
							
							vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
							vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
							vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
							NormalizeVector(vecDir, vecDir);
							
							FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 3000.0, DMG_BULLET, "bullet_tracer01_red");
						}

						npc.m_flNextMeleeAttack = gameTime + 0.05;

						KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
					}
				}
			}
			case 3:	// Minigun
			{
				npc.StopPathing();

				if(npc.m_flNextMeleeAttack < gameTime)
				{
					KillFeed_SetKillIcon(npc.index, "minigun");
					
					npc.FaceTowards(vecTarget, 4000.0);
					
					npc.PlayMinigunSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");

					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					float vecDirShooting[3], vecRight[3], vecUp[3];

					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					float vecDir[3];

					float damage = RaidModeScaling * 0.025;
					
					npc.m_flSpeed -= 1.0;
					if(npc.m_flSpeed < 0.0)
						npc.m_flSpeed = 0.0;
					
					// Scale up damage with longer time
					damage *= 6.0 - (npc.m_flSpeed / 10.0);

					for(int i; i < 3; i++)
					{
						float x = GetRandomFloat(-0.15, 0.15);
						float y = GetRandomFloat(-0.15, 0.15);
						
						vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
						vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
						vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
						NormalizeVector(vecDir, vecDir);
						
						FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 3000.0, DMG_BULLET, "bullet_tracer01_red");
					}

					npc.m_flNextMeleeAttack = gameTime + 0.05;

					KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
				}
			}
			case 6:	// Rocket
			{
				npc.StopPathing();

				if(npc.m_flNextMeleeAttack < gameTime)
				{
					npc.PlayRocketSound();
					
					int enemy[4];
					GetHighDefTargets(view_as<UnderTides>(npc), enemy, sizeof(enemy));
					for(int i; (i < sizeof(enemy)) && enemy[i]; i++)
					{
						if(GetURandomInt() % 2)
						{
							vecTarget = PredictSubjectPositionForProjectilesOld(npc, target, 900.0);
						}
						else
						{
							GetWorldSpaceCenter(target, vecTarget);
						}

						npc.FireRocket(vecTarget, RaidModeScaling, 900.0);
					}

					npc.m_flNextMeleeAttack = gameTime + 0.05;
				}
			}
			case 9:	// Grenade
			{
				npc.StartPathing();

				if(npc.m_flNextMeleeAttack < gameTime)
				{
					if(Can_I_See_Enemy(npc.index, target) == target)
					{
						KillFeed_SetKillIcon(npc.index, "iron_bomber");
						
						npc.PlayGrenadeSound();
						npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");

						vecTarget = PredictSubjectPositionForProjectilesOld(npc, target, 1000.0);
						npc.FireGrenade(vecTarget, 1000.0, RaidModeScaling, "models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl");

						npc.m_flNextMeleeAttack = gameTime + 0.45;
					}
				}
			}
			case 10:	// Healing
			{
				npc.StopPathing();
				npc.SetActivity("taunt_cheers_heavy", true);
			}
			case 11:	// Minigun
			{
				npc.StopPathing();

				if(npc.m_flNextMeleeAttack < gameTime)
				{
					KillFeed_SetKillIcon(npc.index, "minigun");
					
					npc.FaceTowards(vecTarget, 8000.0);
					
					npc.PlayMinigunSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");

					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					float vecDirShooting[3], vecRight[3], vecUp[3];

					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					float vecDir[3];

					float damage = RaidModeScaling * 0.3;

					for(int i; i < 3; i++)
					{
						float x = GetRandomFloat(-0.15, 0.15);
						float y = GetRandomFloat(-0.15, 0.15);
						
						vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
						vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
						vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
						NormalizeVector(vecDir, vecDir);
						
						FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 3000.0, DMG_BULLET, "bullet_tracer01_red");
					}

					npc.m_flNextMeleeAttack = gameTime + 0.05;

					KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
				}
			}
		}
	}
	else
	{
		npc.StopPathing();

		npc.SetActivity("taunt02", true);
		npc.SetPlaybackRate(0.5);
		npc.SetWeaponModel("models/workshop/weapons/c_models/c_russian_riot/c_russian_riot.mdl");
		npc.m_iGunType = 1;
	}
}

static void ClotDeathStartThink(int iNPC)
{
	ThePurge npc = view_as<ThePurge>(iNPC);
	
	npc.SetActivity("taunt_mourning_mercs_heavy", true);
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 2.5;
	func_NPCThink[npc.index] = ClotDeathLoopThink;
	ClotDeathLoopThink(npc.index);
}

static void ClotDeathLoopThink(int iNPC)
{
	ThePurge npc = view_as<ThePurge>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	float vecMe[3]; vecMe = WorldSpaceCenterOld(npc.index);
	
	npc.PlayBoomSound();
	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

	npc.m_bDissapearOnDeath = false;
	SmiteNpcToDeath(npc.index);
}

static Action ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage)
{
	if(attacker > 0)
	{
		ThePurge npc = view_as<ThePurge>(victim);
		
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

		if(damage >= health)
		{
			npc.StopMinigunSound();

			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			RaidBossActive = INVALID_ENT_REFERENCE;

			GiveProgressDelay(3.0);
			func_NPCThink[npc.index] = ClotDeathStartThink;

			npc.PlayDeathSound();

			damage = 0.0;
			return Plugin_Handled;
		}

		if(!npc.Anger && health < (GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 4))
		{
			npc.Anger = true;
			npc.PlayAngerSound();
			npc.StopMinigunSound();
			npc.SetWeaponModel("");
			npc.m_flSwitchCooldown = GetGameTime(npc.index) + 3.0;
			npc.m_iGunType = 10;

			if(RaidModeTime < GetGameTime())
				RaidModeTime = GetGameTime();
			
			RaidModeTime += 61.0;

			npc.m_flRangedArmor = 0.25;
			npc.m_flMeleeArmor = 0.375;

			HealEntityGlobal(npc.index, npc.index, GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 8.0, _, 3.0, HEAL_ABSOLUTE);
			HealEntityGlobal(npc.index, npc.index, GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 16.0, _, 13.0, HEAL_ABSOLUTE);
			HealEntityGlobal(npc.index, npc.index, GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 16.0, _, 13.0, HEAL_SELFHEAL|HEAL_SILENCEABLE);
		}
	}
	return Plugin_Changed;
}

static void ClotDeath(int entity)
{
	ThePurge npc = view_as<ThePurge>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	
	Citizen_MiniBossDeath(entity);
}