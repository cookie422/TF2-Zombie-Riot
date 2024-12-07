#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/scout_paincrticialdeath01.mp3",
	"vo/scout_paincrticialdeath02.mp3",
	"vo/scout_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/scout_taunts02.mp3",
	"vo/taunts/scout_taunts03.mp3",
	"vo/taunts/scout_taunts06.mp3",
	"vo/taunts/scout_taunts07.mp3",
	"vo/taunts/scout_taunts15.mp3",
	"vo/taunts/scout_taunts17.mp3",
	"vo/scout_domination07.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"player/taunt_yeti_standee_demo_swing.wav",
	"player/taunt_yeti_standee_engineer_kick.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/revolver_shoot.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};
static int i_Grab_Twin_ID;
static int i_Got_My_Twin[MAXENTITIES];
void Twin1_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	PrecacheModel("models/player/scout.mdl");
	PrecacheSoundCustom("#zombiesurvival/matrix/doubletrouble.mp3");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Twin No.");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_twins");
	strcopy(data.Icon, sizeof(data.Icon), "matrix_twin");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Matrix;
	data.Func = ClotSummon;
	i_Grab_Twin_ID = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Matrix_Twins(client, vecPos, vecAng, ally, data);
}
methodmap Matrix_Twins < CClotBody
{
	property bool b_Twin_On
	{
		public get()							{ return b_XenoInfectedSpecialHurt[this.index]; }
		public set(bool TempValueForProperty) 	{ b_XenoInfectedSpecialHurt[this.index] = TempValueForProperty; }
	}
	property float fl_Healing_Notifier
	{
		public get()							{ return fl_Charge_Duration[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_Duration[this.index] = TempValueForProperty; }
	}
	property float fl_Heal_Limit
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float fl_Heal_Amount
	{
		public get()							{ return fl_AngerDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AngerDelay[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
	}
	
	public Matrix_Twins(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Matrix_Twins npc = view_as<Matrix_Twins>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.0", "700", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		b_NameNoTranslation[npc.index] = true;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 12;

		npc.m_fbGunout = false;
		npc.m_bmovedelay = false;
		npc.b_Twin_On = false;
		npc.m_bThisNpcIsABoss = true;
		npc.fl_Healing_Notifier = 0.0;
		npc.fl_Heal_Amount = 0.0;
		npc.fl_Heal_Limit = 0.0;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = Matrix_Twins_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Matrix_Twins_OnTakeDamage;
		func_NPCThink[npc.index] = Matrix_Twins_ClotThink;
		//i_Got_My_Twin[npc.index] = 0;
		bool raid = StrContains(data, "Im_The_raid") != -1;
		if(raid)
		{
			RaidPrepare(npc);
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/matrix/doubletrouble.mp3");
			music.Time = 114;
			music.Volume = 1.1;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Double Trouble");
			strcopy(music.Artist, sizeof(music.Artist), "Don Davis");
			Music_SetRaidMusic(music);
		}
		bool spawn_twin = StrContains(data, "My_Twin") != -1;
		if(spawn_twin)
		{
			RequestFrame(Spawn_My_Brother, npc);
		}
		bool twin = StrContains(data, "Im_The_Twin") != -1;
		if(twin)
		{
			npc.b_Twin_On = true;
			b_thisNpcIsARaid[npc.index] = true;
		}
		
		bool whatami = (!twin && !spawn_twin);
		int number =  twin ? 2 : whatami ? GetURandomInt() : 1;

		if(whatami)
		{
			CPrintToChatAll("{forestgreen}%s{default}: What am I supposed to be.", "Twin No. ");
		}
		
		FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "%s %i", "Twin No.", number);
		
		Matrix_Twins_Reset_Healing(npc, GetGameTime(npc.index));

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flSpeed = 310.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador_xmas.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/scout/scout_hair.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/jul13_sweet_shades_s1/jul13_sweet_shades_s1_scout.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/xms2013_jacket/xms2013_jacket_scout.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 255);
		AcceptEntityInput(npc.m_iWearable1, "Disable");

		Citizen_MiniBossSpawn();
		npc.StartPathing();
		
		return npc;
	}
}

public void Matrix_Twins_ClotThink(int iNPC)
{
	Matrix_Twins npc = view_as<Matrix_Twins>(iNPC);

	float gameTime = GetGameTime(npc.index);
	int twin = EntRefToEntIndex(i_Got_My_Twin[npc.index]);
	bool Twin_Alive = IsEntityAlive(twin);

	if(RaidModeTime < GetGameTime())
	{
		if(IsValidEntity(RaidBossActive))
		{
			if(RaidBossActive == EntIndexToEntRef(npc.index))
			{
				ForcePlayerLoss();
				npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");
				RaidBossActive = INVALID_ENT_REFERENCE;
				func_NPCThink[npc.index] = INVALID_FUNCTION;
				if(Twin_Alive)
				{
					func_NPCThink[twin] = INVALID_FUNCTION;
				}
			}
			else
			{
				func_NPCThink[npc.index] = INVALID_FUNCTION;
			}
			
			return;
		}
	}

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	if(!npc.b_Twin_On)
	{
		if(Twin_Alive)
		{
			for(int client; client <= MaxClients; client++)
			{
				if(IsValidClient(client)) //Add to hud as a duo raid.
				{
					Calculate_And_Display_hp(client, twin, 0.0, false);	
				}
			}
		}
	}
	else
	{
		if(!Twin_Alive)
		{
			if(!IsEntityAlive(EntRefToEntIndex(RaidBossActive)))
			{
				RaidBossActive = EntIndexToEntRef(npc.index);
			}
		}
		else
		{
			if(Twin_Alive)
			{
				for(int client; client <= MaxClients; client++)
				{
					if(IsValidClient(client)) //Add to hud as a duo raid.
					{
						Calculate_And_Display_hp(client, twin, 0.0, false);	
					}
				}
			}
		}
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		npc.StartPathing();
	}

	if(npc.m_flDead_Ringer_Invis < gameTime)
	{
		if(npc.m_flDead_Ringer_Invis_bool)
		{
			Matrix_Twins_Reset_Healing(npc, gameTime);
		}
		else
		{
			if(npc.fl_Healing_Notifier)
			{
				if(npc.fl_Healing_Notifier <= gameTime)
				{
					npc.fl_Healing_Notifier = 0.0;
					Matrix_Twins_healspeak(npc);
				}
			}

			Matrix_Twins_Apply_Healing(npc, gameTime);
		}
	}

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
		npc.StartPathing();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}

		Matrix_Twins_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void Matrix_Twins_SelfDefense(Matrix_Twins npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_bmovedelay)
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bmovedelay = false;
			npc.m_iChanged_WalkCycle = 4;
			npc.m_bisWalking = true;
			npc.m_bPathing = true;
			npc.m_flSpeed = 310.0;
			int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			AcceptEntityInput(npc.m_iWearable1, "Disable");
		}
	}
	
	if(npc.m_flAttackHappens)
	{
		if (npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			Handle swingTrace;
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

			npc.FaceTowards(vecTarget, 20000.0);
			if(npc.DoSwingTrace(swingTrace, target))
			{
				target = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(IsValidEnemy(npc.index, target))
				{
					float damage = 10.0;
					damage *= RaidModeScaling;
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
					}
					/*else
					{
						npc.PlayMeleeMissSound();
					}*/
				}
			}
			delete swingTrace;
		}
	}

	if(npc.m_flNextRangedSpecialAttack)
	{
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_flNextRangedSpecialAttack = 0.0;
			
			if(npc.m_iTarget > 0)
			{
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
				npc.FaceTowards(vecTarget, 15000.0);
				
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_iChanged_WalkCycle = 3;
					npc.m_bisWalking = false;
					npc.m_bPathing = false;
					npc.m_flSpeed = 0.0;
					int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					AcceptEntityInput(npc.m_iWearable1, "Enable");
				}
				// Can dodge bullets by moving
				PredictSubjectPositionForProjectiles(npc, target, 400.0, _, vecTarget);
				
				float eyePitch[3], vecDirShooting[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				npc.FaceTowards(vecTarget, 10000.0);
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);

				vecDirShooting[1] = eyePitch[1];

				npc.m_flNextRangedAttack = gameTime + 0.5;
				npc.m_iAttacksTillReload--;
				
				float x = GetRandomFloat( -0.15, 0.15 );
				float y = GetRandomFloat( -0.15, 0.15 );
				
				float vecRight[3], vecUp[3];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float vecDir[3];
				for(int i; i < 3; i++)
				{
					vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
				}

				NormalizeVector(vecDir, vecDir);
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				KillFeed_SetKillIcon(npc.index, "enforcer");

				float damage = 12.0;
				damage *= RaidModeScaling;

				FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 9000.0, DMG_BULLET, "bullet_tracer01_red");
				
				npc.PlayRangedSound();
				if(npc.m_iAttacksTillReload < 1)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.m_flReloadDelay = gameTime + 3.4;
					npc.m_iAttacksTillReload = 12;
					npc.PlayRangedReloadSound();
					int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
					npc.m_bmovedelay = true;
					AcceptEntityInput(npc.m_iWearable1, "Disable");
				}
			}
		}
		return;
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.85))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");//He will SMACK you with this
				npc.m_flAttackHappens = gameTime + 0.3;
				float attack = 1.0;
				npc.m_flNextMeleeAttack = gameTime + attack;
			}
		}
	}
	if(gameTime > npc.m_flNextRangedAttack && gameTime > npc.m_flReloadDelay)
	{
		if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.85) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");//ACT_MP_ATTACK_STAND_ITEM1 | ACT_MP_ATTACK_STAND_MELEE_ALLCLASS
						
				npc.m_flNextRangedSpecialAttack = gameTime + 0.15;
				npc.m_flNextRangedAttack = gameTime + 1.85;
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 6)
			{
				npc.m_iChanged_WalkCycle = 6;
				npc.m_bisWalking = true;
				npc.m_bPathing = true;
				npc.m_flSpeed = 310.0;
			}
		}
	}
}

