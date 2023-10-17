#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
};

static const char g_IdleSound[][] = {
	"npc/combine_soldier/vo/prison_soldier_bunker1.wav",
	"npc/combine_soldier/vo/prison_soldier_bunker2.wav",
	"npc/combine_soldier/vo/prison_soldier_bunker3.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/prison_soldier_leader9dead.wav"
};

static const char g_RangedAttackSounds[][] = {
	"weapons/irifle/irifle_fire2.wav"
};

static const char g_RangedSpecialAttackSoundsSecondary[][] = {
	"npc/combine_soldier/vo/prison_soldier_fallback_b4.wav"
};

void RaidbossBladedance_MapStart()
{
	PrecacheModel("models/effects/combineball.mdl");
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));	i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedSpecialAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedSpecialAttackSoundsSecondary[i]);	}
}

methodmap RaidbossBladedance < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		int rand = GetRandomInt(0, sizeof(g_IdleSound) - 1);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayKilledEnemySound() 
	{
		int rand = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayRangedSpecialAttackSecondarySound(const float pos[3])
	{
		int numClients;
		int[] clients = new int[MaxClients];

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				static float pos2[3];
				GetClientEyePosition(i, pos2);
				if(GetVectorDistance(pos, pos2, true) < 2000000.0)
				{
					clients[numClients++] = i;
				}
			}
		}

		int rand = GetRandomInt(0, sizeof(g_RangedSpecialAttackSoundsSecondary) - 1);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
	}

	public RaidbossBladedance(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		RaidbossBladedance npc = view_as<RaidbossBladedance>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "1500000", ally, false));
		
		i_NpcInternalId[npc.index] = RAIDBOSS_BLADEDANCE;
		i_NpcWeight[npc.index] = 5;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");

		npc.SetActivity("ACT_CUSTOM_WALK_BOW");

		SDKHook(npc.index, SDKHook_Think, RaidbossBladedance_ClotThink);
		
		f_ExplodeDamageVulnerabilityNpc[npc.index] = 0.7;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		npc.m_bThisNpcIsABoss = true;
		npc.Anger = false;
		npc.m_flSpeed = 170.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		b_thisNpcIsARaid[npc.index] = true;

		npc.Anger = false;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flMeleeArmor = 1.25;
		
		Citizen_MiniBossSpawn();
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/spy/spy_party_phantom.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("forward", "models/workshop/player/items/all_class/fall17_jungle_wreath/fall17_jungle_wreath_spy.mdl");//"models/player/items/spy/spy_cardhat.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 55, 55, 255);

		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 55, 55, 255);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				LookAtTarget(client_check, npc.index);
		}
		
		RaidModeScaling = 9999999.99;
		RaidModeTime = GetGameTime() + 300.0;
		Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "??????????????????????????????????");

		RaidBossActive = EntIndexToEntRef(npc.index);
		Raidboss_Clean_Everyone();

		return npc;
	}
}

public void RaidbossBladedance_ClotThink(int iNPC)
{
	RaidbossBladedance npc = view_as<RaidbossBladedance>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	//Raidmode timer runs out, they lost.
	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(RaidBossActive != INVALID_ENT_REFERENCE)
		{
			int entity = CreateEntityByName("game_round_win"); 
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
		}

		SDKUnhook(npc.index, SDKHook_Think, RaidbossBladedance_ClotThink);
		NPC_StopPathing(npc.index);
		npc.m_flNextThinkTime = FAR_FUTURE;
	}

	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	//Think throttling
	if(npc.m_flNextThinkTime > gameTime)
		return;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.05;

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
	
	if(npc.m_flGetClosestTargetTime < gameTime || !IsEntityAlive(npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(npc.Anger)
	{
		if(--npc.m_iOverlordComboAttack < 1)
			npc.Anger = false;
	}
	else if(npc.m_iOverlordComboAttack > 99)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.Anger = true;
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSpecialAttackSecondarySound(vecTarget);
			npc.AddGesture("ACT_METROPOLICE_POINT");
			
			npc.m_flDoingAnimation = gameTime + 0.9;
			npc.m_flNextRangedAttackHappening = 0.0;
			npc.m_bisWalking = false;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;

			float pos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			ParticleEffectAt(pos, "utaunt_bubbles_glow_orange_parent", 0.5);

			int team = GetEntProp(npc.index, Prop_Send, "m_iTeamNum");
			int entity = -1;
			while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
			{
				if(entity != npc.index && !b_NpcHasDied[entity] && GetEntProp(entity, Prop_Send, "m_iTeamNum") != team)
				{
					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
					if(GetVectorDistance(pos, vecTarget, true) < 600000.0)	// 775 HU
					{
						f_GodArkantosBuff[entity] = GetGameTime() + 8.0;
						ParticleEffectAt(pos, "utaunt_bubbles_glow_orange_parent", 0.5);
					}
				}
			}
			
			return;
		}
	}

	if(npc.m_flNextRangedAttackHappening)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				npc.m_flNextRangedAttackHappening = 0.0;
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 400.0);
				npc.FireRocket(vPredictedPos, 500.0, 400.0, "models/effects/combineball.mdl");
				npc.PlayRangedSound();

				SeaSlider_AddNeuralDamage(npc.m_iTarget, npc.index, 100);
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < 160000 && npc.m_flNextRangedAttack < gameTime)
		{
			npc.m_iState = 1;
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_CUSTOM_WALK_BOW");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.SetActivity("ACT_IDLE_PISTOL");
					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
					npc.m_iChanged_WalkCycle = 5;

					npc.m_flNextRangedAttackHappening = gameTime + 0.4;

					npc.m_flDoingAnimation = gameTime + 0.7;
					npc.m_flNextRangedAttack = gameTime + 2.0;

					npc.m_bisWalking = false;
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
		}
	}

	npc.PlayIdleSound();
}

public Action RaidbossBladedance_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;

	RaidbossBladedance npc = view_as<RaidbossBladedance>(victim);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
		if(!npc.Anger)
			npc.m_iOverlordComboAttack++;
	}

	return Plugin_Changed;
}

public void RaidbossBladedance_NPCDeath(int entity)
{
	Waves_ClearWave();

	RaidbossBladedance npc = view_as<RaidbossBladedance>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(entity, SDKHook_Think, RaidbossBladedance_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}