public Action Matrix_Twins_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Matrix_Twins npc = view_as<Matrix_Twins>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	float gameTime = GetGameTime();
		
	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(npc.m_flDead_Ringer_Invis >= gameTime && !npc.m_flDead_Ringer_Invis_bool)
	{
		float healing = damage;
		healing *= npc.b_Twin_On ? 0.4 : 0.5;
		npc.fl_Heal_Amount += healing;
	}

	return Plugin_Changed;
}

static void Matrix_Twins_Apply_Healing(Matrix_Twins npc, float gameTime)
{
	npc.m_flDead_Ringer_Invis = gameTime + 1.0;
	npc.m_flDead_Ringer_Invis_bool = true;
	float Maxhealth = float(ReturnEntityMaxHealth(npc.index));
	float reduction = npc.b_Twin_On ? 0.35 : 0.45;
	float healingamt = (Maxhealth * reduction);
	float minimum = (Maxhealth * 0.1);
	
	if(npc.fl_Heal_Amount >= healingamt)
	{
		npc.fl_Heal_Amount = healingamt;
	}

	if(npc.fl_Heal_Amount <= minimum)
	{
		npc.fl_Heal_Amount = minimum;
	}
	//PrintToChatAll("%f", npc.fl_Heal_Amount);
	HealEntityGlobal(npc.index, npc.index, npc.fl_Heal_Amount, 1.0, _, HEAL_SELFHEAL);
	float ProjLoc[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
	float ProjLocBase[3];
	ProjLocBase = ProjLoc;
	ProjLocBase[2] += 5.0;
	ProjLoc[2] += 70.0;
	ProjLoc[0] += GetRandomFloat(-40.0, 40.0);
	ProjLoc[1] += GetRandomFloat(-40.0, 40.0);
	ProjLoc[2] += GetRandomFloat(-15.0, 15.0);
	TE_Particle("healthgained_blu", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	EmitSoundToAll("misc/halloween/spell_overheal.wav", _, _, _, _, 1.0, 100);
}

static void Matrix_Twins_healspeak(Matrix_Twins npc)
{
	CPrintToChatAll("{forestgreen}%s{default}: %s", c_NpcName[npc.index], npc.b_Twin_On ? "My Healing Glasses are now Ready." : "My Self Regeneration is now Ready.");
}

static void Matrix_Twins_Reset_Healing(Matrix_Twins npc, float gameTime)
{	
	float time = npc.b_Twin_On ? 30.0 : 25.0;
	npc.fl_Heal_Amount = 0.0;
	npc.m_flDead_Ringer_Invis_bool = false;
	npc.m_flDead_Ringer_Invis = gameTime + time;
	npc.fl_Healing_Notifier = gameTime + (time-0.5);
}

public void Matrix_Twins_NPCDeath(int entity)
{
	Matrix_Twins npc = view_as<Matrix_Twins>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	int twin = EntRefToEntIndex(i_Got_My_Twin[npc.index]);
	if(IsValidEntity(twin))
	{
		i_Got_My_Twin[EntRefToEntIndex(i_Got_My_Twin[npc.index])] = 0;
	}
	i_Got_My_Twin[npc.index] = 0;

	if(RaidBossActive == EntIndexToEntRef(npc.index))
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
		{
			RemoveHudCooldown(EnemyLoop);
			Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
		}						
	}
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

static void RaidPrepare(Matrix_Twins npc)
{
	EmitSoundToAll("weapons/physgun_off.wav", _, _, _, _, 1.0);	
	EmitSoundToAll("weapons/physgun_off.wav", _, _, _, _, 1.0);	

	for(int client_check=1; client_check<=MaxClients; client_check++)
	{
		if(IsClientInGame(client_check) && !IsFakeClient(client_check))
		{
			LookAtTarget(client_check, npc.index);
			SetGlobalTransTarget(client_check);
			ShowGameText(client_check, "item_armor", 1, "%s", "The Twins have arrived");
		}
	}

	RaidBossActive = EntIndexToEntRef(npc.index);
	RaidAllowsBuildings = false;
	RaidModeTime = GetGameTime(npc.index) + 200.0;
	
	b_thisNpcIsARaid[npc.index] = true;
	npc.m_flMeleeArmor = 1.25;

	RaidModeScaling = float(ZR_GetWaveCount()+1);
	if(RaidModeScaling < 55)
	{
		RaidModeScaling *= 0.19; //abit low, inreacing
	}
	else
	{
		RaidModeScaling *= 0.38;
	}
	
	float amount_of_people = float(CountPlayersOnRed());
	if(amount_of_people > 12.0)
	{
		amount_of_people = 12.0;
	}
	amount_of_people *= 0.12;
	
	if(amount_of_people < 1.0)
		amount_of_people = 1.0;

	RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
	
	if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
	{
		RaidModeScaling *= 0.85;
	}
	else if(ZR_GetWaveCount()+1 > 55)
	{
		RaidModeTime = GetGameTime(npc.index) + 220.0;
		RaidModeScaling *= 0.85;
	}
}

static void Spawn_My_Brother(Matrix_Twins npc)
{
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	int maxhealth = ReturnEntityMaxHealth(npc.index);

	int spawn_index = NPC_CreateById(i_Grab_Twin_ID, -1, pos, ang, GetTeam(npc.index), "Im_The_Twin");
	if(spawn_index > MaxClients)
	{
		i_RaidGrantExtra[spawn_index] = i_RaidGrantExtra[npc.index];
		if(i_RaidGrantExtra[spawn_index] == 1)
		{
			b_NpcUnableToDie[spawn_index] = true;
		}
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		i_Got_My_Twin[npc.index] = EntIndexToEntRef(spawn_index);
		i_Got_My_Twin[spawn_index] = EntIndexToEntRef(npc.index);
		fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
		fl_Extra_Speed[spawn_index] = fl_Extra_Damage[npc.index];
		b_ThisNpcIsImmuneToNuke[spawn_index] = b_ThisNpcIsImmuneToNuke[npc.index];
		b_thisNpcHasAnOutline[spawn_index] = b_thisNpcHasAnOutline[npc.index];
		fl_MeleeArmor[spawn_index] = npc.m_flMeleeArmor;
		fl_RangedArmor[spawn_index] = npc.m_flRangedArmor;
	}
}