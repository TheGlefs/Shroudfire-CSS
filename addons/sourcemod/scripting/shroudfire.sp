#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>
#undef REQUIRE_EXTENSIONS
#include <connect>
#define REQUIRE_EXTENSIONS
#include <cstrike>
#include <clientprefs>
#undef REQUIRE_PLUGIN
#include <basecomm>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.0"
#define CHAT_PREFIX "\x077BC47F[Shroudfire]\x01"
#define XP_DATABASE_NAME "shroudfire"
#define MAX_PLAYER_LEVEL 40
#define MAX_UPGRADE_STAGE 5
#define UPGRADES_PER_ROLE 8
#define LIGHTWEIGHT_GRAVITY_REDUCTION_PER_STAGE (g_CvarLightweightGravityPercent.FloatValue / 100.0)
#define MOMENTUM_SPEED_INCREASE_PER_STAGE (g_CvarMomentumRunPercent.FloatValue / 100.0)
#define INVISANT_KNIFE_BASE_SPEED 250.0
#define INVISANT_MAX_MOMENTUM_SPEED 300.0
#define INVISANT_SURGE_BASE_SPEED (g_CvarSurgeBaseSpeed.FloatValue - g_CvarSurgeSpeedPerStage.FloatValue)
#define SURGE_SPEED_BOOST_PER_STAGE g_CvarSurgeSpeedPerStage.FloatValue
#define INVISANT_SURGE_COOLDOWN g_CvarSurgeCooldown.FloatValue
#define INVISANT_SURGE_CLEARANCE_DISTANCE 32.0
#define INVISANT_HEADSHOT_DAMAGE_SCALE 0.50
#define INVISANT_HEADSHOT_MAX_DAMAGE 90.0
#define INVISANT_CLAW_REACH 72.0
#define INVISANT_CLAW_TRACE_HALF_SIZE 10.0
#define INVISANT_CLAW_CONE_YAW 12.0
#define INVISANT_CLAW_CONE_PITCH 10.0
#define INVISANT_CLAW_ATTACK_SPEED_MULTIPLIER (g_CvarKnifeAttackSpeedPercent.FloatValue / 100.0)
#define INVISANT_CLAW_ANIMATION_SPEED_MULTIPLIER 1.5
#define MAP_JOIN_RESPAWN_SETTLE_SECONDS 2.0
#define INVISANT_BASE_ARMOR g_CvarInvisantBaseArmor.IntValue
#define RESILIENCE_ARMOR_PER_STAGE g_CvarResilienceArmorPerStage.IntValue
#define VAMPIRISM_HEALTH_PER_STAGE g_CvarVampirismHealthPerStage.IntValue
#define BLOODLUST_HEALTH_PER_STAGE g_CvarBloodlustHealthPerStage.IntValue
#define FORTITUDE_HEALTH_PER_STAGE g_CvarFortitudeHealthPerStage.IntValue
#define OVERLOAD_INCREASE_PER_STAGE (g_CvarOverloadMagazinePercent.FloatValue / 100.0)
#define BARRAGE_FIRE_RATE_INCREASE_PER_STAGE (g_CvarBarrageFireRatePercent.FloatValue / 100.0)
#define DEXTERITY_SPEED_INCREASE_PER_STAGE (g_CvarDexteritySpeedPercent.FloatValue / 100.0)
#define CONTROL_REDUCTION_PER_STAGE (g_CvarControlReductionPercent.FloatValue / 100.0)
#define INVISANT_CROUCH_SPEED_FACTOR 0.34
#define MOBILITY_CROUCH_PENALTY_REDUCTION_PER_STAGE 0.09
#define ARMITIVE_WARD_BASE_DURATION (g_CvarWardBaseSeconds.FloatValue - g_CvarWardSecondsPerStage.FloatValue)
#define ARMITIVE_WARD_DURATION_PER_STAGE g_CvarWardSecondsPerStage.FloatValue
#define ARMITIVE_WARD_COOLDOWN g_CvarWardCooldown.FloatValue
#define ARMITIVE_WARD_FADE_DURATION 128
#define ARMITIVE_WARD_TINT_RED 32
#define ARMITIVE_WARD_TINT_GREEN 96
#define ARMITIVE_WARD_TINT_BLUE 255
#define ARMITIVE_WARD_TINT_ALPHA g_CvarWardScreenTint.IntValue
#define STOCKPILE_TICK_INTERVAL 2.0
#define REFORGING_TICK_INTERVAL g_CvarReforgingInterval.FloatValue
#define RECOVERY_TICK_INTERVAL g_CvarRecoveryInterval.FloatValue
#define CHEATING_HINT_COOLDOWN 30.0
#define BUY_TIME_SECONDS 20.0
// CS:S truncates mp_buytime * 60 when formatting its denial message.
#define BUY_TIME_CVAR_MINUTES 0.334
#define OBS_MODE_DEATHCAM 1
#define OBS_MODE_FREEZECAM 2
#define OBS_MODE_FIXED 3
#define OBS_MODE_IN_EYE 4
#define OBS_MODE_ROAMING 6
#define EF_DIMLIGHT (1 << 2)
#define COLLISION_GROUP_PLAYER 5
#define BLOOD_COLOR_RED 0
#define HITGROUP_HEAD 1
#define ENTITY_RESERVE 128
#define QUEUE_HEARTBEAT_INTERVAL 30
#define WALLHACK_BEAM_SPRITE "materials/sprites/lgtning_noz.vmt"
#define ARMITIVE_WARD_HALO_SPRITE "sprites/blueglow2.vmt"
#define INVISANT_SCREEN_LUT "materials/correction/shroudfire_red.raw"
#define WALLHACK_BEAM_START_FORWARD_OFFSET 24.0
#define WALLHACK_BEAM_START_VERTICAL_OFFSET 16.0
#define WALLHACK_BEAM_START_WIDTH 1.0
#define WALLHACK_BEAM_END_WIDTH 2.0
#define WALLHACK_BEAM_LIFETIME 0.1
#define ARMITIVE_WARD_HALO_REFRESH_INTERVAL 0.10
#define ARMITIVE_WARD_HALO_LIFETIME 0.15
#define ARMITIVE_WARD_HALO_SCALE 0.65
#define ARMITIVE_WARD_HALO_BRIGHTNESS 55
#define ARMITIVE_WARD_RING_WIDTH 2.0
#define TEAM_MENU_CLOSE_INTERVAL 0.1
#define BLOOD_SPRAY_SPRITE "sprites/bloodspray.vmt"
#define BLOOD_DROP_SPRITE "sprites/blood.vmt"
#define AFK_WARNING_SOUND "buttons/blip1.wav"
#define INVISANT_SURGE_SOUND "npc/fast_zombie/leap1.wav"
#define INVISANT_SURGE_COOLDOWN_SOUND "npc/fast_zombie/idle1.wav"
#define INVISANT_SURGE_READY_SOUND "npc/fast_zombie/wake1.wav"
#define INVISANT_SURGE_BLOCKED_SOUND "physics/concrete/concrete_impact_soft1.wav"
#define INVISANT_CLAW_HIT_SOUND "npc/zombie/claw_strike3.wav"
#define INVISANT_ROUND_WIN_SOUND VOICE_FILES[VOICE_START[Voice_InvisantWin]]
#define ARMITIVE_ROUND_WIN_SOUND VOICE_FILES[VOICE_START[Voice_ArmitiveWin]]
#define ARMITIVE_WARD_ACTIVATE_SOUND "items/suitchargeok1.wav"
#define ARMITIVE_WARD_END_SOUND "items/suitchargeno1.wav"
#define ARMITIVE_WARD_COOLDOWN_SOUND "buttons/blip1.wav"
#define ARMITIVE_WARD_READY_SOUND "items/battery_pickup.wav"
#define INVISANT_CLAW_VIEW_MODEL "models/shroudfire/claws/v_invisant_claws.mdl"
#define INVISANT_PLAYER_MODEL "models/shroudfire/player/zombie_v2.mdl"
#define INVISANT_KNIFE_PREDICTION_LOCK_DURATION 3600.0
#define INVISANT_CLAW_SEQUENCE_IDLE 0
#define INVISANT_CLAW_SEQUENCE_STAB_HIT 2
#define INVISANT_CLAW_SEQUENCE_STAB_MISS 3
#define MAX_SPAWN_POSITIONS 256
#define MAX_EXTRA_SPAWNS (MAXPLAYERS * 2)
#define MAX_TONEMAP_SNAPSHOTS 32
#define MAX_TRACKED_EDICTS 2049
#define MAX_TRACKED_AMMO_TYPES 64
#define HUD_SPAWN_DURATION g_CvarRoundInfoSeconds.FloatValue
#define KILL_STREAK_STAGE_COUNT 10
#define FORCED_END_NONE 0
#define FORCED_END_ABORT 1
#define FORCED_END_COMPLETE 2
#define FFADE_IN 0x0001
#define FFADE_OUT 0x0002
#define FFADE_STAYOUT 0x0008
#define FFADE_PURGE 0x0010

enum UpgradeSlot
{
    UpgradeSlot_Lightweight = 0,
    UpgradeSlot_Momentum,
    UpgradeSlot_Resilience,
    UpgradeSlot_Vampirism,
    UpgradeSlot_Reforging,
    UpgradeSlot_Bloodlust,
    UpgradeSlot_Mobility,
    UpgradeSlot_Surge,
    UpgradeSlot_Fortitude,
    UpgradeSlot_Overload,
    UpgradeSlot_Stockpile,
    UpgradeSlot_Barrage,
    UpgradeSlot_Recovery,
    UpgradeSlot_Dexterity,
    UpgradeSlot_Control,
    UpgradeSlot_Ward,
    UpgradeSlot_Count
};

static const char INVISANT_CLAW_MODEL_FILES[][] =
{
    "models/shroudfire/claws/v_invisant_claws.mdl",
    "models/shroudfire/claws/v_invisant_claws.dx80.vtx",
    "models/shroudfire/claws/v_invisant_claws.dx90.vtx",
    "models/shroudfire/claws/v_invisant_claws.sw.vtx",
    "models/shroudfire/claws/v_invisant_claws.vvd",
    "models/shroudfire/claws/v_invisant_claws.xbox.vtx"
};

static const char INVISANT_PLAYER_MODEL_FILES[][] =
{
    "models/shroudfire/player/zombie_v2.mdl",
    "models/shroudfire/player/zombie_v2.dx80.vtx",
    "models/shroudfire/player/zombie_v2.dx90.vtx",
    "models/shroudfire/player/zombie_v2.sw.vtx",
    "models/shroudfire/player/zombie_v2.vvd",
    "models/shroudfire/player/zombie_v2.phy"
};

static const char INVISANT_PLAYER_MATERIAL_FILES[][] =
{
    "materials/models/shroudfire/player/Zombie_Classic_sheet.vmt"
};

static const char INVISANT_CLAW_MATERIAL_FILES[][] =
{
    "materials/models/shroudfire/claws/zombie_classic_sheet.vmt",
    "materials/models/shroudfire/claws/zombie_classic_sheet.vtf",
    "materials/models/shroudfire/claws/zombie_classic_sheet_normal.vtf"
};

static const char INVISANT_CLAW_STOCK_SOUNDS[][] =
{
    "weapons/knife/knife_deploy1.wav",
    "weapons/knife/knife_hit1.wav",
    "weapons/knife/knife_hit2.wav",
    "weapons/knife/knife_hit3.wav",
    "weapons/knife/knife_hit4.wav",
    "weapons/knife/knife_hitwall1.wav",
    "weapons/knife/knife_slash1.wav",
    "weapons/knife/knife_slash2.wav",
    "weapons/knife/knife_stab.wav"
};

static const char INVISANT_CLAW_SOUNDS[][] =
{
    "shroudfire/claws/knife_deploy1.wav",
    "shroudfire/claws/knife_hit1.wav",
    "shroudfire/claws/knife_hit2.wav",
    "shroudfire/claws/knife_hit3.wav",
    "shroudfire/claws/knife_hit4.wav",
    "shroudfire/claws/knife_hitwall1.wav",
    "shroudfire/claws/knife_slash1.wav",
    "shroudfire/claws/knife_slash2.wav",
    "shroudfire/claws/knife_stab.wav"
};

static const char KILL_STREAK_NAMES[][] =
{
    "First Blood",
    "Double Kill",
    "Killing Spree",
    "Ultra Kill",
    "Rampage",
    "Dominating",
    "Unstoppable",
    "Monster Kill",
    "Godlike",
    "Holy Shit"
};


static const char SHROUDFIRE_MUTED_STOCK_SOUNDS[][] =
{
    "radio/ctwin.wav",
    "radio/terwin.wav",
    "radio/rounddraw.wav",
    "radio/letsgo.wav",
    "radio/locknload.wav",
    "radio/moveout.wav"
};

static const int SHROUDFIRE_MUTED_STOCK_SOUND_CHANNELS[] =
{
    SNDCHAN_STATIC,
    SNDCHAN_STATIC,
    SNDCHAN_STATIC,
    SNDCHAN_VOICE,
    SNDCHAN_VOICE,
    SNDCHAN_VOICE
};

ConVar g_CvarEnabled;
ConVar g_CvarInvisantTeam;
ConVar g_CvarVisiblePerInvisant;
ConVar g_CvarInvisantSeeTeam;
ConVar g_CvarAnnounce;
ConVar g_CvarMapLightStyle;
ConVar g_CvarTonemapExposure;
ConVar g_CvarAfkSeconds;
ConVar g_CvarAfkLimit;
ConVar g_CvarHud;
ConVar g_CvarWallhack;
ConVar g_CvarInvisantScreenTint;
ConVar g_CvarExtraSpawns;
ConVar g_CvarQueueReconnectGrace;
ConVar g_CvarAdminSpectate;
ConVar g_CvarAutoBalance;
ConVar g_CvarLimitTeams;
ConVar g_CvarFlashlight;
ConVar g_CvarRoundTime;
ConVar g_CvarFreezeTime;
ConVar g_CvarFriendlyFire;
ConVar g_CvarSolidTeammates;
ConVar g_CvarForceCamera;
ConVar g_CvarBuyTime;
ConVar g_CvarFootsteps;
ConVar g_CvarMaxSpeed;
ConVar g_CvarRoundSeconds;
ConVar g_CvarMapJoinGrace;
ConVar g_CvarBloodAmount;
ConVar g_CvarXpKillInvisant;
ConVar g_CvarXpKillArmitive;
ConVar g_CvarKillStreakWindow;
ConVar g_CvarKillStreakXpPercent[KILL_STREAK_STAGE_COUNT];
ConVar g_CvarXpAssistFraction;
ConVar g_CvarXpAssistDamageShare;
ConVar g_CvarXpRoundWinInvisant;
ConVar g_CvarXpRoundWinArmitive;
ConVar g_CvarXpLevelBase;
ConVar g_CvarGameDescriptionOverride;

bool g_BotsPresent;
bool g_GameCvarsOverridden;
bool g_LightingApplied;
bool g_ManagingRoster;
bool g_StateRefreshQueued;
bool g_BetweenRounds;
bool g_MapEnding;
bool g_RosterSelectedForNextRound;
bool g_SkipNextRoundAdvance;
bool g_RoundAdvanceScheduled;
bool g_RoundInProgress;
bool g_ObjectiveEndBlockedThisRound;
bool g_VoiceOverridesApplied;
bool g_RoundEligibleForAdvance;
bool g_RoundWinXpSuppressed;
bool g_RestoringGameCvars;
bool g_PluginPaused;
bool g_SpawnBudgetWarningLogged;
bool g_TonemapWarningLogged;
bool g_EmptyRoundCheckQueued;
bool g_LightStyleRefreshFlip;
bool g_InitialRosterAtRoundStart;
bool g_AdvanceRosterAtRoundStart;
bool g_XpSchemaReady;
bool g_GameDescriptionOriginalCaptured;
bool g_GameDescriptionOverridden;
bool g_GameDescriptionUnavailableLogged;
bool g_AdminSoloRestartPending;
bool g_AdminSoloRoundActive;
bool g_FirstBloodClaimed;

int g_OriginalAutoBalance;
int g_OriginalLimitTeams;
int g_OriginalFlashlight;
int g_OriginalFriendlyFire;
int g_OriginalSolidTeammates;
int g_OriginalForceCamera;
float g_OriginalRoundTime;
float g_OriginalBuyTime;
float g_OriginalMaxSpeed;
int g_LastActiveHumans;
int g_NextQueueOrder;
int g_NextFrontQueueOrder;
int g_RoundSerial;
int g_EmptyRoundCheckSerial;
int g_ConsecutiveEmptyRoundRestarts;
int g_RoundKills[MAXPLAYERS + 1];
int g_KillStreakCount[MAXPLAYERS + 1];
float g_LastKillAt[MAXPLAYERS + 1];
int g_InvisantRoundsPlayed[MAXPLAYERS + 1];
int g_InvisantSurgeCooldownToken[MAXPLAYERS + 1];
int g_ArmitiveWardCycleToken[MAXPLAYERS + 1];
int g_AssistDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_HealthBeforeDamage[MAXPLAYERS + 1];
int g_InvisibleXp[MAXPLAYERS + 1];
int g_VisibleXp[MAXPLAYERS + 1];
int g_PendingInvisibleXp[MAXPLAYERS + 1];
int g_PendingVisibleXp[MAXPLAYERS + 1];
int g_ResilienceGrantedStageThisLife[MAXPLAYERS + 1];
int g_FortitudeGrantedStageThisLife[MAXPLAYERS + 1];
int g_UpgradeStage[MAXPLAYERS + 1][UpgradeSlot_Count];
int g_AppliedUpgradeStage[MAXPLAYERS + 1][UpgradeSlot_Count];
int g_InvisibleUpgradePoints[MAXPLAYERS + 1];
int g_VisibleUpgradePoints[MAXPLAYERS + 1];
int g_UpgradeMenuToken[MAXPLAYERS + 1];
int g_DexterityAnimationToken[MAXPLAYERS + 1];
int g_ControlShotToken[MAXPLAYERS + 1];
int g_ControlWeaponRef[MAXPLAYERS + 1];
int g_InvisantKnifeWeaponRef[MAXPLAYERS + 1];
int g_InvisantKnifeAttackSequence[MAXPLAYERS + 1];
int g_HeadshotTraceAttackerUserId[MAXPLAYERS + 1];
int g_HeadshotTraceTick[MAXPLAYERS + 1];
int g_AllowedTargetTeam[MAXPLAYERS + 1];
int g_QueueOrder[MAXPLAYERS + 1];
int g_PromotionOrder[MAXPLAYERS + 1];
int g_OverloadReloadOriginalClip[MAX_TRACKED_EDICTS];
int g_OverloadReloadOriginalReserve[MAX_TRACKED_EDICTS];
int g_OverloadInitializedWeaponRef[MAX_TRACKED_EDICTS];
int g_OverloadGrantedClipBonus[MAX_TRACKED_EDICTS];
int g_OverloadGrantedReserveBonus[MAXPLAYERS + 1][MAX_TRACKED_AMMO_TYPES];
int g_LastArmitiveAttackerUserId[MAXPLAYERS + 1];
int g_LastButtons[MAXPLAYERS + 1];
int g_ConsecutiveAfkDeaths[MAXPLAYERS + 1];
int g_PersistedQueueStamp[MAXPLAYERS + 1];
int g_PreviousCollisionGroup[MAXPLAYERS + 1];
int g_ExtraSpawnRefs[MAX_EXTRA_SPAWNS];
int g_TonemapRefs[MAX_TONEMAP_SNAPSHOTS];
int g_TonemapUseExposureMin[MAX_TONEMAP_SNAPSHOTS];
int g_TonemapUseExposureMax[MAX_TONEMAP_SNAPSHOTS];
int g_TonemapUseBloom[MAX_TONEMAP_SNAPSHOTS];
float g_TonemapExposureMin[MAX_TONEMAP_SNAPSHOTS];
float g_TonemapExposureMax[MAX_TONEMAP_SNAPSHOTS];
float g_TonemapBloom[MAX_TONEMAP_SNAPSHOTS];
float g_TonemapBloomMinimum[MAX_TONEMAP_SNAPSHOTS];
bool g_TonemapHasBloomMinimum[MAX_TONEMAP_SNAPSHOTS];
int g_OriginalTonemapControllerRef[MAXPLAYERS + 1];
bool g_TonemapControllerSaved[MAXPLAYERS + 1];
bool g_EarnedInvisant[MAXPLAYERS + 1];
bool g_PromotedByKill[MAXPLAYERS + 1];
bool g_ChoseSpectator[MAXPLAYERS + 1];
bool g_SpectatorLocked[MAXPLAYERS + 1];
bool g_VoiceOverrideSaved[MAXPLAYERS + 1][MAXPLAYERS + 1];
bool g_ActivitySampleReady[MAXPLAYERS + 1];
bool g_UseButtonSampleReady[MAXPLAYERS + 1];
bool g_UseButtonWasDown[MAXPLAYERS + 1];
bool g_QueueCookieLoaded[MAXPLAYERS + 1];
bool g_QueueCookieDirty[MAXPLAYERS + 1];
bool g_CollisionGroupSaved[MAXPLAYERS + 1];
bool g_AfkForcedDeath[MAXPLAYERS + 1];
bool g_AfkWarningShown[MAXPLAYERS + 1];
bool g_StarvationForcedDeath[MAXPLAYERS + 1];
bool g_StarvationWarningShown[MAXPLAYERS + 1];
bool g_AfkQueueRemoved[MAXPLAYERS + 1];
bool g_IgnoreAfkActivityCommand[MAXPLAYERS + 1];
bool g_OverloadReloadPending[MAX_TRACKED_EDICTS];
bool g_WaitingForNextRound[MAXPLAYERS + 1];
bool g_MapJoinRespawnEligible[MAXPLAYERS + 1];
float g_MapJoinRespawnConfirmAt[MAXPLAYERS + 1];
bool g_ForfeitedInvisantThisRound[MAXPLAYERS + 1];
bool g_XpLoaded[MAXPLAYERS + 1];
bool g_XpLoadStarted[MAXPLAYERS + 1];
bool g_UpgradeMenuQueued[MAXPLAYERS + 1];
bool g_UpgradeMenuOpen[MAXPLAYERS + 1];
bool g_LightweightApplied[MAXPLAYERS + 1];
bool g_InvisantMovementSpeedApplied[MAXPLAYERS + 1];
bool g_ResilienceApplied[MAXPLAYERS + 1];
bool g_FortitudeApplied[MAXPLAYERS + 1];
bool g_OverloadApplied[MAXPLAYERS + 1];
bool g_InvisantFootstepPredictionMuted[MAXPLAYERS + 1];
bool g_ControlHadAccuracyPenalty[MAXPLAYERS + 1];
bool g_ControlHadAimPunch[MAXPLAYERS + 1];
bool g_ControlHadAimPunchVelocity[MAXPLAYERS + 1];
bool g_ControlHadViewPunch[MAXPLAYERS + 1];
bool g_InvisantKnifeAttackPending[MAXPLAYERS + 1];
bool g_InvisantKnifeIdlePending[MAXPLAYERS + 1];
bool g_InvisantClawSuppressNativeDamage[MAXPLAYERS + 1];
bool g_InvisantClawApplyingExtendedDamage[MAXPLAYERS + 1];
bool g_HeadshotTracePending[MAXPLAYERS + 1];
bool g_InvisantSurgeReadyCuePlayed[MAXPLAYERS + 1];
bool g_ArmitiveWardReadyCuePlayed[MAXPLAYERS + 1];
bool g_ArmitiveWardVisualsApplied[MAXPLAYERS + 1];
float g_LastActivityTime[MAXPLAYERS + 1];
float g_LastWeaponFireAt[MAXPLAYERS + 1];
float g_LastDamageAt[MAXPLAYERS + 1];
float g_BlockRoundStartAudioUntil;
float g_BlockRoundEndAudioUntil;
float g_NextWallhackBeamAt;
float g_ControlAccuracyPenaltyBeforeShot[MAXPLAYERS + 1];
float g_ControlAimPunchBeforeShot[MAXPLAYERS + 1][3];
float g_ControlAimPunchVelocityBeforeShot[MAXPLAYERS + 1][3];
float g_ControlViewPunchBeforeShot[MAXPLAYERS + 1][3];
float g_InvisantKnifeNextAttack[MAXPLAYERS + 1];
float g_InvisantKnifeIdleAt[MAXPLAYERS + 1];
float g_InvisantSurgeAvailableAt[MAXPLAYERS + 1];
float g_ArmitiveWardAvailableAt[MAXPLAYERS + 1];
float g_ArmitiveWardUntil[MAXPLAYERS + 1];
float g_AdminObserveStartedAt[MAXPLAYERS + 1];
float g_HudUntil[MAXPLAYERS + 1];
float g_VisibleWaitingSince[MAXPLAYERS + 1];
float g_RoundStartedAt;
float g_RoundLiveStartedAt;
float g_InvisantStarvationRoundStartedAt;
float g_LastInvisantDamageDealtAt[MAXPLAYERS + 1];
float g_MapStartedAt;
float g_ActivityPosition[MAXPLAYERS + 1][3];
float g_ActivityAngles[MAXPLAYERS + 1][3];
ListenOverride g_PreviousVoiceOverride[MAXPLAYERS + 1][MAXPLAYERS + 1];

Handle g_RoundTimeoutTimer;
Handle g_HudSync;
Handle g_XpHudSync;
Handle g_RoundResultHudSync;
Handle g_AfkHudSync;
Handle g_StarvationHudSync;
UserMsg g_TextMsgId = INVALID_MESSAGE_ID;
UserMsg g_HintTextMsgId = INVALID_MESSAGE_ID;
UserMsg g_VguiMenuId = INVALID_MESSAGE_ID;
UserMsg g_FadeMsgId = INVALID_MESSAGE_ID;
UserMsg g_SendAudioMsgId = INVALID_MESSAGE_ID;
Handle g_LightingRefreshTimer;
Database g_XpDatabase;
Cookie g_QueueStampCookie;
Cookie g_QueueDisconnectCookie;
Cookie g_QueueLastSeenCookie;
int g_AdminObserveTargetUserId[MAXPLAYERS + 1];
char g_AdminObserveTargetName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
char g_XpSteamId[MAXPLAYERS + 1][32];
int g_WallhackBeamModel = -1;
int g_ArmitiveWardHaloSpriteModel = -1;
int g_BloodSprayModel = -1;
int g_BloodDropModel = -1;
int g_InvisantClawViewModelIndex = -1;
int g_ExtraSpawnCount;
int g_TonemapSnapshotCount;
int g_CreatedTonemapRef = INVALID_ENT_REFERENCE;
int g_InvisantScreenTintRef = INVALID_ENT_REFERENCE;
int g_InvisantScreenTintRefreshToken;
bool g_InvisantScreenTintCleanupBroadcast;
bool g_InvisantScreenTintRecreateAfterCleanup;
bool g_InvisantScreenTintDisabled[MAXPLAYERS + 1];
DynamicHook g_InvisantScreenTintShouldTransmitHook;
DynamicHook g_InvisantScreenTintUpdateTransmitStateHook;
int g_BaseSpawnCount[4];
int g_ForcedRoundEndMode;
int g_LightingRefreshesRemaining;
char g_OriginalGameDescription[256];

#include <shroudfire/settings>
#include <shroudfire/parity>

public Plugin myinfo =
{
    name = "Shroudfire",
    author = "TheGlefs",
    description = "Rotating claw-only Invisant players fight a larger team of armed Armitive.",
    version = PLUGIN_VERSION,
    url = "https://github.com/TheGlefs/Shroudfire-CSS"
};

void ApplyGameDescription()
{
    if (g_CvarEnabled != null && !IsModActive())
    {
        return;
    }
    if (g_CvarGameDescriptionOverride == null)
    {
        g_CvarGameDescriptionOverride = FindConVar("sv_gamedesc_override");
        if (g_CvarGameDescriptionOverride == null)
        {
            if (!g_GameDescriptionUnavailableLogged)
            {
                LogMessage(
                    "The loaded Connect extension does not provide sv_gamedesc_override; " ...
                    "Shroudfire will continue without changing the server-browser Game column."
                );
                g_GameDescriptionUnavailableLogged = true;
            }
            return;
        }
    }

    g_GameDescriptionUnavailableLogged = false;
    if (!g_GameDescriptionOriginalCaptured)
    {
        g_CvarGameDescriptionOverride.GetString(
            g_OriginalGameDescription,
            sizeof(g_OriginalGameDescription)
        );
        g_GameDescriptionOriginalCaptured = true;
    }

    g_CvarGameDescriptionOverride.SetString("Shroudfire", false, false);
    if (!g_GameDescriptionOverridden)
    {
        LogMessage("A2S_INFO game description set to \"#Shroudfire\" through Connect.");
    }
    g_GameDescriptionOverridden = true;
}

void RestoreGameDescription()
{
    if (!g_GameDescriptionOverridden || g_CvarGameDescriptionOverride == null)
    {
        return;
    }

    g_CvarGameDescriptionOverride.SetString(g_OriginalGameDescription, false, false);
    g_GameDescriptionOverridden = false;
}

public Action OnGetGameDescription(char gameDescription[64])
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }
    strcopy(gameDescription, sizeof(gameDescription), "Shroudfire");
    return Plugin_Changed;
}

void InitializeInvisantScreenTintHooks()
{
    GameData sdkHooksGameData = new GameData("sdkhooks.games");
    if (sdkHooksGameData == null)
    {
        SetFailState("Could not load sdkhooks.games for Invisant screen tint transmission.");
        return;
    }

    int setTransmitOffset = sdkHooksGameData.GetOffset("SetTransmit");
    delete sdkHooksGameData;
    if (setTransmitOffset < 3)
    {
        SetFailState("Could not find the CBaseEntity::SetTransmit offset for Invisant screen tint transmission.");
        return;
    }

    // CBaseEntity declares ShouldTransmit, UpdateTransmitState, and SetTransmit
    // consecutively. Override the first two so color_correction cannot restore
    // its global FL_EDICT_ALWAYS state and bypass per-client filtering.
    g_InvisantScreenTintShouldTransmitHook = new DynamicHook(
        setTransmitOffset - 2,
        HookType_Entity,
        ReturnType_Int,
        ThisPointer_CBaseEntity
    );
    g_InvisantScreenTintShouldTransmitHook.AddParam(HookParamType_ObjectPtr);
    g_InvisantScreenTintUpdateTransmitStateHook = new DynamicHook(
        setTransmitOffset - 1,
        HookType_Entity,
        ReturnType_Int,
        ThisPointer_CBaseEntity
    );
}

public void OnPluginStart()
{
    if (GetEngineVersion() != Engine_CSS)
    {
        SetFailState("Shroudfire supports Counter-Strike: Source only.");
    }

    InitializeInvisantScreenTintHooks();
    ApplyGameDescription();

    CreateShroudfireSettings();
    g_QueueStampCookie = new Cookie(
        "shroudfire_queue_stamp",
        "Persistent Shroudfire queue age.",
        CookieAccess_Private
    );
    g_QueueDisconnectCookie = new Cookie(
        "shroudfire_queue_left_at",
        "Last Shroudfire disconnect time for reconnect grace.",
        CookieAccess_Private
    );
    g_QueueLastSeenCookie = new Cookie(
        "shroudfire_queue_seen_at",
        "Last Shroudfire presence heartbeat for reconnect grace.",
        CookieAccess_Private
    );
    g_NextQueueOrder = GetTime();
    g_NextFrontQueueOrder = g_NextQueueOrder;

    g_CvarEnabled.AddChangeHook(OnSettingsChanged);
    g_CvarInvisantTeam.AddChangeHook(OnSettingsChanged);
    g_CvarVisiblePerInvisant.AddChangeHook(OnSettingsChanged);
    g_CvarInvisantSeeTeam.AddChangeHook(OnSettingsChanged);
    g_CvarMapLightStyle.AddChangeHook(OnSettingsChanged);
    g_CvarTonemapExposure.AddChangeHook(OnSettingsChanged);
    g_CvarWallhack.AddChangeHook(OnSettingsChanged);
    g_CvarInvisantScreenTint.AddChangeHook(OnSettingsChanged);
    g_CvarRoundSeconds.AddChangeHook(OnSettingsChanged);
    g_CvarExtraSpawns.AddChangeHook(OnSettingsChanged);
    g_CvarXpLevelBase.AddChangeHook(OnSettingsChanged);

    g_CvarAutoBalance = FindConVar("mp_autoteambalance");
    g_CvarLimitTeams = FindConVar("mp_limitteams");
    g_CvarFlashlight = FindConVar("mp_flashlight");
    g_CvarRoundTime = FindConVar("mp_roundtime");
    g_CvarFreezeTime = FindConVar("mp_freezetime");
    g_CvarFriendlyFire = FindConVar("mp_friendlyfire");
    g_CvarSolidTeammates = FindConVar("mp_solid_teammates");
    g_CvarForceCamera = FindConVar("mp_forcecamera");
    g_CvarBuyTime = FindConVar("mp_buytime");
    g_CvarFootsteps = FindConVar("sv_footsteps");
    g_CvarMaxSpeed = FindConVar("sv_maxspeed");
    if (g_CvarFriendlyFire != null)
    {
        g_CvarFriendlyFire.AddChangeHook(OnEnforcedGameCvarChanged);
    }
    if (g_CvarRoundTime != null)
    {
        g_CvarRoundTime.AddChangeHook(OnEnforcedGameCvarChanged);
    }
    if (g_CvarSolidTeammates != null)
    {
        g_CvarSolidTeammates.AddChangeHook(OnEnforcedGameCvarChanged);
    }
    if (g_CvarForceCamera != null)
    {
        g_CvarForceCamera.AddChangeHook(OnEnforcedGameCvarChanged);
    }
    if (g_CvarBuyTime != null)
    {
        g_CvarBuyTime.AddChangeHook(OnEnforcedGameCvarChanged);
    }
    if (g_CvarMaxSpeed != null)
    {
        g_CvarMaxSpeed.AddChangeHook(OnEnforcedGameCvarChanged);
    }

    HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
    HookEvent("round_freeze_end", Event_RoundFreezeEnd, EventHookMode_PostNoCopy);
    HookEvent("round_end", Event_RoundEndBroadcast, EventHookMode_Pre);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
    HookEventEx("cs_win_panel_round", Event_WinPanel, EventHookMode_Pre);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_team", Event_PlayerTeamAnnouncement, EventHookMode_Pre);
    HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeathPre, EventHookMode_Pre);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
    HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
    AddCommandListener(Command_JoinTeam, "jointeam");
    AddCommandListener(Command_JoinClass, "joinclass");
    AddCommandListener(Command_BlockTeamMenu, "chooseteam");
    AddCommandListener(Command_HandleSuicide, "kill");
    AddCommandListener(Command_HandleSuicide, "explode");
    AddCommandListener(Command_AmmoPurchase, "buymenu");
    AddCommandListener(Command_AmmoPurchase, "buyammo1");
    AddCommandListener(Command_AmmoPurchase, "buyammo2");
    AddCommandListener(Command_AmmoPurchase, "buy");
    AddCommandListener(Command_AmmoPurchase, "autobuy");
    AddCommandListener(Command_AmmoPurchase, "rebuy");
    RegisterInvisantSignalListeners();
    AddAmbientSoundHook(Hook_AmbientSound);
    AddNormalSoundHook(Hook_NormalSound);
    g_TextMsgId = GetUserMessageId("TextMsg");
    if (g_TextMsgId != INVALID_MESSAGE_ID)
    {
        HookUserMessage(g_TextMsgId, Hook_TextMessage, true);
    }
    else
    {
        LogError(
            "TextMsg user message is unavailable; bomb pickup notices cannot be suppressed " ...
            "and stock round/team notices cannot use role names."
        );
    }
    g_SendAudioMsgId = GetUserMessageId("SendAudio");
    if (g_SendAudioMsgId != INVALID_MESSAGE_ID)
    {
        HookUserMessage(g_SendAudioMsgId, Hook_SendAudioMessage, true);
    }
    else
    {
        LogError("SendAudio user message is unavailable; stock round-start and round-end voices cannot be suppressed.");
    }
    g_HintTextMsgId = GetUserMessageId("HintText");
    if (g_HintTextMsgId != INVALID_MESSAGE_ID)
    {
        HookUserMessage(g_HintTextMsgId, Hook_HintTextMessage, true);
    }
    else
    {
        LogError("HintText user message is unavailable; bomb possession hints cannot be suppressed.");
    }
    g_VguiMenuId = GetUserMessageId("VGUIMenu");
    if (g_VguiMenuId != INVALID_MESSAGE_ID)
    {
        HookUserMessage(g_VguiMenuId, Hook_VguiMenuMessage, true);
    }
    else
    {
        LogError("VGUIMenu user message is unavailable; stock team and Invisant buy menus cannot be suppressed.");
    }
    g_FadeMsgId = GetUserMessageId("Fade");
    if (g_FadeMsgId == INVALID_MESSAGE_ID)
    {
        LogError("Fade user message is unavailable; the Invisant screen tint cannot be displayed.");
    }
    RegAdminCmd(
        "sf_status",
        Command_ShroudfireStatus,
        ADMFLAG_GENERIC,
        "Displays Shroudfire state, map rotation, teams, queue, AFK players, and spawn capacity."
    );
    RegAdminCmd(
        "sf_observe",
        Command_ShroudfireObserve,
        ADMFLAG_GENERIC,
        "Moves you to Spectator to watch a living player or use a free camera."
    );
    RegAdminCmd(
        "sf_restart",
        Command_ShroudfireRestart,
        ADMFLAG_GENERIC,
        "Restarts the current round without advancing the Invisant roster, including with one active player. Requires the generic admin flag."
    );
    RegAdminCmd(
        "sf_invisant",
        Command_ShroudfireInvisant,
        ADMFLAG_ROOT,
        "Moves you to the Invisant team and respawns you at its spawn."
    );
    RegAdminCmd(
        "sf_setlevel",
        Command_ShroudfireSetLevel,
        ADMFLAG_ROOT,
        "Sets an online player's Invisant or Armitive level to its starting XP, resets that role's purchased upgrades, and recalculates its available upgrade points for the assigned level."
    );
    RegConsoleCmd(
        "sf_level",
        Command_ShroudfireLevel,
        "Displays your Invisant and Armitive XP and levels."
    );

    AutoExecConfig(false, "shroudfire");

    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client))
        {
            ResetClientState(client);
            HookClient(client);
            if (!IsFakeClient(client) && AreClientCookiesCached(client))
            {
                LoadPersistentQueue(client, false);
            }
        }
    }

    InitializeXpDatabase();
    InitializeParity();

    g_HudSync = CreateHudSynchronizer();
    g_XpHudSync = CreateHudSynchronizer();
    g_RoundResultHudSync = CreateHudSynchronizer();
    g_AfkHudSync = CreateHudSynchronizer();
    g_StarvationHudSync = CreateHudSynchronizer();
    HookExistingEntities();
    CreateTimer(1.0, Timer_UpdateHud, _, TIMER_REPEAT);
    CreateTimer(0.5, Timer_UpdateVoice, _, TIMER_REPEAT);
    CreateTimer(TEAM_MENU_CLOSE_INTERVAL, Timer_KeepTeamMenuClosed, _, TIMER_REPEAT);
    CreateTimer(1.0, Timer_CheckAfk, _, TIMER_REPEAT);

    CreateTimer(1.0, Timer_RegenerateHealth, _, TIMER_REPEAT);
    CreateTimer(1.0, Timer_RegenerateArmor, _, TIMER_REPEAT);
    CreateTimer(float(QUEUE_HEARTBEAT_INTERVAL), Timer_PersistQueuePresence, _, TIMER_REPEAT);
    CreateTimer(0.5, Timer_InitializePlugin, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnPluginEnd()
{
    RestoreMapEngineLimits();
    if (g_XpDatabase != null)
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            if (!IsHumanClient(client))
            {
                continue;
            }
            if (g_XpLoaded[client])
            {
                SavePlayerXp(client, true);
            }
            else if (g_PendingInvisibleXp[client] > 0 || g_PendingVisibleXp[client] > 0)
            {
                SavePendingPlayerXp(client, true);
            }
        }
    }

    // Engine entities are already being destroyed after OnMapEnd.
    if (g_MapEnding) return;

    bool abortRound = IsModActive() && g_RoundInProgress && CountActiveHumans() > 0;
    for (int client = 1; client <= MaxClients; client++)
    {
        EndAdminObservationAudit(client, "plugin unloaded");
        ClearInvisantStarvationWarning(client);
    }

    RestoreAllClientFootstepPrediction();
    g_PluginPaused = true;
    ClearAllInvisantScreenTints(true);
    RemoveAmbientSoundHook(Hook_AmbientSound);
    RemoveNormalSoundHook(Hook_NormalSound);
    if (g_TextMsgId != INVALID_MESSAGE_ID)
    {
        UnhookUserMessage(g_TextMsgId, Hook_TextMessage, true);
    }
    if (g_SendAudioMsgId != INVALID_MESSAGE_ID)
    {
        UnhookUserMessage(g_SendAudioMsgId, Hook_SendAudioMessage, true);
    }
    if (g_HintTextMsgId != INVALID_MESSAGE_ID)
    {
        UnhookUserMessage(g_HintTextMsgId, Hook_HintTextMessage, true);
    }
    if (g_VguiMenuId != INVALID_MESSAGE_ID)
    {
        UnhookUserMessage(g_VguiMenuId, Hook_VguiMenuMessage, true);
    }
    if (g_LightingRefreshTimer != null)
    {
        delete g_LightingRefreshTimer;
        g_LightingRefreshTimer = null;
    }
    CancelRoundTimeout();
    RemoveExtraSpawns();
    RestoreVoiceOverrides();
    RestoreAllPlayerCollisions();
    ClearAllPlayerUpgradeEffects();
    RestoreInvisantPlayers(GetInvisantTeam());
    RestoreMapLighting();
    RestoreGameCvars();
    RestoreGameDescription();

    if (abortRound)
    {
        CS_TerminateRound(0.1, CSRoundEnd_Draw, true);
    }
}

public void OnConfigsExecuted()
{
    ConfigureBlockedWeapons();
    ApplyGameDescription();
    if (IsModActive())
    {
        RemoveAllObjectives();
    }
    RefreshAllInvisantScreenTints();
    CreateTimer(0.1, Timer_ApplyMapLighting, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnPluginPauseChange(bool pause)
{
    if (g_CvarEnabled == null || g_CvarInvisantTeam == null)
    {
        g_PluginPaused = pause;
        return;
    }
    bool wasActive = IsModActive();
    g_PluginPaused = pause;
    if (pause)
    {
        RestoreMapEngineLimits();
        ClearAllAssistDamage();
        RestoreGameDescription();
        RestoreAllClientFootstepPrediction();
        ClearAllInvisantScreenTints();
        for (int client = 1; client <= MaxClients; client++)
        {
            EndAdminObservationAudit(client, "plugin paused");
            ClearInvisantStarvationWarning(client);
        }
        CancelRoundTimeout();
        RemoveExtraSpawns();
        RestoreVoiceOverrides();
        RestoreAllPlayerCollisions();
        ClearAllPlayerUpgradeEffects();
        RestoreInvisantPlayers(GetInvisantTeam());
        RestoreMapLighting();
        RestoreGameCvars();
        ClearRoundPriorities();

        if (wasActive && g_RoundInProgress)
        {
            CS_TerminateRound(0.1, CSRoundEnd_Draw, true);
        }
        LogMessage("Paused cleanly; restored temporary Shroudfire state.");
        return;
    }

    ApplyGameDescription();
    bool botsWerePresent = g_BotsPresent;
    RefreshBotState();
    if (g_CvarEnabled.BoolValue && !g_BotsPresent && !botsWerePresent)
    {
        RemoveAllObjectives();
        EnsureSpawnCapacity();
        InitializeWaitingQueue();
        g_LastActiveHumans = 0;
        HandlePopulationChange();
        OverrideGameCvars();
        ApplyMapLighting();
        RefreshAllInvisantScreenTints();
        LogMessage("Resumed and reinitialized Shroudfire state.");
    }
}

public void OnMapStart()
{
    g_MapEnding = false;
    ApplyGameDescription();
    g_MapStartedAt = GetEngineTime();
    ResetMapRotation();
    PrecacheShroudfireVoices();

    g_BetweenRounds = false;
    g_RosterSelectedForNextRound = false;
    g_SkipNextRoundAdvance = false;
    g_RoundAdvanceScheduled = false;
    g_StateRefreshQueued = false;
    g_EmptyRoundCheckQueued = false;
    g_LightingApplied = false;
    g_RoundInProgress = false;
    g_RoundLiveStartedAt = 0.0;
    g_InvisantStarvationRoundStartedAt = 0.0;
    g_BlockRoundStartAudioUntil = 0.0;
    g_BlockRoundEndAudioUntil = 0.0;
    g_NextWallhackBeamAt = 0.0;
    g_ObjectiveEndBlockedThisRound = false;
    g_RoundEligibleForAdvance = false;
    g_RoundWinXpSuppressed = false;
    g_ForcedRoundEndMode = FORCED_END_NONE;
    g_SpawnBudgetWarningLogged = false;
    g_TonemapWarningLogged = false;
    g_LightStyleRefreshFlip = false;
    g_InitialRosterAtRoundStart = false;
    g_AdvanceRosterAtRoundStart = false;
    g_AdminSoloRestartPending = false;
    g_AdminSoloRoundActive = false;
    g_RoundTimeoutTimer = null;
    g_LightingRefreshTimer = null;
    g_LightingRefreshesRemaining = 0;
    g_WallhackBeamModel = PrecacheModel(WALLHACK_BEAM_SPRITE, true);
    g_ArmitiveWardHaloSpriteModel = PrecacheModel(ARMITIVE_WARD_HALO_SPRITE, true);
    AddFileToDownloadsTable(INVISANT_SCREEN_LUT);
    PrecacheGeneric(INVISANT_SCREEN_LUT, true);
    g_BloodSprayModel = PrecacheModel(BLOOD_SPRAY_SPRITE, true);
    g_BloodDropModel = PrecacheModel(BLOOD_DROP_SPRITE, true);
    for (int index = 0; index < sizeof(INVISANT_CLAW_MODEL_FILES); index++)
    {
        AddFileToDownloadsTable(INVISANT_CLAW_MODEL_FILES[index]);
    }
    for (int index = 0; index < sizeof(INVISANT_CLAW_MATERIAL_FILES); index++)
    {
        AddFileToDownloadsTable(INVISANT_CLAW_MATERIAL_FILES[index]);
    }
    for (int index = 0; index < sizeof(INVISANT_PLAYER_MODEL_FILES); index++)
    {
        AddFileToDownloadsTable(INVISANT_PLAYER_MODEL_FILES[index]);
    }
    for (int index = 0; index < sizeof(INVISANT_PLAYER_MATERIAL_FILES); index++)
    {
        AddFileToDownloadsTable(INVISANT_PLAYER_MATERIAL_FILES[index]);
    }
    for (int index = 0; index < sizeof(INVISANT_CLAW_SOUNDS); index++)
    {
        if ((index >= 1 && index <= 4) || index == 8)
        {
            continue;
        }
        char downloadPath[PLATFORM_MAX_PATH];
        Format(downloadPath, sizeof(downloadPath), "sound/%s", INVISANT_CLAW_SOUNDS[index]);
        AddFileToDownloadsTable(downloadPath);
        PrecacheSound(INVISANT_CLAW_SOUNDS[index], true);
    }
    PrecacheSound(INVISANT_CLAW_HIT_SOUND, true);
    for (int index = 0; index < sizeof(SHROUDFIRE_MUTED_STOCK_SOUNDS); index++)
    {
        PrecacheSound(SHROUDFIRE_MUTED_STOCK_SOUNDS[index], true);
    }
    g_InvisantClawViewModelIndex = PrecacheModel(INVISANT_CLAW_VIEW_MODEL, true);
    PrecacheModel(INVISANT_PLAYER_MODEL, true);
    static const char menuSounds[][] = { "buttons/button14.wav", "buttons/button3.wav", "buttons/button19.wav", "buttons/blip1.wav", "buttons/blip2.wav" };
    for (int i = 0; i < sizeof(menuSounds); i++) PrecacheSound(menuSounds[i], true);
    PrecacheSound(AFK_WARNING_SOUND, true);
    PrecacheSound(INVISANT_SURGE_SOUND, true);
    PrecacheSound(INVISANT_SURGE_COOLDOWN_SOUND, true);
    PrecacheSound(INVISANT_SURGE_READY_SOUND, true);
    PrecacheSound(INVISANT_SURGE_BLOCKED_SOUND, true);
    PrecacheSound(INVISANT_CLAW_HIT_SOUND, true);
    PrecacheSound(ARMITIVE_WARD_ACTIVATE_SOUND, true);
    PrecacheSound(ARMITIVE_WARD_END_SOUND, true);
    PrecacheSound(ARMITIVE_WARD_COOLDOWN_SOUND, true);
    PrecacheSound(ARMITIVE_WARD_READY_SOUND, true);
    g_ExtraSpawnCount = 0;
    g_TonemapSnapshotCount = 0;
    g_CreatedTonemapRef = INVALID_ENT_REFERENCE;
    g_InvisantScreenTintRef = INVALID_ENT_REFERENCE;
    g_InvisantScreenTintCleanupBroadcast = false;
    g_InvisantScreenTintRecreateAfterCleanup = false;
    g_RoundSerial = 0;
    g_FirstBloodClaimed = false;
    g_EmptyRoundCheckSerial = 0;
    g_ConsecutiveEmptyRoundRestarts = 0;
    g_BaseSpawnCount[CS_TEAM_T] = 0;
    g_BaseSpawnCount[CS_TEAM_CT] = 0;
    ClearAllAssistDamage();

    for (int client = 1; client <= MaxClients; client++)
    {
        g_AllowedTargetTeam[client] = 0;
        g_EarnedInvisant[client] = false;
        g_PromotedByKill[client] = false;
        g_PromotionOrder[client] = 0;
        g_SpectatorLocked[client] = false;
        g_LastArmitiveAttackerUserId[client] = 0;
        g_ActivitySampleReady[client] = false;
        g_LastButtons[client] = 0;
        g_UseButtonSampleReady[client] = false;
        g_UseButtonWasDown[client] = false;
        g_CollisionGroupSaved[client] = false;
        g_WaitingForNextRound[client] = false;
        g_MapJoinRespawnEligible[client] = IsHumanClient(client);
        g_MapJoinRespawnConfirmAt[client] = g_MapJoinRespawnEligible[client]
            ? GetEngineTime() + MAP_JOIN_RESPAWN_SETTLE_SECONDS
            : 0.0;
        g_ForfeitedInvisantThisRound[client] = false;
        g_AfkForcedDeath[client] = false;
        g_RoundKills[client] = 0;
        g_KillStreakCount[client] = 0;
        g_LastKillAt[client] = 0.0;
        g_InvisantRoundsPlayed[client] = 0;
        g_AdminObserveTargetUserId[client] = 0;
        g_AdminObserveStartedAt[client] = 0.0;
        g_HudUntil[client] = 0.0;
        g_VisibleWaitingSince[client] = 0.0;
        g_LastWeaponFireAt[client] = 0.0;
        g_LastDamageAt[client] = 0.0;
        g_LastInvisantDamageDealtAt[client] = GetGameTime();
        g_StarvationForcedDeath[client] = false;
        ClearInvisantStarvationWarning(client);
        g_ResilienceGrantedStageThisLife[client] = 0;
        g_FortitudeGrantedStageThisLife[client] = 0;
        for (int ammoType = 0; ammoType < MAX_TRACKED_AMMO_TYPES; ammoType++)
        {
            g_OverloadGrantedReserveBonus[client][ammoType] = 0;
        }
        g_InvisantSurgeAvailableAt[client] = 0.0;
        g_InvisantSurgeCooldownToken[client] = 0;
        g_InvisantSurgeReadyCuePlayed[client] = true;
        g_ArmitiveWardAvailableAt[client] = 0.0;
        g_ArmitiveWardUntil[client] = 0.0;
        g_ArmitiveWardCycleToken[client] = 0;
        g_ArmitiveWardReadyCuePlayed[client] = true;
        g_ArmitiveWardVisualsApplied[client] = false;
        g_AdminObserveTargetName[client][0] = '\0';
    }

    CreateTimer(0.5, Timer_ApplyMapLighting, _, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.75, Timer_EnsureSpawnCapacity, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd()
{
    g_MapEnding = true;
    // SourceMod releases NO_MAPCHANGE timers during level shutdown.
    g_LightingRefreshTimer = null;
    g_RoundTimeoutTimer = null;
    RestoreMapEngineLimits();
    g_MapStartedAt = 0.0;
    ClearAllAssistDamage();
    ClearAllInvisantScreenTints();
    for (int client = 1; client <= MaxClients; client++)
    {
        EndAdminObservationAudit(client, "map ended");
    }
}

public void OnClientPutInServer(int client)
{
    ClearSavedVoiceOverrides(client);
    ResetClientState(client);
    g_MapJoinRespawnEligible[client] = IsMapJoinGraceActive();
    g_MapJoinRespawnConfirmAt[client] = g_MapJoinRespawnEligible[client]
        ? GetEngineTime() + MAP_JOIN_RESPAWN_SETTLE_SECONDS
        : 0.0;
    HookClient(client);
    ClearInvisantScreenFade(client);

    if (!IsFakeClient(client) && AreClientCookiesCached(client))
    {
        LoadPersistentQueue(client);
    }

    if (IsActualBot(client))
    {
        RefreshBotState();
        return;
    }

    CreateTimer(0.1, Timer_AutoJoinVisible, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(1.0, Timer_ApplyMapLighting, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientPostAdminCheck(int client)
{
    if (IsHumanClient(client))
    {
        LoadPlayerXp(client);
        CreateTimer(5.0, Timer_ShowGuideHint, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public void OnClientDisconnect(int client)
{
    EndAdminObservationAudit(client, "administrator disconnected");
    ClearPlayerUpgradeEffects(client);

    if ((g_QueueCookieLoaded[client] || g_QueueCookieDirty[client])
        && g_PersistedQueueStamp[client] > 0)
    {
        SavePersistentQueue(client, g_PersistedQueueStamp[client], true);
    }
    if (AreClientCookiesCached(client))
    {
        int now = GetTime();
        g_QueueDisconnectCookie.SetInt(client, now);
        g_QueueLastSeenCookie.SetInt(client, now);
    }
    else if (!IsFakeClient(client))
    {
        char steamId[32];
        if (GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId), true))
        {
            char timestamp[12];
            IntToString(GetTime(), timestamp, sizeof(timestamp));
            g_QueueDisconnectCookie.SetByAuthId(steamId, timestamp);
            g_QueueLastSeenCookie.SetByAuthId(steamId, timestamp);
        }
    }
    if (g_XpLoaded[client])
    {
        SavePlayerXp(client, true);
        SavePlayerXp(client);
    }
    else if (g_PendingInvisibleXp[client] > 0 || g_PendingVisibleXp[client] > 0)
    {
        SavePendingPlayerXp(client, true);
    }
    ClearSavedVoiceOverrides(client);
    ResetClientState(client);
    RestartAllInvisantScreenTints();
    QueueStateRefresh();
}

public void OnClientCookiesCached(int client)
{
    LoadAudioPreferences(client);
    if (!IsHumanClient(client))
    {
        return;
    }

    LoadPersistentQueue(client);
    QueueStateRefresh();
}

bool ResolvePlayerSteamId(int client, char[] steamId, int length)
{
    steamId[0] = '\0';
    ConVar lan = FindConVar("sv_lan");
    if (lan != null && lan.BoolValue)
    {
        // LAN has no backend validation. Use the engine's per-player account
        // number consistently, including when reloading with clients connected.
        int account = GetSteamAccountID(client, false);
        if (account == 0) return false;
        FormatEx(steamId, length, "STEAM_1:%d:%d", account & 1, account >>> 1);
        return true;
    }
    if (GetClientAuthId(client, AuthId_SteamID64, steamId, length, true)) return true;
    // Failed lookups write an error placeholder. Never cache it as a player ID.
    steamId[0] = '\0';
    return false;
}

void InitializeXpDatabase()
{
    char error[256];
    g_XpDatabase = SQLite_UseDatabase(XP_DATABASE_NAME, error, sizeof(error));
    if (g_XpDatabase == null)
    {
        LogError("Could not open the Shroudfire database: %s", error);
        return;
    }
    g_XpDatabase.Query(SQL_CreateXpTable,
        "CREATE TABLE IF NOT EXISTS shroudfire_players (steam_id TEXT PRIMARY KEY NOT NULL, invisant_xp INTEGER NOT NULL DEFAULT 0, armitive_xp INTEGER NOT NULL DEFAULT 0, upgrades TEXT NOT NULL DEFAULT '', updated_at INTEGER NOT NULL DEFAULT 0);",
        _, DBPrio_High);
}

public void SQL_CreateXpTable(Database db, DBResultSet results, const char[] error, any data)
{
    if (results == null)
    {
        LogError("Could not create the Shroudfire player table: %s", error);
        return;
    }
    InitializeCombatDatabase();
    g_XpSchemaReady = true;
    for (int client = 1; client <= MaxClients; client++)
        if (IsHumanClient(client)) LoadPlayerXp(client);
}

void LoadPlayerXp(int client)
{
    if (!g_XpSchemaReady || g_XpDatabase == null || !IsHumanClient(client)
        || g_XpLoaded[client] || g_XpLoadStarted[client]) return;
    if (g_XpSteamId[client][0] == '\0'
        && !ResolvePlayerSteamId(client, g_XpSteamId[client], sizeof(g_XpSteamId[])))
    {
        g_XpLoadStarted[client] = true;
        CreateTimer(1.0, Timer_RetryPlayerXpLoad, GetClientSerial(client));
        return;
    }
    char steamId[64], query[256];
    if (!g_XpDatabase.Escape(g_XpSteamId[client], steamId, sizeof(steamId))) return;
    FormatEx(query, sizeof(query),
        "SELECT invisant_xp, armitive_xp, upgrades FROM shroudfire_players WHERE steam_id = '%s';", steamId);
    g_XpLoadStarted[client] = true;
    g_XpDatabase.Query(SQL_LoadPlayerXp, query, GetClientSerial(client));
}

public void SQL_LoadPlayerXp(Database db, DBResultSet results, const char[] error, any serial)
{
    int client = GetClientFromSerial(serial);
    if (!IsHumanClient(client))
    {
        return;
    }

    g_XpLoadStarted[client] = false;
    if (results == null)
    {
        LogError("Could not load XP for %N: %s", client, error);
        g_XpLoadStarted[client] = true;
        CreateTimer(30.0, Timer_RetryPlayerXpLoad, serial);
        return;
    }

    int invisantXp, armitiveXp;
    if (results.FetchRow())
    {
        invisantXp = results.FetchInt(0);
        armitiveXp = results.FetchInt(1);
        char upgrades[128], stages[16][8];
        results.FetchString(2, upgrades, sizeof(upgrades));
        int count = ExplodeString(upgrades, ",", stages, sizeof(stages), sizeof(stages[]));
        for (int slot = 0; slot < count; slot++)
            g_UpgradeStage[client][slot] = ClampUpgradeStage(StringToInt(stages[slot]));
    }
    g_InvisibleXp[client] = AddXpWithoutOverflow(invisantXp, g_PendingInvisibleXp[client]);
    g_VisibleXp[client] = AddXpWithoutOverflow(armitiveXp, g_PendingVisibleXp[client]);
    g_PendingInvisibleXp[client] = 0;
    g_PendingVisibleXp[client] = 0;
    ReconcileUpgradePoints(client, true);
    ReconcileUpgradePoints(client, false);
    g_XpLoaded[client] = true;
    int healthBeforeApplying = IsPlayerAlive(client) ? GetClientHealth(client) : 0;
    int armorBeforeApplying = IsPlayerAlive(client)
        && HasEntProp(client, Prop_Send, "m_ArmorValue")
        ? GetEntProp(client, Prop_Send, "m_ArmorValue") : 0;
    int grantedFortitudeBeforeApplying = g_FortitudeGrantedStageThisLife[client];
    int grantedResilienceBeforeApplying = g_ResilienceGrantedStageThisLife[client];
    SyncAppliedUpgradeStages(client, true);
    SyncAppliedUpgradeStages(client, false);

    SavePlayerXp(client);

    if (IsPlayerAlive(client))
    {
        ApplyPlayerUpgrades(client);
        if (IsModActive() && IsActiveHuman(client)
            && GetClientTeam(client) == GetVisibleTeam())
        {
            int newStages = g_FortitudeGrantedStageThisLife[client]
                - grantedFortitudeBeforeApplying;
            if (newStages < 0)
            {
                newStages = 0;
            }
            int health = healthBeforeApplying + (newStages * FORTITUDE_HEALTH_PER_STAGE);
            int healthLimit = g_CvarArmitiveBaseHealth.IntValue + (g_AppliedUpgradeStage[client][UpgradeSlot_Fortitude]
                * FORTITUDE_HEALTH_PER_STAGE);
            SetEntityHealth(client, health > healthLimit ? healthLimit : health);
        }
        else if (IsModActive() && IsActiveHuman(client)
            && GetClientTeam(client) == GetInvisantTeam()
            && HasEntProp(client, Prop_Send, "m_ArmorValue"))
        {
            int newStages = g_ResilienceGrantedStageThisLife[client]
                - grantedResilienceBeforeApplying;
            if (newStages < 0)
            {
                newStages = 0;
            }
            int armor = armorBeforeApplying + (newStages * RESILIENCE_ARMOR_PER_STAGE);
            int armorLimit = INVISANT_BASE_ARMOR
                + (g_AppliedUpgradeStage[client][UpgradeSlot_Resilience]
                    * RESILIENCE_ARMOR_PER_STAGE);
            SetEntProp(client, Prop_Send, "m_ArmorValue", armor > armorLimit ? armorLimit : armor);
        }
    }
    if (IsActiveHuman(client) && IsPlayerAlive(client))
    {
        bool invisantRole = GetClientTeam(client) == GetInvisantTeam();
        int points = invisantRole ? g_InvisibleUpgradePoints[client] : g_VisibleUpgradePoints[client];
        if (points > 0)
        {
            QueueUpgradeMenu(client, invisantRole, 1.0);
        }
    }
}

public Action Timer_RetryPlayerXpLoad(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (IsHumanClient(client) && !g_XpLoaded[client])
    {
        g_XpLoadStarted[client] = false;
        LoadPlayerXp(client);
    }
    return Plugin_Stop;
}

void SavePlayerXp(int client, bool synchronous = false)
{
    if (!g_XpSchemaReady || g_XpDatabase == null || !g_XpLoaded[client]) return;
    if (g_XpSteamId[client][0] == '\0'
        && !ResolvePlayerSteamId(client, g_XpSteamId[client], sizeof(g_XpSteamId[]))) return;
    char steamId[64], upgrades[128], query[512];
    if (!g_XpDatabase.Escape(g_XpSteamId[client], steamId, sizeof(steamId))) return;
    for (int slot = 0; slot < view_as<int>(UpgradeSlot_Count); slot++)
        Format(upgrades, sizeof(upgrades), "%s%s%d", upgrades, slot > 0 ? "," : "", g_UpgradeStage[client][slot]);
    FormatEx(query, sizeof(query),
        "INSERT OR REPLACE INTO shroudfire_players (steam_id, invisant_xp, armitive_xp, upgrades, updated_at) VALUES ('%s', %d, %d, '%s', %d);",
        steamId, g_InvisibleXp[client], g_VisibleXp[client], upgrades, GetTime());
    if (synchronous)
    {
        SQL_LockDatabase(g_XpDatabase);
        if (!SQL_FastQuery(g_XpDatabase, query))
        {
            char error[256]; SQL_GetError(g_XpDatabase, error, sizeof(error));
            LogError("Could not save Shroudfire player: %s", error);
        }
        SQL_UnlockDatabase(g_XpDatabase);
    }
    else g_XpDatabase.Query(SQL_SavePlayerXp, query);
}

void SavePendingPlayerXp(int client, bool synchronous = false)
{
    if (!g_XpSchemaReady || g_XpDatabase == null) return;
    if (g_XpSteamId[client][0] == '\0'
        && !ResolvePlayerSteamId(client, g_XpSteamId[client], sizeof(g_XpSteamId[]))) return;
    char steamId[64], query[768];
    if (!g_XpDatabase.Escape(g_XpSteamId[client], steamId, sizeof(steamId))) return;
    int maximum = GetMaximumPlayerXp();
    FormatEx(query, sizeof(query),
        "INSERT INTO shroudfire_players (steam_id, invisant_xp, armitive_xp, updated_at) VALUES ('%s', %d, %d, %d) ON CONFLICT(steam_id) DO UPDATE SET invisant_xp = MIN(invisant_xp + excluded.invisant_xp, %d), armitive_xp = MIN(armitive_xp + excluded.armitive_xp, %d), updated_at = excluded.updated_at;",
        steamId, g_PendingInvisibleXp[client], g_PendingVisibleXp[client], GetTime(), maximum, maximum);
    if (synchronous)
    {
        SQL_LockDatabase(g_XpDatabase);
        if (!SQL_FastQuery(g_XpDatabase, query))
        {
            char error[256]; SQL_GetError(g_XpDatabase, error, sizeof(error));
            LogError("Could not save pending Shroudfire XP: %s", error);
        }
        SQL_UnlockDatabase(g_XpDatabase);
    }
    else g_XpDatabase.Query(SQL_SavePlayerXp, query);
}

public void SQL_SavePlayerXp(Database db, DBResultSet results, const char[] error, any data)
{
    if (results == null)
    {
        LogError("Could not save Shroudfire XP: %s", error);
    }
}

public void SQL_SaveCombatTransaction(
    Database db,
    any data,
    int numQueries,
    const char[] error,
    int failIndex,
    any[] queryData
)
{
    LogError("Could not save Shroudfire combat statistics at query %d: %s", failIndex, error);
}

public void OnClientSpeaking(int client)
{
    if (IsHumanClient(client))
    {
        RecordClientActivity(client);
    }
}

public Action OnClientCommand(int client, int args)
{
    if (IsHumanClient(client) && !g_IgnoreAfkActivityCommand[client])
    {
        RecordClientActivity(client);
    }
    return Plugin_Continue;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (!IsHumanClient(client) || sArgs[0] == '\0')
    {
        return Plugin_Continue;
    }

    char message[256];
    strcopy(message, sizeof(message), sArgs);
    TrimString(message);
    if (!IsModActive())
    {
        return Plugin_Continue;
    }
    if (HandleShroudfireChat(client, message)) return Plugin_Stop;

    if (IsChatTrigger())
    {
        char commandName[64];
        strcopy(commandName, sizeof(commandName), sArgs[1]);
        int separator = FindCharInString(commandName, ' ');
        if (separator != -1)
        {
            commandName[separator] = '\0';
        }

        char registeredName[72];
        if (StrContains(commandName, "sm_", false) == 0)
        {
            strcopy(registeredName, sizeof(registeredName), commandName);
        }
        else
        {
            Format(registeredName, sizeof(registeredName), "sm_%s", commandName);
        }

        if (commandName[0] != '\0' && CommandExists(registeredName))
        {
            return Plugin_Continue;
        }

        char silentTriggers[16];
        GetSilentChatTriggers(silentTriggers, sizeof(silentTriggers));
        if (FindCharInString(silentTriggers, sArgs[0]) != -1)
        {
            return Plugin_Stop;
        }
    }
    else if (sArgs[0] == '@')
    {
        bool teamChat = StrEqual(command, "say_team", false);
        if (CheckCommandAccess(client, teamChat ? "sm_chat" : "sm_say", ADMFLAG_CHAT))
        {
            return Plugin_Continue;
        }
    }

    if (GetFeatureStatus(FeatureType_Native, "BaseComm_IsClientGagged") == FeatureStatus_Available
        && BaseComm_IsClientGagged(client))
    {
        return Plugin_Continue;
    }

    char chatState[20];
    int senderTeam = GetClientTeam(client);
    if (senderTeam < CS_TEAM_T)
    {
        strcopy(chatState, sizeof(chatState), "*SPEC*");
    }
    else if (!IsPlayerAlive(client))
    {
        strcopy(chatState, sizeof(chatState), "*DEAD*");
    }
    else if (StrEqual(command, "say_team", false))
    {
        strcopy(chatState, sizeof(chatState), "(TEAM)");
    }

    char nameColor[12];
    if (senderTeam == GetInvisantTeam())
    {
        strcopy(nameColor, sizeof(nameColor), "\x077FA7FF");
    }
    else if (senderTeam == GetVisibleTeam())
    {
        strcopy(nameColor, sizeof(nameColor), "\x07E07A6A");
    }
    else
    {
        strcopy(nameColor, sizeof(nameColor), "\x01");
    }

    bool teamChat = StrEqual(command, "say_team", false);
    SanitizeChat(message, sizeof(message));
    for (int receiver = 1; receiver <= MaxClients; receiver++)
    {
        if (!IsHumanClient(receiver)
            || !CanReceiveShroudfireChat(client, receiver, teamChat))
        {
            continue;
        }

        if (chatState[0] == '\0')
        {
            PrintToChat(receiver, "%s%N\x01 :  %s", nameColor, client, message);
        }
        else
        {
            PrintToChat(receiver, "\x01%s %s%N\x01 :  %s", chatState, nameColor, client, message);
        }
    }

    return Plugin_Stop;
}

public Action Hook_TextMessage(
    UserMsg msgId,
    BfRead message,
    const int[] players,
    int playersNum,
    bool reliable,
    bool init
)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    message.ReadByte();

    char token[64];
    message.ReadString(token, sizeof(token));
    if (StrEqual(token, "#Got_bomb", false)
        || StrEqual(token, "#Hint_you_have_the_bomb", false))
    {
        return Plugin_Handled;
    }

    if (StrEqual(token, "#Game_join_ct", false)
        || StrEqual(token, "#Cstrike_game_join_ct", false)
        || StrEqual(token, "#Cstrike_TitlesTXT_Game_join_ct", false)
        || StrEqual(token, "#Game_join_ct_auto", false)
        || StrEqual(token, "#Cstrike_game_join_ct_auto", false)
        || StrEqual(token, "#Cstrike_TitlesTXT_Game_join_ct_auto", false)
        || StrEqual(token, "#Game_join_terrorist", false)
        || StrEqual(token, "#Cstrike_game_join_terrorist", false)
        || StrEqual(token, "#Cstrike_TitlesTXT_Game_join_terrorist", false)
        || StrEqual(token, "#Game_join_terrorist_auto", false)
        || StrEqual(token, "#Cstrike_game_join_terrorist_auto", false)
        || StrEqual(token, "#Cstrike_TitlesTXT_Game_join_terrorist_auto", false))
    {
        return Plugin_Handled;
    }

    if (StrEqual(token, "#CTs_Win", false)
        || StrEqual(token, "#Cstrike_TitlesTXT_CTs_Win", false)
        || StrEqual(token, "#Terrorists_Win", false)
        || StrEqual(token, "#Ts_Win", false)
        || StrEqual(token, "#Cstrike_TitlesTXT_Terrorists_Win", false))
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public Action Hook_SendAudioMessage(
    UserMsg msgId,
    BfRead message,
    const int[] players,
    int playersNum,
    bool reliable,
    bool init
)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    char audio[96];
    for (int field = 0; field < 3 && message.BytesLeft > 0; field++)
    {
        message.ReadString(audio, sizeof(audio));
        if (StrContains(audio, "rounddraw", false) != -1
            || StrContains(audio, "ctwin", false) != -1
            || StrContains(audio, "terwin", false) != -1
            || StrContains(audio, "letsgo", false) != -1
            || StrContains(audio, "locknload", false) != -1
            || StrContains(audio, "moveout", false) != -1)
        {
            return Plugin_Handled;
        }
    }

    float now = GetEngineTime();
    return now <= g_BlockRoundStartAudioUntil || now <= g_BlockRoundEndAudioUntil
        ? Plugin_Handled
        : Plugin_Continue;
}

void StopStockRoundAudio()
{
    if (!IsModActive())
    {
        return;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsHumanClient(client))
        {
            continue;
        }

        for (int index = 0; index < sizeof(SHROUDFIRE_MUTED_STOCK_SOUNDS); index++)
        {
            StopSound(
                client,
                SHROUDFIRE_MUTED_STOCK_SOUND_CHANNELS[index],
                SHROUDFIRE_MUTED_STOCK_SOUNDS[index]
            );
        }
    }
}

public Action Timer_StopStockRoundAudio(Handle timer)
{
    StopStockRoundAudio();
    return Plugin_Stop;
}

void SuppressStockRoundAudio()
{
    if (!IsModActive())
    {
        return;
    }

    StopStockRoundAudio();
    CreateTimer(0.1, Timer_StopStockRoundAudio, _, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.5, Timer_StopStockRoundAudio, _, TIMER_FLAG_NO_MAPCHANGE);
}

void TerminateRoundWithoutStockAudio(float delay, CSRoundEndReason reason)
{
    g_BlockRoundEndAudioUntil = GetEngineTime() + delay + 5.0;
    SuppressStockRoundAudio();
    CS_TerminateRound(delay, reason, true);
}

public Action Hook_HintTextMessage(
    UserMsg msgId,
    BfRead message,
    const int[] players,
    int playersNum,
    bool reliable,
    bool init
)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    char token[64];
    message.ReadString(token, sizeof(token));
    return StrEqual(token, "#Hint_you_have_the_bomb", false)
        ? Plugin_Handled
        : Plugin_Continue;
}

public Action Hook_VguiMenuMessage(
    UserMsg msgId,
    BfRead message,
    const int[] players,
    int playersNum,
    bool reliable,
    bool init
)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    char panelName[64];
    message.ReadString(panelName, sizeof(panelName));
    bool show = message.ReadByte() != 0;
    if (!show)
    {
        return Plugin_Continue;
    }

    if (StrEqual(panelName, "team", false))
    {
        return Plugin_Handled;
    }

    if (StrEqual(panelName, "buy", false) || StrEqual(panelName, "buymenu", false))
    {
        for (int index = 0; index < playersNum; index++)
        {
            if (IsInvisantPlayer(players[index]))
            {
                return Plugin_Handled;
            }
        }
    }

    return Plugin_Continue;
}

public Action Hook_AmbientSound(
    char sample[PLATFORM_MAX_PATH],
    int &entity,
    float &volume,
    int &level,
    int &pitch,
    float position[3],
    int &flags,
    float &delay
)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    return StrContains(sample, "ctwin", false) != -1
        || StrContains(sample, "terwin", false) != -1
        || StrContains(sample, "rounddraw", false) != -1
        || StrContains(sample, "letsgo", false) != -1
        || StrContains(sample, "locknload", false) != -1
        || StrContains(sample, "moveout", false) != -1
        ? Plugin_Stop
        : Plugin_Continue;
}

public Action Hook_NormalSound(
    int clients[MAXPLAYERS],
    int &numClients,
    char sample[PLATFORM_MAX_PATH],
    int &entity,
    int &channel,
    float &volume,
    int &level,
    int &pitch,
    int &flags,
    char soundEntry[PLATFORM_MAX_PATH],
    int &seed
)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    bool stockRoundWinSound = StrContains(soundEntry, "ctwin", false) != -1
        || StrContains(soundEntry, "terwin", false) != -1
        || StrContains(soundEntry, "rounddraw", false) != -1
        || StrContains(sample, "radio/ctwin.wav", false) != -1
        || StrContains(sample, "radio/terwin.wav", false) != -1
        || StrContains(sample, "radio/rounddraw.wav", false) != -1;
    bool stockRoundStartVoice = StrContains(soundEntry, "letsgo", false) != -1
        || StrContains(soundEntry, "locknload", false) != -1
        || StrContains(soundEntry, "moveout", false) != -1
        || StrContains(sample, "radio/letsgo.wav", false) != -1
        || StrContains(sample, "radio/locknload.wav", false) != -1
        || StrContains(sample, "radio/moveout.wav", false) != -1;
    if (stockRoundWinSound || stockRoundStartVoice)
    {
        return Plugin_Stop;
    }

    int source = entity;
    if (source > MaxClients && IsValidEntity(source))
    {
        if (HasEntProp(source, Prop_Send, "m_hOwnerEntity"))
        {
            source = GetEntPropEnt(source, Prop_Send, "m_hOwnerEntity");
        }
        else if (HasEntProp(source, Prop_Data, "m_hOwnerEntity"))
        {
            source = GetEntPropEnt(source, Prop_Data, "m_hOwnerEntity");
        }
        else if (HasEntProp(source, Prop_Send, "m_hOwner"))
        {
            source = GetEntPropEnt(source, Prop_Send, "m_hOwner");
        }
        else if (HasEntProp(source, Prop_Data, "m_hOwner"))
        {
            source = GetEntPropEnt(source, Prop_Data, "m_hOwner");
        }
    }

    if (!IsHumanClient(source) || GetClientTeam(source) != GetInvisantTeam())
    {
        return Plugin_Continue;
    }

    bool invisantKnifeSound;
    bool invisantClawMissSound;
    bool invisantClawPlayerHitSound;
    bool invisantClawWorldSound;
    for (int index = 0; index < sizeof(INVISANT_CLAW_STOCK_SOUNDS); index++)
    {
        if (StrContains(sample, INVISANT_CLAW_STOCK_SOUNDS[index], false) != -1)
        {
            invisantKnifeSound = true;
            invisantClawMissSound = (index == 6 || index == 7) && g_CvarKnifeMissSound.BoolValue;
            invisantClawWorldSound = index == 5 && g_CvarKnifeWorldHitSound.BoolValue;
            invisantClawPlayerHitSound = (index >= 1 && index <= 4) || index == 8;
            if (invisantClawPlayerHitSound)
            {
                strcopy(sample, PLATFORM_MAX_PATH, INVISANT_CLAW_HIT_SOUND);
            }
            else
            {
                strcopy(sample, PLATFORM_MAX_PATH, INVISANT_CLAW_SOUNDS[index]);
            }
            break;
        }
    }

    if (invisantKnifeSound && g_InvisantClawSuppressNativeDamage[source])
    {
        return Plugin_Stop;
    }

    bool playerMovementSample = StrContains(sample, "player/", false) == 0
        && (StrContains(sample, "footstep", false) != -1
            || StrContains(sample, "pl_jump", false) != -1
            || StrContains(sample, "pl_land", false) != -1);
    bool playerMovementEntry = StrContains(soundEntry, "footstep", false) != -1
        || StrContains(soundEntry, "jump", false) != -1
        || StrContains(soundEntry, "land", false) != -1;
    bool hideFromInvisantTeam = playerMovementSample || playerMovementEntry;

    int kept;
    bool sourceIncluded;
    for (int index = 0; index < numClients; index++)
    {
        int receiver = clients[index];
        if (!IsHumanClient(receiver))
        {
            continue;
        }

        if (GetClientTeam(receiver) == GetInvisantTeam())
        {
            if (hideFromInvisantTeam || (invisantClawPlayerHitSound && receiver == source))
            {
                continue;
            }
            clients[kept++] = receiver;
            sourceIncluded = sourceIncluded || receiver == source;
        }
        else if ((invisantClawMissSound || invisantClawWorldSound) && GetClientTeam(receiver) == GetVisibleTeam())
        {
            clients[kept++] = receiver;
        }
        else if (CanAdminObserveInvisant(receiver))
        {
            clients[kept++] = receiver;
        }
    }

    if (invisantClawMissSound || invisantClawWorldSound)
    {
        for (int receiver = 1; receiver <= MaxClients && kept < MAXPLAYERS; receiver++)
        {
            if (!IsHumanClient(receiver) || GetClientTeam(receiver) != GetVisibleTeam())
            {
                continue;
            }

            bool alreadyIncluded;
            for (int index = 0; index < kept; index++)
            {
                if (clients[index] == receiver)
                {
                    alreadyIncluded = true;
                    break;
                }
            }
            if (!alreadyIncluded)
            {
                clients[kept++] = receiver;
            }
        }
    }

    if (invisantKnifeSound
        && !invisantClawPlayerHitSound
        && !sourceIncluded
        && kept < MAXPLAYERS)
    {
        clients[kept++] = source;
    }

    if (kept == 0)
    {
        return Plugin_Stop;
    }
    if (kept != numClients || invisantKnifeSound)
    {
        numClients = kept;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if (IsModActive() && IsShroudfireObjective(classname))
    {
        CreateTimer(
            0.1,
            Timer_RemoveObjectiveEntity,
            EntIndexToEntRef(entity),
            TIMER_FLAG_NO_MAPCHANGE
        );
        return;
    }

    if (StrContains(classname, "weapon_", false) == 0)
    {
        if (entity > MaxClients && entity < MAX_TRACKED_EDICTS)
        {
            g_OverloadReloadOriginalClip[entity] = 0;
            g_OverloadReloadOriginalReserve[entity] = 0;
            g_OverloadReloadPending[entity] = false;
            g_OverloadInitializedWeaponRef[entity] = 0;
            g_OverloadGrantedClipBonus[entity] = 0;
        }
        SDKHook(entity, SDKHook_SetTransmit, Hook_WeaponSetTransmit);
        SDKHook(entity, SDKHook_Reload, Hook_WeaponReload);
        SDKHook(entity, SDKHook_ReloadPost, Hook_WeaponReloadPost);

    }
    else if (StrEqual(classname, "env_tonemap_controller", false))
    {
        CreateTimer(0.1, Timer_ApplyMapLighting, _, TIMER_FLAG_NO_MAPCHANGE);
    }
}

void HookClient(int client)
{
    SDKHook(client, SDKHook_SetTransmit, Hook_PlayerSetTransmit);
    SDKHook(client, SDKHook_WeaponCanUse, Hook_WeaponCanUse);
    SDKHook(client, SDKHook_WeaponEquipPost, Hook_WeaponEquipPost);
    SDKHook(client, SDKHook_WeaponDropPost, Hook_WeaponDropPost);
    SDKHook(client, SDKHook_WeaponSwitchPost, Hook_WeaponSwitchPost);
    SDKHook(client, SDKHook_TraceAttack, Hook_PlayerTraceAttack);
    SDKHook(client, SDKHook_OnTakeDamage, Hook_PlayerTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamagePost, Hook_PlayerTakeDamagePost);
    SDKHook(client, SDKHook_PreThinkPost, Hook_ClientPreThinkPost);
    SDKHook(client, SDKHook_PostThinkPost, Hook_ClientPostThinkPost);
}

void HookExistingEntities()
{
    if (IsModActive())
    {
        RemoveAllObjectives();
    }

    int maxEntities = GetMaxEntities();
    char classname[64];

    for (int entity = MaxClients + 1; entity < maxEntities; entity++)
    {
        if (!IsValidEntity(entity))
        {
            continue;
        }

        GetEntityClassname(entity, classname, sizeof(classname));
        if (StrContains(classname, "weapon_", false) == 0)
        {
            SDKHook(entity, SDKHook_SetTransmit, Hook_WeaponSetTransmit);
            SDKHook(entity, SDKHook_Reload, Hook_WeaponReload);
            SDKHook(entity, SDKHook_ReloadPost, Hook_WeaponReloadPost);
        }
    }
}

public Action Hook_PlayerSetTransmit(int entity, int client)
{
    return ShouldHideFrom(entity, client) ? Plugin_Handled : Plugin_Continue;
}

public Action Hook_WeaponSetTransmit(int entity, int client)
{
    if (!IsModActive() || !IsValidEntity(entity) || !HasEntProp(entity, Prop_Send, "m_hOwnerEntity"))
    {
        return Plugin_Continue;
    }

    int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
    if (owner != client && IsInvisantPlayer(owner))
    {
        // The owner still needs the knife entity for prediction. Other clients
        // see the zombie model without CS:S's third-person knife.
        return Plugin_Handled;
    }
    return ShouldHideFrom(owner, client) ? Plugin_Handled : Plugin_Continue;
}

bool ShouldHideFrom(int invisantClient, int viewer)
{
    if (!IsModActive()
        || !IsHumanClient(invisantClient)
        || viewer < 1
        || viewer > MaxClients
        || !IsClientInGame(viewer)
        || invisantClient == viewer)
    {
        return false;
    }

    if (g_TimeoutReveal || !IsPlayerAlive(invisantClient) || GetClientTeam(invisantClient) != GetInvisantTeam())
    {
        return false;
    }

    if (g_CvarInvisantSeeTeam.BoolValue && GetClientTeam(viewer) == GetInvisantTeam())
    {
        return false;
    }

    if (IsAdminObservingInvisant(viewer, invisantClient))
    {
        return false;
    }

    return true;
}

bool CanAdminObserveInvisant(int client)
{
    return g_CvarAdminSpectate != null
        && g_CvarAdminSpectate.BoolValue
        && IsHumanClient(client)
        && !IsPlayerAlive(client)
        && CheckCommandAccess(client, "sf_observe", ADMFLAG_GENERIC);
}

bool IsAdminObservingInvisant(int viewer, int invisantClient)
{
    return CanAdminObserveInvisant(viewer)
        && IsInvisantPlayer(invisantClient)
        && g_AdminObserveTargetUserId[viewer] == GetClientUserId(invisantClient);
}

void EnforceObserverRestrictions(int client)
{
    if (CanAdminObserveInvisant(client) && GetClientTeam(client) == CS_TEAM_SPECTATOR) return;
    if (!IsModActive()
        || !IsHumanClient(client)
        || IsPlayerAlive(client)
        || !HasEntProp(client, Prop_Send, "m_hObserverTarget"))
    {
        return;
    }

    if (HasEntProp(client, Prop_Send, "m_iObserverMode"))
    {
        int observerMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
        if (observerMode == OBS_MODE_DEATHCAM || observerMode == OBS_MODE_FREEZECAM)
        {
            // Keep the engine's real killer target long enough for CS:S to
            // build the correct "killed you" panel, but leave the view on the
            // victim so the camera does not expose the Invisant's position.
            SetClientViewEntity(client, client);
            return;
        }
    }

    int viewerTeam = GetClientTeam(client);
    int allowedTeam;
    if (viewerTeam == GetInvisantTeam())
    {
        allowedTeam = g_CvarInvisantSeeTeam.BoolValue ? GetInvisantTeam() : 0;
    }
    else
    {
        // Armitive and ordinary spectators may only follow living Armitive players.
        allowedTeam = GetVisibleTeam();
    }

    int target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
    int observedTarget = 0;
    if (IsHumanClient(target)
        && IsPlayerAlive(target)
        && target != client)
    {
        observedTarget = target;
    }
    if (HasEntProp(client, Prop_Send, "m_hViewEntity"))
    {
        int viewEntity = GetEntPropEnt(client, Prop_Send, "m_hViewEntity");
        if (IsHumanClient(viewEntity)
            && IsPlayerAlive(viewEntity)
            && viewEntity != client)
        {
            observedTarget = viewEntity;
        }
    }
    if (observedTarget > 0
        && (GetClientTeam(observedTarget) == allowedTeam
            || IsAdminObservingInvisant(client, observedTarget)))
    {
        return;
    }

    int replacement;
    for (int candidate = 1; candidate <= MaxClients; candidate++)
    {
        if (IsActiveHuman(candidate)
            && IsPlayerAlive(candidate)
            && GetClientTeam(candidate) == allowedTeam)
        {
            replacement = candidate;
            break;
        }
    }

    SetClientViewEntity(client, client);
    SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", replacement > 0 ? replacement : -1);
    if (HasEntProp(client, Prop_Send, "m_iObserverMode"))
    {
        SetEntProp(client, Prop_Send, "m_iObserverMode", replacement > 0 ? OBS_MODE_IN_EYE : OBS_MODE_FIXED);
    }
}

void UpdateAdminObservationAudit(int client)
{
    if (g_AdminObserveTargetUserId[client] == 0)
    {
        return;
    }

    int target = GetClientOfUserId(g_AdminObserveTargetUserId[client]);
    if (!CanAdminObserveInvisant(client) || (!IsActiveHuman(target) || !IsPlayerAlive(target)))
    {
        EndAdminObservationAudit(client, "observer or target became unavailable");
        return;
    }

    if (!HasEntProp(client, Prop_Send, "m_hObserverTarget")
        || GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") != target)
    {
        EndAdminObservationAudit(client, "observer changed target");
    }
}

void EndAdminObservationAudit(int client, const char[] reason)
{
    if (client < 1 || client > MaxClients || g_AdminObserveTargetUserId[client] == 0)
    {
        return;
    }

    float duration = GetEngineTime() - g_AdminObserveStartedAt[client];
    int target = GetClientOfUserId(g_AdminObserveTargetUserId[client]);
    if (IsClientConnected(client))
    {
        LogAction(
            client,
            target,
            "\"%L\" stopped observing Invisant player \"%s\" after %.1f seconds (%s).",
            client,
            g_AdminObserveTargetName[client],
            duration,
            reason
        );
    }
    else
    {
        LogMessage(
            "Administrator client %d stopped observing Invisant player \"%s\" after %.1f seconds (%s).",
            client,
            g_AdminObserveTargetName[client],
            duration,
            reason
        );
    }

    g_AdminObserveTargetUserId[client] = 0;
    g_AdminObserveStartedAt[client] = 0.0;
    g_AdminObserveTargetName[client][0] = '\0';
}

public Action Hook_WeaponCanUse(int client, int weapon)
{
    if (!IsInvisantPlayer(client) || !IsValidEntity(weapon))
    {
        return Plugin_Continue;
    }

    char classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));
    return IsKnife(classname) ? Plugin_Continue : Plugin_Handled;
}

void RestoreInvisantKnifePrediction(int client)
{
    int weapon = EntRefToEntIndex(g_InvisantKnifeWeaponRef[client]);
    if (weapon != INVALID_ENT_REFERENCE && IsValidEntity(weapon))
    {
        float readyAt = g_InvisantKnifeNextAttack[client];
        float now = GetGameTime();
        if (readyAt < now)
        {
            readyAt = now;
        }

        if (HasEntProp(weapon, Prop_Send, "m_flNextPrimaryAttack"))
        {
            SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", readyAt);
        }
        else if (HasEntProp(weapon, Prop_Data, "m_flNextPrimaryAttack"))
        {
            SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", readyAt);
        }
        if (HasEntProp(weapon, Prop_Send, "m_flNextSecondaryAttack"))
        {
            SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", readyAt);
        }
        else if (HasEntProp(weapon, Prop_Data, "m_flNextSecondaryAttack"))
        {
            SetEntPropFloat(weapon, Prop_Data, "m_flNextSecondaryAttack", readyAt);
        }

        float idleAt = g_InvisantKnifeIdleAt[client];
        if (idleAt < now)
        {
            idleAt = now;
        }
        if (HasEntProp(weapon, Prop_Send, "m_flTimeWeaponIdle"))
        {
            SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", idleAt);
        }
        else if (HasEntProp(weapon, Prop_Data, "m_flTimeWeaponIdle"))
        {
            SetEntPropFloat(weapon, Prop_Data, "m_flTimeWeaponIdle", idleAt);
        }
    }

    if (IsHumanClient(client))
    {
        int viewModel = -1;
        if (HasEntProp(client, Prop_Send, "m_hViewModel"))
        {
            viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
        }
        else if (HasEntProp(client, Prop_Data, "m_hViewModel"))
        {
            viewModel = GetEntPropEnt(client, Prop_Data, "m_hViewModel");
        }
        if (viewModel != -1 && IsValidEntity(viewModel))
        {
            if (HasEntProp(viewModel, Prop_Send, "m_flPlaybackRate"))
            {
                SetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate", 1.0);
            }
            else if (HasEntProp(viewModel, Prop_Data, "m_flPlaybackRate"))
            {
                SetEntPropFloat(viewModel, Prop_Data, "m_flPlaybackRate", 1.0);
            }
        }
    }

    g_InvisantKnifeWeaponRef[client] = INVALID_ENT_REFERENCE;
    g_InvisantKnifeAttackSequence[client] = INVISANT_CLAW_SEQUENCE_STAB_MISS;
    g_InvisantKnifeAttackPending[client] = false;
    g_InvisantKnifeIdlePending[client] = false;
    g_InvisantClawSuppressNativeDamage[client] = false;
    g_InvisantClawApplyingExtendedDamage[client] = false;
    g_InvisantKnifeNextAttack[client] = 0.0;
    g_InvisantKnifeIdleAt[client] = 0.0;
}

void ApplyInvisantClawViewModel(int client, int weapon)
{
    if (g_InvisantClawViewModelIndex <= 0
        || !IsModActive()
        || !IsActiveHuman(client)
        || !IsPlayerAlive(client)
        || GetClientTeam(client) != GetInvisantTeam()
        || !IsValidEntity(weapon))
    {
        return;
    }

    char classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));
    if (!IsKnife(classname))
    {
        return;
    }

    int weaponRef = EntIndexToEntRef(weapon);
    if (g_InvisantKnifeWeaponRef[client] != weaponRef)
    {
        RestoreInvisantKnifePrediction(client);
        g_InvisantKnifeWeaponRef[client] = weaponRef;
        float now = GetGameTime();
        g_InvisantKnifeNextAttack[client] = GetEntityTimerEnd(weapon, "m_flNextPrimaryAttack");
        float secondaryReadyAt = GetEntityTimerEnd(weapon, "m_flNextSecondaryAttack");
        if (secondaryReadyAt > g_InvisantKnifeNextAttack[client])
        {
            g_InvisantKnifeNextAttack[client] = secondaryReadyAt;
        }
        if (g_InvisantKnifeNextAttack[client] < now)
        {
            g_InvisantKnifeNextAttack[client] = now;
        }
        g_InvisantKnifeIdleAt[client] = GetEntityTimerEnd(weapon, "m_flTimeWeaponIdle");
        if (g_InvisantKnifeIdleAt[client] < now)
        {
            g_InvisantKnifeIdleAt[client] = now;
        }
        g_InvisantKnifeIdlePending[client] = true;
    }

    if (HasEntProp(weapon, Prop_Send, "m_iViewModelIndex"))
    {
        SetEntProp(weapon, Prop_Send, "m_iViewModelIndex", g_InvisantClawViewModelIndex);
    }
    else if (HasEntProp(weapon, Prop_Data, "m_iViewModelIndex"))
    {
        SetEntProp(weapon, Prop_Data, "m_iViewModelIndex", g_InvisantClawViewModelIndex);
    }

    int viewModel = -1;
    if (HasEntProp(client, Prop_Send, "m_hViewModel"))
    {
        viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    }
    else if (HasEntProp(client, Prop_Data, "m_hViewModel"))
    {
        viewModel = GetEntPropEnt(client, Prop_Data, "m_hViewModel");
    }
    if (viewModel != -1 && IsValidEntity(viewModel))
    {
        if (HasEntProp(viewModel, Prop_Send, "m_nModelIndex"))
        {
            SetEntProp(viewModel, Prop_Send, "m_nModelIndex", g_InvisantClawViewModelIndex);
        }
        else if (HasEntProp(viewModel, Prop_Data, "m_nModelIndex"))
        {
            SetEntProp(viewModel, Prop_Data, "m_nModelIndex", g_InvisantClawViewModelIndex);
        }
    }

    float predictionLockUntil = GetGameTime() + INVISANT_KNIFE_PREDICTION_LOCK_DURATION;
    float predictionRefreshAt = predictionLockUntil - 60.0;
    if (GetEntityTimerEnd(weapon, "m_flNextPrimaryAttack") < predictionRefreshAt)
    {
        if (HasEntProp(weapon, Prop_Send, "m_flNextPrimaryAttack"))
        {
            SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", predictionLockUntil);
        }
        else if (HasEntProp(weapon, Prop_Data, "m_flNextPrimaryAttack"))
        {
            SetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack", predictionLockUntil);
        }
    }
    if (GetEntityTimerEnd(weapon, "m_flNextSecondaryAttack") < predictionRefreshAt)
    {
        if (HasEntProp(weapon, Prop_Send, "m_flNextSecondaryAttack"))
        {
            SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", predictionLockUntil);
        }
        else if (HasEntProp(weapon, Prop_Data, "m_flNextSecondaryAttack"))
        {
            SetEntPropFloat(weapon, Prop_Data, "m_flNextSecondaryAttack", predictionLockUntil);
        }
    }
    if (GetEntityTimerEnd(weapon, "m_flTimeWeaponIdle") < predictionRefreshAt)
    {
        if (HasEntProp(weapon, Prop_Send, "m_flTimeWeaponIdle"))
        {
            SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", predictionLockUntil);
        }
        else if (HasEntProp(weapon, Prop_Data, "m_flTimeWeaponIdle"))
        {
            SetEntPropFloat(weapon, Prop_Data, "m_flTimeWeaponIdle", predictionLockUntil);
        }
    }
}

public void Hook_WeaponEquipPost(int client, int weapon)
{
    if (IsHumanClient(client)) RequestFrame(Frame_ApplyStockpile, GetClientSerial(client));
    if (!IsHumanClient(client) || !IsValidEntity(weapon))
    {
        return;
    }

    ApplyInvisantClawViewModel(client, weapon);

    DataPack pack;
    CreateDataTimer(0.1, Timer_ApplyOverload, pack, TIMER_FLAG_NO_MAPCHANGE);
    pack.WriteCell(GetClientSerial(client));
    pack.WriteCell(EntIndexToEntRef(weapon));
}

public void Hook_WeaponSwitchPost(int client, int weapon)
{
    if (!IsModActive() || !IsActiveHuman(client) || !IsPlayerAlive(client))
    {
        return;
    }

    ApplyInvisantClawViewModel(client, weapon);

    if (GetClientTeam(client) == GetInvisantTeam()
        && (g_AppliedUpgradeStage[client][UpgradeSlot_Momentum] > 0
            || g_AppliedUpgradeStage[client][UpgradeSlot_Mobility] > 0))
    {
        ApplyInvisantMovementSpeed(
            client,
            IsInvisantCrouchMovementActive(client)
        );
    }
    else if (GetClientTeam(client) == GetVisibleTeam()
        && g_XpLoaded[client]
        && g_AppliedUpgradeStage[client][UpgradeSlot_Dexterity] > 0
        && IsValidEntity(weapon))
    {
        DataPack pack;
        CreateDataTimer(0.0, Timer_ApplyDexterityTiming, pack, TIMER_FLAG_NO_MAPCHANGE);
        pack.WriteCell(GetClientSerial(client));
        pack.WriteCell(EntIndexToEntRef(weapon));
        pack.WriteCell(false);
    }
}

public void Hook_WeaponDropPost(int client, int weapon)
{
    if (client < 1 || client > MaxClients || !IsClientConnected(client) || !IsValidEntity(weapon))
    {
        return;
    }

    if (g_InvisantKnifeWeaponRef[client] == EntIndexToEntRef(weapon))
    {
        RestoreInvisantKnifePrediction(client);
    }

    if (!g_OverloadApplied[client] || GetWeaponBaseClip(weapon) <= 0)
    {
        return;
    }

    RestoreOverload(client, weapon, true);
}

public Action Hook_WeaponReload(int weapon)
{
    if (weapon <= MaxClients
        || weapon >= MAX_TRACKED_EDICTS
        || !IsValidEntity(weapon)
        || !HasEntProp(weapon, Prop_Send, "m_iClip1"))
    {
        return Plugin_Continue;
    }

    if (g_OverloadReloadPending[weapon])
    {
        return Plugin_Handled;
    }

    int client = GetWeaponOwner(weapon);
    g_OverloadReloadOriginalClip[weapon] = 0;
    g_OverloadReloadOriginalReserve[weapon] = 0;
    if (!CanUseOverload(client, weapon))
    {
        return Plugin_Continue;
    }

    int baseClip = GetWeaponBaseClip(weapon);
    int currentClip = GetEntProp(weapon, Prop_Send, "m_iClip1");
    if (baseClip <= 0 || currentClip < baseClip)
    {
        return Plugin_Continue;
    }

    int bonus = RoundToFloor(float(baseClip) * float(g_AppliedUpgradeStage[client][UpgradeSlot_Overload]) * OVERLOAD_INCREASE_PER_STAGE);
    if (bonus < 1 && g_CvarOverloadMagazinePercent.IntValue > 0)
    {
        bonus = 1;
    }
    if (currentClip >= baseClip + bonus
        || !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")
        || !HasEntProp(client, Prop_Send, "m_iAmmo"))
    {
        return Plugin_Handled;
    }

    int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (ammoType < 0)
    {
        return Plugin_Handled;
    }

    int reserve = GetEntProp(client, Prop_Send, "m_iAmmo", 4, ammoType);
    if (reserve <= 0)
    {
        return Plugin_Handled;
    }

    // CSS refuses to start a reload once the stock magazine is full. Briefly
    // present one missing stock round so the engine starts its real animation,
    // then restore the visible Overload values in ReloadPost. The completion
    // timer applies the actual bonus-ammo transfer after the engine is done.
    g_OverloadReloadOriginalClip[weapon] = currentClip;
    g_OverloadReloadOriginalReserve[weapon] = reserve;
    int probeClip = baseClip - 1;
    SetEntProp(weapon, Prop_Send, "m_iClip1", probeClip);
    SetEntProp(client, Prop_Send, "m_iAmmo", reserve + currentClip - probeClip, 4, ammoType);
    return Plugin_Continue;
}

public void Hook_WeaponReloadPost(int weapon, bool successful)
{
    if (weapon <= MaxClients || weapon >= MAX_TRACKED_EDICTS || !IsValidEntity(weapon))
    {
        return;
    }

    int client = GetWeaponOwner(weapon);
    int originalClip = g_OverloadReloadOriginalClip[weapon];
    int originalReserve = g_OverloadReloadOriginalReserve[weapon];
    g_OverloadReloadOriginalClip[weapon] = 0;
    g_OverloadReloadOriginalReserve[weapon] = 0;
    if (originalClip > 0
        && IsHumanClient(client)
        && HasEntProp(weapon, Prop_Send, "m_iClip1")
        && HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")
        && HasEntProp(client, Prop_Send, "m_iAmmo"))
    {
        int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
        if (ammoType >= 0)
        {
            SetEntProp(weapon, Prop_Send, "m_iClip1", originalClip);
            SetEntProp(client, Prop_Send, "m_iAmmo", originalReserve, 4, ammoType);
        }
    }

    if (successful
        && IsModActive()
        && IsActiveHuman(client)
        && IsPlayerAlive(client)
        && g_XpLoaded[client]
        && GetClientTeam(client) == GetVisibleTeam()
        && g_AppliedUpgradeStage[client][UpgradeSlot_Dexterity] > 0)
    {
        DataPack dexterityPack;
        CreateDataTimer(0.0, Timer_ApplyDexterityTiming, dexterityPack, TIMER_FLAG_NO_MAPCHANGE);
        dexterityPack.WriteCell(GetClientSerial(client));
        dexterityPack.WriteCell(EntIndexToEntRef(weapon));
        dexterityPack.WriteCell(true);
    }

    if (successful && CanUseOverload(client, weapon))
    {
        g_OverloadReloadPending[weapon] = true;
        DataPack overloadPack;
        CreateDataTimer(0.05, Timer_FinishOverloadReload, overloadPack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        overloadPack.WriteCell(GetClientSerial(client));
        overloadPack.WriteCell(EntIndexToEntRef(weapon));
        overloadPack.WriteCell(0);
        overloadPack.WriteCell(0);
    }
}

float ShortenDexterityTimer(int entity, const char[] property, float now, float speedMultiplier)
{
    PropType propType;
    if (HasEntProp(entity, Prop_Send, property))
    {
        propType = Prop_Send;
    }
    else if (HasEntProp(entity, Prop_Data, property))
    {
        propType = Prop_Data;
    }
    else
    {
        return 0.0;
    }

    float finishTime = GetEntPropFloat(entity, propType, property);
    if (finishTime <= now)
    {
        return 0.0;
    }

    float shortenedDuration = (finishTime - now) / speedMultiplier;
    SetEntPropFloat(entity, propType, property, now + shortenedDuration);
    return shortenedDuration;
}

public Action Timer_ApplyDexterityTiming(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int weapon = EntRefToEntIndex(pack.ReadCell());
    bool reloading = pack.ReadCell() != 0;
    if (!IsModActive()
        || !IsActiveHuman(client)
        || !IsPlayerAlive(client)
        || !g_XpLoaded[client]
        || GetClientTeam(client) != GetVisibleTeam()
        || g_AppliedUpgradeStage[client][UpgradeSlot_Dexterity] <= 0
        || weapon == INVALID_ENT_REFERENCE
        || !IsValidEntity(weapon)
        || GetWeaponOwner(weapon) != client
        || !HasEntProp(client, Prop_Send, "m_hActiveWeapon")
        || GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") != weapon)
    {
        return Plugin_Stop;
    }

    float now = GetGameTime();
    float speedMultiplier = 1.0 / (1.0 - (float(g_AppliedUpgradeStage[client][UpgradeSlot_Dexterity]) * DEXTERITY_SPEED_INCREASE_PER_STAGE));
    float animationDuration = ShortenDexterityTimer(client, "m_flNextAttack", now, speedMultiplier);
    float shortenedDuration = ShortenDexterityTimer(weapon, "m_flNextPrimaryAttack", now, speedMultiplier);
    if (shortenedDuration > animationDuration)
    {
        animationDuration = shortenedDuration;
    }
    shortenedDuration = ShortenDexterityTimer(weapon, "m_flNextSecondaryAttack", now, speedMultiplier);
    if (shortenedDuration > animationDuration)
    {
        animationDuration = shortenedDuration;
    }
    shortenedDuration = ShortenDexterityTimer(weapon, "m_flTimeWeaponIdle", now, speedMultiplier);
    if (shortenedDuration > animationDuration)
    {
        animationDuration = shortenedDuration;
    }

    int viewModel = -1;
    if (HasEntProp(client, Prop_Send, "m_hViewModel"))
    {
        viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    }
    else if (HasEntProp(client, Prop_Data, "m_hViewModel"))
    {
        viewModel = GetEntPropEnt(client, Prop_Data, "m_hViewModel");
    }
    if (viewModel != -1 && IsValidEntity(viewModel))
    {
        if (HasEntProp(viewModel, Prop_Send, "m_flPlaybackRate"))
        {
            SetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate", speedMultiplier);
        }
        else if (HasEntProp(viewModel, Prop_Data, "m_flPlaybackRate"))
        {
            SetEntPropFloat(viewModel, Prop_Data, "m_flPlaybackRate", speedMultiplier);
        }
    }

    if (animationDuration <= 0.0)
    {
        animationDuration = reloading ? 1.0 : 0.5;
    }
    g_DexterityAnimationToken[client]++;
    DataPack restorePack;
    CreateDataTimer(animationDuration + 0.05, Timer_RestoreDexterityPlaybackRate, restorePack, TIMER_FLAG_NO_MAPCHANGE);
    restorePack.WriteCell(GetClientSerial(client));
    restorePack.WriteCell(g_DexterityAnimationToken[client]);
    return Plugin_Stop;
}

public Action Timer_RestoreDexterityPlaybackRate(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int token = pack.ReadCell();
    if (!IsHumanClient(client) || token != g_DexterityAnimationToken[client])
    {
        return Plugin_Stop;
    }

    int viewModel = -1;
    if (HasEntProp(client, Prop_Send, "m_hViewModel"))
    {
        viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    }
    else if (HasEntProp(client, Prop_Data, "m_hViewModel"))
    {
        viewModel = GetEntPropEnt(client, Prop_Data, "m_hViewModel");
    }
    if (viewModel != -1 && IsValidEntity(viewModel))
    {
        if (HasEntProp(viewModel, Prop_Send, "m_flPlaybackRate"))
        {
            SetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate", 1.0);
        }
        else if (HasEntProp(viewModel, Prop_Data, "m_flPlaybackRate"))
        {
            SetEntPropFloat(viewModel, Prop_Data, "m_flPlaybackRate", 1.0);
        }
    }
    return Plugin_Stop;
}

public Action Timer_ApplyOverload(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int weapon = EntRefToEntIndex(pack.ReadCell());
    if (IsHumanClient(client) && weapon != INVALID_ENT_REFERENCE)
    {
        ApplyOverloadOnEquip(client, weapon);
    }
    return Plugin_Stop;
}

float GetEntityTimerEnd(int entity, const char[] property)
{
    if (HasEntProp(entity, Prop_Send, property))
    {
        return GetEntPropFloat(entity, Prop_Send, property);
    }
    if (HasEntProp(entity, Prop_Data, property))
    {
        return GetEntPropFloat(entity, Prop_Data, property);
    }
    return 0.0;
}

public Action Timer_FinishOverloadReload(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int weapon = EntRefToEntIndex(pack.ReadCell());
    int attempts = pack.ReadCell();
    int settledChecks = pack.ReadCell();
    if (weapon == INVALID_ENT_REFERENCE)
    {
        return Plugin_Stop;
    }
    if (!CanUseOverload(client, weapon))
    {
        g_OverloadReloadPending[weapon] = false;
        return Plugin_Stop;
    }

    float now = GetGameTime();
    float readyAt = now;
    float timerEnd = GetEntityTimerEnd(client, "m_flNextAttack");
    if (timerEnd > readyAt)
    {
        readyAt = timerEnd;
    }
    timerEnd = GetEntityTimerEnd(weapon, "m_flNextPrimaryAttack");
    if (timerEnd > readyAt)
    {
        readyAt = timerEnd;
    }

    bool reloading;
    if (HasEntProp(weapon, Prop_Send, "m_bInReload"))
    {
        reloading = GetEntProp(weapon, Prop_Send, "m_bInReload") != 0;
    }
    else if (HasEntProp(weapon, Prop_Data, "m_bInReload"))
    {
        reloading = GetEntProp(weapon, Prop_Data, "m_bInReload") != 0;
    }

    attempts++;
    if (reloading || readyAt > now || ++settledChecks < 2)
    {
        if (reloading || readyAt > now)
        {
            settledChecks = 0;
        }
        if (attempts >= 200)
        {
            g_OverloadReloadPending[weapon] = false;
            return Plugin_Stop;
        }

        pack.Reset();
        pack.WriteCell(GetClientSerial(client));
        pack.WriteCell(EntIndexToEntRef(weapon));
        pack.WriteCell(attempts);
        pack.WriteCell(settledChecks);
        return Plugin_Continue;
    }

    ApplyOverload(client, weapon);
    g_OverloadReloadPending[weapon] = false;
    return Plugin_Stop;
}

int GetWeaponOwner(int weapon)
{
    if (!IsValidEntity(weapon))
    {
        return -1;
    }
    if (HasEntProp(weapon, Prop_Send, "m_hOwnerEntity"))
    {
        return GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
    }
    if (HasEntProp(weapon, Prop_Data, "m_hOwnerEntity"))
    {
        return GetEntPropEnt(weapon, Prop_Data, "m_hOwnerEntity");
    }
    return -1;
}

bool CanUseOverload(int client, int weapon)
{
    int primary = IsHumanClient(client) ? GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) : -1;
    int secondary = IsHumanClient(client) ? GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) : -1;
    return IsModActive()
        && IsActiveHuman(client)
        && IsPlayerAlive(client)
        && g_XpLoaded[client]
        && GetClientTeam(client) == GetVisibleTeam()
        && g_AppliedUpgradeStage[client][UpgradeSlot_Overload] > 0
        && IsValidEntity(weapon)
        && (primary == weapon || secondary == weapon);
}

int GetWeaponBaseClip(int weapon)
{
    if (!IsValidEntity(weapon))
    {
        return 0;
    }

    char classname[32];
    GetEntityClassname(weapon, classname, sizeof(classname));
    if (StrEqual(classname, "weapon_galil"))
    {
        return 35;
    }
    if (StrEqual(classname, "weapon_ak47") || StrEqual(classname, "weapon_sg552")
        || StrEqual(classname, "weapon_m4a1") || StrEqual(classname, "weapon_aug")
        || StrEqual(classname, "weapon_tmp") || StrEqual(classname, "weapon_mac10")
        || StrEqual(classname, "weapon_mp5navy") || StrEqual(classname, "weapon_sg550"))
    {
        return 30;
    }
    if (StrEqual(classname, "weapon_famas") || StrEqual(classname, "weapon_ump45"))
    {
        return 25;
    }
    if (StrEqual(classname, "weapon_scout") || StrEqual(classname, "weapon_awp"))
    {
        return 10;
    }
    if (StrEqual(classname, "weapon_g3sg1"))
    {
        return 20;
    }
    if (StrEqual(classname, "weapon_m249"))
    {
        return 100;
    }
    if (StrEqual(classname, "weapon_m3"))
    {
        return 8;
    }
    if (StrEqual(classname, "weapon_xm1014"))
    {
        return 7;
    }
    if (StrEqual(classname, "weapon_p90"))
    {
        return 50;
    }
    if (StrEqual(classname, "weapon_glock") || StrEqual(classname, "weapon_fiveseven"))
    {
        return 20;
    }
    if (StrEqual(classname, "weapon_usp"))
    {
        return 12;
    }
    if (StrEqual(classname, "weapon_p228"))
    {
        return 13;
    }
    if (StrEqual(classname, "weapon_deagle"))
    {
        return 7;
    }
    if (StrEqual(classname, "weapon_elite"))
    {
        return 30;
    }
    return 0;
}

int GetWeaponBaseReserve(int weapon)
{
    if (!IsValidEntity(weapon))
    {
        return 0;
    }

    char classname[32];
    GetEntityClassname(weapon, classname, sizeof(classname));
    if (StrEqual(classname, "weapon_awp"))
    {
        return 30;
    }
    if (StrEqual(classname, "weapon_m3") || StrEqual(classname, "weapon_xm1014"))
    {
        return 32;
    }
    if (StrEqual(classname, "weapon_m249"))
    {
        return 200;
    }
    if (StrEqual(classname, "weapon_tmp") || StrEqual(classname, "weapon_mp5navy")
        || StrEqual(classname, "weapon_glock") || StrEqual(classname, "weapon_elite"))
    {
        return 120;
    }
    if (StrEqual(classname, "weapon_mac10") || StrEqual(classname, "weapon_ump45")
        || StrEqual(classname, "weapon_p90") || StrEqual(classname, "weapon_usp")
        || StrEqual(classname, "weapon_fiveseven"))
    {
        return 100;
    }
    if (StrEqual(classname, "weapon_p228"))
    {
        return 52;
    }
    if (StrEqual(classname, "weapon_deagle"))
    {
        return 35;
    }
    if (GetWeaponBaseClip(weapon) > 0)
    {
        return 90;
    }
    return 0;
}

void ApplyOverloadAfterAmmoPurchase(int client, int moneyBefore, const int ammoTypesBefore[2], const int reservesBefore[2])
{
    if (!IsHumanClient(client) || !IsPlayerAlive(client) || moneyBefore < 0
        || !HasEntProp(client, Prop_Send, "m_iAccount")
        || GetEntProp(client, Prop_Send, "m_iAccount") >= moneyBefore) return;
    for (int slot = 0; slot < 2; slot++)
    {
        int ammo = ammoTypesBefore[slot];
        if (ammo < 0 || ammo >= MAX_TRACKED_AMMO_TYPES) continue;
        int reserve = GetEntProp(client, Prop_Send, "m_iAmmo", 4, ammo);
        if (reserve > reservesBefore[slot]) ApplyStockpile(client, ammo);
    }
}

void ApplyOverloadStageIncrease(int client, int newStage)
{
    if (!IsHumanClient(client) || !IsPlayerAlive(client))
    {
        return;
    }

    int weapons[2];
    weapons[0] = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
    weapons[1] = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
    for (int index = 0; index < sizeof(weapons); index++)
    {
        int weapon = weapons[index];
        if (!CanUseOverload(client, weapon)
            || !HasEntProp(weapon, Prop_Send, "m_iClip1")
            || !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")
            || !HasEntProp(client, Prop_Send, "m_iAmmo"))
        {
            continue;
        }

        int baseClip = GetWeaponBaseClip(weapon);
        int baseReserve = GetWeaponBaseReserve(weapon);
        int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
        if (baseClip <= 0 || baseReserve <= 0 || ammoType < 0
            || ammoType >= MAX_TRACKED_AMMO_TYPES || weapon >= MAX_TRACKED_EDICTS)
        {
            continue;
        }
        g_OverloadInitializedWeaponRef[weapon] = EntIndexToEntRef(weapon);

        int newBonus = RoundToFloor(float(baseClip) * float(newStage) * OVERLOAD_INCREASE_PER_STAGE);
        if (newStage > 0 && newBonus < 1 && g_CvarOverloadMagazinePercent.IntValue > 0)
        {
            newBonus = 1;
        }

        int newReserveBonus = GetReserveBonus(client, weapon);
        int clipRoundsToAdd = newBonus - g_OverloadGrantedClipBonus[weapon];
        int reserveRoundsToAdd = newReserveBonus
            - g_OverloadGrantedReserveBonus[client][ammoType];
        if (newBonus > g_OverloadGrantedClipBonus[weapon])
        {
            g_OverloadGrantedClipBonus[weapon] = newBonus;
        }
        if (newReserveBonus > g_OverloadGrantedReserveBonus[client][ammoType])
        {
            g_OverloadGrantedReserveBonus[client][ammoType] = newReserveBonus;
        }
        int currentClip = GetEntProp(weapon, Prop_Send, "m_iClip1");
        int currentReserve = GetEntProp(client, Prop_Send, "m_iAmmo", 4, ammoType);

        if (clipRoundsToAdd > 0)
        {
            int targetClip = baseClip + newBonus;
            int updatedClip = currentClip + clipRoundsToAdd;
            if (updatedClip > targetClip)
            {
                updatedClip = targetClip;
            }
            if (updatedClip > currentClip)
            {
                SetEntProp(weapon, Prop_Send, "m_iClip1", updatedClip);
            }
        }

        if (reserveRoundsToAdd > 0)
        {
            int targetReserve = baseReserve + newReserveBonus;
            int updatedReserve = currentReserve + reserveRoundsToAdd;
            if (updatedReserve > targetReserve)
            {
                updatedReserve = targetReserve;
            }
            if (updatedReserve > currentReserve)
            {
                SetEntProp(client, Prop_Send, "m_iAmmo", updatedReserve, 4, ammoType);
            }
        }

        if (clipRoundsToAdd > 0 || reserveRoundsToAdd > 0)
        {
            g_OverloadApplied[client] = true;
        }
    }
}

void ApplyOverloadOnEquip(int client, int weapon)
{
    if (!CanUseOverload(client, weapon)
        || !HasEntProp(weapon, Prop_Send, "m_iClip1")
        || !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")
        || !HasEntProp(client, Prop_Send, "m_iAmmo"))
    {
        return;
    }

    int baseClip = GetWeaponBaseClip(weapon);
    int baseReserve = GetWeaponBaseReserve(weapon);
    int currentClip = GetEntProp(weapon, Prop_Send, "m_iClip1");
    int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (baseClip <= 0 || baseReserve <= 0 || ammoType < 0
        || ammoType >= MAX_TRACKED_AMMO_TYPES || weapon >= MAX_TRACKED_EDICTS)
    {
        return;
    }

    int weaponRef = EntIndexToEntRef(weapon);
    if (g_OverloadInitializedWeaponRef[weapon] == weaponRef)
    {
        return;
    }
    g_OverloadInitializedWeaponRef[weapon] = weaponRef;
    if (currentClip < baseClip)
    {
        return;
    }

    int clipBonus = RoundToFloor(float(baseClip) * float(g_AppliedUpgradeStage[client][UpgradeSlot_Overload]) * OVERLOAD_INCREASE_PER_STAGE);
    if (clipBonus < 1 && g_CvarOverloadMagazinePercent.IntValue > 0)
    {
        clipBonus = 1;
    }
    int targetClip = baseClip + clipBonus;
    if (currentClip < targetClip)
    {
        SetEntProp(weapon, Prop_Send, "m_iClip1", targetClip);
    }
    if (clipBonus > g_OverloadGrantedClipBonus[weapon])
    {
        g_OverloadGrantedClipBonus[weapon] = clipBonus;
    }

    int reserve = GetEntProp(client, Prop_Send, "m_iAmmo", 4, ammoType);
    int reserveBonus = GetReserveBonus(client, weapon);
    int targetReserve = baseReserve + reserveBonus;
    int reserveRoundsToAdd = reserveBonus
        - g_OverloadGrantedReserveBonus[client][ammoType];
    if (reserve >= baseReserve && reserveRoundsToAdd > 0)
    {
        int updatedReserve = reserve + reserveRoundsToAdd;
        if (updatedReserve > targetReserve)
        {
            updatedReserve = targetReserve;
        }
        if (updatedReserve > reserve)
        {
            SetEntProp(client, Prop_Send, "m_iAmmo", updatedReserve, 4, ammoType);
        }
    }
    if (reserve >= baseReserve
        && reserveBonus > g_OverloadGrantedReserveBonus[client][ammoType])
    {
        g_OverloadGrantedReserveBonus[client][ammoType] = reserveBonus;
    }
    g_OverloadApplied[client] = true;
}

void ApplyOverload(int client, int weapon)
{
    if (!CanUseOverload(client, weapon)
        || !HasEntProp(weapon, Prop_Send, "m_iClip1")
        || !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")
        || !HasEntProp(client, Prop_Send, "m_iAmmo"))
    {
        return;
    }

    int baseClip = GetWeaponBaseClip(weapon);
    int currentClip = GetEntProp(weapon, Prop_Send, "m_iClip1");
    int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (baseClip <= 0 || currentClip < baseClip || ammoType < 0)
    {
        return;
    }
    if (weapon < MAX_TRACKED_EDICTS)
    {
        g_OverloadInitializedWeaponRef[weapon] = EntIndexToEntRef(weapon);
    }

    int bonus = RoundToFloor(float(baseClip) * float(g_AppliedUpgradeStage[client][UpgradeSlot_Overload]) * OVERLOAD_INCREASE_PER_STAGE);
    if (bonus < 1 && g_CvarOverloadMagazinePercent.IntValue > 0)
    {
        bonus = 1;
    }
    int targetClip = baseClip + bonus;
    int needed = targetClip - currentClip;
    if (needed <= 0)
    {
        if (weapon < MAX_TRACKED_EDICTS
            && bonus > g_OverloadGrantedClipBonus[weapon])
        {
            g_OverloadGrantedClipBonus[weapon] = bonus;
        }
        g_OverloadApplied[client] = currentClip > baseClip;
        return;
    }

    int reserve = GetEntProp(client, Prop_Send, "m_iAmmo", 4, ammoType);
    if (reserve <= 0)
    {
        return;
    }
    if (needed > reserve)
    {
        needed = reserve;
    }

    SetEntProp(weapon, Prop_Send, "m_iClip1", currentClip + needed);
    SetEntProp(client, Prop_Send, "m_iAmmo", reserve - needed, 4, ammoType);
    if (weapon < MAX_TRACKED_EDICTS
        && bonus > g_OverloadGrantedClipBonus[weapon])
    {
        g_OverloadGrantedClipBonus[weapon] = bonus;
    }
    g_OverloadApplied[client] = true;
}

void RestoreOverloadFromWeapons(int client)
{
    if (!IsHumanClient(client))
    {
        return;
    }

    int weapons[2];
    weapons[0] = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
    weapons[1] = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
    for (int index = 0; index < sizeof(weapons); index++)
    {
        if (weapons[index] != -1)
        {
            RestoreOverload(client, weapons[index]);
        }
    }
}

void RestoreOverload(int client, int weapon, bool weaponDropped = false)
{
    if (client < 1 || client > MaxClients || !IsClientConnected(client) || !IsValidEntity(weapon)
        || !HasEntProp(weapon, Prop_Send, "m_iClip1")
        || !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")
        || !HasEntProp(client, Prop_Send, "m_iAmmo"))
    {
        return;
    }

    int baseClip = GetWeaponBaseClip(weapon);
    int baseReserve = GetWeaponBaseReserve(weapon);
    int currentClip = GetEntProp(weapon, Prop_Send, "m_iClip1");
    int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (baseClip <= 0 || baseReserve <= 0 || ammoType < 0)
    {
        return;
    }

    int reserve = GetEntProp(client, Prop_Send, "m_iAmmo", 4, ammoType);
    if (currentClip > baseClip)
    {
        reserve += currentClip - baseClip;
        SetEntProp(weapon, Prop_Send, "m_iClip1", baseClip);
    }
    int reserveLimit = baseReserve;
    if (weaponDropped)
    {
        int remainingWeapons[2];
        remainingWeapons[0] = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
        remainingWeapons[1] = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
        for (int index = 0; index < sizeof(remainingWeapons); index++)
        {
            int otherWeapon = remainingWeapons[index];
            if (otherWeapon == -1 || otherWeapon == weapon
                || !IsValidEntity(otherWeapon)
                || !HasEntProp(otherWeapon, Prop_Send, "m_iPrimaryAmmoType")
                || GetEntProp(otherWeapon, Prop_Send, "m_iPrimaryAmmoType") != ammoType)
            {
                continue;
            }

            int otherBaseReserve = GetWeaponBaseReserve(otherWeapon);
            int otherReserveBonus = GetReserveBonus(client, otherWeapon);
            if (otherBaseReserve + otherReserveBonus > reserveLimit)
            {
                reserveLimit = otherBaseReserve + otherReserveBonus;
            }
        }
    }
    if (reserve > reserveLimit)
    {
        reserve = reserveLimit;
    }
    SetEntProp(client, Prop_Send, "m_iAmmo", reserve, 4, ammoType);
}

public Action Hook_PlayerTraceAttack(
    int victim,
    int &attacker,
    int &inflictor,
    float &damage,
    int &damagetype,
    int &ammotype,
    int hitbox,
    int hitgroup
)
{
    if (!IsModActive()
        || !g_RoundInProgress
        || !IsInvisantPlayer(victim)
        || !IsActiveHuman(attacker)
        || GetClientTeam(attacker) != GetVisibleTeam())
    {
        return Plugin_Continue;
    }

    int attackerUserId = GetClientUserId(attacker);
    int tick = GetGameTickCount();
    if (g_HeadshotTraceTick[victim] != tick
        || g_HeadshotTraceAttackerUserId[victim] != attackerUserId)
    {
        g_HeadshotTracePending[victim] = false;
    }
    g_HeadshotTraceAttackerUserId[victim] = attackerUserId;
    g_HeadshotTraceTick[victim] = tick;
    if (hitgroup == HITGROUP_HEAD)
    {
        g_HeadshotTracePending[victim] = true;
    }
    return Plugin_Continue;
}

public Action Hook_PlayerTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (IsHumanClient(victim) && IsPlayerAlive(victim))
    {
        g_HealthBeforeDamage[victim] = GetClientHealth(victim);
    }
    else if (victim >= 1 && victim <= MaxClients)
    {
        g_HealthBeforeDamage[victim] = 0;
    }

    int traceTickDifference = GetGameTickCount() - g_HeadshotTraceTick[victim];
    bool armitiveHeadshot = IsModActive()
        && g_RoundInProgress
        && g_HeadshotTracePending[victim]
        && traceTickDifference >= 0
        && traceTickDifference <= 1
        && IsActiveHuman(attacker)
        && g_HeadshotTraceAttackerUserId[victim] == GetClientUserId(attacker)
        && IsInvisantPlayer(victim)
        && GetClientTeam(attacker) == GetVisibleTeam();
    g_HeadshotTracePending[victim] = false;
    g_HeadshotTraceAttackerUserId[victim] = 0;
    g_HeadshotTraceTick[victim] = 0;

    if (IsModActive()
        && damage > 0.0
        && IsActiveHuman(victim)
        && IsPlayerAlive(victim)
        && GetClientTeam(victim) == GetVisibleTeam()
        && g_AppliedUpgradeStage[victim][UpgradeSlot_Ward] > 0
        && g_ArmitiveWardUntil[victim] > GetGameTime())
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    Action result = Plugin_Continue;
    if (armitiveHeadshot && damage > 0.0)
    {
        float reducedDamage = damage * INVISANT_HEADSHOT_DAMAGE_SCALE;
        if (reducedDamage > INVISANT_HEADSHOT_MAX_DAMAGE)
        {
            reducedDamage = INVISANT_HEADSHOT_MAX_DAMAGE;
        }
        if (reducedDamage < damage)
        {
            damage = reducedDamage;
            result = Plugin_Changed;
        }
    }

    if (IsInvisantPlayer(victim) && (damagetype & DMG_FALL) != 0)
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    if (damage > 0.0
        && IsInvisantPlayer(victim)
        && IsInvisantPlayer(attacker)
        && victim != attacker)
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    if (IsModActive()
        && damage > 0.0
        && IsActiveHuman(victim)
        && GetClientTeam(victim) == GetVisibleTeam()
        && IsInvisantPlayer(attacker)
        && g_InvisantClawSuppressNativeDamage[attacker]
        && !g_InvisantClawApplyingExtendedDamage[attacker])
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    if (IsModActive()
        && g_RoundInProgress
        && damage > 0.0
        && IsInvisantPlayer(victim)
        && IsActiveHuman(attacker)
        && attacker != victim
        && GetClientTeam(attacker) == GetVisibleTeam())
    {
        g_LastArmitiveAttackerUserId[victim] = GetClientUserId(attacker);
    }

    if (IsModActive()
        && g_RoundInProgress
        && damage > 0.0
        && IsActiveHuman(victim)
        && GetClientTeam(victim) == GetVisibleTeam()
        && IsInvisantPlayer(attacker))
    {
        // The Invisant is claw-only. Cap every hit it deals so CSS's distinct
        // backstab damage classification cannot bypass the claw damage range.
        damage = float(RollInvisantKnifeDamage());
        return Plugin_Changed;
    }

    return result;
}

public void Hook_PlayerTakeDamagePost(
    int victim,
    int attacker,
    int inflictor,
    float damage,
    int damagetype,
    int weapon,
    const float damageForce[3],
    const float damagePosition[3]
)
{
    if (IsModActive() && damage > 0.0 && IsHumanClient(victim))
    {
        g_LastDamageAt[victim] = GetEngineTime();
        if (IsInvisantPlayer(victim) && IsActiveHuman(attacker)
            && GetClientTeam(attacker) == GetVisibleTeam() && g_RoundInProgress)
        {
            g_LastInvisantDamageDealtAt[victim] = GetGameTime();
            ClearInvisantStarvationWarning(victim);
        }
    }

    if (IsModActive()
        && g_RoundInProgress
        && damage > 0.0
        && IsHumanClient(victim)
        && GetClientTeam(victim) == GetVisibleTeam()
        && IsInvisantPlayer(attacker))
    {
        g_LastInvisantDamageDealtAt[attacker] = GetGameTime();
        ClearInvisantStarvationWarning(attacker);

        EmitSoundToClient(
            victim,
            INVISANT_CLAW_HIT_SOUND,
            victim,
            SNDCHAN_AUTO,
            SNDLEVEL_NORMAL
        );

        if (g_AppliedUpgradeStage[attacker][UpgradeSlot_Vampirism] > 0)
        {
            int health = GetClientHealth(attacker);
            if (health < 100)
            {
                health += g_AppliedUpgradeStage[attacker][UpgradeSlot_Vampirism] * VAMPIRISM_HEALTH_PER_STAGE;
                if (health > 100)
                {
                    health = 100;
                }
                SetEntityHealth(attacker, health);
            }
        }
    }

    if (IsModActive()
        && damage > 0.0
        && (damagetype & DMG_FALL) != 0
        && IsHumanClient(victim)
        && GetClientTeam(victim) == GetVisibleTeam()
        && !IsPlayerAlive(victim)
        && !g_WaitingForNextRound[victim])
    {
        ForfeitNextInvisantRole(victim, "dying from a fatal fall");
    }

    int extraBursts = g_CvarBloodAmount.IntValue;
    if (!IsModActive()
        || extraBursts <= 0
        || damage <= 0.0
        || g_BloodSprayModel <= 0
        || g_BloodDropModel <= 0
        || !IsHumanClient(victim)
        || GetClientTeam(victim) != GetInvisantTeam()
        || !IsActiveHuman(attacker)
        || GetClientTeam(attacker) != GetVisibleTeam())
    {
        return;
    }

    float position[3];
    if (GetVectorLength(damagePosition, true) > 1.0)
    {
        position[0] = damagePosition[0];
        position[1] = damagePosition[1];
        position[2] = damagePosition[2];
    }
    else
    {
        GetClientAbsOrigin(victim, position);
        position[2] += 48.0;
    }

    float direction[3];
    if (GetVectorLength(damageForce, true) > 1.0)
    {
        NormalizeVector(damageForce, direction);
    }
    else
    {
        float attackerPosition[3];
        GetClientEyePosition(attacker, attackerPosition);
        MakeVectorFromPoints(attackerPosition, position, direction);
        NormalizeVector(direction, direction);
    }

    int size = RoundToNearest(damage * 0.5) + 8;
    if (size < 10)
    {
        size = 10;
    }
    else if (size > 28)
    {
        size = 28;
    }

    int color[4] = {160, 0, 0, 255};
    for (int burst = 0; burst < extraBursts; burst++)
    {
        float burstPosition[3];
        float burstDirection[3];
        for (int axis = 0; axis < 3; axis++)
        {
            burstPosition[axis] = position[axis] + GetRandomFloat(-4.0, 4.0);
            burstDirection[axis] = direction[axis] + GetRandomFloat(-0.18, 0.18);
        }
        NormalizeVector(burstDirection, burstDirection);

        TE_SetupBloodSprite(
            burstPosition,
            burstDirection,
            color,
            size,
            g_BloodSprayModel,
            g_BloodDropModel
        );
        TE_SendToAll();
    }
}

public Action OnPlayerRunCmd(
    int client,
    int &buttons,
    int &impulse,
    float velocity[3],
    float angles[3],
    int &weapon,
    int &subtype,
    int &cmdnum,
    int &tickcount,
    int &seed,
    int mouse[2]
)
{
    if (!IsHumanClient(client))
    {
        return Plugin_Continue;
    }

    bool useButtonDown = (buttons & IN_USE) != 0;
    bool useActionRequested = g_UseButtonSampleReady[client]
        && useButtonDown
        && !g_UseButtonWasDown[client];
    g_UseButtonSampleReady[client] = true;
    g_UseButtonWasDown[client] = useButtonDown;

    float position[3];
    GetClientAbsOrigin(client, position);

    if (!g_ActivitySampleReady[client])
    {
        g_ActivitySampleReady[client] = true;
        g_LastButtons[client] = buttons;
        g_ActivityPosition[client][0] = position[0];
        g_ActivityPosition[client][1] = position[1];
        g_ActivityPosition[client][2] = position[2];
        g_ActivityAngles[client][0] = angles[0];
        g_ActivityAngles[client][1] = angles[1];
        g_ActivityAngles[client][2] = angles[2];
    }
    else
    {
        float pitchChange = FloatAbs(angles[0] - g_ActivityAngles[client][0]);
        float yawChange = FloatAbs(angles[1] - g_ActivityAngles[client][1]);
        if (pitchChange > 180.0)
        {
            pitchChange = 360.0 - pitchChange;
        }
        if (yawChange > 180.0)
        {
            yawChange = 360.0 - yawChange;
        }

        bool moved = IsPlayerAlive(client)
            && GetVectorDistance(position, g_ActivityPosition[client], true) >= 16.0;
        if (moved && IsModActive() && g_RoundInProgress && GameRules_GetProp("m_bFreezePeriod") == 0)
        {
            g_MovedThisRound[client] = true;
            g_ConsecutiveAfkDeaths[client] = 0;
        }
        bool looked = pitchChange >= 3.0 || yawChange >= 3.0;
        bool changedButtons = buttons != g_LastButtons[client];

        g_LastButtons[client] = buttons;
        if (moved || looked || changedButtons || impulse != 0)
        {
            RecordClientActivity(client);
            g_ActivityPosition[client][0] = position[0];
            g_ActivityPosition[client][1] = position[1];
            g_ActivityPosition[client][2] = position[2];
            g_ActivityAngles[client][0] = angles[0];
            g_ActivityAngles[client][1] = angles[1];
            g_ActivityAngles[client][2] = angles[2];
        }
    }

    if (IsModActive()
        && IsPlayerAlive(client)
        && g_XpLoaded[client]
        && GetClientTeam(client) == GetVisibleTeam()
        && g_AppliedUpgradeStage[client][UpgradeSlot_Control] > 0
        && (buttons & IN_ATTACK) != 0
        && HasEntProp(client, Prop_Send, "m_hActiveWeapon"))
    {
        int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if (activeWeapon != -1
            && IsValidEntity(activeWeapon)
            && GetWeaponBaseClip(activeWeapon) > 0
            && HasEntProp(activeWeapon, Prop_Send, "m_iClip1")
            && GetEntProp(activeWeapon, Prop_Send, "m_iClip1") > 0)
        {
            float now = GetGameTime();
            bool readyToFire = true;
            if (HasEntProp(activeWeapon, Prop_Send, "m_flNextPrimaryAttack")
                && GetEntPropFloat(activeWeapon, Prop_Send, "m_flNextPrimaryAttack") > now)
            {
                readyToFire = false;
            }
            if (HasEntProp(client, Prop_Send, "m_flNextAttack")
                && GetEntPropFloat(client, Prop_Send, "m_flNextAttack") > now)
            {
                readyToFire = false;
            }
            if ((HasEntProp(activeWeapon, Prop_Send, "m_bInReload")
                    && GetEntProp(activeWeapon, Prop_Send, "m_bInReload") != 0)
                || (HasEntProp(activeWeapon, Prop_Data, "m_bInReload")
                    && GetEntProp(activeWeapon, Prop_Data, "m_bInReload") != 0))
            {
                readyToFire = false;
            }

            if (readyToFire)
            {
                float reduction = float(g_AppliedUpgradeStage[client][UpgradeSlot_Control]) * CONTROL_REDUCTION_PER_STAGE;
                g_ControlShotToken[client]++;
                g_ControlWeaponRef[client] = EntIndexToEntRef(activeWeapon);
                g_ControlHadAccuracyPenalty[client] = false;
                g_ControlHadAimPunch[client] = false;
                g_ControlHadAimPunchVelocity[client] = false;
                g_ControlHadViewPunch[client] = false;

                PropType accuracyPropType;
                if (HasEntProp(activeWeapon, Prop_Send, "m_fAccuracyPenalty"))
                {
                    accuracyPropType = Prop_Send;
                    g_ControlHadAccuracyPenalty[client] = true;
                }
                else if (HasEntProp(activeWeapon, Prop_Data, "m_fAccuracyPenalty"))
                {
                    accuracyPropType = Prop_Data;
                    g_ControlHadAccuracyPenalty[client] = true;
                }
                if (g_ControlHadAccuracyPenalty[client])
                {
                    g_ControlAccuracyPenaltyBeforeShot[client] = GetEntPropFloat(activeWeapon, accuracyPropType, "m_fAccuracyPenalty");
                    SetEntPropFloat(
                        activeWeapon,
                        accuracyPropType,
                        "m_fAccuracyPenalty",
                        g_ControlAccuracyPenaltyBeforeShot[client] * (1.0 - reduction)
                    );
                }

                if (HasEntProp(client, Prop_Send, "m_aimPunchAngle"))
                {
                    GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", g_ControlAimPunchBeforeShot[client]);
                    g_ControlHadAimPunch[client] = true;
                }
                else if (HasEntProp(client, Prop_Send, "m_vecPunchAngle"))
                {
                    GetEntPropVector(client, Prop_Send, "m_vecPunchAngle", g_ControlAimPunchBeforeShot[client]);
                    g_ControlHadAimPunch[client] = true;
                }
                if (HasEntProp(client, Prop_Send, "m_aimPunchAngleVel"))
                {
                    GetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", g_ControlAimPunchVelocityBeforeShot[client]);
                    g_ControlHadAimPunchVelocity[client] = true;
                }
                else if (HasEntProp(client, Prop_Send, "m_vecPunchAngleVel"))
                {
                    GetEntPropVector(client, Prop_Send, "m_vecPunchAngleVel", g_ControlAimPunchVelocityBeforeShot[client]);
                    g_ControlHadAimPunchVelocity[client] = true;
                }
                if (HasEntProp(client, Prop_Send, "m_viewPunchAngle"))
                {
                    GetEntPropVector(client, Prop_Send, "m_viewPunchAngle", g_ControlViewPunchBeforeShot[client]);
                    g_ControlHadViewPunch[client] = true;
                }

                DataPack controlPack;
                CreateDataTimer(0.0, Timer_ApplyControlAfterShot, controlPack, TIMER_FLAG_NO_MAPCHANGE);
                controlPack.WriteCell(GetClientSerial(client));
                controlPack.WriteCell(g_ControlShotToken[client]);
                controlPack.WriteFloat(reduction);
            }
        }
    }

    bool commandChanged = false;
    if (IsInvisantPlayer(client)
        && (g_AppliedUpgradeStage[client][UpgradeSlot_Momentum] > 0
            || g_AppliedUpgradeStage[client][UpgradeSlot_Mobility] > 0))
    {
        ApplyInvisantMovementSpeed(
            client,
            IsInvisantCrouchMovementActive(client)
        );
    }

    if (IsInvisantPlayer(client))
    {
        if (useActionRequested
            && g_RoundInProgress && g_ForcedRoundEndMode == FORCED_END_NONE
            && g_AppliedUpgradeStage[client][UpgradeSlot_Surge] > 0)
        {
            float now = GetGameTime();
            // Read the engine state instead of relying on round_freeze_end.
            // That event may already have passed when the plugin is reloaded
            // or an administrator joins Invisant during an active round.
            if (GameRules_GetProp("m_bFreezePeriod") != 0)
            {
                PrintCenterText(client, "Surge unavailable until freeze time ends");
            }
            else if (g_InvisantSurgeAvailableAt[client] <= now)
            {
                if (g_InvisantSurgeAvailableAt[client] > 0.0
                    && !g_InvisantSurgeReadyCuePlayed[client])
                {
                    g_InvisantSurgeReadyCuePlayed[client] = true;
                    ClientCommand(client, "play %s", INVISANT_SURGE_READY_SOUND);
                }

                float leapDirection[3];
                GetAngleVectors(angles, leapDirection, NULL_VECTOR, NULL_VECTOR);

                float leapStart[3];
                float leapEnd[3];
                float mins[3];
                float maxs[3];
                GetClientAbsOrigin(client, leapStart);
                GetClientMins(client, mins);
                GetClientMaxs(client, maxs);
                leapStart[2] += 2.0;
                leapEnd[0] = leapStart[0] + (leapDirection[0] * INVISANT_SURGE_CLEARANCE_DISTANCE);
                leapEnd[1] = leapStart[1] + (leapDirection[1] * INVISANT_SURGE_CLEARANCE_DISTANCE);
                leapEnd[2] = leapStart[2] + (leapDirection[2] * INVISANT_SURGE_CLEARANCE_DISTANCE);

                Handle trace = TR_TraceHullFilterEx(
                    leapStart,
                    leapEnd,
                    mins,
                    maxs,
                    MASK_PLAYERSOLID,
                    TraceFilter_IgnoreClient,
                    client
                );
                bool leapBlocked = TR_StartSolid(trace) || TR_GetFraction(trace) < 0.98;
                delete trace;

                if (leapBlocked || GetEntityMoveType(client) != MOVETYPE_WALK)
                {
                    ClientCommand(client, "play %s", INVISANT_SURGE_BLOCKED_SOUND);
                    PrintCenterText(client, "Surge blocked");
                }
                else
                {
                    float leapVelocity[3];
                    float currentVelocity[3];
                    leapVelocity[0] = leapDirection[0];
                    leapVelocity[1] = leapDirection[1];
                    leapVelocity[2] = leapDirection[2];
                    ScaleVector(
                        leapVelocity,
                        INVISANT_SURGE_BASE_SPEED
                            + (float(g_AppliedUpgradeStage[client][UpgradeSlot_Surge]) * SURGE_SPEED_BOOST_PER_STAGE)
                    );
                    GetEntPropVector(client, Prop_Data, "m_vecVelocity", currentVelocity);
                    if (g_CvarSurgeAddMomentum.BoolValue)
                    {
                        AddVectors(leapVelocity, currentVelocity, leapVelocity);
                    }
                    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, leapVelocity);
                    EmitSoundToClient(
                        client,
                        INVISANT_SURGE_SOUND,
                        client,
                        SNDCHAN_AUTO,
                        SNDLEVEL_NORMAL
                    );
                    g_InvisantSurgeAvailableAt[client] = now + INVISANT_SURGE_COOLDOWN;
                    g_InvisantSurgeReadyCuePlayed[client] = false;
                    g_InvisantSurgeCooldownToken[client]++;
                    DataPack leapReadyPack;
                    CreateDataTimer(
                        INVISANT_SURGE_COOLDOWN,
                        Timer_NotifyInvisantSurgeReady,
                        leapReadyPack,
                        TIMER_FLAG_NO_MAPCHANGE
                    );
                    leapReadyPack.WriteCell(GetClientSerial(client));
                    leapReadyPack.WriteCell(g_InvisantSurgeCooldownToken[client]);
                }
            }
            else
            {
                ClientCommand(client, "play %s", INVISANT_SURGE_COOLDOWN_SOUND);
                PrintCenterText(
                    client,
                    "Surge ready in %d second%s",
                    RoundToCeil(g_InvisantSurgeAvailableAt[client] - now),
                    g_InvisantSurgeAvailableAt[client] - now > 1.0 ? "s" : ""
                );
            }
        }

        bool knifeAttackRequested = (buttons & (IN_ATTACK | IN_ATTACK2)) != 0;
        if (knifeAttackRequested
            && GameRules_GetProp("m_bFreezePeriod") == 0
            && HasEntProp(client, Prop_Send, "m_hActiveWeapon"))
        {
            int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
            if (activeWeapon != -1 && IsValidEntity(activeWeapon))
            {
                char classname[64];
                GetEntityClassname(activeWeapon, classname, sizeof(classname));
                if (IsKnife(classname))
                {
                    int weaponRef = EntIndexToEntRef(activeWeapon);
                    if (g_InvisantKnifeWeaponRef[client] != weaponRef)
                    {
                        ApplyInvisantClawViewModel(client, activeWeapon);
                    }

                    float now = GetGameTime();
                    if (!g_InvisantKnifeAttackPending[client]
                        && g_InvisantKnifeNextAttack[client] <= now
                        && GetEntityTimerEnd(client, "m_flNextAttack") <= now)
                    {
                        if (HasEntProp(activeWeapon, Prop_Send, "m_flNextPrimaryAttack"))
                        {
                            SetEntPropFloat(activeWeapon, Prop_Send, "m_flNextPrimaryAttack", now);
                        }
                        else if (HasEntProp(activeWeapon, Prop_Data, "m_flNextPrimaryAttack"))
                        {
                            SetEntPropFloat(activeWeapon, Prop_Data, "m_flNextPrimaryAttack", now);
                        }
                        if (HasEntProp(activeWeapon, Prop_Send, "m_flNextSecondaryAttack"))
                        {
                            SetEntPropFloat(activeWeapon, Prop_Send, "m_flNextSecondaryAttack", now);
                        }
                        else if (HasEntProp(activeWeapon, Prop_Data, "m_flNextSecondaryAttack"))
                        {
                            SetEntPropFloat(activeWeapon, Prop_Data, "m_flNextSecondaryAttack", now);
                        }
                        if (HasEntProp(activeWeapon, Prop_Send, "m_flTimeWeaponIdle"))
                        {
                            SetEntPropFloat(activeWeapon, Prop_Send, "m_flTimeWeaponIdle", now);
                        }
                        else if (HasEntProp(activeWeapon, Prop_Data, "m_flTimeWeaponIdle"))
                        {
                            SetEntPropFloat(activeWeapon, Prop_Data, "m_flTimeWeaponIdle", now);
                        }
                        g_InvisantClawSuppressNativeDamage[client] = false;
                        g_InvisantClawApplyingExtendedDamage[client] = false;
                        g_InvisantKnifeAttackPending[client] = true;
                        g_InvisantKnifeIdlePending[client] = false;

                        int clawTarget = FindKnifeConeTarget(client, angles);
                        int friendlyTarget = -1;

                        if (IsActiveHuman(clawTarget)
                            && IsPlayerAlive(clawTarget)
                            && GetClientTeam(clawTarget) == GetVisibleTeam())
                        {
                            int healthBefore = GetClientHealth(clawTarget);
                            g_InvisantClawSuppressNativeDamage[client] = true;
                            g_InvisantClawApplyingExtendedDamage[client] = true;
                            SDKHooks_TakeDamage(
                                clawTarget,
                                client,
                                client,
                                1.0,
                                DMG_SLASH,
                                activeWeapon,
                                NULL_VECTOR,
                                NULL_VECTOR,
                                false
                            );
                            g_InvisantClawApplyingExtendedDamage[client] = false;

                            if (IsHumanClient(clawTarget)
                                && GetClientHealth(clawTarget) < healthBefore)
                            {
                                ClientCommand(client, "play %s", INVISANT_CLAW_HIT_SOUND);
                            }
                        }
                        else if (IsInvisantPlayer(friendlyTarget)
                            && IsPlayerAlive(friendlyTarget))
                        {
                            g_InvisantClawSuppressNativeDamage[client] = true;
                            ClientCommand(client, "play %s", INVISANT_CLAW_HIT_SOUND);
                            EmitSoundToClient(
                                friendlyTarget,
                                INVISANT_CLAW_HIT_SOUND,
                                friendlyTarget,
                                SNDCHAN_AUTO,
                                SNDLEVEL_NORMAL
                            );
                        }
                    }
                }
            }
        }

        if ((buttons & IN_ATTACK) != 0)
        {
            buttons &= ~IN_ATTACK;
            buttons |= IN_ATTACK2;
            commandChanged = true;
        }
        if (impulse == 100 || impulse == 201)
        {
            impulse = 0;
            commandChanged = true;
        }
    }

    if (useActionRequested
        && g_RoundInProgress && g_ForcedRoundEndMode == FORCED_END_NONE
        && IsModActive()
        && IsPlayerAlive(client)
        && GetClientTeam(client) == GetVisibleTeam()
        && g_AppliedUpgradeStage[client][UpgradeSlot_Ward] > 0)
    {
        float now = GetGameTime();
        if (GameRules_GetProp("m_bFreezePeriod") != 0)
        {
            PrintCenterText(client, "Ward unavailable until freeze time ends");
        }
        else if (g_ArmitiveWardUntil[client] <= now
            && g_ArmitiveWardAvailableAt[client] <= now)
        {
            float immunityDuration = ARMITIVE_WARD_BASE_DURATION
                + (float(g_AppliedUpgradeStage[client][UpgradeSlot_Ward]) * ARMITIVE_WARD_DURATION_PER_STAGE);
            g_ArmitiveWardUntil[client] = now + immunityDuration;
            g_ArmitiveWardAvailableAt[client] = g_ArmitiveWardUntil[client] + ARMITIVE_WARD_COOLDOWN;
            g_ArmitiveWardReadyCuePlayed[client] = false;
            g_ArmitiveWardCycleToken[client]++;
            ApplyArmitiveWardVisuals(client);
            ClientCommand(client, "play %s", ARMITIVE_WARD_ACTIVATE_SOUND);

            DataPack shieldEndPack;
            CreateDataTimer(
                immunityDuration,
                Timer_NotifyArmitiveWardEnded,
                shieldEndPack,
                TIMER_FLAG_NO_MAPCHANGE
            );
            shieldEndPack.WriteCell(GetClientSerial(client));
            shieldEndPack.WriteCell(g_ArmitiveWardCycleToken[client]);
        }
        else if (g_ArmitiveWardUntil[client] <= now)
        {
            ClientCommand(client, "play %s", ARMITIVE_WARD_COOLDOWN_SOUND);
            PrintCenterText(
                client,
                "Ward ready in %d second%s",
                RoundToCeil(g_ArmitiveWardAvailableAt[client] - now),
                g_ArmitiveWardAvailableAt[client] - now > 1.0 ? "s" : ""
            );
        }
    }

    return commandChanged ? Plugin_Changed : Plugin_Continue;
}

public Action Timer_NotifyArmitiveWardEnded(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int cycleToken = pack.ReadCell();
    if (!IsActiveHuman(client)
        || !IsPlayerAlive(client)
        || GetClientTeam(client) != GetVisibleTeam()
        || g_AppliedUpgradeStage[client][UpgradeSlot_Ward] < 1
        || cycleToken != g_ArmitiveWardCycleToken[client]
        || g_ArmitiveWardUntil[client] <= 0.0)
    {
        return Plugin_Stop;
    }

    float remaining = g_ArmitiveWardUntil[client] - GetGameTime();
    if (remaining > 0.0)
    {
        DataPack retryPack;
        CreateDataTimer(
            remaining,
            Timer_NotifyArmitiveWardEnded,
            retryPack,
            TIMER_FLAG_NO_MAPCHANGE
        );
        retryPack.WriteCell(GetClientSerial(client));
        retryPack.WriteCell(cycleToken);
        return Plugin_Stop;
    }

    g_ArmitiveWardUntil[client] = 0.0;
    ClearArmitiveWardVisuals(client);
    ClientCommand(client, "play %s", ARMITIVE_WARD_END_SOUND);

    float cooldownRemaining = g_ArmitiveWardAvailableAt[client] - GetGameTime();
    if (cooldownRemaining < 0.0)
    {
        cooldownRemaining = 0.0;
    }
    DataPack readyPack;
    CreateDataTimer(
        cooldownRemaining,
        Timer_NotifyArmitiveWardReady,
        readyPack,
        TIMER_FLAG_NO_MAPCHANGE
    );
    readyPack.WriteCell(GetClientSerial(client));
    readyPack.WriteCell(cycleToken);
    return Plugin_Stop;
}

public Action Timer_NotifyArmitiveWardReady(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int cycleToken = pack.ReadCell();
    if (!IsActiveHuman(client)
        || !IsPlayerAlive(client)
        || GetClientTeam(client) != GetVisibleTeam()
        || g_AppliedUpgradeStage[client][UpgradeSlot_Ward] < 1
        || cycleToken != g_ArmitiveWardCycleToken[client]
        || g_ArmitiveWardReadyCuePlayed[client]
        || g_ArmitiveWardAvailableAt[client] <= 0.0)
    {
        return Plugin_Stop;
    }

    float remaining = g_ArmitiveWardAvailableAt[client] - GetGameTime();
    if (remaining > 0.0)
    {
        DataPack retryPack;
        CreateDataTimer(
            remaining,
            Timer_NotifyArmitiveWardReady,
            retryPack,
            TIMER_FLAG_NO_MAPCHANGE
        );
        retryPack.WriteCell(GetClientSerial(client));
        retryPack.WriteCell(cycleToken);
        return Plugin_Stop;
    }

    g_ArmitiveWardReadyCuePlayed[client] = true;
    ClientCommand(client, "play %s", ARMITIVE_WARD_READY_SOUND);
    return Plugin_Stop;
}

public Action Timer_NotifyInvisantSurgeReady(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int cooldownToken = pack.ReadCell();
    if (!IsInvisantPlayer(client)
        || g_AppliedUpgradeStage[client][UpgradeSlot_Surge] < 1
        || cooldownToken != g_InvisantSurgeCooldownToken[client]
        || g_InvisantSurgeReadyCuePlayed[client]
        || g_InvisantSurgeAvailableAt[client] <= 0.0)
    {
        return Plugin_Stop;
    }

    float remaining = g_InvisantSurgeAvailableAt[client] - GetGameTime();
    if (remaining > 0.0)
    {
        DataPack retryPack;
        CreateDataTimer(
            remaining,
            Timer_NotifyInvisantSurgeReady,
            retryPack,
            TIMER_FLAG_NO_MAPCHANGE
        );
        retryPack.WriteCell(GetClientSerial(client));
        retryPack.WriteCell(cooldownToken);
        return Plugin_Stop;
    }

    g_InvisantSurgeReadyCuePlayed[client] = true;
    ClientCommand(client, "play %s", INVISANT_SURGE_READY_SOUND);
    return Plugin_Stop;
}

public Action Timer_ApplyControlAfterShot(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int token = pack.ReadCell();
    float reduction = pack.ReadFloat();
    if (!IsHumanClient(client) || token != g_ControlShotToken[client])
    {
        return Plugin_Stop;
    }

    int activeWeapon = EntRefToEntIndex(g_ControlWeaponRef[client]);
    if (activeWeapon == INVALID_ENT_REFERENCE
        || !IsValidEntity(activeWeapon)
        || GetWeaponOwner(activeWeapon) != client)
    {
        return Plugin_Stop;
    }

    if (g_ControlHadAccuracyPenalty[client])
    {
        if (HasEntProp(activeWeapon, Prop_Send, "m_fAccuracyPenalty"))
        {
            float penalty = GetEntPropFloat(activeWeapon, Prop_Send, "m_fAccuracyPenalty");
            SetEntPropFloat(activeWeapon, Prop_Send, "m_fAccuracyPenalty", penalty + (g_ControlAccuracyPenaltyBeforeShot[client] * reduction));
        }
        else if (HasEntProp(activeWeapon, Prop_Data, "m_fAccuracyPenalty"))
        {
            float penalty = GetEntPropFloat(activeWeapon, Prop_Data, "m_fAccuracyPenalty");
            SetEntPropFloat(activeWeapon, Prop_Data, "m_fAccuracyPenalty", penalty + (g_ControlAccuracyPenaltyBeforeShot[client] * reduction));
        }
    }

    if (!IsModActive()
        || !IsActiveHuman(client)
        || !IsPlayerAlive(client)
        || !g_XpLoaded[client]
        || GetClientTeam(client) != GetVisibleTeam()
        || g_AppliedUpgradeStage[client][UpgradeSlot_Control] <= 0)
    {
        return Plugin_Stop;
    }

    float currentPunch[3];
    if (g_ControlHadAimPunch[client])
    {
        if (HasEntProp(client, Prop_Send, "m_aimPunchAngle"))
        {
            GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", currentPunch);
            for (int axis = 0; axis < 3; axis++)
            {
                currentPunch[axis] = g_ControlAimPunchBeforeShot[client][axis]
                    + ((currentPunch[axis] - g_ControlAimPunchBeforeShot[client][axis]) * (1.0 - reduction));
            }
            SetEntPropVector(client, Prop_Send, "m_aimPunchAngle", currentPunch);
        }
        else if (HasEntProp(client, Prop_Send, "m_vecPunchAngle"))
        {
            GetEntPropVector(client, Prop_Send, "m_vecPunchAngle", currentPunch);
            for (int axis = 0; axis < 3; axis++)
            {
                currentPunch[axis] = g_ControlAimPunchBeforeShot[client][axis]
                    + ((currentPunch[axis] - g_ControlAimPunchBeforeShot[client][axis]) * (1.0 - reduction));
            }
            SetEntPropVector(client, Prop_Send, "m_vecPunchAngle", currentPunch);
        }
    }
    if (g_ControlHadAimPunchVelocity[client])
    {
        if (HasEntProp(client, Prop_Send, "m_aimPunchAngleVel"))
        {
            GetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", currentPunch);
            for (int axis = 0; axis < 3; axis++)
            {
                currentPunch[axis] = g_ControlAimPunchVelocityBeforeShot[client][axis]
                    + ((currentPunch[axis] - g_ControlAimPunchVelocityBeforeShot[client][axis]) * (1.0 - reduction));
            }
            SetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", currentPunch);
        }
        else if (HasEntProp(client, Prop_Send, "m_vecPunchAngleVel"))
        {
            GetEntPropVector(client, Prop_Send, "m_vecPunchAngleVel", currentPunch);
            for (int axis = 0; axis < 3; axis++)
            {
                currentPunch[axis] = g_ControlAimPunchVelocityBeforeShot[client][axis]
                    + ((currentPunch[axis] - g_ControlAimPunchVelocityBeforeShot[client][axis]) * (1.0 - reduction));
            }
            SetEntPropVector(client, Prop_Send, "m_vecPunchAngleVel", currentPunch);
        }
    }
    if (g_ControlHadViewPunch[client] && HasEntProp(client, Prop_Send, "m_viewPunchAngle"))
    {
        GetEntPropVector(client, Prop_Send, "m_viewPunchAngle", currentPunch);
        for (int axis = 0; axis < 3; axis++)
        {
            currentPunch[axis] = g_ControlViewPunchBeforeShot[client][axis]
                + ((currentPunch[axis] - g_ControlViewPunchBeforeShot[client][axis]) * (1.0 - reduction));
        }
        SetEntPropVector(client, Prop_Send, "m_viewPunchAngle", currentPunch);
    }
    return Plugin_Stop;
}

public void Hook_ClientPreThinkPost(int client)
{
    if (!IsModActive() || !IsHumanClient(client))
    {
        return;
    }

    EnsurePlayerCollision(client);

    if (IsInvisantPlayer(client))
    {
        StripInvisantEquipment(client);
        EnableInvisantBlood(client);
        if (g_AppliedUpgradeStage[client][UpgradeSlot_Momentum] > 0
            || g_AppliedUpgradeStage[client][UpgradeSlot_Mobility] > 0)
        {
            ApplyInvisantMovementSpeed(
                client,
                IsInvisantCrouchMovementActive(client)
            );
        }
    }
    EnforceObserverRestrictions(client);
    UpdateAdminObservationAudit(client);
}

public void Hook_ClientPostThinkPost(int client)
{
    if (!IsInvisantPlayer(client)
        || !IsPlayerAlive(client)
        || !HasEntProp(client, Prop_Send, "m_hActiveWeapon"))
    {
        return;
    }

    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (weapon != -1)
    {
        int viewModel = -1;
        if (HasEntProp(client, Prop_Send, "m_hViewModel"))
        {
            viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
        }
        else if (HasEntProp(client, Prop_Data, "m_hViewModel"))
        {
            viewModel = GetEntPropEnt(client, Prop_Data, "m_hViewModel");
        }

        if (g_InvisantKnifeAttackPending[client]
            && g_InvisantKnifeWeaponRef[client] == EntIndexToEntRef(weapon))
        {
            float now = GetGameTime();
            float nextAttack = GetEntityTimerEnd(weapon, "m_flNextPrimaryAttack");
            float secondaryNextAttack = GetEntityTimerEnd(weapon, "m_flNextSecondaryAttack");
            if (secondaryNextAttack > nextAttack)
            {
                nextAttack = secondaryNextAttack;
            }
            if (nextAttack > now)
            {
                nextAttack = now
                    + ((nextAttack - now) / INVISANT_CLAW_ATTACK_SPEED_MULTIPLIER);
                g_InvisantKnifeNextAttack[client] = nextAttack;
                g_InvisantKnifeIdleAt[client] = GetEntityTimerEnd(weapon, "m_flTimeWeaponIdle");
                if (g_InvisantKnifeIdleAt[client] > now)
                {
                    g_InvisantKnifeIdleAt[client] = now
                        + ((g_InvisantKnifeIdleAt[client] - now) / INVISANT_CLAW_ANIMATION_SPEED_MULTIPLIER);
                }
                else
                {
                    g_InvisantKnifeIdleAt[client] = now;
                }
                g_InvisantKnifeIdlePending[client] = true;

                if (viewModel != -1 && IsValidEntity(viewModel))
                {
                    g_InvisantKnifeAttackSequence[client] =
                        g_InvisantKnifeAttackSequence[client] == INVISANT_CLAW_SEQUENCE_STAB_HIT
                            ? INVISANT_CLAW_SEQUENCE_STAB_MISS
                            : INVISANT_CLAW_SEQUENCE_STAB_HIT;
                    if (HasEntProp(viewModel, Prop_Send, "m_nSequence"))
                    {
                        SetEntProp(
                            viewModel,
                            Prop_Send,
                            "m_nSequence",
                            g_InvisantKnifeAttackSequence[client]
                        );
                    }
                    else if (HasEntProp(viewModel, Prop_Data, "m_nSequence"))
                    {
                        SetEntProp(
                            viewModel,
                            Prop_Data,
                            "m_nSequence",
                            g_InvisantKnifeAttackSequence[client]
                        );
                    }
                    if (HasEntProp(viewModel, Prop_Send, "m_flCycle"))
                    {
                        SetEntPropFloat(viewModel, Prop_Send, "m_flCycle", 0.0);
                    }
                    else if (HasEntProp(viewModel, Prop_Data, "m_flCycle"))
                    {
                        SetEntPropFloat(viewModel, Prop_Data, "m_flCycle", 0.0);
                    }
                    if (HasEntProp(viewModel, Prop_Send, "m_nAnimationParity"))
                    {
                        int parity = GetEntProp(viewModel, Prop_Send, "m_nAnimationParity");
                        SetEntProp(viewModel, Prop_Send, "m_nAnimationParity", (parity + 1) & 7);
                    }
                    if (HasEntProp(viewModel, Prop_Send, "m_flPlaybackRate"))
                    {
                        SetEntPropFloat(
                            viewModel,
                            Prop_Send,
                            "m_flPlaybackRate",
                            INVISANT_CLAW_ANIMATION_SPEED_MULTIPLIER
                        );
                    }
                    else if (HasEntProp(viewModel, Prop_Data, "m_flPlaybackRate"))
                    {
                        SetEntPropFloat(
                            viewModel,
                            Prop_Data,
                            "m_flPlaybackRate",
                            INVISANT_CLAW_ANIMATION_SPEED_MULTIPLIER
                        );
                    }
                }
            }
            g_InvisantKnifeAttackPending[client] = false;
            g_InvisantClawSuppressNativeDamage[client] = false;
            g_InvisantClawApplyingExtendedDamage[client] = false;
        }

        if (g_InvisantKnifeIdlePending[client] && g_InvisantKnifeIdleAt[client] <= GetGameTime())
        {
            if (viewModel != -1 && IsValidEntity(viewModel))
            {
                if (HasEntProp(viewModel, Prop_Send, "m_nSequence"))
                {
                    SetEntProp(viewModel, Prop_Send, "m_nSequence", INVISANT_CLAW_SEQUENCE_IDLE);
                }
                else if (HasEntProp(viewModel, Prop_Data, "m_nSequence"))
                {
                    SetEntProp(viewModel, Prop_Data, "m_nSequence", INVISANT_CLAW_SEQUENCE_IDLE);
                }
                if (HasEntProp(viewModel, Prop_Send, "m_flCycle"))
                {
                    SetEntPropFloat(viewModel, Prop_Send, "m_flCycle", 0.0);
                }
                else if (HasEntProp(viewModel, Prop_Data, "m_flCycle"))
                {
                    SetEntPropFloat(viewModel, Prop_Data, "m_flCycle", 0.0);
                }
                if (HasEntProp(viewModel, Prop_Send, "m_nAnimationParity"))
                {
                    int parity = GetEntProp(viewModel, Prop_Send, "m_nAnimationParity");
                    SetEntProp(viewModel, Prop_Send, "m_nAnimationParity", (parity + 1) & 7);
                }
                if (HasEntProp(viewModel, Prop_Send, "m_flPlaybackRate"))
                {
                    SetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate", 1.0);
                }
                else if (HasEntProp(viewModel, Prop_Data, "m_flPlaybackRate"))
                {
                    SetEntPropFloat(viewModel, Prop_Data, "m_flPlaybackRate", 1.0);
                }
            }
            g_InvisantKnifeIdlePending[client] = false;
        }
        ApplyInvisantClawViewModel(client, weapon);
    }
}

int RollInvisantKnifeDamage()
{
    int minimum = g_CvarKnifeDamageMin.IntValue;
    int maximum = g_CvarKnifeDamageMax.IntValue;
    return minimum <= maximum ? GetRandomInt(minimum, maximum) : GetRandomInt(maximum, minimum);
}

public Action CS_OnBuyCommand(int client, const char[] weapon)
{
    if (IsInvisantPlayer(client))
    {
        PrintCenterText(client, "Invisant are claw-only");
        return Plugin_Handled;
    }
    // SourceMod's purchase hook also runs for autobuy and rebuy; pickups and
    // spawn equipment do not pass through it.
    if (IsModActive() && IsActiveHuman(client) && GetClientTeam(client) == GetVisibleTeam()
        && g_BlockedWeaponIds != null)
    {
        CSWeaponID id = PurchaseWeaponId(weapon);
        if (id != CSWeapon_NONE && g_BlockedWeaponIds.FindValue(id) != -1)
        {
            PrintCenterText(client, "This weapon is unavailable in Shroudfire");
            PrintToChat(client, "%s This weapon is disabled by the server's purchase settings", CHAT_PREFIX);
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    g_BlockRoundEndAudioUntil = GetEngineTime() + delay + 5.0;

    if (CountActiveHumans() < 2 && !g_AdminSoloRestartPending)
    {
        QueueEmptyRoundRestartCheck();
        return Plugin_Handled;
    }

    if (g_ForcedRoundEndMode != FORCED_END_NONE)
    {
        g_RoundEligibleForAdvance = g_ForcedRoundEndMode == FORCED_END_COMPLETE;
        return Plugin_Continue;
    }

    int invisantAlive = CountAliveHumans(GetInvisantTeam());
    int visibleAlive = CountAliveHumans(GetVisibleTeam());

    bool playableRoundEnd = g_RoundInProgress
        && !g_ManagingRoster
        && !g_SkipNextRoundAdvance;

    // CS:S can carry its built-in Game Commencing termination into the first
    // playable two-team round. Let that startup transition through when both
    // roles are still alive, while preserving genuine elimination results.
    if (reason == CSRoundEnd_GameStart && invisantAlive > 0 && visibleAlive > 0)
    {
        return Plugin_Continue;
    }

    if (playableRoundEnd && visibleAlive == 0 && invisantAlive == 0 && CountRoundParticipants() >= 2)
    {
        g_RoundEligibleForAdvance = true;
        reason = CSRoundEnd_Draw;
        return Plugin_Changed;
    }

    if (playableRoundEnd && visibleAlive > 0 && invisantAlive == 0)
    {
        g_RoundEligibleForAdvance = true;
        reason = GetVisibleTeam() == CS_TEAM_CT ? CSRoundEnd_CTWin : CSRoundEnd_TerroristWin;
        return Plugin_Changed;
    }

    if (playableRoundEnd && invisantAlive > 0 && visibleAlive == 0)
    {
        g_RoundEligibleForAdvance = true;
        reason = GetInvisantTeam() == CS_TEAM_CT ? CSRoundEnd_CTWin : CSRoundEnd_TerroristWin;
        return Plugin_Changed;
    }

    if (reason == CSRoundEnd_GameStart)
    {
        return Plugin_Continue;
    }

    if (visibleAlive == 0 && invisantAlive == 0)
    {
        QueueEmptyRoundRestartCheck();
        if (!g_ObjectiveEndBlockedThisRound)
        {
            g_ObjectiveEndBlockedThisRound = true;
            LogMessage("Blocked an unforced zero-alive round ending; the delayed restart watchdog will resolve it.");
        }
        return Plugin_Handled;
    }

    if (!g_ObjectiveEndBlockedThisRound)
    {
        g_ObjectiveEndBlockedThisRound = true;
        LogMessage("Blocked a normal Counter-Strike objective or timeout ending while both Shroudfire teams were alive.");
    }
    return Plugin_Handled;
}

public Action Command_JoinTeam(int client, const char[] command, int argc)
{
    if (!IsModActive() || !IsHumanClient(client) || argc < 1)
    {
        return Plugin_Continue;
    }

    char argument[8];
    GetCmdArg(1, argument, sizeof(argument));
    int requestedTeam = StringToInt(argument);

    if (g_SpectatorLocked[client] && requestedTeam != CS_TEAM_SPECTATOR)
    {
        if (CountAliveHumans(CS_TEAM_T) + CountAliveHumans(CS_TEAM_CT) == 0)
        {
            g_SpectatorLocked[client] = false;
        }
        else
        {
            PrintToChat(client, "%s You left \x077FA7FFInvisant\x01 (Spectating until \x07D6B86Anext round\x01)", CHAT_PREFIX);
            return Plugin_Handled;
        }
    }

    if (requestedTeam == CS_TEAM_SPECTATOR)
    {
        if (GetClientTeam(client) == GetInvisantTeam())
        {
            g_SpectatorLocked[client] = true;
        }
        g_MapJoinRespawnEligible[client] = false;
        g_MapJoinRespawnConfirmAt[client] = 0.0;
        g_ChoseSpectator[client] = true;
        return Plugin_Continue;
    }

    if (requestedTeam == GetVisibleTeam()
        && GetClientTeam(client) == GetVisibleTeam()
        && IsPlayerAlive(client))
    {
        return Plugin_Handled;
    }

    g_ChoseSpectator[client] = false;

    if (GetClientTeam(client) == GetInvisantTeam())
    {
        PrintToChat(client, "%s \x077FA7FFInvisant\x01 is queue-assigned", CHAT_PREFIX);
        return Plugin_Handled;
    }

    if (requestedTeam == GetInvisantTeam() || requestedTeam == 0)
    {
        if (GetClientTeam(client) != GetVisibleTeam())
        {
            MarkClientWaitingForNextRound(client);
            MoveClientToTeam(client, GetVisibleTeam());
            PutAtBackOfQueue(client);
            QueueStateRefresh();
        }

        PrintToChat(client, "%s \x077FA7FFInvisant\x01 is queue-assigned", CHAT_PREFIX);
        return Plugin_Handled;
    }

    if (requestedTeam == GetVisibleTeam() && GetClientTeam(client) < CS_TEAM_T)
    {
        MarkClientWaitingForNextRound(client);
    }

    return Plugin_Continue;
}

public Action Command_BlockTeamMenu(int client, const char[] command, int argc)
{
    if (!IsModActive() || !IsHumanClient(client))
    {
        return Plugin_Continue;
    }

    int serial = GetClientSerial(client);
    CloseJoinPanels(client);
    CreateTimer(0.0, Timer_CloseJoinPanels, serial, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.1, Timer_CloseJoinPanels, serial, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Handled;
}

public Action Command_JoinClass(int client, const char[] command, int argc)
{
    if (!IsModActive() || !IsHumanClient(client))
    {
        return Plugin_Continue;
    }

    int team = GetClientTeam(client);
    if (IsPlayerAlive(client) && (team == GetVisibleTeam() || team == GetInvisantTeam()))
    {
        CloseJoinPanels(client);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public Action Command_HandleSuicide(int client, const char[] command, int argc)
{
    if (!IsModActive() || !IsHumanClient(client))
    {
        return Plugin_Continue;
    }

    if (IsPlayerAlive(client) && GetClientTeam(client) == GetVisibleTeam())
    {
        ForfeitNextInvisantRole(client, "using a suicide command");
        return Plugin_Continue;
    }

    return Plugin_Continue;
}

public Action Command_BlockInvisantSignal(int client, const char[] command, int argc)
{
    return IsModActive()
        && IsHumanClient(client)
        && GetClientTeam(client) == GetInvisantTeam()
        ? Plugin_Handled
        : Plugin_Continue;
}

void RegisterInvisantSignalListeners()
{
    AddCommandListener(Command_BlockInvisantSignal, "radio1");
    AddCommandListener(Command_BlockInvisantSignal, "radio2");
    AddCommandListener(Command_BlockInvisantSignal, "radio3");
    AddCommandListener(Command_BlockInvisantSignal, "coverme");
    AddCommandListener(Command_BlockInvisantSignal, "takepoint");
    AddCommandListener(Command_BlockInvisantSignal, "holdpos");
    AddCommandListener(Command_BlockInvisantSignal, "regroup");
    AddCommandListener(Command_BlockInvisantSignal, "followme");
    AddCommandListener(Command_BlockInvisantSignal, "takingfire");
    AddCommandListener(Command_BlockInvisantSignal, "go");
    AddCommandListener(Command_BlockInvisantSignal, "fallback");
    AddCommandListener(Command_BlockInvisantSignal, "sticktog");
    AddCommandListener(Command_BlockInvisantSignal, "getinpos");
    AddCommandListener(Command_BlockInvisantSignal, "stormfront");
    AddCommandListener(Command_BlockInvisantSignal, "report");
    AddCommandListener(Command_BlockInvisantSignal, "roger");
    AddCommandListener(Command_BlockInvisantSignal, "enemyspot");
    AddCommandListener(Command_BlockInvisantSignal, "needbackup");
    AddCommandListener(Command_BlockInvisantSignal, "sectorclear");
    AddCommandListener(Command_BlockInvisantSignal, "inposition");
    AddCommandListener(Command_BlockInvisantSignal, "reportingin");
    AddCommandListener(Command_BlockInvisantSignal, "getout");
    AddCommandListener(Command_BlockInvisantSignal, "negative");
    AddCommandListener(Command_BlockInvisantSignal, "enemydown");
}

public Action Command_ShroudfireObserve(int client, int args)
{
    if (!IsHumanClient(client) || !IsModActive() || !g_CvarAdminSpectate.BoolValue)
    {
        ReplyToCommand(client, "[Shroudfire] Admin observation unavailable.");
        return Plugin_Handled;
    }
    int target;
    if (args > 0)
    {
        char argument[64]; GetCmdArgString(argument, sizeof(argument)); StripQuotes(argument); TrimString(argument);
        target = FindTarget(client, argument, true, false);
        if (target <= 0) return Plugin_Handled;
        if (target == client || !IsActiveHuman(target) || !IsPlayerAlive(target))
        {
            ReplyToCommand(client, "[Shroudfire] Choose another living player.");
            return Plugin_Handled;
        }
    }
    else
    {
        for (int teamIndex = 0; teamIndex < 2 && target == 0; teamIndex++)
            for (int candidate = 1; candidate <= MaxClients; candidate++)
                if (candidate != client && IsActiveHuman(candidate) && IsPlayerAlive(candidate)
                    && GetClientTeam(candidate) == (teamIndex == 0 ? GetInvisantTeam() : GetVisibleTeam()))
                { target = candidate; break; }
    }
    g_ChoseSpectator[client] = true;
    if (GetClientTeam(client) == GetInvisantTeam()) g_SpectatorLocked[client] = true;
    if (GetClientTeam(client) != CS_TEAM_SPECTATOR) ChangeClientTeam(client, CS_TEAM_SPECTATOR);
    DataPack pack;
    CreateDataTimer(0.1, Timer_AdminObserve, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    pack.WriteCell(GetClientSerial(client)); pack.WriteCell(target > 0 ? GetClientUserId(target) : 0); pack.WriteCell(0);
    return Plugin_Handled;
}

public Action Timer_AdminObserve(Handle timer, DataPack pack)
{
    pack.Reset(); int serial = pack.ReadCell(), userId = pack.ReadCell(), attempts = pack.ReadCell();
    int client = GetClientFromSerial(serial), target = GetClientOfUserId(userId);
    if (!CanAdminObserveInvisant(client) || GetClientTeam(client) != CS_TEAM_SPECTATOR) return Plugin_Stop;
    if (userId != 0 && (!IsActiveHuman(target) || !IsPlayerAlive(target))) return Plugin_Stop;
    if (!HasEntProp(client, Prop_Send, "m_iObserverMode") || !HasEntProp(client, Prop_Send, "m_hObserverTarget"))
    {
        if (++attempts >= 50) return Plugin_Stop;
        pack.Reset(); pack.WriteCell(serial); pack.WriteCell(userId); pack.WriteCell(attempts); return Plugin_Continue;
    }
    EndAdminObservationAudit(client, "administrator selected another target");
    SetEntProp(client, Prop_Send, "m_iObserverMode", target > 0 ? OBS_MODE_IN_EYE : OBS_MODE_ROAMING);
    SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", target > 0 ? target : -1);
    g_AdminObserveTargetUserId[client] = userId;
    g_AdminObserveStartedAt[client] = GetEngineTime();
    if (target > 0) GetClientName(target, g_AdminObserveTargetName[client], sizeof(g_AdminObserveTargetName[]));
    LogAction(client, target, "Administrator observation started via sf_observe.");
    return Plugin_Stop;
}

public Action Command_ShroudfireStatus(int client, int args)
{
    char invisantName[32];
    char visibleName[32];
    GetRoleTeamNames(invisantName, sizeof(invisantName), visibleName, sizeof(visibleName));

    int activeHumans = CountActiveHumans();
    int desiredInvisant = GetDesiredInvisantCount(activeHumans);
    int maximumInvisant = GetDesiredInvisantCount(MaxClients);
    int terroristSpawns = CountTeamSpawns(CS_TEAM_T);
    int counterTerroristSpawns = CountTeamSpawns(CS_TEAM_CT);

    StatusLine(client, "[Shroudfire] Version %s", PLUGIN_VERSION);
    char currentMap[PLATFORM_MAX_PATH], nextMap[PLATFORM_MAX_PATH];
    GetCurrentMap(currentMap, sizeof(currentMap)); NextRotationMap(nextMap, sizeof(nextMap));
    StatusLine(client, "Map: %s | rounds: %d/%d | play minutes: %.1f/%.1f | next: %s", currentMap,
        g_MapCompletedRounds, g_CvarMapMaxRounds.IntValue, g_MapPlayedSeconds/60.0, g_CvarMapTimeLimit.FloatValue, nextMap);
    StatusLine(
        client,
        "State: %s | round: %s | bots: %s",
        IsModActive() ? "active" : (g_CvarEnabled.BoolValue ? "paused" : "disabled"),
        g_RoundInProgress ? "active" : "between rounds",
        g_BotsPresent ? "present" : "none"
    );
    StatusLine(
        client,
        "Roster: %d humans | %d/%d Invisant (%s) | %d Armitive (%s)",
        activeHumans,
        CountInvisantHumans(),
        desiredInvisant,
        invisantName,
        activeHumans - CountInvisantHumans(),
        visibleName
    );
    StatusLine(
        client,
        "Settings: %d Armitive per Invisant | round %ds | AFK death %.0fs | AFK limit %d | wallhack %s",
        g_CvarVisiblePerInvisant.IntValue,
        g_CvarRoundSeconds.IntValue,
        g_CvarAfkSeconds.FloatValue,
        g_CvarAfkLimit.IntValue,
        g_CvarWallhack.BoolValue ? "on" : "off"
    );
    StatusLine(
        client,
        "Protection: reconnect grace %ds | admin observe %s | tracking beams per-viewer",
        g_CvarQueueReconnectGrace.IntValue,
        g_CvarAdminSpectate.BoolValue ? "on" : "off"
    );
    StatusLine(
        client,
        "Spawns: T %d/%d | CT %d/%d | %d validated additions",
        terroristSpawns,
        GetInvisantTeam() == CS_TEAM_T ? maximumInvisant : MaxClients - maximumInvisant,
        counterTerroristSpawns,
        GetInvisantTeam() == CS_TEAM_CT ? maximumInvisant : MaxClients - maximumInvisant,
        g_ExtraSpawnCount
    );

    for (int target = 1; target <= MaxClients; target++)
    {
        if (!IsHumanClient(target))
        {
            continue;
        }

        int team = GetClientTeam(target);
        char role[32];
        if (team == GetInvisantTeam())
        {
            strcopy(role, sizeof(role), "Invisant");
        }
        else if (team == GetVisibleTeam())
        {
            strcopy(role, sizeof(role), "Armitive");
        }
        else
        {
            strcopy(role, sizeof(role), "spectator");
        }

        float idleSeconds = GetEngineTime() - g_LastActivityTime[target];
        StatusLine(
            client,
            "#%d %N: %s/%s | queue %d | earned %s | idle %.0fs | wait-next %s | spec-lock %s",
            GetClientUserId(target),
            target,
            role,
            IsPlayerAlive(target) ? "alive" : "dead",
            GetQueuePosition(target),
            g_EarnedInvisant[target] ? "yes" : "no",
            idleSeconds,
            g_WaitingForNextRound[target] ? "yes" : "no",
            g_SpectatorLocked[target] ? "yes" : "no"
        );
    }

    if (client > 0)
    {
        PrintToChat(client, "%s Status sent to console.", CHAT_PREFIX);
    }
    return Plugin_Handled;
}

public Action Command_ShroudfireRestart(int client, int args)
{
    if (!IsModActive())
    {
        ReplyToCommand(client, "[Shroudfire] Mod unavailable.");
        return Plugin_Handled;
    }
    if (!g_RoundInProgress || g_ForcedRoundEndMode != FORCED_END_NONE)
    {
        ReplyToCommand(client, "[Shroudfire] No active round to restart.");
        return Plugin_Handled;
    }
    int activeHumans = CountActiveHumans();
    if (activeHumans == 0)
    {
        ReplyToCommand(client, "[Shroudfire] At least one active player is required.");
        return Plugin_Handled;
    }

    // An administrative restart aborts the current attempt. Preserve the
    // roster, but do not carry partial-round promotion priority or charge the
    // Invisant with an extra round played when the replacement round starts.
    for (int target = 1; target <= MaxClients; target++)
    {
        if (IsActiveHuman(target)
            && GetClientTeam(target) == GetInvisantTeam()
            && g_InvisantRoundsPlayed[target] > 0)
        {
            g_InvisantRoundsPlayed[target]--;
        }
    }
    ClearRoundPriorities();
    g_InitialRosterAtRoundStart = false;
    g_AdvanceRosterAtRoundStart = false;
    g_RosterSelectedForNextRound = false;
    g_RoundAdvanceScheduled = false;
    g_SkipNextRoundAdvance = true;
    g_RoundEligibleForAdvance = false;
    g_ForcedRoundEndMode = FORCED_END_ABORT;
    g_AdminSoloRestartPending = activeHumans == 1;
    BeginLightingTransitionRefresh();

    ReplyToCommand(client, "[Shroudfire] Restarting the round.");
    LogAction(client, -1, "\"%L\" used sf_restart.", client);
    TerminateRoundWithoutStockAudio(0.2, CSRoundEnd_Draw);
    return Plugin_Handled;
}

public Action Command_ShroudfireLevel(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "[Shroudfire] Players only.");
        return Plugin_Handled;
    }
    if (g_XpDatabase == null || !g_XpSchemaReady)
    {
        ReplyToCommand(client, "[Shroudfire] XP unavailable.");
        return Plugin_Handled;
    }
    if (!g_XpLoaded[client])
    {
        LoadPlayerXp(client);
        ReplyToCommand(client, "[Shroudfire] XP loading. Try again shortly.");
        return Plugin_Handled;
    }

    ShowRoleXp(client, true);
    ShowRoleXp(client, false);
    return Plugin_Handled;
}

public Action Command_ShroudfireInvisant(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "[Shroudfire] Players only.");
        return Plugin_Handled;
    }
    if (!IsModActive())
    {
        ReplyToCommand(client, "[Shroudfire] Mod unavailable.");
        return Plugin_Handled;
    }
    if (GetClientTeam(client) == GetInvisantTeam())
    {
        ReplyToCommand(client, "[Shroudfire] Already Invisant.");
        return Plugin_Handled;
    }

    CloseUpgradeMenu(client);
    EndAdminObservationAudit(client, "administrator joined the Invisant team");
    g_SpectatorLocked[client] = false;
    g_ChoseSpectator[client] = false;
    g_WaitingForNextRound[client] = false;
    g_ForfeitedInvisantThisRound[client] = false;
    g_EarnedInvisant[client] = false;
    g_PromotionOrder[client] = g_QueueOrder[client];
    g_PromotedByKill[client] = false;
    g_QueueOrder[client] = 0;
    g_VisibleWaitingSince[client] = 0.0;
    SavePersistentQueue(client, GetNextBackQueueStamp(), true);
    DisableFlashlight(client);

    bool wasManagingRoster = g_ManagingRoster;
    g_ManagingRoster = true;
    MoveClientToTeam(client, GetInvisantTeam());
    g_ManagingRoster = wasManagingRoster;

    CS_RespawnPlayer(client);

    RefreshInvisantScreenTint(client);
    RecordClientActivity(client);
    g_HudUntil[client] = GetEngineTime() + HUD_SPAWN_DURATION;
    UpdateClientXpHud(client);
    UpdateClientHud(client);
    ReplyToCommand(client, "[Shroudfire] Now Invisant.");
    LogAction(client, client, "\"%L\" manually joined the Invisant team.", client);
    return Plugin_Handled;
}

public Action Command_ShroudfireSetLevel(int client, int args)
{
    if (args != 3)
    {
        ReplyToCommand(
            client,
            "[Shroudfire] Usage: sf_setlevel <player> <invisant|armitive> <level>"
        );
        return Plugin_Handled;
    }
    if (g_XpDatabase == null || !g_XpSchemaReady)
    {
        ReplyToCommand(client, "[Shroudfire] XP unavailable.");
        return Plugin_Handled;
    }

    char targetArgument[64];
    GetCmdArg(1, targetArgument, sizeof(targetArgument));
    int target = FindTarget(client, targetArgument, true, false);
    if (target <= 0)
    {
        return Plugin_Handled;
    }
    if (!g_XpLoaded[target])
    {
        LoadPlayerXp(target);
        ReplyToCommand(client, "[Shroudfire] %N's XP is loading. Try again shortly.", target);
        return Plugin_Handled;
    }

    char roleArgument[16];
    GetCmdArg(2, roleArgument, sizeof(roleArgument));
    bool invisantRole;
    if (StrEqual(roleArgument, "invisant", false))
    {
        invisantRole = true;
    }
    else if (StrEqual(roleArgument, "armitive", false))
    {
        invisantRole = false;
    }
    else
    {
        ReplyToCommand(client, "[Shroudfire] Role must be invisant or armitive.");
        return Plugin_Handled;
    }

    int level;
    int maximumLevel = MAX_PLAYER_LEVEL;
    if (!GetCmdArgIntEx(3, level) || level < 0 || level > maximumLevel)
    {
        ReplyToCommand(client, "[Shroudfire] Level must be 0-%d.", maximumLevel);
        return Plugin_Handled;
    }

    int oldLevel = GetXpLevel(invisantRole ? g_InvisibleXp[target] : g_VisibleXp[target]);
    int resetStages = invisantRole
        ? g_UpgradeStage[target][UpgradeSlot_Lightweight] + g_UpgradeStage[target][UpgradeSlot_Momentum] + g_UpgradeStage[target][UpgradeSlot_Resilience] + g_UpgradeStage[target][UpgradeSlot_Vampirism] + g_UpgradeStage[target][UpgradeSlot_Reforging] + g_UpgradeStage[target][UpgradeSlot_Bloodlust] + g_UpgradeStage[target][UpgradeSlot_Mobility] + g_UpgradeStage[target][UpgradeSlot_Surge]
        : g_UpgradeStage[target][UpgradeSlot_Fortitude] + g_UpgradeStage[target][UpgradeSlot_Overload] + g_UpgradeStage[target][UpgradeSlot_Stockpile] + g_UpgradeStage[target][UpgradeSlot_Barrage] + g_UpgradeStage[target][UpgradeSlot_Recovery] + g_UpgradeStage[target][UpgradeSlot_Dexterity] + g_UpgradeStage[target][UpgradeSlot_Control] + g_UpgradeStage[target][UpgradeSlot_Ward];
    int xp = GetXpRequiredForLevel(level);
    int availablePoints = ClampUpgradePoints(level, 0);
    if (invisantRole)
    {
        g_InvisibleXp[target] = xp;
        g_UpgradeStage[target][UpgradeSlot_Lightweight] = 0;
        g_UpgradeStage[target][UpgradeSlot_Momentum] = 0;
        g_UpgradeStage[target][UpgradeSlot_Resilience] = 0;
        g_UpgradeStage[target][UpgradeSlot_Vampirism] = 0;
        g_UpgradeStage[target][UpgradeSlot_Reforging] = 0;
        g_UpgradeStage[target][UpgradeSlot_Bloodlust] = 0;
        g_UpgradeStage[target][UpgradeSlot_Mobility] = 0;
        g_UpgradeStage[target][UpgradeSlot_Surge] = 0;
        g_InvisibleUpgradePoints[target] = availablePoints;
    }
    else
    {
        g_VisibleXp[target] = xp;
        g_UpgradeStage[target][UpgradeSlot_Fortitude] = 0;
        g_UpgradeStage[target][UpgradeSlot_Overload] = 0;
        g_UpgradeStage[target][UpgradeSlot_Stockpile] = 0;
        g_UpgradeStage[target][UpgradeSlot_Barrage] = 0;
        g_UpgradeStage[target][UpgradeSlot_Recovery] = 0;
        g_UpgradeStage[target][UpgradeSlot_Dexterity] = 0;
        g_UpgradeStage[target][UpgradeSlot_Control] = 0;
        g_UpgradeStage[target][UpgradeSlot_Ward] = 0;
        g_VisibleUpgradePoints[target] = availablePoints;
    }
    SyncAppliedUpgradeStages(target, invisantRole);

    CloseUpgradeMenu(target);
    if (IsModActive())
    {
        if (IsPlayerAlive(target)
            && GetClientTeam(target) == (invisantRole ? GetInvisantTeam() : GetVisibleTeam()))
        {
            int healthBeforeChange = GetClientHealth(target);
            int armorBeforeChange = invisantRole && HasEntProp(target, Prop_Send, "m_ArmorValue")
                ? GetEntProp(target, Prop_Send, "m_ArmorValue")
                : -1;
            float shieldAvailableBeforeChange = g_ArmitiveWardAvailableAt[target];
            ApplyPlayerUpgrades(target);
            if (invisantRole && armorBeforeChange >= 0)
            {
                SetEntProp(target, Prop_Send, "m_ArmorValue", armorBeforeChange > INVISANT_BASE_ARMOR
                    ? INVISANT_BASE_ARMOR : armorBeforeChange);
            }
            else if (!invisantRole && GetClientHealth(target) > healthBeforeChange)
            {
                SetEntityHealth(target, healthBeforeChange);
            }
            if (!invisantRole)
            {
                g_ArmitiveWardAvailableAt[target] = shieldAvailableBeforeChange;
            }
        }
        QueueUpgradeMenu(target, invisantRole, 0.1);
    }
    SavePlayerXp(target);
    UpdateClientXpHud(target);

    char roleName[16];
    strcopy(roleName, sizeof(roleName), invisantRole ? "Invisant" : "Armitive");
    ReplyToCommand(
        client,
        "[Shroudfire] %N: %s %d -> %d (%d XP); reset %d stage%s; %d point%s available.",
        target,
        roleName,
        oldLevel,
        level,
        xp,
        resetStages,
        resetStages == 1 ? "" : "s",
        availablePoints,
        availablePoints == 1 ? "" : "s"
    );
    if (target != client)
    {
        PrintToChat(
            target,
            "%s %s set to level %d (%d XP); upgrades reset; %d point%s available.",
            CHAT_PREFIX,
            roleName,
            level,
            xp,
            availablePoints,
            availablePoints == 1 ? "" : "s"
        );
    }
    LogAction(
        client,
        target,
        "\"%L\" set \"%L\"'s %s level from %d to %d (%d XP), resetting %d purchased upgrade stages and making %d upgrade points available.",
        client,
        target,
        roleName,
        oldLevel,
        level,
        xp,
        resetStages,
        availablePoints
    );
    return Plugin_Handled;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    float freezeSeconds = g_CvarFreezeTime == null ? 0.0 : g_CvarFreezeTime.FloatValue;
    g_BlockRoundStartAudioUntil = GetEngineTime() + freezeSeconds + 2.0;
    SuppressStockRoundAudio();

    if (g_RoundResultHudSync != null)
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsHumanClient(client))
            {
                ClearSyncHud(client, g_RoundResultHudSync);
            }
        }
    }

    int activeHumans = CountActiveHumans();
    bool adminSoloRestart = IsModActive()
        && g_AdminSoloRestartPending
        && activeHumans == 1;
    g_AdminSoloRestartPending = false;
    g_AdminSoloRoundActive = adminSoloRestart;
    bool rosterApplied;
    if (IsModActive() && activeHumans >= 2)
    {
        if (g_InitialRosterAtRoundStart || CountInvisantHumans() == 0)
        {
            g_InitialRosterAtRoundStart = false;
            g_AdvanceRosterAtRoundStart = false;
            SelectInitialRoster(false);
            rosterApplied = true;
        }
        else if (g_AdvanceRosterAtRoundStart)
        {
            g_AdvanceRosterAtRoundStart = false;
            SelectNextRoster();
            rosterApplied = true;
        }
    }
    else
    {
        g_InitialRosterAtRoundStart = false;
        g_AdvanceRosterAtRoundStart = false;
    }

    ResetRoundParity();
    g_RoundSerial++;
    g_FirstBloodClaimed = false;
    CancelRoundTimeout();
    g_RoundInProgress = true;
    g_RoundStartedAt = GetGameTime();
    g_RoundLiveStartedAt = 0.0;
    g_InvisantStarvationRoundStartedAt = 0.0;
    g_ObjectiveEndBlockedThisRound = false;
    g_RoundEligibleForAdvance = false;
    g_RoundWinXpSuppressed = false;
    g_ForcedRoundEndMode = FORCED_END_NONE;
    g_SkipNextRoundAdvance = false;
    g_BetweenRounds = false;
    g_RosterSelectedForNextRound = false;
    g_RoundAdvanceScheduled = false;
    ClearAllAssistDamage();

    if (rosterApplied)
    {
        CreateTimer(0.05, Timer_RespawnAppliedRoster, g_RoundSerial, TIMER_FLAG_NO_MAPCHANGE);
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (g_XpLoaded[client])
        {
            SyncAppliedUpgradeStages(client, true);
            SyncAppliedUpgradeStages(client, false);
        }
        g_SpectatorLocked[client] = false;
        g_WaitingForNextRound[client] = false;
        g_PromotedByKill[client] = false;
        g_PromotionOrder[client] = 0;
        g_LastArmitiveAttackerUserId[client] = 0;
        g_LastInvisantDamageDealtAt[client] = 0.0;
        g_StarvationForcedDeath[client] = false;
        ClearInvisantStarvationWarning(client);
        g_ActivitySampleReady[client] = false;
        CreateTimer(0.0, Timer_CloseJoinPanels, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
        g_ForfeitedInvisantThisRound[client] = false;
        g_RoundKills[client] = 0;
        g_KillStreakCount[client] = 0;
        g_LastKillAt[client] = 0.0;
        if (IsActiveHuman(client) && GetClientTeam(client) == GetInvisantTeam())
        {
            g_InvisantRoundsPlayed[client]++;
        }
    }

    if (!IsModActive())
    {
        return;
    }

    OverrideGameCvars();
    BeginLightingTransitionRefresh();
    RemoveAllObjectives();
    QueueEmptyRoundRestartCheck();

    float timeout = GetConfiguredRoundSeconds();
    if (g_CvarFreezeTime != null)
    {
        timeout += g_CvarFreezeTime.FloatValue;
    }
    StartRoundTimeout(timeout);

    g_LastActiveHumans = activeHumans;
    if (activeHumans < 2)
    {
        CancelRoundTimeout();
        if (!g_AdminSoloRoundActive)
        {
            MoveEveryoneToVisible(true);
        }
        return;
    }

}

public Action Timer_PlayRoundStartVoices(Handle timer, int roundSerial)
{
    if (!IsModActive() || !g_RoundInProgress || roundSerial != g_RoundSerial
        || (CountActiveHumans() < 2 && !g_AdminSoloRoundActive)) return Plugin_Stop;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsActiveHuman(client) || g_WaitingForNextRound[client]) continue;
        PlayRandomVoice(client, Audio_RoundStart,
            GetClientTeam(client) == GetInvisantTeam() ? Voice_InvisantStart : Voice_ArmitiveStart);
    }
    return Plugin_Stop;
}

public void Event_RoundFreezeEnd(Event event, const char[] name, bool dontBroadcast)
{
    g_BlockRoundStartAudioUntil = GetEngineTime() + 2.0;
    SuppressStockRoundAudio();
    if (IsModActive() && g_RoundInProgress && CountActiveHumans() >= 2)
    {
        g_RoundLiveStartedAt = GetGameTime();
        g_InvisantStarvationRoundStartedAt = GetGameTime();
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsInvisantPlayer(client) && IsPlayerAlive(client))
            {
                g_LastInvisantDamageDealtAt[client] = g_InvisantStarvationRoundStartedAt;
            }
            ClearInvisantStarvationWarning(client);
        }
        StartRoundTimeout(GetConfiguredRoundSeconds());
    }

    if (IsModActive()
        && g_RoundInProgress
        && (CountActiveHumans() >= 2 || g_AdminSoloRoundActive))
    {
        CreateTimer(0.25, Timer_PlayRoundStartVoices, g_RoundSerial, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Event_WinPanel(Event event, const char[] name, bool dontBroadcast)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    // The stock panel hard-codes Counter-Terrorist/Terrorist role names and
    // generates unrelated fun facts such as "knife to a gunfight". Shroudfire
    // shows its own role-aware result instead.
    event.BroadcastDisabled = true;
    return Plugin_Changed;
}

public Action Timer_RespawnAppliedRoster(Handle timer, int roundSerial)
{
    if (!IsModActive() || !g_RoundInProgress || roundSerial != g_RoundSerial)
    {
        return Plugin_Stop;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsActiveHuman(client))
        {
            continue;
        }

        g_WaitingForNextRound[client] = false;
        CS_RespawnPlayer(client);
        if (IsPlayerAlive(client))
        {
            g_MapJoinRespawnEligible[client] = false;
            g_MapJoinRespawnConfirmAt[client] = 0.0;
        }
    }

    return Plugin_Stop;
}

public Action Event_RoundEndBroadcast(Event event, const char[] name, bool dontBroadcast)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    g_BlockRoundEndAudioUntil = GetEngineTime() + 5.0;
    SuppressStockRoundAudio();

    // The client uses the stock round_end broadcast for role-inaccurate win
    // presentation, including its Terrorists/Counter-Terrorists voice line.
    // Shroudfire processes the same event server-side and shows its own result.
    event.BroadcastDisabled = true;
    return Plugin_Changed;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    g_RoundInProgress = false;
    g_RoundLiveStartedAt = 0.0;
    g_InvisantStarvationRoundStartedAt = 0.0;
    g_BlockRoundEndAudioUntil = GetEngineTime() + 5.0;
    SuppressStockRoundAudio();
    CancelRoundTimeout();
    for (int client = 1; client <= MaxClients; client++)
    {
        g_KillStreakCount[client] = 0;
        g_LastKillAt[client] = 0.0;
        EndAdminObservationAudit(client, "round ended");
        g_HudUntil[client] = 0.0;
        if (g_HudSync != null && IsHumanClient(client))
        {
            ClearSyncHud(client, g_HudSync);
        }
        ClearAfkWarning(client);
        ClearInvisantStarvationWarning(client);
    }

    if (!IsModActive())
    {
        return;
    }

    g_BetweenRounds = true;
    if (g_RoundEligibleForAdvance && CountRoundParticipants() >= 2) g_MapCompletedRounds++;
    BeginLightingTransitionRefresh();

    if (g_SkipNextRoundAdvance && !g_RoundEligibleForAdvance)
    {
        g_ForcedRoundEndMode = FORCED_END_NONE;
        return;
    }

    g_SkipNextRoundAdvance = false;

    if (!g_RoundEligibleForAdvance)
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            g_EarnedInvisant[client] = false;
            g_LastArmitiveAttackerUserId[client] = 0;
        }
        g_ForcedRoundEndMode = FORCED_END_NONE;
        LogMessage("Round ended without a Shroudfire elimination or timeout; keeping the current roster and discarding partial-round rewards.");
        return;
    }

    int winningTeam = event.GetInt("winner");
    if (winningTeam < CS_TEAM_T)
    {
        for (int player = 1; player <= MaxClients; player++)
        {
            if (!IsHumanClient(player)) continue;
            PlayRandomVoice(player, Audio_RoundEnd, Voice_Draw);
            SetNotice(player, 3, g_CvarHudRoundResultSeconds.FloatValue, "ROUND DRAW");
        }
    }
    if (winningTeam == GetInvisantTeam() || winningTeam == GetVisibleTeam())
    {
        bool invisantWon = winningTeam == GetInvisantTeam();
        char roundWinSound[PLATFORM_MAX_PATH];
        strcopy(
            roundWinSound,
            sizeof(roundWinSound),
            invisantWon ? INVISANT_ROUND_WIN_SOUND : ARMITIVE_ROUND_WIN_SOUND
        );
        SetHudTextParams(
            -1.0,
            0.33,
            g_CvarHudRoundResultSeconds.FloatValue,
            invisantWon ? 127 : 224,
            invisantWon ? 167 : 122,
            invisantWon ? 255 : 106,
            255,
            0,
            0.0,
            0.0,
            0.0
        );
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsHumanClient(client))
            {
                DataPack voicePack;
                CreateDataTimer(g_CvarRoundWinSoundDelay.FloatValue, Timer_RoundWinVoice, voicePack, TIMER_FLAG_NO_MAPCHANGE);
                voicePack.WriteCell(GetClientSerial(client));
                voicePack.WriteCell(invisantWon ? view_as<int>(Voice_InvisantWin) : view_as<int>(Voice_ArmitiveWin));
                voicePack.WriteCell(g_RoundSerial);
                if (g_CvarHud.BoolValue && g_CvarHudRoundResultSeconds.FloatValue > 0.0) ShowSyncHudText(
                    client,
                    g_RoundResultHudSync,
                    invisantWon ? "INVISANT WIN" : "ARMITIVE WIN"
                );
            }
        }
    }

    int losingTeam = winningTeam == GetInvisantTeam() ? GetVisibleTeam() : GetInvisantTeam();
    bool allIneligible = CountAliveHumans(losingTeam) == 0;
    int losers;
    for (int player = 1; player <= MaxClients; player++)
    {
        if (!IsActiveHuman(player) || GetClientTeam(player) != losingTeam || g_WaitingForNextRound[player]) continue;
        losers++;
        if (!g_IneligibleRoundDeath[player]) allIneligible = false;
    }
    g_RoundWinXpSuppressed = losers > 0 && allIneligible;
    if (g_RoundWinXpSuppressed)
    {
        LogMessage("Suppressed round-win XP because the losing team was eliminated solely by inactivity or suicide.");
    }
    else if (winningTeam == GetInvisantTeam() || winningTeam == GetVisibleTeam())
    {
        AwardRoundWinXp(winningTeam);
    }
    g_ForcedRoundEndMode = FORCED_END_NONE;

    if (!g_RoundAdvanceScheduled)
    {
        g_RoundAdvanceScheduled = true;
        g_AdvanceRosterAtRoundStart = true;
        g_RosterSelectedForNextRound = true;
    }
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int spawned = GetClientOfUserId(event.GetInt("userid"));
    if (IsHumanClient(spawned))
    {
        g_CampingAnchorReady[spawned] = false;
        g_CampingActive[spawned] = false;
        g_CampingForcedDeath[spawned] = false;
        g_TimeoutForcedDeath[spawned] = false;
        g_LastRecoveryAt[spawned] = GetEngineTime();
        g_LastReforgeAt[spawned] = GetEngineTime();
    }
    if (!IsModActive())
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0)
    {
        g_KillStreakCount[client] = 0;
        g_LastKillAt[client] = 0.0;
        ClearAssistDamageForClient(client);
        CloseUpgradeMenu(client);
        g_ConsecutiveEmptyRoundRestarts = 0;
        g_HudUntil[client] = GetEngineTime() + HUD_SPAWN_DURATION;
        g_LastWeaponFireAt[client] = 0.0;
        g_LastDamageAt[client] = 0.0;
        g_ResilienceGrantedStageThisLife[client] = 0;
        g_FortitudeGrantedStageThisLife[client] = 0;
        for (int ammoType = 0; ammoType < MAX_TRACKED_AMMO_TYPES; ammoType++)
        {
            g_OverloadGrantedReserveBonus[client][ammoType] = 0;
        }
        int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
        int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
        if (primary > MaxClients && primary < MAX_TRACKED_EDICTS)
        {
            g_OverloadInitializedWeaponRef[primary] = 0;
            g_OverloadGrantedClipBonus[primary] = 0;
        }
        if (secondary > MaxClients && secondary < MAX_TRACKED_EDICTS)
        {
            g_OverloadInitializedWeaponRef[secondary] = 0;
            g_OverloadGrantedClipBonus[secondary] = 0;
        }
        g_LastInvisantDamageDealtAt[client] = GetGameTime();
        g_StarvationForcedDeath[client] = false;
        ClearInvisantStarvationWarning(client);
        g_InvisantSurgeAvailableAt[client] = 0.0;
        g_InvisantSurgeCooldownToken[client]++;
        g_InvisantSurgeReadyCuePlayed[client] = true;
        CancelArmitiveWard(client);
        CreateTimer(0.1, Timer_ShowSpawnHud, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
        BeginLightingTransitionRefresh();
        g_LastArmitiveAttackerUserId[client] = 0;
        g_ActivitySampleReady[client] = false;
        RestartAfkTimer(client);
        RefreshClientFootstepPrediction(client);
        if (g_WaitingForNextRound[client])
        {
            CreateTimer(0.0, Timer_EnforceLateJoinWait, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
            return;
        }
        CreateTimer(0.1, Timer_PreparePlayer, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
        CreateTimer(0.25, Timer_CheckSpawnSafety, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Command_AmmoPurchase(int client, const char[] command, int args)
{
    if (IsInvisantPlayer(client))
    {
        return Plugin_Handled;
    }

    if (StrEqual(command, "buymenu", false))
    {
        return Plugin_Continue;
    }

    if (!IsModActive() || !IsActiveHuman(client) || !IsPlayerAlive(client)
        || GetClientTeam(client) != GetVisibleTeam()
        || (g_AppliedUpgradeStage[client][UpgradeSlot_Overload] <= 0
            && g_AppliedUpgradeStage[client][UpgradeSlot_Stockpile] <= 0))
    {
        return Plugin_Continue;
    }

    if (StrEqual(command, "buy", false))
    {
        char item[32];
        GetCmdArg(1, item, sizeof(item));
        if (!StrEqual(item, "primammo", false)
            && !StrEqual(item, "buyammo1", false)
            && !StrEqual(item, "primaryammo", false)
            && !StrEqual(item, "secammo", false)
            && !StrEqual(item, "buyammo2", false)
            && !StrEqual(item, "secondaryammo", false))
        {
            return Plugin_Continue;
        }
    }

    float delay = StrEqual(command, "autobuy", false) || StrEqual(command, "rebuy", false) ? 0.5 : 0.15;
    DataPack pack;
    CreateDataTimer(delay, Timer_ApplyOverloadAfterAmmoPurchase, pack, TIMER_FLAG_NO_MAPCHANGE);
    pack.WriteCell(GetClientSerial(client));
    pack.WriteCell(HasEntProp(client, Prop_Send, "m_iAccount")
        ? GetEntProp(client, Prop_Send, "m_iAccount") : -1);
    for (int slot = CS_SLOT_PRIMARY; slot <= CS_SLOT_SECONDARY; slot++)
    {
        int weapon = GetPlayerWeaponSlot(client, slot);
        int ammoType = -1;
        int reserve = -1;
        if (weapon != -1 && IsValidEntity(weapon)
            && HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")
            && HasEntProp(client, Prop_Send, "m_iAmmo"))
        {
            ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
            if (ammoType >= 0 && ammoType < MAX_TRACKED_AMMO_TYPES)
            {
                reserve = GetEntProp(client, Prop_Send, "m_iAmmo", 4, ammoType);
            }
        }
        pack.WriteCell(ammoType);
        pack.WriteCell(reserve);
    }
    return Plugin_Continue;
}

public Action Timer_ApplyOverloadAfterAmmoPurchase(Handle timer, DataPack pack)
{
    pack.Reset();
    int serial = pack.ReadCell();
    int moneyBefore = pack.ReadCell();
    int ammoTypesBefore[2];
    int reservesBefore[2];
    for (int index = 0; index < 2; index++)
    {
        ammoTypesBefore[index] = pack.ReadCell();
        reservesBefore[index] = pack.ReadCell();
    }
    int client = GetClientFromSerial(serial);
    if (IsHumanClient(client))
    {
        ApplyOverloadAfterAmmoPurchase(client, moneyBefore, ammoTypesBefore, reservesBefore);
    }
    return Plugin_Stop;
}

public Action Event_PlayerTeamAnnouncement(Event event, const char[] name, bool dontBroadcast)
{
    if (!IsModActive() || event.BroadcastDisabled || event.GetBool("silent") || event.GetBool("disconnect"))
    {
        return Plugin_Continue;
    }

    int newTeam = event.GetInt("team");
    if (newTeam != GetInvisantTeam() && newTeam != GetVisibleTeam())
    {
        return Plugin_Continue;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!IsHumanClient(client))
    {
        return Plugin_Continue;
    }

    event.SetBool("silent", true);
    event.BroadcastDisabled = true;
    return Plugin_Changed;
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    if (event.GetBool("disconnect"))
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!IsHumanClient(client))
    {
        return;
    }

    int newTeam = event.GetInt("team");
    int oldTeam = event.GetInt("oldteam");
    SetClientFootstepPrediction(client, IsModActive() && g_CvarSilentLocalMovement.BoolValue && newTeam == GetInvisantTeam());
    if (oldTeam != newTeam)
    {
        g_KillStreakCount[client] = 0;
        g_LastKillAt[client] = 0.0;
        ClearAssistDamageForClient(client);
        RestoreInvisantKnifePrediction(client);
        ClearPlayerUpgradeEffects(client);
        ClearInvisantScreenFade(client);
        RequestFrame(Frame_RefreshInvisantScreenTint, GetClientSerial(client));
        RequestFrame(Frame_RefreshInvisantPlayerModel, GetClientSerial(client));
    }
    if (oldTeam < CS_TEAM_T && newTeam >= CS_TEAM_T)
    {
        g_ConsecutiveEmptyRoundRestarts = 0;
    }
    g_LastArmitiveAttackerUserId[client] = 0;
    g_ActivitySampleReady[client] = false;
    if (newTeam < CS_TEAM_T)
    {
        g_HudUntil[client] = 0.0;
        if (g_HudSync != null)
        {
            ClearSyncHud(client, g_HudSync);
        }
    }
    bool allowedMove = g_AllowedTargetTeam[client] == newTeam;
    if (allowedMove)
    {
        g_AllowedTargetTeam[client] = 0;
    }

    if (!IsModActive())
    {
        return;
    }

    if (g_SpectatorLocked[client] && newTeam >= CS_TEAM_T)
    {
        CreateTimer(0.1, Timer_ForceSpectator, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
        return;
    }

    if (newTeam == GetInvisantTeam() && !allowedMove)
    {
        PrintToChat(client, "%s \x077FA7FFInvisant\x01 is queue-assigned", CHAT_PREFIX);
        CreateTimer(0.1, Timer_ForceVisible, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    }
    else if (newTeam == GetVisibleTeam())
    {
        g_ChoseSpectator[client] = false;
        if (g_VisibleWaitingSince[client] <= 0.0)
        {
            g_VisibleWaitingSince[client] = GetEngineTime();
        }
        if (oldTeam < CS_TEAM_T && !allowedMove)
        {
            MarkClientWaitingForNextRound(client);
        }
        if (!allowedMove)
        {
            RestartAfkTimer(client);
            if (g_QueueOrder[client] == 0)
            {
                PutAtBackOfQueue(client);
            }
        }
    }
    else if (newTeam < CS_TEAM_T)
    {
        if (oldTeam == GetInvisantTeam())
        {
            g_SpectatorLocked[client] = true;
        }
        if (g_EarnedInvisant[client] || g_PromotedByKill[client])
        {
            LogMessage("%N forfeited Invisant-role priority by joining Spectator.", client);
        }
        g_QueueOrder[client] = 0;
        g_VisibleWaitingSince[client] = 0.0;
        g_EarnedInvisant[client] = false;
        g_PromotedByKill[client] = false;
        g_PromotionOrder[client] = 0;
        SavePersistentQueue(client, GetNextBackQueueStamp(), true);
    }

    if (!g_ManagingRoster)
    {
        QueueStateRefresh();
    }
    QueueEmptyRoundRestartCheck();
}

public void Frame_RefreshInvisantScreenTint(any serial)
{
    int client = GetClientFromSerial(serial);
    if (client > 0)
    {
        RefreshInvisantScreenTint(client);
    }
}

public void Frame_RefreshInvisantPlayerModel(any serial)
{
    int client = GetClientFromSerial(serial);
    if (!IsHumanClient(client) || !IsPlayerAlive(client))
    {
        return;
    }

    if (IsModActive() && GetClientTeam(client) == GetInvisantTeam())
    {
        SetEntityModel(client, INVISANT_PLAYER_MODEL);
    }
    else
    {
        CS_UpdateClientModel(client);
    }
}

public Action Event_PlayerDeathPre(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    if (IsHumanClient(victim)
        && (g_AfkForcedDeath[victim] || g_StarvationForcedDeath[victim]))
    {
        event.BroadcastDisabled = true;
        return Plugin_Changed;
    }

    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (IsModActive()
        && IsHumanClient(victim)
        && IsActiveHuman(attacker)
        && attacker != victim
        && GetClientTeam(victim) == GetVisibleTeam()
        && GetClientTeam(attacker) == GetInvisantTeam())
    {
        // Keep the named death notice, but let CS:S use its skull fallback.
        event.SetString("weapon", "");
        return Plugin_Changed;
    }

    return Plugin_Continue;
}

public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int healthDamage = event.GetInt("dmg_health");
    if (IsHumanClient(victim))
    {
        if (g_HealthBeforeDamage[victim] > 0 && healthDamage > g_HealthBeforeDamage[victim])
        {
            healthDamage = g_HealthBeforeDamage[victim];
        }
        g_HealthBeforeDamage[victim] = 0;
    }

    if (!IsModActive()
        || !g_RoundInProgress
        || healthDamage <= 0
        || !IsActiveHuman(victim)
        || !IsActiveHuman(attacker)
        || attacker == victim
        || g_WaitingForNextRound[victim]
        || g_WaitingForNextRound[attacker]
        || GetClientTeam(attacker) == GetClientTeam(victim))
    {
        return;
    }

    g_AssistDamage[attacker][victim] += healthDamage;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    if (!IsModActive())
    {
        return;
    }

    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (IsHumanClient(victim))
    {
        g_KillStreakCount[victim] = 0;
        g_LastKillAt[victim] = 0.0;
    }
    bool scoring = g_RoundInProgress && g_ForcedRoundEndMode == FORCED_END_NONE && !g_SkipNextRoundAdvance;
    bool inactiveDeath = scoring && IsHumanClient(victim) && !g_MovedThisRound[victim]
        && IsActiveHuman(attacker) && attacker != victim
        && GetClientTeam(attacker) != GetClientTeam(victim);
    RecordCombatDeath(victim, attacker, scoring);
    bool afkDeath = IsHumanClient(victim) && (g_AfkForcedDeath[victim] || inactiveDeath);
    bool starvationDeath = IsHumanClient(victim) && g_StarvationForcedDeath[victim];
    if (afkDeath)
    {
        if (g_EarnedInvisant[victim] || g_PromotedByKill[victim])
        {
            LogMessage("%N forfeited Invisant-role priority by remaining AFK.", victim);
        }
        g_EarnedInvisant[victim] = false;
        g_PromotedByKill[victim] = false;
        g_PromotionOrder[victim] = 0;
        g_AfkQueueRemoved[victim] = true;
        g_QueueOrder[victim] = 0;
        g_VisibleWaitingSince[victim] = 0.0;
        SavePersistentQueue(victim, GetNextBackQueueStamp(), true);
        QueueStateRefresh();
        g_ConsecutiveAfkDeaths[victim]++;
        LogMessage("%N was silently killed for inactivity (consecutive AFK death %d).", victim,
            g_ConsecutiveAfkDeaths[victim]);
        if (g_CvarAfkLimit.IntValue > 0
            && g_ConsecutiveAfkDeaths[victim] >= g_CvarAfkLimit.IntValue)
        {
            CreateTimer(0.1, Timer_KickRepeatedAfk, GetClientSerial(victim), TIMER_FLAG_NO_MAPCHANGE);
        }
    }
    if (IsHumanClient(victim))
    {
        g_AfkForcedDeath[victim] = false;
        g_StarvationForcedDeath[victim] = false;
        CancelArmitiveWard(victim);
        ClearInvisantScreenFade(victim);
        if (afkDeath)
        {
            char victimColor[12];
            if (GetClientTeam(victim) == GetInvisantTeam())
            {
                strcopy(victimColor, sizeof(victimColor), "\x077FA7FF");
            }
            else if (GetClientTeam(victim) == GetVisibleTeam())
            {
                strcopy(victimColor, sizeof(victimColor), "\x07E07A6A");
            }
            else
            {
                strcopy(victimColor, sizeof(victimColor), "\x01");
            }
            PrintToChatAll("%s %s%N\x01 was killed for being \x07EF5555AFK\x01", CHAT_PREFIX, victimColor, victim);
        }
        else if (starvationDeath)
        {
            PrintToChatAll(
                "%s \x077FA7FF%N\x01 died from \x07EF5555starvation\x01",
                CHAT_PREFIX,
                victim
            );
        }
    }

    if (!scoring && IsActiveHuman(attacker) && attacker != victim && IsActiveHuman(victim)
        && GetClientTeam(attacker) != GetClientTeam(victim))
        SetNotice(attacker, 4, g_CvarHudNoRewardsSeconds.FloatValue, "Round over: no XP, rank or priority");
    bool validXpKill = g_RoundInProgress
        && g_ForcedRoundEndMode == FORCED_END_NONE
        && !g_SkipNextRoundAdvance
        && !afkDeath
        && !starvationDeath
        && !g_CampingForcedDeath[victim]
        && CountRoundParticipants() >= 2
        && IsActiveHuman(victim)
        && IsActiveHuman(attacker)
        && attacker != victim
        && !g_WaitingForNextRound[victim]
        && !g_WaitingForNextRound[attacker]
        && GetClientTeam(attacker) != GetClientTeam(victim);
    if (validXpKill)
    {
        IncrementCombatStat(attacker, GetClientTeam(attacker) == GetInvisantTeam() ? "invisant_kills" : "armitive_kills");
        bool invisantKill = GetClientTeam(attacker) == GetInvisantTeam();
        int baseKillXp = invisantKill ? g_CvarXpKillInvisant.IntValue : g_CvarXpKillArmitive.IntValue;
        int awardedKillXp = baseKillXp;
        int weaponXpPercent = 0;
        char weaponType[8];

        if (!invisantKill)
        {
            char weapon[32];
            event.GetString("weapon", weapon, sizeof(weapon));
            if (StrEqual(weapon, "knife", false) || StrEqual(weapon, "weapon_knife", false))
            {
                weaponXpPercent = g_CvarXpArmitiveKnifePercent.IntValue;
                awardedKillXp = RoundToNearest(float(baseKillXp) * float(weaponXpPercent) / 100.0);
                strcopy(weaponType, sizeof(weaponType), "knife");
            }
            else if (StrEqual(weapon, "glock", false)
                || StrEqual(weapon, "usp", false)
                || StrEqual(weapon, "p228", false)
                || StrEqual(weapon, "deagle", false)
                || StrEqual(weapon, "elite", false)
                || StrEqual(weapon, "fiveseven", false)
                || StrEqual(weapon, "weapon_glock", false)
                || StrEqual(weapon, "weapon_usp", false)
                || StrEqual(weapon, "weapon_p228", false)
                || StrEqual(weapon, "weapon_deagle", false)
                || StrEqual(weapon, "weapon_elite", false)
                || StrEqual(weapon, "weapon_fiveseven", false))
            {
                weaponXpPercent = g_CvarXpArmitivePistolPercent.IntValue;
                awardedKillXp = RoundToNearest(float(baseKillXp) * float(weaponXpPercent) / 100.0);
                strcopy(weaponType, sizeof(weaponType), "pistol");
            }
        }

        float now = GetGameTime();
        int previousStreak = g_KillStreakCount[attacker];
        bool continuedStreak = previousStreak > 0
            && now >= g_LastKillAt[attacker]
            && now - g_LastKillAt[attacker] <= g_CvarKillStreakWindow.FloatValue;
        g_KillStreakCount[attacker] = continuedStreak
            ? (previousStreak < KILL_STREAK_STAGE_COUNT ? previousStreak + 1 : KILL_STREAK_STAGE_COUNT)
            : 1;
        g_LastKillAt[attacker] = now;

        int streakIndex = -1;
        bool playStreakSound = false;
        if (!g_FirstBloodClaimed)
        {
            g_FirstBloodClaimed = true;
            int invisantParticipants;
            int armitiveParticipants;
            for (int client = 1; client <= MaxClients; client++)
            {
                if (!IsActiveHuman(client) || g_WaitingForNextRound[client])
                {
                    continue;
                }
                if (GetClientTeam(client) == GetInvisantTeam())
                {
                    invisantParticipants++;
                }
                else if (GetClientTeam(client) == GetVisibleTeam())
                {
                    armitiveParticipants++;
                }
            }
            if (invisantParticipants >= 2 && armitiveParticipants >= 2)
            {
                streakIndex = 0;
                playStreakSound = true;
            }
        }
        else if (continuedStreak)
        {
            streakIndex = g_KillStreakCount[attacker] - 1;
            playStreakSound = previousStreak < KILL_STREAK_STAGE_COUNT;
        }

        int streakXpPercent = 100;
        if (streakIndex >= 0)
        {
            streakXpPercent = g_CvarKillStreakXpPercent[streakIndex].IntValue;
            awardedKillXp = RoundToNearest(float(awardedKillXp) * float(streakXpPercent) / 100.0);
            if (playStreakSound)
            {
                PlayVoice(attacker, VOICE_FILES[KILL_STREAK_VOICE_START + streakIndex], Audio_KillStreak);
            }
        }

        int beforeKillXp = invisantKill ? g_InvisibleXp[attacker] : g_VisibleXp[attacker];
        AwardPlayerXp(attacker, invisantKill, awardedKillXp);
        int afterKillXp = invisantKill ? g_InvisibleXp[attacker] : g_VisibleXp[attacker];
        SetNotice(attacker, 0, g_CvarHudKillSeconds.FloatValue, "Killed %N | +%d XP", victim, afterKillXp-beforeKillXp);
        AwardAssistXpForKill(victim, attacker, invisantKill, baseKillXp);
        if (playStreakSound)
        {
            int combinedPercent = RoundToNearest(
                float(weaponXpPercent > 0 ? weaponXpPercent : 100) * float(streakXpPercent) / 100.0
            );
            PrintToChat(
                attacker,
                "%s \x07D6B86A%s\x01: \x0793C47D%d%%\x01 kill XP rate",
                CHAT_PREFIX,
                KILL_STREAK_NAMES[streakIndex],
                combinedPercent
            );
        }
        else if (weaponXpPercent > 0)
        {
            int combinedPercent = RoundToNearest(float(weaponXpPercent) * float(streakXpPercent) / 100.0);
            PrintToChat(
                attacker,
                "%s Killing \x077FA7FF%N\x01 with a \x07D6B86A%s\x01: \x0793C47D%d%%\x01 kill XP rate",
                CHAT_PREFIX,
                victim,
                weaponType,
                combinedPercent
            );
        }
    }
    if (IsHumanClient(victim))
    {
        ClearAssistDamageAgainstVictim(victim);
    }

    if (g_RoundInProgress
        && !afkDeath
        && IsActiveHuman(victim)
        && GetClientTeam(victim) == GetVisibleTeam()
        && IsInvisantPlayer(attacker)
        && !g_WaitingForNextRound[victim]
        && !g_WaitingForNextRound[attacker]
        && g_AppliedUpgradeStage[attacker][UpgradeSlot_Bloodlust] > 0)
    {
        int health = GetClientHealth(attacker);
        if (health < 100)
        {
            health += g_AppliedUpgradeStage[attacker][UpgradeSlot_Bloodlust] * BLOODLUST_HEALTH_PER_STAGE;
            if (health > 100)
            {
                health = 100;
            }
            SetEntityHealth(attacker, health);
        }
    }

    if (validXpKill
        && g_ForcedRoundEndMode == FORCED_END_NONE
        && !g_SkipNextRoundAdvance
        && !afkDeath
        && IsHumanClient(victim)
        && IsActiveHuman(attacker)
        && attacker != victim
        && GetClientTeam(attacker) == GetInvisantTeam())
    {
        g_RoundKills[attacker]++;
    }

    if (IsHumanClient(victim))
    {
        ClearAfkWarning(victim);
        ClearInvisantStarvationWarning(victim);
        g_HudUntil[victim] = 0.0;
        if (g_HudSync != null)
        {
            ClearSyncHud(victim, g_HudSync);
        }
        BeginLightingTransitionRefresh();
        RequestFrame(Frame_EnforceObserverRestrictions, GetClientSerial(victim));
        CreateTimer(0.1, Timer_EnforceObserverRestrictions, GetClientSerial(victim), TIMER_FLAG_NO_MAPCHANGE);
        QueueEmptyRoundRestartCheck();

    }

    if (g_ForcedRoundEndMode == FORCED_END_NONE && CountActiveHumans() >= 2)
    {
        int invisantAlive = CountAliveHumans(GetInvisantTeam());
        int visibleAlive = CountAliveHumans(GetVisibleTeam());
        if ((invisantAlive == 0 && visibleAlive > 0)
            || (visibleAlive == 0 && invisantAlive > 0))
        {
            g_RoundEligibleForAdvance = true;
        }
    }

    if (!g_RoundInProgress
        || g_ForcedRoundEndMode != FORCED_END_NONE
        || g_SkipNextRoundAdvance
        || afkDeath
        || starvationDeath
        || !IsHumanClient(victim)
        || GetClientTeam(victim) != GetInvisantTeam())
    {
        return;
    }

    bool usedLastAttacker = false;
    if (!IsActiveHuman(attacker) || attacker == victim || GetClientTeam(attacker) != GetVisibleTeam())
    {
        attacker = GetClientOfUserId(g_LastArmitiveAttackerUserId[victim]);
        usedLastAttacker = true;
    }
    g_LastArmitiveAttackerUserId[victim] = 0;

    if (!IsActiveHuman(attacker) || attacker == victim || GetClientTeam(attacker) != GetVisibleTeam())
    {
        return;
    }

    if (!g_EarnedInvisant[attacker])
    {
        g_EarnedInvisant[attacker] = true;
        SetNotice(attacker, 4, g_CvarHudPrioritySeconds.FloatValue, "Invisant priority next round");
        if (usedLastAttacker)
        {
            LogMessage("%N earned Invisant-role priority as the last Armitive to damage %N.", attacker, victim);
        }
        else
        {
            LogMessage("%N earned Invisant-role priority by killing %N.", attacker, victim);
        }
        if (g_CvarAnnounce.BoolValue)
        {
            PrintToChat(
                attacker,
                "%s \x077FA7FFInvisant\x01 priority \x07D6B86Anext round%s",
                CHAT_PREFIX,
                usedLastAttacker ? "\x01 (last Armitive attacker)" : ""
            );
        }
    }
}

public Action Timer_InitializePlugin(Handle timer)
{
    RefreshBotState();

    if (!IsModActive())
    {
        g_LastActiveHumans = CountActiveHumans();
        return Plugin_Stop;
    }

    RemoveAllObjectives();
    EnsureSpawnCapacity();

    g_ManagingRoster = true;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsHumanClient(client) || GetClientTeam(client) == CS_TEAM_SPECTATOR)
        {
            continue;
        }

        if (GetClientTeam(client) != GetVisibleTeam())
        {
            MoveClientToTeam(client, GetVisibleTeam());
        }
    }
    g_ManagingRoster = false;

    InitializeWaitingQueue();
    g_LastActiveHumans = CountActiveHumans();

    if (g_LastActiveHumans >= 2)
    {
        SelectInitialRoster(true);
    }
    else
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsActiveHuman(client)
                && GetClientTeam(client) == GetVisibleTeam()
                && !IsPlayerAlive(client))
            {
                CreateTimer(0.1, Timer_RespawnWaitingForPlayers, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
            }
        }
    }

    OverrideGameCvars();
    ApplyMapLighting();
    return Plugin_Stop;
}

public Action Timer_ApplyMapLighting(Handle timer)
{
    ApplyMapLighting();
    return Plugin_Stop;
}

public Action Timer_ReassertMapLighting(Handle timer)
{
    if (g_LightingRefreshTimer != timer
        || !IsModActive()
        || g_LightingRefreshesRemaining <= 0)
    {
        if (g_LightingRefreshTimer == timer)
        {
            g_LightingRefreshTimer = null;
        }
        return Plugin_Stop;
    }

    ApplyMapLighting();
    g_LightingRefreshesRemaining--;
    return Plugin_Continue;
}

public void Frame_ApplyMapLighting(any data)
{
    ApplyMapLighting();
}

public Action Timer_RemoveObjectiveEntity(Handle timer, int reference)
{
    int entity = EntRefToEntIndex(reference);
    if (IsModActive() && entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
    {
        char classname[64];
        GetEntityClassname(entity, classname, sizeof(classname));
        if (IsShroudfireObjective(classname))
        {
            AcceptEntityInput(entity, "Kill");
        }
    }

    return Plugin_Stop;
}

public Action Timer_RoundTimeout(Handle timer)
{
    g_RoundTimeoutTimer = null;

    if (!IsModActive()
        || !g_RoundInProgress
        || g_ForcedRoundEndMode != FORCED_END_NONE
        || g_SkipNextRoundAdvance
        || g_RoundEligibleForAdvance
        || CountRoundParticipants() < 2
        || CountAliveHumans(GetInvisantTeam()) == 0
        || CountAliveHumans(GetVisibleTeam()) == 0)
    {
        return Plugin_Stop;
    }

    CSRoundEndReason winner = GetVisibleTeam() == CS_TEAM_CT ? CSRoundEnd_CTWin : CSRoundEnd_TerroristWin;
    LogMessage("Round time expired; awarding the round to the Armitive.");
    g_RoundEligibleForAdvance = true;
    g_ForcedRoundEndMode = FORCED_END_COMPLETE;
    HandleTimeoutSurvivors();
    TerminateRoundWithoutStockAudio(10.0, winner);
    return Plugin_Stop;
}

public Action Timer_UpdateHud(Handle timer)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        UpdateClientXpHud(client);
        UpdateClientHud(client);
    }

    return Plugin_Continue;
}

public Action Timer_RegenerateHealth(Handle timer)
{
    float now = GetEngineTime();
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsModActive()
            || !IsActiveHuman(client)
            || !IsPlayerAlive(client)
            || !g_XpLoaded[client])
        {
            continue;
        }

        if (now - g_LastRecoveryAt[client] < RECOVERY_TICK_INTERVAL || g_CampingActive[client]) continue;
        g_LastRecoveryAt[client] = now;
        float secondsSinceDamage = now - g_LastDamageAt[client];
        if (g_LastDamageAt[client] > 0.0
            && secondsSinceDamage >= 0.0
            && secondsSinceDamage < RECOVERY_TICK_INTERVAL)
        {
            continue;
        }

        if (GetClientTeam(client) == GetVisibleTeam()
            && g_AppliedUpgradeStage[client][UpgradeSlot_Recovery] > 0)
        {
            int maximumHealth = g_CvarArmitiveBaseHealth.IntValue
                + (g_AppliedUpgradeStage[client][UpgradeSlot_Fortitude] * FORTITUDE_HEALTH_PER_STAGE);
            int health = GetClientHealth(client);
            if (health < maximumHealth)
            {
                health += g_AppliedUpgradeStage[client][UpgradeSlot_Recovery] * g_CvarRecoveryHealthPerStage.IntValue;
                if (health > maximumHealth)
                {
                    health = maximumHealth;
                }
                SetEntityHealth(client, health);
            }
        }
    }
    return Plugin_Continue;
}

public Action Timer_RegenerateArmor(Handle timer)
{
    float now = GetEngineTime();
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsModActive()
            || !IsActiveHuman(client)
            || !IsPlayerAlive(client)
            || !g_XpLoaded[client])
        {
            continue;
        }

        if (now - g_LastReforgeAt[client] < REFORGING_TICK_INTERVAL) continue;
        g_LastReforgeAt[client] = now;
        float secondsSinceDamage = now - g_LastDamageAt[client];
        if (g_LastDamageAt[client] > 0.0
            && secondsSinceDamage >= 0.0
            && secondsSinceDamage < REFORGING_TICK_INTERVAL)
        {
            continue;
        }

        if (GetClientTeam(client) == GetInvisantTeam()
            && g_AppliedUpgradeStage[client][UpgradeSlot_Reforging] > 0
            && HasEntProp(client, Prop_Send, "m_ArmorValue"))
        {
            int maximumArmor = INVISANT_BASE_ARMOR
                + (g_AppliedUpgradeStage[client][UpgradeSlot_Resilience] * RESILIENCE_ARMOR_PER_STAGE);
            int armor = GetEntProp(client, Prop_Send, "m_ArmorValue");
            if (armor < maximumArmor)
            {
                armor += g_AppliedUpgradeStage[client][UpgradeSlot_Reforging] * g_CvarReforgingArmorPerStage.IntValue;
                if (armor > maximumArmor)
                {
                    armor = maximumArmor;
                }
                SetEntProp(client, Prop_Send, "m_ArmorValue", armor);
                g_ResilienceApplied[client] = true;
            }
        }
    }
    return Plugin_Continue;
}

public void Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsModActive()
        && IsActiveHuman(client)
        && IsPlayerAlive(client)
        && GetClientTeam(client) == GetVisibleTeam())
    {
        g_LastWeaponFireAt[client] = GetEngineTime();

        int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if (g_AppliedUpgradeStage[client][UpgradeSlot_Barrage] > 0
            && weapon != -1
            && GetWeaponBaseClip(weapon) > 0)
        {
            DataPack pack;
            CreateDataTimer(0.0, Timer_ApplyBarrageAfterShot, pack, TIMER_FLAG_NO_MAPCHANGE);
            pack.WriteCell(GetClientSerial(client));
            pack.WriteCell(EntIndexToEntRef(weapon));
        }
    }
}

public Action Timer_ApplyBarrageAfterShot(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    int weapon = EntRefToEntIndex(pack.ReadCell());
    if (!IsModActive()
        || !IsActiveHuman(client)
        || !IsPlayerAlive(client)
        || GetClientTeam(client) != GetVisibleTeam()
        || g_AppliedUpgradeStage[client][UpgradeSlot_Barrage] <= 0
        || weapon == INVALID_ENT_REFERENCE
        || !IsValidEntity(weapon)
        || GetWeaponOwner(weapon) != client
        || !HasEntProp(weapon, Prop_Send, "m_flNextPrimaryAttack"))
    {
        return Plugin_Stop;
    }

    float now = GetGameTime();
    float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
    if (nextAttack > now)
    {
        float fireRateMultiplier = 1.0
            + (float(g_AppliedUpgradeStage[client][UpgradeSlot_Barrage]) * BARRAGE_FIRE_RATE_INCREASE_PER_STAGE);
        SetEntPropFloat(
            weapon,
            Prop_Send,
            "m_flNextPrimaryAttack",
            now + ((nextAttack - now) / fireRateMultiplier)
        );
    }
    return Plugin_Stop;
}

public Action Timer_ShowSpawnHud(Handle timer, int serial)
{
    UpdateClientHud(GetClientFromSerial(serial));
    return Plugin_Stop;
}

void UpdateClientXpHud(int client)
{
    if (g_XpHudSync == null || !IsHumanClient(client))
    {
        return;
    }

    if (!g_CvarHud.BoolValue || !IsModActive())
    {
        ClearSyncHud(client, g_XpHudSync);
        return;
    }

    int team = GetClientTeam(client);
    bool invisibleRole = team == GetInvisantTeam();
    if (!invisibleRole && team != GetVisibleTeam())
    {
        ClearSyncHud(client, g_XpHudSync);
        return;
    }

    SetHudTextParams(0.01, 0.01, 2.0, 180, 220, 255, 220, 0, 0.0, 0.0, 0.0);
    if (g_XpDatabase == null)
    {
        ShowSyncHudText(client, g_XpHudSync, "XP unavailable");
        return;
    }
    if (!g_XpLoaded[client])
    {
        ShowSyncHudText(client, g_XpHudSync, "XP loading...");
        return;
    }

    char progress[48];
    FormatXpHudProgress(
        invisibleRole,
        invisibleRole ? g_InvisibleXp[client] : g_VisibleXp[client],
        progress,
        sizeof(progress)
    );
    ShowSyncHudText(
        client,
        g_XpHudSync,
        "%s",
        progress
    );
}

void FormatXpHudProgress(bool invisantRole, int xp, char[] buffer, int length)
{
    int level = GetXpLevel(xp);
    if (level >= MAX_PLAYER_LEVEL)
    {
        FormatEx(buffer, length, "%s Level %d MAX", invisantRole ? "Invisant" : "Armitive", level);
        return;
    }

    int levelStart = GetXpRequiredForLevel(level);
    int nextLevel = GetXpRequiredForLevel(level + 1);
    FormatEx(buffer, length, "%s Level %d XP %d/%d", invisantRole ? "Invisant" : "Armitive", level, xp - levelStart, nextLevel - levelStart);
}

void ClearInvisantScreenFade(int client)
{
    if (!IsHumanClient(client) || g_FadeMsgId == INVALID_MESSAGE_ID)
    {
        return;
    }

    int recipients[1];
    recipients[0] = client;
    Handle message = StartMessageEx(g_FadeMsgId, recipients, sizeof(recipients), USERMSG_RELIABLE);
    if (message == null)
    {
        return;
    }

    BfWriteShort(message, 0);
    BfWriteShort(message, 0);
    BfWriteShort(message, FFADE_IN | FFADE_PURGE);
    BfWriteByte(message, 0);
    BfWriteByte(message, 0);
    BfWriteByte(message, 0);
    BfWriteByte(message, 0);
    EndMessage();
}

void SetArmitiveWardScreenTint(int client, bool enabled)
{
    if (!IsHumanClient(client) || g_FadeMsgId == INVALID_MESSAGE_ID)
    {
        return;
    }

    int recipients[1];
    recipients[0] = client;
    Handle message = StartMessageEx(g_FadeMsgId, recipients, sizeof(recipients), USERMSG_RELIABLE);
    if (message == null)
    {
        return;
    }

    BfWriteShort(message, ARMITIVE_WARD_FADE_DURATION);
    BfWriteShort(message, 0);
    BfWriteShort(
        message,
        (enabled ? FFADE_OUT | FFADE_STAYOUT : FFADE_IN) | FFADE_PURGE
    );
    BfWriteByte(message, ARMITIVE_WARD_TINT_RED);
    BfWriteByte(message, ARMITIVE_WARD_TINT_GREEN);
    BfWriteByte(message, ARMITIVE_WARD_TINT_BLUE);
    BfWriteByte(message, ARMITIVE_WARD_TINT_ALPHA);
    EndMessage();
}

void ApplyArmitiveWardVisuals(int client)
{
    if (!IsHumanClient(client))
    {
        return;
    }

    if (g_ArmitiveWardVisualsApplied[client])
    {
        SetArmitiveWardScreenTint(client, true);
        return;
    }

    g_ArmitiveWardVisualsApplied[client] = true;
    SetArmitiveWardScreenTint(client, true);
    CreateTimer(
        ARMITIVE_WARD_HALO_REFRESH_INTERVAL,
        Timer_UpdateArmitiveWardHalo,
        GetClientSerial(client),
        TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE
    );
}

void ClearArmitiveWardVisuals(int client)
{
    if (!g_ArmitiveWardVisualsApplied[client])
    {
        return;
    }

    if (IsHumanClient(client))
    {
        SetArmitiveWardScreenTint(client, false);
    }
    g_ArmitiveWardVisualsApplied[client] = false;
}

public Action Timer_UpdateArmitiveWardHalo(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (!IsModActive()
        || !IsActiveHuman(client)
        || !IsPlayerAlive(client)
        || GetClientTeam(client) != GetVisibleTeam()
        || !g_ArmitiveWardVisualsApplied[client]
        || g_ArmitiveWardUntil[client] <= GetGameTime()
        || g_ArmitiveWardHaloSpriteModel <= 0
        || g_WallhackBeamModel <= 0)
    {
        return Plugin_Stop;
    }

    int recipients[MAXPLAYERS];
    int recipientCount;
    for (int receiver = 1; receiver <= MaxClients; receiver++)
    {
        if (receiver != client && IsHumanClient(receiver))
        {
            recipients[recipientCount++] = receiver;
        }
    }
    if (recipientCount > 0)
    {
        float origin[3];
        GetClientAbsOrigin(client, origin);

        float glowHeights[] = {10.0, 34.0, 58.0, 72.0};
        for (int layer = 0; layer < sizeof(glowHeights); layer++)
        {
            float glowPosition[3];
            glowPosition[0] = origin[0];
            glowPosition[1] = origin[1];
            glowPosition[2] = origin[2] + glowHeights[layer];
            TE_SetupGlowSprite(
                glowPosition,
                g_ArmitiveWardHaloSpriteModel,
                ARMITIVE_WARD_HALO_LIFETIME,
                ARMITIVE_WARD_HALO_SCALE,
                ARMITIVE_WARD_HALO_BRIGHTNESS
            );
            TE_Send(recipients, recipientCount);
        }

        float ringHeights[] = {8.0, 28.0, 48.0, 68.0};
        float ringRadii[] = {13.0, 23.0, 23.0, 13.0};
        int shieldColor[4] = {110, 205, 255, 105};
        for (int ring = 0; ring < sizeof(ringHeights); ring++)
        {
            float ringPosition[3];
            ringPosition[0] = origin[0];
            ringPosition[1] = origin[1];
            ringPosition[2] = origin[2] + ringHeights[ring];
            TE_SetupBeamRingPoint(
                ringPosition,
                ringRadii[ring] - 0.5,
                ringRadii[ring] + 0.5,
                g_WallhackBeamModel,
                g_ArmitiveWardHaloSpriteModel,
                0,
                0,
                ARMITIVE_WARD_HALO_LIFETIME,
                ARMITIVE_WARD_RING_WIDTH,
                0.0,
                shieldColor,
                0,
                0
            );
            TE_Send(recipients, recipientCount);
        }
    }
    return Plugin_Continue;
}

void CancelArmitiveWard(int client)
{
    ClearArmitiveWardVisuals(client);
    g_ArmitiveWardAvailableAt[client] = 0.0;
    g_ArmitiveWardUntil[client] = 0.0;
    g_ArmitiveWardCycleToken[client]++;
    g_ArmitiveWardReadyCuePlayed[client] = true;
}

void ForceInvisantScreenTintFullCheck(int entity)
{
    int flags = GetEdictFlags(entity);
    flags &= ~FL_EDICT_ALWAYS;
    flags &= ~FL_EDICT_DONTSEND;
    flags &= ~FL_EDICT_PVSCHECK;
    SetEdictFlags(entity, flags);
}

void ForceInvisantScreenTintAlways(int entity)
{
    int flags = GetEdictFlags(entity);
    flags &= ~FL_EDICT_DONTSEND;
    flags &= ~FL_EDICT_PVSCHECK;
    flags |= FL_EDICT_ALWAYS;
    SetEdictFlags(entity, flags);
}

public MRESReturn DHook_InvisantScreenTintUpdateTransmitState(int entity, DHookReturn hReturn)
{
    if (EntRefToEntIndex(g_InvisantScreenTintRef) != entity
        || g_InvisantScreenTintCleanupBroadcast)
    {
        return MRES_Ignored;
    }

    ForceInvisantScreenTintFullCheck(entity);
    hReturn.Value = FL_EDICT_FULLCHECK;
    return MRES_Supercede;
}

public MRESReturn DHook_InvisantScreenTintShouldTransmit(
    int entity,
    DHookReturn hReturn,
    DHookParam hParams
)
{
    if (EntRefToEntIndex(g_InvisantScreenTintRef) != entity
        || g_InvisantScreenTintCleanupBroadcast)
    {
        return MRES_Ignored;
    }

    // FULLCHECK makes this decision recipient-specific. Returning ALWAYS here
    // avoids PVS culling while SDKHook_SetTransmit still rejects Armitive clients.
    hReturn.Value = FL_EDICT_ALWAYS;
    return MRES_Supercede;
}

void RemoveInvisantScreenTintController()
{
    int entity = EntRefToEntIndex(g_InvisantScreenTintRef);
    g_InvisantScreenTintRef = INVALID_ENT_REFERENCE;
    g_InvisantScreenTintCleanupBroadcast = false;
    g_InvisantScreenTintRecreateAfterCleanup = false;
    if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
    {
        return;
    }

    SDKUnhook(entity, SDKHook_SetTransmit, Hook_InvisantScreenTintTransmit);
    AcceptEntityInput(entity, "Disable");
    AcceptEntityInput(entity, "Kill");
}

bool HasInvisantRoleClient()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsHumanClient(client) && GetClientTeam(client) == GetInvisantTeam())
        {
            return true;
        }
    }
    return false;
}

void CreateInvisantScreenTintController()
{
    if (!IsModActive()
        || g_CvarInvisantScreenTint == null
        || g_CvarInvisantScreenTint.IntValue <= 0
        || !HasInvisantRoleClient())
    {
        return;
    }

    int entity = CreateEntityByName("color_correction");
    if (entity == -1)
    {
        LogError("Could not create the Invisant screen color-correction controller.");
        return;
    }

    // Start disabled so an initial FL_EDICT_ALWAYS update cannot tint anyone.
    // The controller is enabled on a later frame after FULLCHECK is established.
    g_InvisantScreenTintRef = EntIndexToEntRef(entity);
    int shouldTransmitHookId = g_InvisantScreenTintShouldTransmitHook.HookEntity(
        Hook_Pre,
        entity,
        DHook_InvisantScreenTintShouldTransmit
    );
    int updateTransmitStateHookId = g_InvisantScreenTintUpdateTransmitStateHook.HookEntity(
        Hook_Pre,
        entity,
        DHook_InvisantScreenTintUpdateTransmitState
    );
    if (shouldTransmitHookId == INVALID_HOOK_ID
        || updateTransmitStateHookId == INVALID_HOOK_ID)
    {
        g_InvisantScreenTintRef = INVALID_ENT_REFERENCE;
        AcceptEntityInput(entity, "Kill");
        LogError("Could not install per-client Invisant screen tint transmission hooks.");
        return;
    }
    SDKHook(entity, SDKHook_SetTransmit, Hook_InvisantScreenTintTransmit);
    ForceInvisantScreenTintFullCheck(entity);

    char weight[16];
    FloatToString(float(g_CvarInvisantScreenTint.IntValue) / 255.0, weight, sizeof(weight));
    DispatchKeyValue(entity, "targetname", "shroudfire_invisant_screen_tint");
    DispatchKeyValue(entity, "filename", INVISANT_SCREEN_LUT);
    DispatchKeyValue(entity, "minfalloff", "-1");
    DispatchKeyValue(entity, "maxfalloff", "-1");
    DispatchKeyValue(entity, "maxweight", weight);
    DispatchKeyValue(entity, "fadeInDuration", "0");
    DispatchKeyValue(entity, "fadeOutDuration", "0");
    DispatchKeyValue(entity, "StartDisabled", "1");
    DispatchSpawn(entity);
    ActivateEntity(entity);
    ForceInvisantScreenTintFullCheck(entity);
    CreateTimer(
        0.1,
        Timer_EnableInvisantScreenTintController,
        g_InvisantScreenTintRefreshToken,
        TIMER_FLAG_NO_MAPCHANGE
    );
}

public Action Timer_EnableInvisantScreenTintController(Handle timer, int refreshToken)
{
    if (refreshToken != g_InvisantScreenTintRefreshToken
        || g_InvisantScreenTintCleanupBroadcast)
    {
        return Plugin_Stop;
    }

    int entity = EntRefToEntIndex(g_InvisantScreenTintRef);
    if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
    {
        g_InvisantScreenTintRef = INVALID_ENT_REFERENCE;
        return Plugin_Stop;
    }

    if (!IsModActive()
        || g_CvarInvisantScreenTint == null
        || g_CvarInvisantScreenTint.IntValue <= 0
        || !HasInvisantRoleClient())
    {
        RemoveInvisantScreenTintController();
        return Plugin_Stop;
    }

    AcceptEntityInput(entity, "Enable");
    // Enable dirties the entity and can restore FL_EDICT_ALWAYS. Clear it
    // synchronously so no Armitive client receives the enabled update.
    ForceInvisantScreenTintFullCheck(entity);
    return Plugin_Stop;
}

public Action Hook_InvisantScreenTintTransmit(int entity, int client)
{
    if (EntRefToEntIndex(g_InvisantScreenTintRef) != entity)
    {
        return Plugin_Handled;
    }
    if (g_InvisantScreenTintCleanupBroadcast)
    {
        return Plugin_Continue;
    }
    if (!IsModActive()
        || !IsHumanClient(client)
        || GetClientTeam(client) != GetInvisantTeam()
        || g_InvisantScreenTintDisabled[client])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

void BeginInvisantScreenTintTransition(bool recreate)
{
    g_InvisantScreenTintRefreshToken++;
    for (int client = 1; client <= MaxClients; client++)
    {
        ClearInvisantScreenFade(client);
        if (recreate && g_ArmitiveWardVisualsApplied[client])
        {
            SetArmitiveWardScreenTint(client, true);
        }
    }

    int entity = EntRefToEntIndex(g_InvisantScreenTintRef);
    if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
    {
        // A client keeps a dormant color_correction entity active. Broadcast
        // its disabled, zero-weight state before stopping transmission so a
        // former Invisant cannot retain the red LUT as Armitive.
        g_InvisantScreenTintCleanupBroadcast = true;
        g_InvisantScreenTintRecreateAfterCleanup = recreate;
        AcceptEntityInput(entity, "Disable");
        ForceInvisantScreenTintAlways(entity);
        CreateTimer(
            0.2,
            Timer_FinishInvisantScreenTintTransition,
            g_InvisantScreenTintRefreshToken,
            TIMER_FLAG_NO_MAPCHANGE
        );
        return;
    }

    g_InvisantScreenTintRef = INVALID_ENT_REFERENCE;
    g_InvisantScreenTintCleanupBroadcast = false;
    g_InvisantScreenTintRecreateAfterCleanup = recreate;
    CreateTimer(
        0.05,
        Timer_FinishInvisantScreenTintTransition,
        g_InvisantScreenTintRefreshToken,
        TIMER_FLAG_NO_MAPCHANGE
    );
}

public Action Timer_FinishInvisantScreenTintTransition(Handle timer, int refreshToken)
{
    if (refreshToken != g_InvisantScreenTintRefreshToken)
    {
        return Plugin_Stop;
    }

    bool recreate = g_InvisantScreenTintRecreateAfterCleanup;
    RemoveInvisantScreenTintController();
    if (recreate)
    {
        CreateInvisantScreenTintController();
    }
    return Plugin_Stop;
}

void RestartAllInvisantScreenTints()
{
    BeginInvisantScreenTintTransition(true);
}

void RefreshInvisantScreenTint(int client)
{
    ClearInvisantScreenFade(client);
    RestartAllInvisantScreenTints();
}

void RefreshAllInvisantScreenTints()
{
    BeginInvisantScreenTintTransition(true);
}

void ClearAllInvisantScreenTints(bool immediate = false)
{
    if (!immediate)
    {
        BeginInvisantScreenTintTransition(false);
        return;
    }

    g_InvisantScreenTintRefreshToken++;
    for (int client = 1; client <= MaxClients; client++)
    {
        ClearInvisantScreenFade(client);
    }
    RemoveInvisantScreenTintController();
}

void UpdateClientHud(int client)
{
    if (g_HudSync == null || !IsHumanClient(client))
    {
        return;
    }

    if (!g_CvarHud.BoolValue
        || !IsModActive()
        || !IsPlayerAlive(client)
        || GetEngineTime() >= g_HudUntil[client])
    {
        ClearSyncHud(client, g_HudSync);
        return;
    }

    int invisibleCount = CountInvisantHumans();
    int armitiveCount = CountActiveHumans() - invisibleCount;
    SetHudTextParams(-1.0, 0.08, 1.2, 180, 220, 255, 220);

    if (GetClientTeam(client) == GetInvisantTeam())
    {
        if (g_CvarWallhack.BoolValue)
        {
            ShowSyncHudText(
                client,
                g_HudSync,
                "Role: INVISANT\nClaw-only; lines track Armitive\nTeams: %d Invisant / %d Armitive",
                invisibleCount,
                armitiveCount
            );
        }
        else
        {
            ShowSyncHudText(
                client,
                g_HudSync,
                "Role: INVISANT\nClaw-only; eliminate Armitive\nTeams: %d Invisant / %d Armitive",
                invisibleCount,
                armitiveCount
            );
        }
    }
    else if (GetClientTeam(client) == GetVisibleTeam())
    {
        if (g_WaitingForNextRound[client])
        {
            ShowSyncHudText(
                client,
                g_HudSync,
                "Role: ARMITIVE\nEntering next round\nTeams: %d Invisant / %d Armitive",
                invisibleCount,
                armitiveCount
            );
        }
        else if (IsClientAfk(client))
        {
            ShowSyncHudText(
                client,
                g_HudSync,
                "Role: ARMITIVE\nAFK - move to rejoin queue\nTeams: %d Invisant / %d Armitive",
                invisibleCount,
                armitiveCount
            );
        }
        else if (g_EarnedInvisant[client])
        {
            ShowSyncHudText(
                client,
                g_HudSync,
                "Role: ARMITIVE\nInvisant priority next round\nTeams: %d Invisant / %d Armitive",
                invisibleCount,
                armitiveCount
            );
        }
        else
        {
            ShowSyncHudText(
                client,
                g_HudSync,
                "Role: ARMITIVE\nInvisant queue: %d\nTeams: %d Invisant / %d Armitive",
                GetQueuePosition(client),
                invisibleCount,
                armitiveCount
            );
        }
    }
    else
    {
        ClearSyncHud(client, g_HudSync);
    }
}

void SendWallhackBeams()
{
    if (!IsModActive()
        || !g_CvarWallhack.BoolValue
        || !g_RoundInProgress
        || g_WallhackBeamModel <= 0
        || CountAliveHumans(GetInvisantTeam()) == 0)
    {
        return;
    }

    float now = GetGameTime();
    if (now < g_NextWallhackBeamAt)
    {
        return;
    }
    g_NextWallhackBeamAt = now + WALLHACK_BEAM_LIFETIME;

    for (int viewer = 1; viewer <= MaxClients; viewer++)
    {
        if (!IsInvisantPlayer(viewer))
        {
            continue;
        }

        float viewerBeamOrigin[3];
        GetClientAbsOrigin(viewer, viewerBeamOrigin);
        viewerBeamOrigin[2] += WALLHACK_BEAM_START_VERTICAL_OFFSET;

        for (int target = 1; target <= MaxClients; target++)
        {
            if (!IsActiveHuman(target)
                || !IsPlayerAlive(target)
                || GetClientTeam(target) != GetVisibleTeam())
            {
                continue;
            }

            float beamTargetPosition[3];
            GetClientAbsOrigin(target, beamTargetPosition);
            beamTargetPosition[2] += 36.0;

            float beamDirection[3];
            MakeVectorFromPoints(viewerBeamOrigin, beamTargetPosition, beamDirection);
            NormalizeVector(beamDirection, beamDirection);
            ScaleVector(beamDirection, WALLHACK_BEAM_START_FORWARD_OFFSET);

            float beamStart[3];
            AddVectors(viewerBeamOrigin, beamDirection, beamStart);
            int beamColor[4] = {255, 48, 48, 210};
            TE_SetupBeamPoints(
                beamStart,
                beamTargetPosition,
                g_WallhackBeamModel,
                0,
                0,
                0,
                WALLHACK_BEAM_LIFETIME,
                WALLHACK_BEAM_START_WIDTH,
                WALLHACK_BEAM_END_WIDTH,
                0,
                0.0,
                beamColor,
                0
            );
            TE_SendToClient(viewer);
        }
    }
}

public void OnGameFrame()
{
    CheckInvisantStarvation();
    int tintController = EntRefToEntIndex(g_InvisantScreenTintRef);
    if (tintController != INVALID_ENT_REFERENCE && IsValidEntity(tintController))
    {
        if (g_InvisantScreenTintCleanupBroadcast)
        {
            // Let every client receive the disabled, zero-weight state before
            // the controller is removed or replaced.
            ForceInvisantScreenTintAlways(tintController);
        }
        else
        {
            // color_correction restores FL_EDICT_ALWAYS from
            // UpdateTransmitState. Keep it on FULLCHECK so SetTransmit can
            // restrict the enabled controller to the Invisant team.
            ForceInvisantScreenTintFullCheck(tintController);
        }
    }
    else
    {
        g_InvisantScreenTintRef = INVALID_ENT_REFERENCE;
    }

    if (!IsModActive())
    {
        return;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsHumanClient(client) && !IsPlayerAlive(client))
        {
            EnforceObserverRestrictions(client);
        }
    }

    SendWallhackBeams();
}

public Action Timer_UpdateVoice(Handle timer)
{
    RefreshVoiceOverrides();
    RefreshAllClientFootstepPrediction();
    return Plugin_Continue;
}

public Action Timer_KeepTeamMenuClosed(Handle timer)
{
    if (!IsModActive())
    {
        return Plugin_Continue;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsHumanClient(client))
        {
            ShowVGUIPanel(client, "team", INVALID_HANDLE, false);
        }
    }

    return Plugin_Continue;
}

public Action Timer_PersistQueuePresence(Handle timer)
{
    int now = GetTime();
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsHumanClient(client) || !AreClientCookiesCached(client))
        {
            continue;
        }

        if (!g_QueueCookieLoaded[client])
        {
            LoadPersistentQueue(client);
        }
        g_QueueLastSeenCookie.SetInt(client, now);
    }

    return Plugin_Continue;
}

public Action Timer_CheckAfk(Handle timer)
{
    if (!IsModActive())
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            ClearAfkWarning(client);
        }
        return Plugin_Continue;
    }

    if (CountRoundParticipants() < 2)
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsActiveHuman(client))
            {
                RestartAfkTimer(client);
            }
        }
        return Plugin_Continue;
    }

    float threshold = g_CvarAfkSeconds.FloatValue;
    if (GameRules_GetProp("m_bFreezePeriod") != 0)
    {
        for (int client = 1; client <= MaxClients; client++) if (IsActiveHuman(client)) RestartAfkTimer(client);
        return Plugin_Continue;
    }
    if (!g_RoundInProgress || threshold <= 0.0)
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            ClearAfkWarning(client);
        }
        return Plugin_Continue;
    }

    float now = GetEngineTime();
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsActiveHuman(client) || !IsPlayerAlive(client))
        {
            ClearAfkWarning(client);
            continue;
        }

        float idleSeconds = now - g_LastActivityTime[client];
        if (idleSeconds < threshold)
        {
            float warningAt = threshold - g_CvarAfkWarningSeconds.FloatValue;
            if (g_CvarAfkWarningSeconds.FloatValue > 0.0 && idleSeconds >= warningAt)
            {
                int secondsRemaining = RoundToCeil(threshold - idleSeconds);
                if (secondsRemaining < 1)
                {
                    secondsRemaining = 1;
                }

                if (!g_AfkWarningShown[client]) PlayRandomVoice(client, Audio_Afk, Voice_Afk);
                g_AfkWarningShown[client] = true;
                SetHudTextParams(-1.0, 0.25, 1.1, 255, 0, 0, 255, 0, 0.0, 0.0, 0.1);
                ShowSyncHudText(client, g_AfkHudSync, "AFK death in %ds", secondsRemaining);
                EmitSoundToClient(client, AFK_WARNING_SOUND);
            }
            continue;
        }

        g_AfkForcedDeath[client] = true;
        ClearAfkWarning(client);
        ForcePlayerSuicide(client);
        if (IsHumanClient(client) && IsPlayerAlive(client))
        {
            g_AfkForcedDeath[client] = false;
            RestartAfkTimer(client);
            LogError("AFK death for %N was blocked; restarting the inactivity timer.", client);
        }
    }

    return Plugin_Continue;
}

int AdvanceInvisantStarvation(int client, float now, float startsAt)
{
    if (now < startsAt)
    {
        g_StarvationActive[client] = false;
        return 0;
    }
    if (!g_StarvationActive[client])
    {
        g_StarvationActive[client] = true;
        g_StarvationStartedAt[client] = now;
        g_NextStarvationTickAt[client] = now;
    }
    if (now < g_NextStarvationTickAt[client]) return 0;

    float accelerationAt = g_StarvationStartedAt[client] + g_CvarStarvationAccelerationDelay.FloatValue;
    bool accelerated = now >= accelerationAt;
    float interval = accelerated ? g_CvarStarvationAcceleratedInterval.FloatValue : g_CvarStarvationInterval.FloatValue;
    int amount = accelerated ? g_CvarStarvationAcceleratedDamage.IntValue : g_CvarStarvationDamage.IntValue;
    // Retain fractional cadence, but never burst missed ticks after a slow frame.
    g_NextStarvationTickAt[client] += interval;
    if (g_NextStarvationTickAt[client] <= now) g_NextStarvationTickAt[client] = now + interval;
    if (!accelerated && g_NextStarvationTickAt[client] > accelerationAt)
        g_NextStarvationTickAt[client] = accelerationAt;
    return amount;
}

void CheckInvisantStarvation()
{
    bool canStarve = IsModActive() && g_RoundInProgress
        && g_ForcedRoundEndMode == FORCED_END_NONE
        && g_InvisantStarvationRoundStartedAt > 0.0 && CountRoundParticipants() >= 2
        && CountAliveHumans(GetVisibleTeam()) > 0 && GameRules_GetProp("m_bFreezePeriod") == 0;
    float now = GetGameTime();
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!canStarve || !IsInvisantPlayer(client) || !IsPlayerAlive(client) || g_WaitingForNextRound[client])
        {
            ClearInvisantStarvationWarning(client);
            if (!canStarve) g_LastInvisantDamageDealtAt[client] = now;
            continue;
        }
        float startsAt = g_InvisantStarvationRoundStartedAt + g_CvarStarvationRoundDelay.FloatValue;
        float combatGrace = g_LastInvisantDamageDealtAt[client] + g_CvarStarvationCombatDelay.FloatValue;
        if (combatGrace > startsAt) startsAt = combatGrace;
        if (now < startsAt)
        {
            ClearInvisantStarvationWarning(client);
            continue;
        }
        int amount = AdvanceInvisantStarvation(client, now, startsAt);
        if (!g_StarvationWarningShown[client]) PlayRandomVoice(client, Audio_Starvation, Voice_Starvation);
        g_StarvationWarningShown[client] = true;
        if (!g_AfkWarningShown[client] && now >= g_StarvationHudRefreshAt[client])
        {
            g_StarvationHudRefreshAt[client] = now + 1.0;
            SetHudTextParams(-1.0, 0.32, 1.1, 239, 85, 85, 255);
            ShowSyncHudText(client, g_StarvationHudSync, "You're starving\nDeal or take damage");
        }
        if (amount <= 0) continue;
        int health = GetClientHealth(client);
        if (health > amount) SetEntityHealth(client, health - amount);
        else
        {
            g_StarvationForcedDeath[client] = true;
            ForcePlayerSuicide(client);
            if (IsHumanClient(client) && IsPlayerAlive(client)) g_StarvationForcedDeath[client] = false;
        }
    }
}

public Action Timer_KickRepeatedAfk(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (IsHumanClient(client)
        && g_CvarAfkLimit.IntValue > 0
        && g_ConsecutiveAfkDeaths[client] >= g_CvarAfkLimit.IntValue)
    {
        LogMessage("%N was removed after %d consecutive AFK deaths.", client, g_ConsecutiveAfkDeaths[client]);
        KickClient(client, "Kicked for repeated inactivity.");
    }
    return Plugin_Stop;
}

public Action Timer_EnsureSpawnCapacity(Handle timer)
{
    EnsureSpawnCapacity();
    return Plugin_Stop;
}

public Action Timer_ShowGuideHint(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (IsModActive() && IsHumanClient(client))
    {
        PrintToChat(
            client,
            "%s New? Type \x07D6B86Ahelp\x01 to learn the game",
            CHAT_PREFIX
        );
    }
    return Plugin_Stop;
}

public Action Timer_AutoJoinVisible(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (!IsModActive() || !IsHumanClient(client))
    {
        return Plugin_Stop;
    }

    if (!g_QueueCookieLoaded[client] && AreClientCookiesCached(client))
    {
        LoadPersistentQueue(client);
    }

    int team = GetClientTeam(client);
    if (team == 0 || (team == CS_TEAM_SPECTATOR && !g_ChoseSpectator[client]))
    {
        MarkClientWaitingForNextRound(client);
        MoveClientToTeam(client, GetVisibleTeam());
        if (g_PersistedQueueStamp[client] > 0)
        {
            g_QueueOrder[client] = g_PersistedQueueStamp[client];
            TrackQueueStamp(g_QueueOrder[client]);
            g_VisibleWaitingSince[client] = GetEngineTime();
        }
        else
        {
            PutAtBackOfQueue(client);
        }
    }
    else if (team == GetVisibleTeam() && g_QueueOrder[client] == 0)
    {
        PutAtBackOfQueue(client);
    }
    else if (team == GetInvisantTeam())
    {
        MoveClientToTeam(client, GetVisibleTeam());
        PutAtBackOfQueue(client);
    }

    if (GetClientTeam(client) == GetVisibleTeam() && !g_WaitingForNextRound[client])
    {
        CreateTimer(0.1, Timer_RespawnWaitingForPlayers, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    }

    CloseJoinPanels(client);
    CreateTimer(0.1, Timer_CloseJoinPanels, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.5, Timer_CloseJoinPanels, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);

    // Clear any client-side fade left from a previous state, then reapply the
    // tint only to players who are currently assigned to the Invisant role.
    RestartAllInvisantScreenTints();

    QueueStateRefresh();
    return Plugin_Stop;
}

public Action Timer_CloseJoinPanels(Handle timer, int serial)
{
    CloseJoinPanels(GetClientFromSerial(serial));
    return Plugin_Stop;
}

void CloseJoinPanels(int client)
{
    if (!IsHumanClient(client))
    {
        return;
    }

    ShowVGUIPanel(client, "info", INVALID_HANDLE, false);
    ShowVGUIPanel(client, "team", INVALID_HANDLE, false);
    ShowVGUIPanel(client, "class_ter", INVALID_HANDLE, false);
    ShowVGUIPanel(client, "class_ct", INVALID_HANDLE, false);
}

public Action Timer_EnforceLateJoinWait(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (IsModActive()
        && g_RoundInProgress
        && IsHumanClient(client)
        && g_WaitingForNextRound[client]
        && IsPlayerAlive(client))
    {
        ForcePlayerSuicide(client);
    }

    return Plugin_Stop;
}

public Action Timer_RespawnWaitingForPlayers(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    bool mapJoinRespawn = IsMapJoinGraceActive()
        && client > 0
        && g_MapJoinRespawnEligible[client];
    if (!IsModActive()
        || !IsHumanClient(client)
        || GetClientTeam(client) != GetVisibleTeam()
        || g_WaitingForNextRound[client])
    {
        return Plugin_Stop;
    }

    if (IsPlayerAlive(client))
    {
        if (mapJoinRespawn)
        {
            if (GetEngineTime() >= g_MapJoinRespawnConfirmAt[client])
            {
                g_MapJoinRespawnEligible[client] = false;
                g_MapJoinRespawnConfirmAt[client] = 0.0;
            }
            else
            {
                CreateTimer(
                    0.25,
                    Timer_RespawnWaitingForPlayers,
                    GetClientSerial(client),
                    TIMER_FLAG_NO_MAPCHANGE
                );
            }
        }
        return Plugin_Stop;
    }

    if (CountActiveHumans() >= 2 && !mapJoinRespawn)
    {
        return Plugin_Stop;
    }

    CS_RespawnPlayer(client);
    if (mapJoinRespawn)
    {
        // Team assignment can briefly report a successful spawn before CS:S
        // settles the joining player back to dead. Recheck through the first
        // two client-seconds instead of consuming the map-start grace at once.
        CreateTimer(
            0.25,
            Timer_RespawnWaitingForPlayers,
            GetClientSerial(client),
            TIMER_FLAG_NO_MAPCHANGE
        );
    }

    return Plugin_Stop;
}

void QueueEmptyRoundRestartCheck()
{
    if (!g_EmptyRoundCheckQueued)
    {
        g_EmptyRoundCheckQueued = true;
        g_EmptyRoundCheckSerial = g_RoundSerial;
        CreateTimer(0.5, Timer_RestartEmptyRound, _, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_RestartEmptyRound(Handle timer)
{
    int checkedRound = g_EmptyRoundCheckSerial;
    g_EmptyRoundCheckQueued = false;
    if (checkedRound != g_RoundSerial)
    {
        QueueEmptyRoundRestartCheck();
        return Plugin_Stop;
    }

    if (!IsModActive()
        || !g_RoundInProgress
        || g_ForcedRoundEndMode != FORCED_END_NONE
        || CountAliveHumans(CS_TEAM_T) + CountAliveHumans(CS_TEAM_CT) > 0)
    {
        return Plugin_Stop;
    }

    if (CountActiveHumans() == 0)
    {
        int unlocked;
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsHumanClient(client)
                && GetClientTeam(client) < CS_TEAM_T
                && g_SpectatorLocked[client])
            {
                g_SpectatorLocked[client] = false;
                unlocked++;
            }
        }
        if (unlocked > 0)
        {
            LogMessage("Cleared %d stalled Invisant spectator lock(s) because no active or living players remained.", unlocked);
        }
        return Plugin_Stop;
    }

    if (CountActiveHumans() == 1)
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsActiveHuman(client)
                && !IsPlayerAlive(client)
                && !g_WaitingForNextRound[client])
            {
                CS_RespawnPlayer(client);
                BeginLightingTransitionRefresh();
                LogMessage("Respawned the sole active player without ending the round.");
                break;
            }
        }
        g_ConsecutiveEmptyRoundRestarts = 0;
        return Plugin_Stop;
    }

    g_SkipNextRoundAdvance = true;
    g_RoundEligibleForAdvance = false;
    g_ForcedRoundEndMode = FORCED_END_ABORT;
    if (g_ConsecutiveEmptyRoundRestarts > 0)
    {
        g_ConsecutiveEmptyRoundRestarts = 2;
        g_SkipNextRoundAdvance = false;
        g_ForcedRoundEndMode = FORCED_END_NONE;

        int respawned;
        for (int client = 1; client <= MaxClients; client++)
        {
            if (!IsActiveHuman(client)
                || IsPlayerAlive(client)
                || g_WaitingForNextRound[client])
            {
                continue;
            }

            CS_RespawnPlayer(client);
            respawned++;
        }

        if (respawned > 0)
        {
            LogMessage("Recovered a repeated empty round by respawning %d active player(s) without another draw.", respawned);
        }
        else
        {
            LogError("Suppressed a repeated empty-round draw because no eligible player could be respawned.");
        }
        return Plugin_Stop;
    }

    g_ConsecutiveEmptyRoundRestarts = 1;
    LogMessage("Restarting a stalled round because active players remain but nobody is alive.");
    BeginLightingTransitionRefresh();
    TerminateRoundWithoutStockAudio(0.2, CSRoundEnd_Draw);
    return Plugin_Stop;
}

public Action Timer_ForceVisible(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (IsModActive() && IsHumanClient(client) && GetClientTeam(client) == GetInvisantTeam())
    {
        MoveClientToTeam(client, GetVisibleTeam());
        PutAtBackOfQueue(client);
        QueueStateRefresh();
    }

    return Plugin_Stop;
}

public Action Timer_ForceSpectator(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (IsModActive() && IsHumanClient(client) && g_SpectatorLocked[client] && GetClientTeam(client) >= CS_TEAM_T)
    {
        ChangeClientTeam(client, CS_TEAM_SPECTATOR);
    }

    return Plugin_Stop;
}

public void Frame_EnforceObserverRestrictions(any serial)
{
    int client = GetClientFromSerial(serial);
    if (client > 0)
    {
        EnforceObserverRestrictions(client);
    }
}

public Action Timer_EnforceObserverRestrictions(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (client > 0)
    {
        EnforceObserverRestrictions(client);
    }
    return Plugin_Stop;
}

public Action Timer_PreparePlayer(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (!IsModActive() || !IsActiveHuman(client) || !IsPlayerAlive(client))
    {
        return Plugin_Stop;
    }

    RemoveBombFromPlayer(client);
    EnsurePlayerCollision(client);

    if (GetClientTeam(client) == GetVisibleTeam())
    {
        if (HasEntProp(client, Prop_Send, "m_iAccount"))
        {
            SetEntProp(client, Prop_Send, "m_iAccount", 16000);
        }
        if (GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1)
        {
            char pistol[32];
            strcopy(pistol, sizeof(pistol), GetClientTeam(client) == CS_TEAM_T ? "weapon_glock" : "weapon_usp");
            GivePlayerItem(client, pistol);
            g_IgnoreAfkActivityCommand[client] = true;
            FakeClientCommand(client, "use %s", pistol);
            g_IgnoreAfkActivityCommand[client] = false;
        }
    }
    else if (GetClientTeam(client) == GetInvisantTeam())
    {
        SetEntityModel(client, INVISANT_PLAYER_MODEL);
        PrepareInvisantWeapons(client);
        StripInvisantEquipment(client);
        EnableInvisantBlood(client);
    }

    ApplyPlayerUpgrades(client);
    RefreshInvisantScreenTint(client);
    bool invisantRole = GetClientTeam(client) == GetInvisantTeam();
    int points = invisantRole ? g_InvisibleUpgradePoints[client] : g_VisibleUpgradePoints[client];
    if (points > 0)
    {
        QueueUpgradeMenu(client, invisantRole, 0.3);
    }

    return Plugin_Stop;
}

public Action Timer_CheckSpawnSafety(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (!IsModActive()
        || !g_RoundInProgress
        || !IsActiveHuman(client)
        || !IsPlayerAlive(client)
        || g_WaitingForNextRound[client])
    {
        return Plugin_Stop;
    }

    float currentPosition[3];
    GetClientAbsOrigin(client, currentPosition);
    if (!IsRuntimeSpawnBlocked(client, currentPosition))
    {
        return Plugin_Stop;
    }

    char classname[40];
    GetSpawnClassname(GetClientTeam(client), classname, sizeof(classname));

    float positions[MAX_SPAWN_POSITIONS][3];
    float angles[MAX_SPAWN_POSITIONS][3];
    int count = CollectSpawnPoints(classname, positions, angles, MAX_SPAWN_POSITIONS);
    int start = count > 0 ? GetClientUserId(client) % count : 0;
    for (int offset = 0; offset < count; offset++)
    {
        int index = (start + offset) % count;
        float candidate[3];
        candidate[0] = positions[index][0];
        candidate[1] = positions[index][1];
        candidate[2] = positions[index][2] + 2.0;
        if (TR_PointOutsideWorld(candidate) || IsRuntimeSpawnBlocked(client, candidate))
        {
            continue;
        }

        TeleportEntity(client, candidate, angles[index], NULL_VECTOR);
        LogMessage("Relocated %N from an obstructed spawn to a clear %s spawn.", client, classname);
        return Plugin_Stop;
    }

    g_WaitingForNextRound[client] = true;
    LogError("No clear %s spawn remained for %N; keeping the player dead until the next round.", classname, client);
    PrintToChat(client, "%s No safe spawn (Joining \x07D6B86Anext round\x01)", CHAT_PREFIX);
    ForcePlayerSuicide(client);
    return Plugin_Stop;
}

bool IsRuntimeSpawnBlocked(int client, const float position[3])
{
    float mins[3];
    float maxs[3];
    GetClientMins(client, mins);
    GetClientMaxs(client, maxs);

    Handle trace = TR_TraceHullFilterEx(
        position,
        position,
        mins,
        maxs,
        MASK_PLAYERSOLID,
        TraceFilter_IgnoreClient,
        client
    );
    bool blocked = TR_DidHit(trace) || TR_StartSolid(trace);
    delete trace;
    return blocked;
}

public bool TraceFilter_IgnoreClient(int entity, int contentsMask, any client)
{
    return entity != client;
}

void QueueStateRefresh()
{
    if (!g_StateRefreshQueued)
    {
        g_StateRefreshQueued = true;
        RequestFrame(Frame_RefreshState);
    }
}

public void Frame_RefreshState(any data)
{
    g_StateRefreshQueued = false;
    RefreshBotState();
    HandlePopulationChange();
}

void HandlePopulationChange()
{
    int activeHumans = CountActiveHumans();

    if (!IsModActive())
    {
        g_LastActiveHumans = activeHumans;
        return;
    }

    if (g_SkipNextRoundAdvance || g_ForcedRoundEndMode == FORCED_END_ABORT)
    {
        g_LastActiveHumans = activeHumans;
        return;
    }

    if (g_AdminSoloRoundActive && activeHumans == 1)
    {
        g_LastActiveHumans = activeHumans;
        QueueEmptyRoundRestartCheck();
        return;
    }
    g_AdminSoloRoundActive = false;

    if (activeHumans < 2)
    {
        MoveEveryoneToVisible(true);
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsActiveHuman(client))
            {
                g_WaitingForNextRound[client] = false;
            }
        }
        ClearRoundPriorities();
        g_BetweenRounds = false;
        g_RosterSelectedForNextRound = false;
        g_InitialRosterAtRoundStart = false;
        g_AdvanceRosterAtRoundStart = false;
    }
    else if (g_LastActiveHumans < 2)
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            if (IsActiveHuman(client))
            {
                RestartAfkTimer(client);
            }
        }
        SelectInitialRoster(true);
    }
    else if (g_RoundInProgress
        && !g_BetweenRounds
        && !g_RoundEligibleForAdvance
        && CountRoundParticipants() < 2)
    {
        SelectInitialRoster(true);
    }
    else if (g_BetweenRounds && g_RosterSelectedForNextRound)
    {
        AdjustPendingRoster();
    }

    g_LastActiveHumans = activeHumans;
    if (activeHumans > 0)
    {
        QueueEmptyRoundRestartCheck();
    }
}

void SelectInitialRoster(bool restartRound)
{
    if (!IsModActive())
    {
        return;
    }

    if (restartRound
        && (g_SkipNextRoundAdvance || g_ForcedRoundEndMode != FORCED_END_NONE))
    {
        g_LastActiveHumans = CountActiveHumans();
        return;
    }

    if (restartRound)
    {
        g_InitialRosterAtRoundStart = true;
        g_AdvanceRosterAtRoundStart = false;
        g_BetweenRounds = true;
        g_RosterSelectedForNextRound = true;
        g_LastActiveHumans = CountActiveHumans();
        g_SkipNextRoundAdvance = true;
        g_RoundEligibleForAdvance = false;
        g_ForcedRoundEndMode = FORCED_END_ABORT;
        BeginLightingTransitionRefresh();
        TerminateRoundWithoutStockAudio(0.2, CSRoundEnd_Draw);
        return;
    }

    g_ManagingRoster = true;
    MoveEveryoneToVisible(false);
    ClearRoundPriorities();

    int desiredInvisant = GetDesiredInvisantCount(CountActiveHumans());
    bool selected[MAXPLAYERS + 1];
    for (int slot = 0; slot < desiredInvisant; slot++)
    {
        int client = FindLongestVisibleWaitingCandidate(selected, false);
        if (client == 0)
        {
            client = FindLongestVisibleWaitingCandidate(selected, true);
        }
        if (client == 0)
        {
            break;
        }

        selected[client] = true;
        PromoteToInvisant(client, false);
    }

    g_ManagingRoster = false;
    g_BetweenRounds = false;
    g_RosterSelectedForNextRound = true;
    g_LastActiveHumans = CountActiveHumans();

}

void SelectNextRoster()
{
    g_ManagingRoster = true;
    bool previousInvisant[MAXPLAYERS + 1];

    // Record the outgoing Invisant roster before selecting replacements. A
    // retained Invisant player never leaves the physical Invisant team, which avoids
    // duplicate team events immediately before the round's spawns.
    for (int client = 1; client <= MaxClients; client++)
    {
        g_PromotedByKill[client] = false;
        g_PromotionOrder[client] = 0;

        if (IsActiveHuman(client) && GetClientTeam(client) == GetInvisantTeam())
        {
            previousInvisant[client] = true;
        }
        else if (IsActiveHuman(client)
            && GetClientTeam(client) == GetVisibleTeam()
            && g_QueueOrder[client] == 0
            && !g_AfkQueueRemoved[client])
        {
            PutAtBackOfQueue(client);
        }
    }

    int desiredInvisant = GetDesiredInvisantCount(CountActiveHumans());
    bool selected[MAXPLAYERS + 1];
    int selectedCount;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (g_EarnedInvisant[client] && IsClientAfk(client))
        {
            g_EarnedInvisant[client] = false;
            LogMessage("%N lost Invisant-role priority because they were AFK.", client);
        }
    }

    while (selectedCount < desiredInvisant)
    {
        int client = FindOldestRotatingCandidate(selected, previousInvisant, true, false);
        if (client == 0)
        {
            break;
        }

        selected[client] = true;
        selectedCount++;
        PromoteToInvisant(client, true);
    }

    int skipped[MAXPLAYERS + 1];
    int skippedCount;
    while (skippedCount <= MaxClients)
    {
        int client = FindOldestUnselectedReward(selected, skipped, skippedCount);
        if (client == 0)
        {
            break;
        }

        skipped[skippedCount++] = client;
    }

    // A reduced roster can have more rewarded killers than available slots.
    // Preserve their relative priority while moving them ahead of the queue.
    for (int index = skippedCount - 1; index >= 0; index--)
    {
        PutAtFrontOfQueue(skipped[index]);
    }

    while (selectedCount < desiredInvisant)
    {
        int client = FindOldestRotatingCandidate(selected, previousInvisant, false, false);
        if (client == 0)
        {
            break;
        }

        selected[client] = true;
        selectedCount++;
        PromoteToInvisant(client, false);
    }

    while (selectedCount < desiredInvisant)
    {
        int client = FindInvisantPlayerToRetain(previousInvisant, selected);
        if (client == 0)
        {
            break;
        }

        selected[client] = true;
        selectedCount++;
        LogMessage(
            "%N retained an Invisant slot because no eligible Armitive was available (%d kills, %d prior Invisant rounds).",
            client,
            g_RoundKills[client],
            g_InvisantRoundsPlayed[client]
        );
    }

    // AFK players stay out of the normal queue, but the match must still have
    // an Invisant player when every available candidate has been removed for AFK.
    while (selectedCount < desiredInvisant)
    {
        int client = FindOldestRotatingCandidate(selected, previousInvisant, false, true);
        if (client == 0)
        {
            break;
        }

        selected[client] = true;
        selectedCount++;
        PromoteToInvisant(client, false);
        LogMessage("%N was assigned a required Invisant slot despite being AFK.", client);
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!previousInvisant[client] || selected[client] || !IsActiveHuman(client))
        {
            continue;
        }

        MoveClientToTeam(client, GetVisibleTeam());
        PutAtBackOfQueue(client);
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        g_EarnedInvisant[client] = false;
    }

    g_ManagingRoster = false;
    g_BetweenRounds = true;
    g_RosterSelectedForNextRound = true;
    g_LastActiveHumans = CountActiveHumans();
}

void AdjustPendingRoster()
{
    if (!IsModActive()
        || !g_BetweenRounds
        || !g_RosterSelectedForNextRound
        || g_InitialRosterAtRoundStart
        || g_AdvanceRosterAtRoundStart)
    {
        return;
    }

    g_ManagingRoster = true;
    int desiredInvisant = GetDesiredInvisantCount(CountActiveHumans());
    int invisantCount = CountInvisantHumans();

    while (invisantCount > desiredInvisant)
    {
        int client = FindNewestPromotion(true);
        if (client == 0)
        {
            client = FindNewestPromotion(false);
        }
        if (client == 0)
        {
            break;
        }

        int previousOrder = g_PromotionOrder[client];
        bool wasKillPromotion = g_PromotedByKill[client];
        MoveClientToTeam(client, GetVisibleTeam());

        if (wasKillPromotion)
        {
            PutAtFrontOfQueue(client);
        }
        else if (previousOrder != 0)
        {
            g_QueueOrder[client] = previousOrder;
            SavePersistentQueue(client, previousOrder, true);
        }
        else
        {
            PutAtBackOfQueue(client);
        }

        g_PromotedByKill[client] = false;
        g_PromotionOrder[client] = 0;
        invisantCount--;
    }

    while (invisantCount < desiredInvisant)
    {
        int client = FindOldestVisibleHuman(false);
        if (client == 0)
        {
            client = FindOldestVisibleHuman(true);
        }
        if (client == 0)
        {
            break;
        }

        PromoteToInvisant(client, false);
        invisantCount++;
    }

    g_ManagingRoster = false;
}

int FindLongestVisibleWaitingCandidate(bool[] selected, bool includeAfk)
{
    int bestClient;
    float oldestWaitingSince = 999999999.0;
    int bestOrder = 2147483647;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (selected[client]
            || (!includeAfk && g_AfkQueueRemoved[client])
            || !IsActiveHuman(client)
            || GetClientTeam(client) != GetVisibleTeam())
        {
            continue;
        }

        if (!includeAfk && IsClientAfk(client))
        {
            continue;
        }

        if (g_QueueOrder[client] == 0)
        {
            PutAtBackOfQueue(client);
        }

        if (g_VisibleWaitingSince[client] <= 0.0)
        {
            g_VisibleWaitingSince[client] = GetEngineTime() - GetClientTime(client);
        }

        if (g_QueueOrder[client] < bestOrder
            || (g_QueueOrder[client] == bestOrder
                && g_VisibleWaitingSince[client] < oldestWaitingSince))
        {
            bestClient = client;
            oldestWaitingSince = g_VisibleWaitingSince[client];
            bestOrder = g_QueueOrder[client];
        }
    }

    return bestClient;
}

int FindOldestRotatingCandidate(
    bool[] selected,
    bool[] previousInvisant,
    bool rewardedOnly,
    bool includeAfk
)
{
    int bestClient;
    int bestOrder = 2147483647;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (selected[client]
            || previousInvisant[client]
            || g_ForfeitedInvisantThisRound[client]
            || (!includeAfk && g_AfkQueueRemoved[client])
            || !IsActiveHuman(client)
            || GetClientTeam(client) != GetVisibleTeam())
        {
            continue;
        }

        if (rewardedOnly && !g_EarnedInvisant[client])
        {
            continue;
        }

        if (!includeAfk && IsClientAfk(client))
        {
            continue;
        }

        if (g_QueueOrder[client] == 0)
        {
            PutAtBackOfQueue(client);
        }

        if (g_QueueOrder[client] < bestOrder)
        {
            bestClient = client;
            bestOrder = g_QueueOrder[client];
        }
    }

    return bestClient;
}

int FindInvisantPlayerToRetain(bool[] previousInvisant, bool[] selected)
{
    int bestClient;
    int bestKills = -1;
    int fewestInvisantRounds = 2147483647;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!previousInvisant[client]
            || selected[client]
            || g_AfkQueueRemoved[client]
            || !IsActiveHuman(client)
            || GetClientTeam(client) != GetInvisantTeam())
        {
            continue;
        }

        if (g_RoundKills[client] > bestKills
            || (g_RoundKills[client] == bestKills
                && g_InvisantRoundsPlayed[client] < fewestInvisantRounds))
        {
            bestClient = client;
            bestKills = g_RoundKills[client];
            fewestInvisantRounds = g_InvisantRoundsPlayed[client];
        }
    }

    return bestClient;
}

int FindOldestUnselectedReward(bool[] selected, int[] skipped, int skippedCount)
{
    int bestClient;
    int bestOrder = 2147483647;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (selected[client]
            || !g_EarnedInvisant[client]
            || g_ForfeitedInvisantThisRound[client]
            || !IsActiveHuman(client)
            || GetClientTeam(client) != GetVisibleTeam()
            || IsClientAfk(client))
        {
            continue;
        }

        bool alreadySkipped;
        for (int index = 0; index < skippedCount; index++)
        {
            if (skipped[index] == client)
            {
                alreadySkipped = true;
                break;
            }
        }

        if (alreadySkipped)
        {
            continue;
        }

        if (g_QueueOrder[client] < bestOrder)
        {
            bestClient = client;
            bestOrder = g_QueueOrder[client];
        }
    }

    return bestClient;
}

int FindNewestPromotion(bool killPromotionsOnly)
{
    int bestClient;
    int newestOrder = -2147483647;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsActiveHuman(client) || GetClientTeam(client) != GetInvisantTeam())
        {
            continue;
        }

        if (killPromotionsOnly && !g_PromotedByKill[client])
        {
            continue;
        }

        if (g_PromotionOrder[client] > newestOrder)
        {
            bestClient = client;
            newestOrder = g_PromotionOrder[client];
        }
    }

    return bestClient;
}

int FindOldestVisibleHuman(bool includeAfk)
{
    int bestClient;
    int bestOrder = 2147483647;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsActiveHuman(client)
            || GetClientTeam(client) != GetVisibleTeam()
            || (!includeAfk && g_AfkQueueRemoved[client]))
        {
            continue;
        }

        if (!includeAfk && IsClientAfk(client))
        {
            continue;
        }

        if (g_QueueOrder[client] == 0)
        {
            PutAtBackOfQueue(client);
        }

        if (g_QueueOrder[client] < bestOrder)
        {
            bestClient = client;
            bestOrder = g_QueueOrder[client];
        }
    }

    return bestClient;
}

void PromoteToInvisant(int client, bool byKill)
{
    g_PromotionOrder[client] = g_QueueOrder[client];
    g_PromotedByKill[client] = byKill;
    g_QueueOrder[client] = 0;
    g_VisibleWaitingSince[client] = 0.0;
    SavePersistentQueue(client, GetNextBackQueueStamp(), true);
    DisableFlashlight(client);
    MoveClientToTeam(client, GetInvisantTeam());
    if (IsPlayerAlive(client))
    {
        PrepareInvisantWeapons(client);
        StripInvisantEquipment(client);
        ApplyPlayerUpgrades(client);
        EnableInvisantBlood(client);
    }
    LogMessage("%N was assigned an Invisant slot%s.", client, byKill ? " after earning kill priority" : " from the queue");
}

void MoveEveryoneToVisible(bool respawnMovedPlayers)
{
    bool wasManagingRoster = g_ManagingRoster;
    g_ManagingRoster = true;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsActiveHuman(client))
        {
            continue;
        }

        bool movedToVisible = GetClientTeam(client) != GetVisibleTeam();
        if (movedToVisible)
        {
            MoveClientToTeam(client, GetVisibleTeam());
        }

        if (g_QueueOrder[client] == 0)
        {
            PutAtBackOfQueue(client);
        }

        g_PromotedByKill[client] = false;
        g_PromotionOrder[client] = 0;

        if (movedToVisible && respawnMovedPlayers)
        {
            CreateTimer(0.05, Timer_RespawnAfterVisibleTransition, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
        }
    }

    g_ManagingRoster = wasManagingRoster;
}

public Action Timer_RespawnAfterVisibleTransition(Handle timer, int serial)
{
    int client = GetClientFromSerial(serial);
    if (IsModActive()
        && IsActiveHuman(client)
        && GetClientTeam(client) == GetVisibleTeam()
        && CountActiveHumans() < 2)
    {
        g_WaitingForNextRound[client] = false;
        CS_RespawnPlayer(client);
    }

    return Plugin_Stop;
}

void MoveClientToTeam(int client, int team)
{
    if (!IsHumanClient(client) || GetClientTeam(client) == team)
    {
        return;
    }

    int oldTeam = GetClientTeam(client);
    ClearPlayerUpgradeEffects(client);
    g_AllowedTargetTeam[client] = team;
    if (oldTeam < CS_TEAM_T && team >= CS_TEAM_T)
    {
        ChangeClientTeam(client, team);
    }
    else
    {
        CS_SwitchTeam(client, team);
    }
}

void InitializeWaitingQueue()
{
    g_NextQueueOrder = GetTime();
    g_NextFrontQueueOrder = g_NextQueueOrder;

    for (int client = 1; client <= MaxClients; client++)
    {
        g_QueueOrder[client] = 0;
        if (!IsActiveHuman(client)
            || GetClientTeam(client) != GetVisibleTeam()
            || g_AfkQueueRemoved[client])
        {
            continue;
        }

        if (!g_QueueCookieLoaded[client] && AreClientCookiesCached(client))
        {
            LoadPersistentQueue(client);
        }

        int stamp = g_PersistedQueueStamp[client];
        if (stamp <= 0)
        {
            stamp = GetTime() - RoundToFloor(GetClientTime(client));
            if (stamp <= 0)
            {
                stamp = GetNextBackQueueStamp();
            }
            SavePersistentQueue(client, stamp);
        }

        g_QueueOrder[client] = stamp;
        g_VisibleWaitingSince[client] = GetEngineTime() - GetClientTime(client);
        TrackQueueStamp(stamp);
    }
}

void PutAtBackOfQueue(int client)
{
    if (IsHumanClient(client) && !g_AfkQueueRemoved[client])
    {
        int stamp = GetNextBackQueueStamp();
        g_QueueOrder[client] = stamp;
        g_VisibleWaitingSince[client] = GetEngineTime();
        SavePersistentQueue(client, stamp);
    }
}

void PutAtFrontOfQueue(int client)
{
    if (IsHumanClient(client) && !g_AfkQueueRemoved[client])
    {
        int stamp = --g_NextFrontQueueOrder;
        g_QueueOrder[client] = stamp;
        SavePersistentQueue(client, stamp, true);
    }
}

int GetNextBackQueueStamp()
{
    int now = GetTime();
    if (g_NextQueueOrder < now)
    {
        g_NextQueueOrder = now;
    }
    return ++g_NextQueueOrder;
}

void TrackQueueStamp(int stamp)
{
    if (stamp > g_NextQueueOrder)
    {
        g_NextQueueOrder = stamp;
    }
    if (stamp < g_NextFrontQueueOrder)
    {
        g_NextFrontQueueOrder = stamp;
    }
}

void LoadPersistentQueue(int client, bool applyReconnectGrace = true)
{
    if (!IsHumanClient(client) || !AreClientCookiesCached(client))
    {
        return;
    }

    int stamp;
    bool pendingQueueUpdate = g_QueueCookieDirty[client] && g_PersistedQueueStamp[client] > 0;
    if (pendingQueueUpdate)
    {
        stamp = g_PersistedQueueStamp[client];
        g_QueueStampCookie.SetInt(client, stamp);
        g_QueueCookieDirty[client] = false;
    }
    else
    {
        char value[24];
        g_QueueStampCookie.Get(client, value, sizeof(value));
        stamp = StringToInt(value);
    }
    int now = GetTime();
    int disconnectedAt = g_QueueDisconnectCookie.GetInt(client);
    int lastSeen = g_QueueLastSeenCookie.GetInt(client);
    int absentSince = disconnectedAt > 0 ? disconnectedAt : lastSeen;
    int reconnectGrace = g_CvarQueueReconnectGrace.IntValue;
    int heartbeatTolerance = disconnectedAt > 0 ? 0 : QUEUE_HEARTBEAT_INTERVAL;
    if (!pendingQueueUpdate
        && applyReconnectGrace
        && reconnectGrace > 0
        && absentSince > 0
        && absentSince <= now
        && now - absentSince > reconnectGrace + heartbeatTolerance)
    {
        stamp = GetNextBackQueueStamp();
        g_QueueStampCookie.SetInt(client, stamp);
        LogMessage("%N returned after the %d-second reconnect grace and was placed at the back of the queue.", client, reconnectGrace);
    }
    if (stamp <= 0 || stamp > now + 86400)
    {
        stamp = now - RoundToFloor(GetClientTime(client));
        if (stamp <= 0)
        {
            stamp = now;
        }
        g_QueueStampCookie.SetInt(client, stamp);
    }
    g_QueueDisconnectCookie.SetInt(client, 0);
    g_QueueLastSeenCookie.SetInt(client, now);

    g_QueueCookieLoaded[client] = true;
    g_PersistedQueueStamp[client] = stamp;
    TrackQueueStamp(stamp);

    if (IsActiveHuman(client)
        && GetClientTeam(client) == GetVisibleTeam()
        && !g_AfkQueueRemoved[client])
    {
        g_QueueOrder[client] = stamp;
    }
}

void SavePersistentQueue(int client, int stamp, bool preserveBeforeLoad = false)
{
    if (client < 1 || client > MaxClients || stamp <= 0)
    {
        return;
    }

    g_PersistedQueueStamp[client] = stamp;
    TrackQueueStamp(stamp);
    if (IsClientInGame(client) && !IsFakeClient(client) && AreClientCookiesCached(client))
    {
        g_QueueStampCookie.SetInt(client, stamp);
        g_QueueCookieLoaded[client] = true;
        g_QueueCookieDirty[client] = false;
    }
    else if (preserveBeforeLoad)
    {
        g_QueueCookieDirty[client] = true;
        if (IsClientConnected(client) && !IsFakeClient(client))
        {
            char steamId[32];
            if (GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId), true))
            {
                char value[12];
                IntToString(stamp, value, sizeof(value));
                g_QueueStampCookie.SetByAuthId(steamId, value);
            }
        }
    }
}

void ClearRoundPriorities()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        g_EarnedInvisant[client] = false;
        g_PromotedByKill[client] = false;
        g_PromotionOrder[client] = 0;
        g_ForfeitedInvisantThisRound[client] = false;
        g_RoundKills[client] = 0;
        g_KillStreakCount[client] = 0;
        g_LastKillAt[client] = 0.0;
    }
}

void ForfeitNextInvisantRole(int client, const char[] reason)
{
    if (!g_RoundInProgress
        || !IsHumanClient(client)
        || GetClientTeam(client) != GetVisibleTeam()
        || g_ForfeitedInvisantThisRound[client])
    {
        return;
    }

    g_ForfeitedInvisantThisRound[client] = true;
    g_EarnedInvisant[client] = false;
    LogMessage("%N forfeited Invisant-role eligibility this round by %s.", client, reason);
    PrintToChat(client, "%s You cannot be \x077FA7FFInvisant \x07D6B86Anext round\x01 by suicide", CHAT_PREFIX);
}

void RecordClientActivity(int client)
{
    // Only actual live-round movement resets consecutive inactive deaths.
    int savedAfkDeaths = g_ConsecutiveAfkDeaths[client];
    bool rejoinQueue = g_AfkQueueRemoved[client];
    g_AfkQueueRemoved[client] = false;
    RestartAfkTimer(client);
    g_ConsecutiveAfkDeaths[client] = savedAfkDeaths;

    if (rejoinQueue)
    {
        PutAtBackOfQueue(client);
        QueueStateRefresh();
    }
}

void RestartAfkTimer(int client)
{
    g_LastActivityTime[client] = GetEngineTime();
    ClearAfkWarning(client);
}

void ClearAfkWarning(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    bool warningShown = g_AfkWarningShown[client];
    g_AfkWarningShown[client] = false;
    if (warningShown && g_AfkHudSync != null && IsHumanClient(client))
    {
        ClearSyncHud(client, g_AfkHudSync);
    }
}

void ClearInvisantStarvationWarning(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    g_StarvationActive[client] = false;
    g_StarvationStartedAt[client] = 0.0;
    g_NextStarvationTickAt[client] = 0.0;
    g_StarvationHudRefreshAt[client] = 0.0;
    bool warningShown = g_StarvationWarningShown[client];
    g_StarvationWarningShown[client] = false;
    if (warningShown && g_StarvationHudSync != null && IsHumanClient(client))
    {
        ClearSyncHud(client, g_StarvationHudSync);
    }
}

bool IsMapJoinGraceActive()
{
    return g_MapStartedAt > 0.0
        && g_CvarMapJoinGrace != null
        && g_CvarMapJoinGrace.FloatValue > 0.0
        && GetEngineTime() - g_MapStartedAt <= g_CvarMapJoinGrace.FloatValue;
}

void MarkClientWaitingForNextRound(int client)
{
    if (!IsModActive() || !g_RoundInProgress || !IsHumanClient(client) || g_WaitingForNextRound[client])
    {
        return;
    }

    if (IsMapJoinGraceActive() && g_MapJoinRespawnEligible[client])
    {
        return;
    }

    int otherActiveHumans;
    bool otherInvisantPlayer;
    for (int other = 1; other <= MaxClients; other++)
    {
        if (other == client || !IsActiveHuman(other))
        {
            continue;
        }

        otherActiveHumans++;
        if (GetClientTeam(other) == GetInvisantTeam())
        {
            otherInvisantPlayer = true;
        }
    }

    // The first human must be able to enter play, and the second human causes
    // the initial-roster restart. Only an established match needs this lock.
    // A lone Invisant player still counts so Spectator cannot evade a death.
    if (otherActiveHumans < 2 && !otherInvisantPlayer)
    {
        return;
    }

    g_WaitingForNextRound[client] = true;
    PrintToChat(client, "%s Joined \x07E07A6AArmitive\x01; entering \x07D6B86Anext round", CHAT_PREFIX);
    if (IsPlayerAlive(client))
    {
        CreateTimer(0.0, Timer_EnforceLateJoinWait, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    }
}

void ResetClientState(int client)
{
    g_InvisantScreenTintDisabled[client] = false;
    ClearAssistDamageForClient(client);
    g_OriginalTonemapControllerRef[client] = INVALID_ENT_REFERENCE;
    g_TonemapControllerSaved[client] = false;
    g_AllowedTargetTeam[client] = 0;
    g_QueueOrder[client] = 0;
    g_PromotionOrder[client] = 0;
    g_EarnedInvisant[client] = false;
    g_PromotedByKill[client] = false;
    g_ChoseSpectator[client] = false;
    g_SpectatorLocked[client] = false;
    g_LastArmitiveAttackerUserId[client] = 0;
    g_LastButtons[client] = 0;
    g_UseButtonSampleReady[client] = false;
    g_UseButtonWasDown[client] = false;
    g_PersistedQueueStamp[client] = 0;
    g_QueueCookieLoaded[client] = false;
    g_QueueCookieDirty[client] = false;
    g_ActivitySampleReady[client] = false;
    g_CollisionGroupSaved[client] = false;
    g_AfkForcedDeath[client] = false;
    g_AfkWarningShown[client] = false;
    g_StarvationForcedDeath[client] = false;
    g_StarvationWarningShown[client] = false;
    g_LastInvisantDamageDealtAt[client] = 0.0;
    g_AfkQueueRemoved[client] = false;
    g_IgnoreAfkActivityCommand[client] = false;
    g_ConsecutiveAfkDeaths[client] = 0;
    g_WaitingForNextRound[client] = false;
    g_MapJoinRespawnEligible[client] = false;
    g_MapJoinRespawnConfirmAt[client] = 0.0;
    g_ForfeitedInvisantThisRound[client] = false;
    g_RoundKills[client] = 0;
    g_KillStreakCount[client] = 0;
    g_LastKillAt[client] = 0.0;
    g_InvisantRoundsPlayed[client] = 0;
    g_InvisibleXp[client] = 0;
    g_VisibleXp[client] = 0;
    g_PendingInvisibleXp[client] = 0;
    g_PendingVisibleXp[client] = 0;
    g_UpgradeStage[client][UpgradeSlot_Lightweight] = 0;
    g_UpgradeStage[client][UpgradeSlot_Momentum] = 0;
    g_UpgradeStage[client][UpgradeSlot_Resilience] = 0;
    g_ResilienceGrantedStageThisLife[client] = 0;
    g_UpgradeStage[client][UpgradeSlot_Vampirism] = 0;
    g_UpgradeStage[client][UpgradeSlot_Reforging] = 0;
    g_UpgradeStage[client][UpgradeSlot_Bloodlust] = 0;
    g_UpgradeStage[client][UpgradeSlot_Mobility] = 0;
    g_UpgradeStage[client][UpgradeSlot_Surge] = 0;
    g_UpgradeStage[client][UpgradeSlot_Fortitude] = 0;
    g_FortitudeGrantedStageThisLife[client] = 0;
    g_UpgradeStage[client][UpgradeSlot_Overload] = 0;
    for (int ammoType = 0; ammoType < MAX_TRACKED_AMMO_TYPES; ammoType++)
    {
        g_OverloadGrantedReserveBonus[client][ammoType] = 0;
    }
    g_UpgradeStage[client][UpgradeSlot_Stockpile] = 0;
    g_UpgradeStage[client][UpgradeSlot_Barrage] = 0;
    g_UpgradeStage[client][UpgradeSlot_Recovery] = 0;
    g_UpgradeStage[client][UpgradeSlot_Dexterity] = 0;
    g_UpgradeStage[client][UpgradeSlot_Control] = 0;
    g_UpgradeStage[client][UpgradeSlot_Ward] = 0;
    for (int slot = 0; slot < view_as<int>(UpgradeSlot_Count); slot++)
    {
        g_AppliedUpgradeStage[client][slot] = 0;
    }
    g_InvisibleUpgradePoints[client] = 0;
    g_VisibleUpgradePoints[client] = 0;
    g_XpLoaded[client] = false;
    g_XpLoadStarted[client] = false;
    g_UpgradeMenuQueued[client] = false;
    g_UpgradeMenuOpen[client] = false;
    g_UpgradeMenuToken[client] = 0;
    g_DexterityAnimationToken[client] = 0;
    g_ControlShotToken[client] = 0;
    g_ControlWeaponRef[client] = INVALID_ENT_REFERENCE;
    g_InvisantKnifeWeaponRef[client] = INVALID_ENT_REFERENCE;
    g_InvisantKnifeAttackSequence[client] = INVISANT_CLAW_SEQUENCE_STAB_MISS;
    g_HeadshotTraceAttackerUserId[client] = 0;
    g_HeadshotTraceTick[client] = 0;
    g_LightweightApplied[client] = false;
    g_InvisantMovementSpeedApplied[client] = false;
    g_ResilienceApplied[client] = false;
    g_FortitudeApplied[client] = false;
    g_OverloadApplied[client] = false;
    g_InvisantFootstepPredictionMuted[client] = false;
    g_ControlHadAccuracyPenalty[client] = false;
    g_ControlHadAimPunch[client] = false;
    g_ControlHadAimPunchVelocity[client] = false;
    g_ControlHadViewPunch[client] = false;
    g_InvisantKnifeAttackPending[client] = false;
    g_InvisantKnifeIdlePending[client] = false;
    g_InvisantClawSuppressNativeDamage[client] = false;
    g_InvisantClawApplyingExtendedDamage[client] = false;
    g_HeadshotTracePending[client] = false;
    g_XpSteamId[client][0] = '\0';
    g_AdminObserveTargetUserId[client] = 0;
    g_AdminObserveStartedAt[client] = 0.0;
    g_HudUntil[client] = 0.0;
    g_VisibleWaitingSince[client] = 0.0;
    g_LastWeaponFireAt[client] = 0.0;
    g_LastDamageAt[client] = 0.0;
    g_ControlAccuracyPenaltyBeforeShot[client] = 0.0;
    g_InvisantKnifeNextAttack[client] = 0.0;
    g_InvisantKnifeIdleAt[client] = 0.0;
    g_InvisantSurgeAvailableAt[client] = 0.0;
    g_InvisantSurgeCooldownToken[client]++;
    g_InvisantSurgeReadyCuePlayed[client] = true;
    CancelArmitiveWard(client);
    g_AdminObserveTargetName[client][0] = '\0';
    g_LastActivityTime[client] = GetEngineTime();
    ResetClientParity(client);
}

void RefreshBotState()
{
    bool botsPresent;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsActualBot(client))
        {
            botsPresent = true;
            break;
        }
    }

    if (botsPresent == g_BotsPresent)
    {
        return;
    }

    g_BotsPresent = botsPresent;
    if (g_BotsPresent)
    {
        RestoreGameDescription();
        ClearAllAssistDamage();
        ClearAllInvisantScreenTints();
        for (int client = 1; client <= MaxClients; client++)
        {
            EndAdminObservationAudit(client, "mod disabled by bot presence");
        }
        CancelRoundTimeout();
        RemoveExtraSpawns();
        RestoreVoiceOverrides();
        RestoreAllPlayerCollisions();
        ClearAllPlayerUpgradeEffects();
        RestoreInvisantPlayers(GetInvisantTeam());
        RestoreMapLighting();
        RestoreGameCvars();
        ClearRoundPriorities();
        PrintToChatAll("%s Bots connected. Shroudfire disabled.", CHAT_PREFIX);
        LogMessage("Disabled because a gameplay bot connected.");
        if (g_RoundInProgress)
        {
            CS_TerminateRound(0.2, CSRoundEnd_Draw, true);
        }
    }
    else if (g_CvarEnabled.BoolValue)
    {
        ApplyGameDescription();
        PrintToChatAll("%s Bots left. Shroudfire active.", CHAT_PREFIX);
        LogMessage("Re-enabled after the final gameplay bot disconnected.");
        RemoveAllObjectives();
        EnsureSpawnCapacity();
        InitializeWaitingQueue();
        g_LastActiveHumans = 0;
        HandlePopulationChange();
        OverrideGameCvars();
        ApplyMapLighting();
        RefreshAllInvisantScreenTints();
    }
}

void RestoreInvisantPlayers(int team)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsHumanClient(client) || !IsPlayerAlive(client) || GetClientTeam(client) != team)
        {
            continue;
        }

        RestoreInvisantKnifePrediction(client);
        CS_UpdateClientModel(client);

        if (GetPlayerWeaponSlot(client, 1) == -1)
        {
            GivePlayerItem(client, team == CS_TEAM_T ? "weapon_glock" : "weapon_usp");
        }
        if (HasEntProp(client, Prop_Send, "m_iAccount"))
        {
            SetEntProp(client, Prop_Send, "m_iAccount", 16000);
        }
    }
}

bool IsInvisantCrouchMovementActive(int client)
{
    int flags = GetEntityFlags(client);
    return (flags & FL_ONGROUND) != 0 && (flags & FL_DUCKING) != 0;
}

void SyncAppliedUpgradeStages(int client, bool invisantRole)
{
    if (invisantRole)
    {
        g_AppliedUpgradeStage[client][UpgradeSlot_Lightweight] = g_UpgradeStage[client][UpgradeSlot_Lightweight];
        g_AppliedUpgradeStage[client][UpgradeSlot_Momentum] = g_UpgradeStage[client][UpgradeSlot_Momentum];
        g_AppliedUpgradeStage[client][UpgradeSlot_Resilience] = g_UpgradeStage[client][UpgradeSlot_Resilience];
        g_AppliedUpgradeStage[client][UpgradeSlot_Vampirism] = g_UpgradeStage[client][UpgradeSlot_Vampirism];
        g_AppliedUpgradeStage[client][UpgradeSlot_Reforging] = g_UpgradeStage[client][UpgradeSlot_Reforging];
        g_AppliedUpgradeStage[client][UpgradeSlot_Bloodlust] = g_UpgradeStage[client][UpgradeSlot_Bloodlust];
        g_AppliedUpgradeStage[client][UpgradeSlot_Mobility] = g_UpgradeStage[client][UpgradeSlot_Mobility];
        g_AppliedUpgradeStage[client][UpgradeSlot_Surge] = g_UpgradeStage[client][UpgradeSlot_Surge];
        return;
    }

    g_AppliedUpgradeStage[client][UpgradeSlot_Fortitude] = g_UpgradeStage[client][UpgradeSlot_Fortitude];
    g_AppliedUpgradeStage[client][UpgradeSlot_Overload] = g_UpgradeStage[client][UpgradeSlot_Overload];
    g_AppliedUpgradeStage[client][UpgradeSlot_Stockpile] = g_UpgradeStage[client][UpgradeSlot_Stockpile];
    g_AppliedUpgradeStage[client][UpgradeSlot_Barrage] = g_UpgradeStage[client][UpgradeSlot_Barrage];
    g_AppliedUpgradeStage[client][UpgradeSlot_Recovery] = g_UpgradeStage[client][UpgradeSlot_Recovery];
    g_AppliedUpgradeStage[client][UpgradeSlot_Dexterity] = g_UpgradeStage[client][UpgradeSlot_Dexterity];
    g_AppliedUpgradeStage[client][UpgradeSlot_Control] = g_UpgradeStage[client][UpgradeSlot_Control];
    g_AppliedUpgradeStage[client][UpgradeSlot_Ward] = g_UpgradeStage[client][UpgradeSlot_Ward];
}

bool CanApplyUpgradeChangesImmediately()
{
    return !g_RoundInProgress || g_RoundStartedAt <= 0.0
        || GetGameTime() - g_RoundStartedAt <= g_CvarUpgradePurchaseWindow.FloatValue;
}

void ApplyInvisantMovementSpeed(int client, bool crouchingOnGround)
{
    if (!IsModActive() || !IsInvisantPlayer(client))
    {
        return;
    }

    if (g_AppliedUpgradeStage[client][UpgradeSlot_Momentum] <= 0
        && g_AppliedUpgradeStage[client][UpgradeSlot_Mobility] <= 0)
    {
        return;
    }

    float movementMultiplier = 1.0
        + (float(g_AppliedUpgradeStage[client][UpgradeSlot_Momentum]) * MOMENTUM_SPEED_INCREASE_PER_STAGE);
    if (crouchingOnGround && g_AppliedUpgradeStage[client][UpgradeSlot_Mobility] > 0)
    {
        movementMultiplier *= 1.0 + float(g_AppliedUpgradeStage[client][UpgradeSlot_Mobility])
            * g_CvarMobilityCrouchPercent.FloatValue / 100.0;
    }
    // CS:S rewrites m_flMaxspeed from the active weapon during movement.
    // Lagged movement survives that rewrite without forcing velocity changes
    // that the client would perceive as prediction corrections.
    if (HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", movementMultiplier);
    }
    if (HasEntProp(client, Prop_Send, "m_flMaxspeed"))
    {
        SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", INVISANT_KNIFE_BASE_SPEED);
    }
    g_InvisantMovementSpeedApplied[client] = true;
}

void ApplyPlayerUpgrades(int client)
{
    if (!IsModActive() || !IsActiveHuman(client) || !IsPlayerAlive(client))
    {
        return;
    }

    ClearPlayerUpgradeEffects(client);
    if (GetClientTeam(client) == GetInvisantTeam())
    {
        if (g_AppliedUpgradeStage[client][UpgradeSlot_Lightweight] > 0)
        {
            float gravity = 1.0 - float(g_AppliedUpgradeStage[client][UpgradeSlot_Lightweight]) * LIGHTWEIGHT_GRAVITY_REDUCTION_PER_STAGE;
            SetEntityGravity(client, gravity > 0.0 ? gravity : 0.001);
            g_LightweightApplied[client] = true;
        }
        if (g_AppliedUpgradeStage[client][UpgradeSlot_Momentum] > 0
            || g_AppliedUpgradeStage[client][UpgradeSlot_Mobility] > 0)
        {
            ApplyInvisantMovementSpeed(
                client,
                IsInvisantCrouchMovementActive(client)
            );
        }
        if (HasEntProp(client, Prop_Send, "m_ArmorValue"))
        {
            int armorLimit = INVISANT_BASE_ARMOR
                + (g_AppliedUpgradeStage[client][UpgradeSlot_Resilience] * RESILIENCE_ARMOR_PER_STAGE);
            SetEntProp(client, Prop_Send, "m_ArmorValue", armorLimit);
            g_ResilienceApplied[client] = true;
        }
        if (g_AppliedUpgradeStage[client][UpgradeSlot_Resilience] > g_ResilienceGrantedStageThisLife[client])
        {
            g_ResilienceGrantedStageThisLife[client] = g_AppliedUpgradeStage[client][UpgradeSlot_Resilience];
        }
        if (HasEntProp(client, Prop_Send, "m_bHasHelmet"))
        {
            SetEntProp(
                client,
                Prop_Send,
                "m_bHasHelmet",
                g_AppliedUpgradeStage[client][UpgradeSlot_Resilience] >= g_CvarResilienceHelmetStage.IntValue ? 1 : 0
            );
            g_ResilienceApplied[client] = true;
        }
    }
    else if (GetClientTeam(client) == GetVisibleTeam())
    {
        if (g_CvarArmitiveBaseHealth.IntValue > 0)
        {
            SetEntityHealth(
                client,
                g_CvarArmitiveBaseHealth.IntValue + (g_AppliedUpgradeStage[client][UpgradeSlot_Fortitude] * FORTITUDE_HEALTH_PER_STAGE)
            );
            g_FortitudeApplied[client] = true;
        }
        if (g_AppliedUpgradeStage[client][UpgradeSlot_Fortitude] > g_FortitudeGrantedStageThisLife[client])
        {
            g_FortitudeGrantedStageThisLife[client] = g_AppliedUpgradeStage[client][UpgradeSlot_Fortitude];
        }
        ApplyStockpile(client);
        if (g_AppliedUpgradeStage[client][UpgradeSlot_Overload] > 0)
        {
            int primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
            int secondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
            if (primary != -1)
            {
                ApplyOverloadOnEquip(client, primary);
            }
            if (secondary != -1)
            {
                ApplyOverloadOnEquip(client, secondary);
            }
        }
    }
}

void ClearPlayerUpgradeEffects(int client)
{
    if (IsHumanClient(client) && IsPlayerAlive(client))
    {
        if (g_LightweightApplied[client])
        {
            SetEntityGravity(client, 1.0);
        }
        if (g_InvisantMovementSpeedApplied[client])
        {
            if (HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
            {
                SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            }
            if (HasEntProp(client, Prop_Send, "m_flMaxspeed"))
            {
                SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", INVISANT_KNIFE_BASE_SPEED);
            }
        }
        if (g_ResilienceApplied[client] && HasEntProp(client, Prop_Send, "m_ArmorValue"))
        {
            SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
        }
        if (g_ResilienceApplied[client] && HasEntProp(client, Prop_Send, "m_bHasHelmet"))
        {
            SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
        }
        if (g_FortitudeApplied[client] && GetClientHealth(client) > 100)
        {
            SetEntityHealth(client, 100);
        }
        if (g_OverloadApplied[client])
        {
            RestoreOverloadFromWeapons(client);
        }
        int viewModel = -1;
        if (HasEntProp(client, Prop_Send, "m_hViewModel"))
        {
            viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
        }
        else if (HasEntProp(client, Prop_Data, "m_hViewModel"))
        {
            viewModel = GetEntPropEnt(client, Prop_Data, "m_hViewModel");
        }
        if (viewModel != -1 && IsValidEntity(viewModel))
        {
            if (HasEntProp(viewModel, Prop_Send, "m_flPlaybackRate"))
            {
                SetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate", 1.0);
            }
            else if (HasEntProp(viewModel, Prop_Data, "m_flPlaybackRate"))
            {
                SetEntPropFloat(viewModel, Prop_Data, "m_flPlaybackRate", 1.0);
            }
        }
    }

    g_DexterityAnimationToken[client]++;
    CancelArmitiveWard(client);
    g_LightweightApplied[client] = false;
    g_InvisantMovementSpeedApplied[client] = false;
    g_ResilienceApplied[client] = false;
    g_FortitudeApplied[client] = false;
    g_OverloadApplied[client] = false;
}

void ClearAllPlayerUpgradeEffects()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        ClearPlayerUpgradeEffects(client);
    }
}

void EnsurePlayerCollision(int client)
{
    if (!IsActiveHuman(client) || !IsPlayerAlive(client) || !HasEntProp(client, Prop_Send, "m_CollisionGroup"))
    {
        return;
    }

    if (!g_CollisionGroupSaved[client])
    {
        g_PreviousCollisionGroup[client] = GetEntProp(client, Prop_Send, "m_CollisionGroup");
        g_CollisionGroupSaved[client] = true;
    }

    if (GetEntProp(client, Prop_Send, "m_CollisionGroup") != COLLISION_GROUP_PLAYER)
    {
        SetEntityCollisionGroup(client, COLLISION_GROUP_PLAYER);
    }
}

void RestoreAllPlayerCollisions()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!g_CollisionGroupSaved[client])
        {
            continue;
        }

        if (IsClientInGame(client) && HasEntProp(client, Prop_Send, "m_CollisionGroup"))
        {
            SetEntityCollisionGroup(client, g_PreviousCollisionGroup[client]);
        }
        g_CollisionGroupSaved[client] = false;
    }
}

void EnableInvisantBlood(int client)
{
    if (!IsHumanClient(client) || !HasEntProp(client, Prop_Data, "m_bloodColor"))
    {
        return;
    }

    if (GetEntProp(client, Prop_Data, "m_bloodColor") != BLOOD_COLOR_RED)
    {
        SetEntProp(client, Prop_Data, "m_bloodColor", BLOOD_COLOR_RED);
    }
}

void OverrideGameCvars()
{
    if (!IsModActive())
    {
        RestoreGameCvars();
        return;
    }

    if (!g_GameCvarsOverridden)
    {
        if (g_CvarAutoBalance != null)
        {
            g_OriginalAutoBalance = g_CvarAutoBalance.IntValue;
        }
        if (g_CvarLimitTeams != null)
        {
            g_OriginalLimitTeams = g_CvarLimitTeams.IntValue;
        }
        if (g_CvarFlashlight != null)
        {
            g_OriginalFlashlight = g_CvarFlashlight.IntValue;
        }
        if (g_CvarFriendlyFire != null)
        {
            g_OriginalFriendlyFire = g_CvarFriendlyFire.IntValue;
        }
        if (g_CvarSolidTeammates != null)
        {
            g_OriginalSolidTeammates = g_CvarSolidTeammates.IntValue;
        }
        if (g_CvarForceCamera != null)
        {
            g_OriginalForceCamera = g_CvarForceCamera.IntValue;
        }
        if (g_CvarRoundTime != null)
        {
            g_OriginalRoundTime = g_CvarRoundTime.FloatValue;
        }
        if (g_CvarBuyTime != null)
        {
            g_OriginalBuyTime = g_CvarBuyTime.FloatValue;
        }
        if (g_CvarMaxSpeed != null)
        {
            g_OriginalMaxSpeed = g_CvarMaxSpeed.FloatValue;
        }
        g_GameCvarsOverridden = true;
    }

    if (g_CvarAutoBalance != null)
    {
        g_CvarAutoBalance.IntValue = 0;
    }
    if (g_CvarLimitTeams != null)
    {
        g_CvarLimitTeams.IntValue = 0;
    }
    if (g_CvarFlashlight != null)
    {
        g_CvarFlashlight.IntValue = 1;
    }
    if (g_CvarFriendlyFire != null)
    {
        g_CvarFriendlyFire.IntValue = 0;
    }
    if (g_CvarSolidTeammates != null)
    {
        g_CvarSolidTeammates.IntValue = 1;
    }
    if (g_CvarForceCamera != null)
    {
        g_CvarForceCamera.IntValue = 1;
    }
    if (g_CvarRoundTime != null)
    {
        g_CvarRoundTime.FloatValue = GetConfiguredRoundSeconds() / 60.0;
    }
    if (g_CvarBuyTime != null)
    {
        g_CvarBuyTime.FloatValue = BUY_TIME_CVAR_MINUTES;
    }
    if (g_CvarMaxSpeed != null && g_CvarMaxSpeed.FloatValue < INVISANT_MAX_MOMENTUM_SPEED)
    {
        g_CvarMaxSpeed.FloatValue = INVISANT_MAX_MOMENTUM_SPEED;
    }
}

void RestoreGameCvars()
{
    if (!g_GameCvarsOverridden)
    {
        return;
    }

    g_RestoringGameCvars = true;

    if (g_CvarAutoBalance != null)
    {
        g_CvarAutoBalance.IntValue = g_OriginalAutoBalance;
    }
    if (g_CvarLimitTeams != null)
    {
        g_CvarLimitTeams.IntValue = g_OriginalLimitTeams;
    }
    if (g_CvarFlashlight != null)
    {
        g_CvarFlashlight.IntValue = g_OriginalFlashlight;
    }
    if (g_CvarFriendlyFire != null)
    {
        g_CvarFriendlyFire.IntValue = g_OriginalFriendlyFire;
    }
    if (g_CvarSolidTeammates != null)
    {
        g_CvarSolidTeammates.IntValue = g_OriginalSolidTeammates;
    }
    if (g_CvarForceCamera != null)
    {
        g_CvarForceCamera.IntValue = g_OriginalForceCamera;
    }
    if (g_CvarRoundTime != null)
    {
        g_CvarRoundTime.FloatValue = g_OriginalRoundTime;
    }
    if (g_CvarBuyTime != null)
    {
        g_CvarBuyTime.FloatValue = g_OriginalBuyTime;
    }
    if (g_CvarMaxSpeed != null)
    {
        g_CvarMaxSpeed.FloatValue = g_OriginalMaxSpeed;
    }
    g_GameCvarsOverridden = false;
    g_RestoringGameCvars = false;
}

public void OnEnforcedGameCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (!IsModActive() || !g_GameCvarsOverridden || g_RestoringGameCvars)
    {
        return;
    }

    if (convar == g_CvarFriendlyFire && convar.BoolValue)
    {
        convar.IntValue = 0;
    }
    else if (convar == g_CvarSolidTeammates && !convar.BoolValue)
    {
        convar.IntValue = 1;
    }
    else if (convar == g_CvarForceCamera && convar.IntValue != 1)
    {
        convar.IntValue = 1;
    }
    else if (convar == g_CvarRoundTime
        && FloatAbs(convar.FloatValue - GetConfiguredRoundSeconds() / 60.0) > 0.001)
    {
        convar.FloatValue = GetConfiguredRoundSeconds() / 60.0;
    }
    else if (convar == g_CvarBuyTime
        && FloatAbs(convar.FloatValue - BUY_TIME_CVAR_MINUTES) > 0.001)
    {
        convar.FloatValue = BUY_TIME_CVAR_MINUTES;
    }
    else if (convar == g_CvarMaxSpeed && convar.FloatValue < INVISANT_MAX_MOMENTUM_SPEED)
    {
        convar.FloatValue = INVISANT_MAX_MOMENTUM_SPEED;
    }
}

bool HasTonemapProperties(int entity)
{
    return HasEntProp(entity, Prop_Send, "m_bUseCustomAutoExposureMin")
        && HasEntProp(entity, Prop_Send, "m_bUseCustomAutoExposureMax")
        && HasEntProp(entity, Prop_Send, "m_bUseCustomBloomScale")
        && HasEntProp(entity, Prop_Send, "m_flCustomAutoExposureMin")
        && HasEntProp(entity, Prop_Send, "m_flCustomAutoExposureMax")
        && HasEntProp(entity, Prop_Send, "m_flCustomBloomScale");
}

int FindTonemapSnapshot(int reference)
{
    for (int index = 0; index < g_TonemapSnapshotCount; index++)
    {
        if (g_TonemapRefs[index] == reference)
        {
            return index;
        }
    }
    return -1;
}

bool SaveTonemapSnapshot(int entity)
{
    int reference = EntIndexToEntRef(entity);
    if (FindTonemapSnapshot(reference) != -1)
    {
        return true;
    }
    if (g_TonemapSnapshotCount >= MAX_TONEMAP_SNAPSHOTS)
    {
        if (!g_TonemapWarningLogged)
        {
            LogError(
                "More than %d env_tonemap_controller entities exist; extra controllers were left unchanged.",
                MAX_TONEMAP_SNAPSHOTS
            );
            g_TonemapWarningLogged = true;
        }
        return false;
    }

    int index = g_TonemapSnapshotCount++;
    g_TonemapRefs[index] = reference;
    g_TonemapUseExposureMin[index] = GetEntProp(entity, Prop_Send, "m_bUseCustomAutoExposureMin");
    g_TonemapUseExposureMax[index] = GetEntProp(entity, Prop_Send, "m_bUseCustomAutoExposureMax");
    g_TonemapUseBloom[index] = GetEntProp(entity, Prop_Send, "m_bUseCustomBloomScale");
    g_TonemapExposureMin[index] = GetEntPropFloat(entity, Prop_Send, "m_flCustomAutoExposureMin");
    g_TonemapExposureMax[index] = GetEntPropFloat(entity, Prop_Send, "m_flCustomAutoExposureMax");
    g_TonemapBloom[index] = GetEntPropFloat(entity, Prop_Send, "m_flCustomBloomScale");
    g_TonemapHasBloomMinimum[index] = HasEntProp(entity, Prop_Send, "m_flCustomBloomScaleMinimum");
    if (g_TonemapHasBloomMinimum[index])
    {
        g_TonemapBloomMinimum[index] = GetEntPropFloat(
            entity,
            Prop_Send,
            "m_flCustomBloomScaleMinimum"
        );
    }
    return true;
}

void SetTonemapDark(int entity, float exposure)
{
    SetEntPropFloat(entity, Prop_Send, "m_flCustomAutoExposureMin", exposure);
    SetEntPropFloat(entity, Prop_Send, "m_flCustomAutoExposureMax", exposure);
    SetEntProp(entity, Prop_Send, "m_bUseCustomAutoExposureMin", 1);
    SetEntProp(entity, Prop_Send, "m_bUseCustomAutoExposureMax", 1);
    SetEntPropFloat(entity, Prop_Send, "m_flCustomBloomScale", 0.0);
    if (HasEntProp(entity, Prop_Send, "m_flCustomBloomScaleMinimum"))
    {
        SetEntPropFloat(entity, Prop_Send, "m_flCustomBloomScaleMinimum", 0.0);
    }
    SetEntProp(entity, Prop_Send, "m_bUseCustomBloomScale", 1);
}

void AssignTonemapControllerToPlayers(int controller)
{
    if (controller == -1 || !IsValidEntity(controller))
    {
        return;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsHumanClient(client)
            || !HasEntProp(client, Prop_Send, "m_hTonemapController"))
        {
            continue;
        }

        int currentController = GetEntPropEnt(client, Prop_Send, "m_hTonemapController");
        if (currentController == controller)
        {
            continue;
        }

        if (!g_TonemapControllerSaved[client])
        {
            g_OriginalTonemapControllerRef[client] = currentController == -1
                ? INVALID_ENT_REFERENCE
                : EntIndexToEntRef(currentController);
            g_TonemapControllerSaved[client] = true;
        }

        SetEntPropEnt(client, Prop_Send, "m_hTonemapController", controller);
    }
}

void RestorePlayerTonemapControllers()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (g_TonemapControllerSaved[client]
            && IsClientInGame(client)
            && HasEntProp(client, Prop_Send, "m_hTonemapController"))
        {
            int controller = EntRefToEntIndex(g_OriginalTonemapControllerRef[client]);
            if (controller == INVALID_ENT_REFERENCE || !IsValidEntity(controller))
            {
                controller = -1;
            }
            SetEntPropEnt(client, Prop_Send, "m_hTonemapController", controller);
        }

        g_OriginalTonemapControllerRef[client] = INVALID_ENT_REFERENCE;
        g_TonemapControllerSaved[client] = false;
    }
}

void ApplyTonemapDarkening()
{
    float exposure = g_CvarTonemapExposure.FloatValue;
    if (g_LightStyleRefreshFlip)
    {
        exposure += exposure >= 0.9999 ? -0.0001 : 0.0001;
    }
    int entity = -1;
    int controlled = 0;
    int activeController = -1;

    while ((entity = FindEntityByClassname(entity, "env_tonemap_controller")) != -1)
    {
        if (!HasTonemapProperties(entity))
        {
            continue;
        }

        int reference = EntIndexToEntRef(entity);
        if (reference != g_CreatedTonemapRef && !SaveTonemapSnapshot(entity))
        {
            continue;
        }

        SetTonemapDark(entity, exposure);
        if (activeController == -1)
        {
            activeController = entity;
        }
        controlled++;
    }

    if (controlled > 0)
    {
        AssignTonemapControllerToPlayers(activeController);
        return;
    }

    int controller = CreateEntityByName("env_tonemap_controller");
    if (controller == -1)
    {
        if (!g_TonemapWarningLogged)
        {
            LogError("Could not create an env_tonemap_controller; HDR objects may remain brighter than the map.");
            g_TonemapWarningLogged = true;
        }
        return;
    }

    DispatchKeyValue(controller, "targetname", "shroudfire_tonemap");
    DispatchSpawn(controller);
    ActivateEntity(controller);

    if (!HasTonemapProperties(controller))
    {
        AcceptEntityInput(controller, "Kill");
        if (!g_TonemapWarningLogged)
        {
            LogError("env_tonemap_controller does not expose the expected CS:S properties; HDR darkening is unavailable.");
            g_TonemapWarningLogged = true;
        }
        return;
    }

    g_CreatedTonemapRef = EntIndexToEntRef(controller);
    SetTonemapDark(controller, exposure);
    AssignTonemapControllerToPlayers(controller);
}

void RestoreTonemapControllers()
{
    RestorePlayerTonemapControllers();

    for (int index = 0; index < g_TonemapSnapshotCount; index++)
    {
        int entity = EntRefToEntIndex(g_TonemapRefs[index]);
        if (entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity) || !HasTonemapProperties(entity))
        {
            continue;
        }

        SetEntPropFloat(entity, Prop_Send, "m_flCustomAutoExposureMin", g_TonemapExposureMin[index]);
        SetEntPropFloat(entity, Prop_Send, "m_flCustomAutoExposureMax", g_TonemapExposureMax[index]);
        SetEntProp(entity, Prop_Send, "m_bUseCustomAutoExposureMin", g_TonemapUseExposureMin[index]);
        SetEntProp(entity, Prop_Send, "m_bUseCustomAutoExposureMax", g_TonemapUseExposureMax[index]);
        SetEntPropFloat(entity, Prop_Send, "m_flCustomBloomScale", g_TonemapBloom[index]);
        if (g_TonemapHasBloomMinimum[index]
            && HasEntProp(entity, Prop_Send, "m_flCustomBloomScaleMinimum"))
        {
            SetEntPropFloat(
                entity,
                Prop_Send,
                "m_flCustomBloomScaleMinimum",
                g_TonemapBloomMinimum[index]
            );
        }
        SetEntProp(entity, Prop_Send, "m_bUseCustomBloomScale", g_TonemapUseBloom[index]);
    }
    g_TonemapSnapshotCount = 0;

    int created = EntRefToEntIndex(g_CreatedTonemapRef);
    if (created != INVALID_ENT_REFERENCE && IsValidEntity(created))
    {
        AcceptEntityInput(created, "Kill");
    }
    g_CreatedTonemapRef = INVALID_ENT_REFERENCE;
}

void BeginLightingTransitionRefresh()
{
    ApplyMapLighting();
    if (!IsModActive())
    {
        return;
    }

    RequestFrame(Frame_ApplyMapLighting);
    g_LightingRefreshesRemaining = 20;
    if (g_LightingRefreshTimer == null)
    {
        g_LightingRefreshTimer = CreateTimer(
            0.1,
            Timer_ReassertMapLighting,
            _,
            TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE
        );
    }
}

void ApplyMapLighting()
{
    if (!IsModActive())
    {
        RestoreMapLighting();
        return;
    }

    char lightStyle[8];
    g_CvarMapLightStyle.GetString(lightStyle, sizeof(lightStyle));
    TrimString(lightStyle);

    if (strlen(lightStyle) != 1)
    {
        strcopy(lightStyle, sizeof(lightStyle), "h");
        LogError("Invalid sf_map_lightstyle; using dark style 'h'.");
    }
    else
    {
        lightStyle[0] = CharToLower(lightStyle[0]);
        if (lightStyle[0] < 'a' || lightStyle[0] > 'm')
        {
            strcopy(lightStyle, sizeof(lightStyle), "h");
            LogError("Invalid sf_map_lightstyle; use one letter from 'a' through 'm'. Using 'h'.");
        }
    }

    char lightPattern[4];
    if (lightStyle[0] != 'm' && g_LightStyleRefreshFlip)
    {
        Format(lightPattern, sizeof(lightPattern), "%c%c", lightStyle[0], lightStyle[0]);
    }
    else
    {
        strcopy(lightPattern, sizeof(lightPattern), lightStyle);
    }
    g_LightStyleRefreshFlip = !g_LightStyleRefreshFlip;

    SetLightStyle(0, lightPattern);
    if (lightStyle[0] == 'm')
    {
        RestoreTonemapControllers();
        g_LightingApplied = false;
        return;
    }

    ApplyTonemapDarkening();
    g_LightingApplied = true;
}

void RestoreMapLighting()
{
    RestoreTonemapControllers();
    if (g_LightingApplied)
    {
        SetLightStyle(0, "m");
        g_LightingApplied = false;
    }
}

public void OnSettingsChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (convar == g_CvarInvisantSeeTeam)
    {
        return;
    }

    if (convar == g_CvarEnabled)
    {
        if (!g_CvarEnabled.BoolValue)
        {
            RestoreMapEngineLimits();
            bool wasActive = StringToInt(oldValue) != 0 && !g_BotsPresent && !g_PluginPaused;
            RestoreGameDescription();
            ClearAllAssistDamage();
            ClearAllInvisantScreenTints();
            for (int client = 1; client <= MaxClients; client++)
            {
                EndAdminObservationAudit(client, "mod disabled by configuration");
            }
            CancelRoundTimeout();
            RemoveExtraSpawns();
            RestoreVoiceOverrides();
            RestoreAllPlayerCollisions();
            ClearAllPlayerUpgradeEffects();
            RestoreInvisantPlayers(GetInvisantTeam());
            RestoreMapLighting();
            RestoreGameCvars();
            ClearRoundPriorities();
            if (wasActive && g_RoundInProgress)
            {
                CS_TerminateRound(0.1, CSRoundEnd_Draw, true);
            }
        }
        else
        {
            RefreshBotState();
            if (IsModActive())
            {
                ApplyGameDescription();
                RemoveAllObjectives();
                EnsureSpawnCapacity();
                InitializeWaitingQueue();
                g_LastActiveHumans = 0;
                HandlePopulationChange();
                OverrideGameCvars();
                ApplyMapLighting();
                RefreshAllInvisantScreenTints();
            }
        }
        return;
    }

    if (convar == g_CvarWallhack)
    {
        return;
    }

    if (convar == g_CvarInvisantScreenTint)
    {
        RefreshAllInvisantScreenTints();
        return;
    }

    if (convar == g_CvarExtraSpawns)
    {
        if (g_CvarExtraSpawns.BoolValue)
        {
            EnsureSpawnCapacity();
        }
        else
        {
            RemoveExtraSpawns();
        }
        return;
    }

    if (convar == g_CvarMapLightStyle || convar == g_CvarTonemapExposure)
    {
        ApplyMapLighting();
        return;
    }

    if (convar == g_CvarRoundSeconds)
    {
        OverrideGameCvars();
        if (IsModActive() && g_RoundInProgress && CountRoundParticipants() >= 2)
        {
            float remaining = GetConfiguredRoundSeconds();
            if (g_RoundLiveStartedAt > 0.0)
            {
                remaining -= GetGameTime() - g_RoundLiveStartedAt;
            }
            else
            {
                remaining += (g_CvarFreezeTime == null ? 0.0 : g_CvarFreezeTime.FloatValue)
                    - (GetGameTime() - g_RoundStartedAt);
            }
            StartRoundTimeout(remaining > 0.0 ? remaining : 0.01);
        }
        return;
    }

    if (convar == g_CvarXpLevelBase)
    {
        for (int client = 1; client <= MaxClients; client++)
        {
            if (!IsHumanClient(client) || !g_XpLoaded[client])
            {
                continue;
            }
            bool invisantChanged = ReconcileUpgradePoints(client, true);
            bool armitiveChanged = ReconcileUpgradePoints(client, false);
            if (invisantChanged || armitiveChanged)
            {
                SavePlayerXp(client);
            }
        }
        return;
    }

    if (convar == g_CvarInvisantTeam && IsModActive())
    {
        ClearAllInvisantScreenTints();
        ClearAllPlayerUpgradeEffects();
        RestoreInvisantPlayers(StringToInt(oldValue));
        EnsureSpawnCapacity();
        InitializeWaitingQueue();
        SelectInitialRoster(CountActiveHumans() >= 2);
        return;
    }

    if (convar == g_CvarVisiblePerInvisant && IsModActive())
    {
        EnsureSpawnCapacity();
        if (g_BetweenRounds && g_RosterSelectedForNextRound)
        {
            AdjustPendingRoster();
        }
        return;
    }
}

void SetClientFootstepPrediction(int client, bool muted)
{
    if (!IsHumanClient(client) || g_CvarFootsteps == null
        || g_InvisantFootstepPredictionMuted[client] == muted)
    {
        return;
    }

    char value[16];
    if (muted)
    {
        strcopy(value, sizeof(value), "0");
    }
    else
    {
        g_CvarFootsteps.GetString(value, sizeof(value));
    }

    if (SendConVarValue(client, g_CvarFootsteps, value))
    {
        g_InvisantFootstepPredictionMuted[client] = muted;
    }
}

void RefreshClientFootstepPrediction(int client)
{
    SetClientFootstepPrediction(
        client,
        IsModActive() && g_CvarSilentLocalMovement.BoolValue && GetClientTeam(client) == GetInvisantTeam()
    );
}

void RefreshAllClientFootstepPrediction()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsHumanClient(client))
        {
            RefreshClientFootstepPrediction(client);
        }
    }
}

void RestoreAllClientFootstepPrediction()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsHumanClient(client))
        {
            SetClientFootstepPrediction(client, false);
        }
    }
}

void RefreshVoiceOverrides()
{
    bool active = IsModActive();
    if (!active)
    {
        RestoreVoiceOverrides();
        return;
    }

    g_VoiceOverridesApplied = true;
    for (int receiver = 1; receiver <= MaxClients; receiver++)
    {
        if (!IsHumanClient(receiver))
        {
            continue;
        }

        for (int sender = 1; sender <= MaxClients; sender++)
        {
            if (!IsHumanClient(sender))
            {
                continue;
            }

            ListenOverride voiceRule = Listen_Default;
            if (!g_VoiceOverrideSaved[receiver][sender])
            {
                g_PreviousVoiceOverride[receiver][sender] = GetListenOverride(receiver, sender);
                g_VoiceOverrideSaved[receiver][sender] = true;
            }

            voiceRule = g_PreviousVoiceOverride[receiver][sender];
            bool muted = GetFeatureStatus(FeatureType_Native, "BaseComm_IsClientMuted") == FeatureStatus_Available
                && BaseComm_IsClientMuted(sender);
            if (muted)
            {
                voiceRule = Listen_No;
            }
            else if (voiceRule != Listen_No)
            {
                voiceRule = Listen_Yes;
            }
            SetListenOverride(receiver, sender, voiceRule);
        }
    }
}

void RestoreVoiceOverrides()
{
    if (!g_VoiceOverridesApplied)
    {
        return;
    }

    for (int receiver = 1; receiver <= MaxClients; receiver++)
    {
        if (!IsHumanClient(receiver))
        {
            continue;
        }

        for (int sender = 1; sender <= MaxClients; sender++)
        {
            if (g_VoiceOverrideSaved[receiver][sender])
            {
                if (IsHumanClient(sender))
                {
                    SetListenOverride(receiver, sender, g_PreviousVoiceOverride[receiver][sender]);
                }
                g_VoiceOverrideSaved[receiver][sender] = false;
            }
        }
    }
    g_VoiceOverridesApplied = false;
}

void ClearSavedVoiceOverrides(int client)
{
    for (int other = 1; other <= MaxClients; other++)
    {
        g_VoiceOverrideSaved[client][other] = false;
        g_VoiceOverrideSaved[other][client] = false;
    }
}

void EnsureSpawnCapacity()
{
    if (!IsModActive() || !g_CvarExtraSpawns.BoolValue)
    {
        return;
    }

    if (GetMaxEntities() - GetEntityCount() > ENTITY_RESERVE + 32)
    {
        g_SpawnBudgetWarningLogged = false;
    }

    int maximumInvisant = GetDesiredInvisantCount(MaxClients);
    EnsureTeamSpawnCapacity(GetInvisantTeam(), maximumInvisant);
    EnsureTeamSpawnCapacity(GetVisibleTeam(), MaxClients - maximumInvisant);
}

void EnsureTeamSpawnCapacity(int team, int targetCount)
{
    char classname[40];
    GetSpawnClassname(team, classname, sizeof(classname));

    float positions[MAX_SPAWN_POSITIONS][3];
    float angles[MAX_SPAWN_POSITIONS][3];
    int count = CollectSpawnPoints(classname, positions, angles, MAX_SPAWN_POSITIONS);
    if (g_BaseSpawnCount[team] == 0)
    {
        g_BaseSpawnCount[team] = count;
    }

    int baseCount = g_BaseSpawnCount[team];
    if (baseCount > count)
    {
        baseCount = count;
    }

    if (count >= targetCount)
    {
        return;
    }
    if (baseCount == 0)
    {
        LogError("Cannot add %s spawns because the map has no original spawn to clone safely.", classname);
        return;
    }

    int startingCount = count;
    for (int ring = 1; ring <= 8 && count < targetCount; ring++)
    {
        float radius = 32.0 + float(ring) * 24.0;
        for (int base = 0; base < baseCount && count < targetCount; base++)
        {
            for (int direction = 0; direction < 8 && count < targetCount; direction++)
            {
                float directionDegrees = float(direction) * 45.0 + float(base % 2) * 22.5;
                float candidate[3];
                candidate[0] = positions[base][0] + Cosine(DegToRad(directionDegrees)) * radius;
                candidate[1] = positions[base][1] + Sine(DegToRad(directionDegrees)) * radius;
                candidate[2] = positions[base][2];

                if (!ValidateSpawnCandidate(positions[base], candidate, positions, count))
                {
                    continue;
                }

                int freeEntities = GetMaxEntities() - GetEntityCount();
                if (freeEntities <= ENTITY_RESERVE)
                {
                    if (!g_SpawnBudgetWarningLogged)
                    {
                        g_SpawnBudgetWarningLogged = true;
                        LogError(
                            "Stopped adding %s spawns at %d/%d to preserve %d free entities.",
                            classname,
                            count,
                            targetCount,
                            ENTITY_RESERVE
                        );
                    }
                    return;
                }

                int spawn = CreateEntityByName(classname);
                if (spawn == -1)
                {
                    if (!g_SpawnBudgetWarningLogged)
                    {
                        g_SpawnBudgetWarningLogged = true;
                        LogError("Stopped adding %s spawns because entity creation failed at %d/%d.", classname, count, targetCount);
                    }
                    return;
                }

                DispatchKeyValueVector(spawn, "origin", candidate);
                DispatchKeyValueVector(spawn, "angles", angles[base]);
                DispatchSpawn(spawn);
                ActivateEntity(spawn);

                if (g_ExtraSpawnCount >= MAX_EXTRA_SPAWNS)
                {
                    AcceptEntityInput(spawn, "Kill");
                    break;
                }

                g_ExtraSpawnRefs[g_ExtraSpawnCount++] = EntIndexToEntRef(spawn);
                positions[count][0] = candidate[0];
                positions[count][1] = candidate[1];
                positions[count][2] = candidate[2];
                angles[count][0] = angles[base][0];
                angles[count][1] = angles[base][1];
                angles[count][2] = angles[base][2];
                count++;
            }
        }
    }

    if (count > startingCount)
    {
        LogMessage("Added %d validated %s spawns (%d/%d available).", count - startingCount, classname, count, targetCount);
    }
    if (count < targetCount)
    {
        LogError("Only %d/%d safe %s spawns are available; no unsafe positions were created.", count, targetCount, classname);
    }
}

int CollectSpawnPoints(const char[] classname, float positions[][3], float angles[][3], int maximum)
{
    int count;
    int entity = -1;
    while (count < maximum && (entity = FindEntityByClassname(entity, classname)) != -1)
    {
        if (HasEntProp(entity, Prop_Data, "m_bDisabled")
            && GetEntProp(entity, Prop_Data, "m_bDisabled") != 0)
        {
            continue;
        }

        if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
        {
            GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", positions[count]);
        }
        else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
        {
            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", positions[count]);
        }
        else
        {
            continue;
        }

        if (HasEntProp(entity, Prop_Data, "m_angAbsRotation"))
        {
            GetEntPropVector(entity, Prop_Data, "m_angAbsRotation", angles[count]);
        }
        else if (HasEntProp(entity, Prop_Data, "m_angRotation"))
        {
            GetEntPropVector(entity, Prop_Data, "m_angRotation", angles[count]);
        }
        else
        {
            angles[count][0] = 0.0;
            angles[count][1] = 0.0;
            angles[count][2] = 0.0;
        }
        count++;
    }
    return count;
}

bool ValidateSpawnCandidate(
    const float basePosition[3],
    float candidate[3],
    const float occupiedPositions[][3],
    int occupiedCount
)
{
    float rayStart[3];
    float rayEnd[3];
    rayStart[0] = candidate[0];
    rayStart[1] = candidate[1];
    rayStart[2] = candidate[2] + 48.0;
    rayEnd[0] = candidate[0];
    rayEnd[1] = candidate[1];
    rayEnd[2] = candidate[2] - 128.0;

    Handle groundTrace = TR_TraceRayFilterEx(
        rayStart,
        rayEnd,
        MASK_PLAYERSOLID_BRUSHONLY,
        RayType_EndPoint,
        TraceFilter_SpawnGeometry
    );
    if (!TR_DidHit(groundTrace) || TR_StartSolid(groundTrace) || TR_GetEntityIndex(groundTrace) > 0)
    {
        delete groundTrace;
        return false;
    }

    float groundNormal[3];
    TR_GetPlaneNormal(groundTrace, groundNormal);
    TR_GetEndPosition(candidate, groundTrace);
    delete groundTrace;

    if (groundNormal[2] < 0.7)
    {
        return false;
    }
    candidate[2] += 2.0;

    if (TR_PointOutsideWorld(candidate))
    {
        return false;
    }

    int contents = TR_GetPointContents(candidate);
    if ((contents & (CONTENTS_SOLID | CONTENTS_SLIME | CONTENTS_WATER | CONTENTS_PLAYERCLIP | CONTENTS_LADDER)) != 0)
    {
        return false;
    }

    for (int index = 0; index < occupiedCount; index++)
    {
        float deltaX = candidate[0] - occupiedPositions[index][0];
        float deltaY = candidate[1] - occupiedPositions[index][1];
        if (FloatAbs(candidate[2] - occupiedPositions[index][2]) < 72.0
            && deltaX * deltaX + deltaY * deltaY < 2304.0)
        {
            return false;
        }
    }

    float hullMins[3] = {-16.0, -16.0, 0.0};
    float hullMaxs[3] = {16.0, 16.0, 72.0};
    Handle clearanceTrace = TR_TraceHullFilterEx(
        candidate,
        candidate,
        hullMins,
        hullMaxs,
        MASK_PLAYERSOLID,
        TraceFilter_SpawnGeometry
    );
    bool blocked = TR_DidHit(clearanceTrace) || TR_StartSolid(clearanceTrace);
    delete clearanceTrace;
    if (blocked)
    {
        return false;
    }

    float pathStart[3];
    pathStart[0] = basePosition[0];
    pathStart[1] = basePosition[1];
    pathStart[2] = basePosition[2] + 2.0;
    Handle pathTrace = TR_TraceHullFilterEx(
        pathStart,
        candidate,
        hullMins,
        hullMaxs,
        MASK_PLAYERSOLID,
        TraceFilter_SpawnGeometry
    );
    bool reachable = !TR_StartSolid(pathTrace) && TR_GetFraction(pathTrace) > 0.98;
    delete pathTrace;
    return reachable;
}

public bool TraceFilter_SpawnGeometry(int entity, int contentsMask, any data)
{
    return entity <= 0 || entity > MaxClients;
}

int CountTeamSpawns(int team)
{
    char classname[40];
    GetSpawnClassname(team, classname, sizeof(classname));

    int count;
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, classname)) != -1)
    {
        if (HasEntProp(entity, Prop_Data, "m_bDisabled")
            && GetEntProp(entity, Prop_Data, "m_bDisabled") != 0)
        {
            continue;
        }
        count++;
    }
    return count;
}

void GetSpawnClassname(int team, char[] classname, int length)
{
    strcopy(
        classname,
        length,
        team == CS_TEAM_T ? "info_player_terrorist" : "info_player_counterterrorist"
    );
}

void RemoveExtraSpawns()
{
    for (int index = 0; index < g_ExtraSpawnCount; index++)
    {
        int reference = g_ExtraSpawnRefs[index];
        g_ExtraSpawnRefs[index] = INVALID_ENT_REFERENCE;
        if (reference == 0 || reference == INVALID_ENT_REFERENCE)
        {
            continue;
        }

        int entity = EntRefToEntIndex(reference);
        if (entity != INVALID_ENT_REFERENCE && entity > MaxClients && IsValidEntity(entity))
        {
            AcceptEntityInput(entity, "Kill");
        }
    }
    g_ExtraSpawnCount = 0;
}

void StatusLine(int client, const char[] format, any ...)
{
    char buffer[256];
    VFormat(buffer, sizeof(buffer), format, 3);
    if (client == 0)
    {
        PrintToServer("%s", buffer);
    }
    else
    {
        PrintToConsole(client, "%s", buffer);
    }
}

void StartRoundTimeout(float seconds)
{
    CancelRoundTimeout();

    if (IsModActive() && g_RoundInProgress && CountActiveHumans() >= 2 && seconds > 0.0)
    {
        g_RoundTimeoutTimer = CreateTimer(seconds, Timer_RoundTimeout, _, TIMER_FLAG_NO_MAPCHANGE);
    }
}

void CancelRoundTimeout()
{
    if (g_RoundTimeoutTimer != null)
    {
        delete g_RoundTimeoutTimer;
        g_RoundTimeoutTimer = null;
    }
}

float GetConfiguredRoundSeconds()
{
    return g_CvarRoundSeconds == null ? 120.0 : g_CvarRoundSeconds.FloatValue;
}

bool IsShroudfireObjective(const char[] classname)
{
    return StrContains(classname, "hostage_", false) == 0
        || StrEqual(classname, "func_hostage_rescue", false)
        || StrEqual(classname, "info_hostage_rescue", false)
        || StrEqual(classname, "weapon_c4", false)
        || StrEqual(classname, "planted_c4", false)
        || StrEqual(classname, "func_bomb_target", false)
        || StrEqual(classname, "info_bomb_target", false)
        || StrEqual(classname, "func_escapezone", false)
        || StrEqual(classname, "func_vip_safetyzone", false);
}

void RemoveAllObjectives()
{
    int maxEntities = GetMaxEntities();
    char classname[64];
    for (int entity = MaxClients + 1; entity < maxEntities; entity++)
    {
        if (!IsValidEntity(entity))
        {
            continue;
        }

        GetEntityClassname(entity, classname, sizeof(classname));
        if (IsShroudfireObjective(classname))
        {
            AcceptEntityInput(entity, "Kill");
        }
    }
}

void RemoveBombFromPlayer(int client)
{
    int bomb = GetPlayerWeaponSlot(client, CS_SLOT_C4);
    if (bomb != -1 && IsValidEntity(bomb))
    {
        RemovePlayerItem(client, bomb);
        AcceptEntityInput(bomb, "Kill");
    }
}

void DisableFlashlight(int client)
{
    if (!IsHumanClient(client) || !HasEntProp(client, Prop_Send, "m_fEffects"))
    {
        return;
    }

    int effects = GetEntProp(client, Prop_Send, "m_fEffects");
    if ((effects & EF_DIMLIGHT) != 0)
    {
        SetEntProp(client, Prop_Send, "m_fEffects", effects & ~EF_DIMLIGHT);
    }
}

void StripInvisantEquipment(int client)
{
    DisableFlashlight(client);

    if (HasEntProp(client, Prop_Send, "m_ArmorValue"))
    {
        int armor = GetEntProp(client, Prop_Send, "m_ArmorValue");
        int armorLimit = INVISANT_BASE_ARMOR
            + (g_AppliedUpgradeStage[client][UpgradeSlot_Resilience] * RESILIENCE_ARMOR_PER_STAGE);
        if (armor > armorLimit)
        {
            SetEntProp(client, Prop_Send, "m_ArmorValue", armorLimit);
        }
    }
    if (HasEntProp(client, Prop_Send, "m_bHasHelmet"))
    {
        int shouldHaveHelmet = g_AppliedUpgradeStage[client][UpgradeSlot_Resilience] >= g_CvarResilienceHelmetStage.IntValue ? 1 : 0;
        if (GetEntProp(client, Prop_Send, "m_bHasHelmet") != shouldHaveHelmet)
        {
            SetEntProp(client, Prop_Send, "m_bHasHelmet", shouldHaveHelmet);
        }
    }
    if (HasEntProp(client, Prop_Send, "m_bHasDefuser") && GetEntProp(client, Prop_Send, "m_bHasDefuser") != 0)
    {
        SetEntProp(client, Prop_Send, "m_bHasDefuser", 0);
    }
    if (HasEntProp(client, Prop_Send, "m_bHasNightVision") && GetEntProp(client, Prop_Send, "m_bHasNightVision") != 0)
    {
        SetEntProp(client, Prop_Send, "m_bHasNightVision", 0);
    }
    if (HasEntProp(client, Prop_Send, "m_bNightVisionOn") && GetEntProp(client, Prop_Send, "m_bNightVisionOn") != 0)
    {
        SetEntProp(client, Prop_Send, "m_bNightVisionOn", 0);
    }
    if (HasEntProp(client, Prop_Send, "m_bHasWard") && GetEntProp(client, Prop_Send, "m_bHasWard") != 0)
    {
        SetEntProp(client, Prop_Send, "m_bHasWard", 0);
    }
    if (HasEntProp(client, Prop_Send, "m_iAccount") && GetEntProp(client, Prop_Send, "m_iAccount") != 0)
    {
        SetEntProp(client, Prop_Send, "m_iAccount", 0);
    }
}

bool IsClientAfk(int client)
{
    if (!IsHumanClient(client))
    {
        return false;
    }

    if (g_AfkQueueRemoved[client])
    {
        return true;
    }

    if (g_CvarAfkSeconds.FloatValue <= 0.0
        || CountActiveHumans() < 2)
    {
        return false;
    }

    return GetEngineTime() - g_LastActivityTime[client] >= g_CvarAfkSeconds.FloatValue;
}

int GetQueuePosition(int client)
{
    if (!IsActiveHuman(client) || GetClientTeam(client) != GetVisibleTeam() || IsClientAfk(client))
    {
        return 0;
    }

    int position = 1;
    for (int other = 1; other <= MaxClients; other++)
    {
        if (other == client
            || !IsActiveHuman(other)
            || GetClientTeam(other) != GetVisibleTeam()
            || IsClientAfk(other))
        {
            continue;
        }

        if (g_EarnedInvisant[client])
        {
            if (g_EarnedInvisant[other] && g_QueueOrder[other] < g_QueueOrder[client])
            {
                position++;
            }
        }
        else if (g_EarnedInvisant[other] || g_QueueOrder[other] < g_QueueOrder[client])
        {
            position++;
        }
    }

    return position;
}

void PrepareInvisantWeapons(int client)
{
    for (int slot = 0; slot <= 4; slot++)
    {
        int weapon;
        while ((weapon = GetPlayerWeaponSlot(client, slot)) != -1)
        {
            if (slot == CS_SLOT_KNIFE)
            {
                char classname[64];
                GetEntityClassname(weapon, classname, sizeof(classname));
                if (IsKnife(classname))
                {
                    break;
                }
            }

            if (!RemovePlayerItem(client, weapon))
            {
                break;
            }

            AcceptEntityInput(weapon, "Kill");
        }
    }

    // The stock spawn already supplies a knife. Keeping it avoids a second
    // client-side weapon-pickup notice when the Invisant loadout is prepared.
    if (GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) == -1)
    {
        GivePlayerItem(client, "weapon_knife");
    }
    g_IgnoreAfkActivityCommand[client] = true;
    FakeClientCommand(client, "use weapon_knife");
    g_IgnoreAfkActivityCommand[client] = false;
}

int CountActiveHumans()
{
    int count;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsActiveHuman(client))
        {
            count++;
        }
    }
    return count;
}

int CountRoundParticipants()
{
    int count;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsActiveHuman(client) && !g_WaitingForNextRound[client])
        {
            count++;
        }
    }
    return count;
}

int CountInvisantHumans()
{
    int count;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsActiveHuman(client) && GetClientTeam(client) == GetInvisantTeam())
        {
            count++;
        }
    }
    return count;
}

int CountAliveHumans(int team)
{
    int count;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsActiveHuman(client) && IsPlayerAlive(client) && GetClientTeam(client) == team)
        {
            count++;
        }
    }
    return count;
}

int GetDesiredInvisantCount(int activeHumans)
{
    if (activeHumans < 2)
    {
        return 0;
    }

    int visiblePerInvisant = g_CvarVisiblePerInvisant.IntValue;
    // Round upward when the existing Invisant players would otherwise have
    // more Armitive opponents than the configured maximum.
    int desired = (activeHumans + visiblePerInvisant) / (visiblePerInvisant + 1);
    int maximum = activeHumans == 2 ? 1 : (activeHumans - 1) / 2;

    if (desired < 1)
    {
        desired = 1;
    }
    if (desired > maximum)
    {
        desired = maximum;
    }
    return desired;
}

int GetInvisantTeam()
{
    return g_CvarInvisantTeam.IntValue;
}

int GetVisibleTeam()
{
    return GetInvisantTeam() == CS_TEAM_T ? CS_TEAM_CT : CS_TEAM_T;
}

bool IsModActive()
{
    return g_CvarEnabled != null && g_CvarEnabled.BoolValue && !g_BotsPresent && !g_PluginPaused;
}

bool IsInvisantPlayer(int client)
{
    return IsModActive()
        && IsHumanClient(client)
        && IsPlayerAlive(client)
        && GetClientTeam(client) == GetInvisantTeam();
}

bool IsActiveHuman(int client)
{
    if (!IsHumanClient(client))
    {
        return false;
    }

    int team = GetClientTeam(client);
    return team == CS_TEAM_T || team == CS_TEAM_CT;
}

bool IsHumanClient(int client)
{
    return client >= 1
        && client <= MaxClients
        && IsClientInGame(client)
        && !IsFakeClient(client);
}

bool IsActualBot(int client)
{
    return client >= 1
        && client <= MaxClients
        && IsClientInGame(client)
        && IsFakeClient(client)
        && !IsClientSourceTV(client)
        && !IsClientReplay(client);
}

bool IsKnife(const char[] classname)
{
    return StrEqual(classname, "weapon_knife", false);
}

void ClearAssistDamageAgainstVictim(int victim)
{
    if (victim < 1 || victim > MaxClients)
    {
        return;
    }

    for (int attacker = 1; attacker <= MaxClients; attacker++)
    {
        g_AssistDamage[attacker][victim] = 0;
    }
    g_HealthBeforeDamage[victim] = 0;
}

void ClearAssistDamageForClient(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    for (int other = 1; other <= MaxClients; other++)
    {
        g_AssistDamage[client][other] = 0;
        g_AssistDamage[other][client] = 0;
    }
    g_HealthBeforeDamage[client] = 0;
}

void ClearAllAssistDamage()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        ClearAssistDamageForClient(client);
    }
}

void AwardAssistXpForKill(int victim, int killer, bool invisibleRole, int killXp)
{
    float xpFraction = g_CvarXpAssistFraction.FloatValue;

    int killerTeam = GetClientTeam(killer);
    int totalDamage;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (g_AssistDamage[client][victim] > 0
            && IsActiveHuman(client)
            && GetClientTeam(client) == killerTeam
            && !g_WaitingForNextRound[client])
        {
            totalDamage += g_AssistDamage[client][victim];
        }
    }
    if (totalDamage <= 0)
    {
        return;
    }

    int assistXp = RoundToNearest(float(killXp) * xpFraction);

    float minimumDamageShare = g_CvarXpAssistDamageShare.FloatValue;
    for (int client = 1; client <= MaxClients; client++)
    {
        int assistedDamage = g_AssistDamage[client][victim];
        if (client == killer
            || assistedDamage <= 0
            || !IsActiveHuman(client)
            || GetClientTeam(client) != killerTeam
            || g_WaitingForNextRound[client]
            || float(assistedDamage) + 0.001 < float(totalDamage) * minimumDamageShare)
        {
            continue;
        }

        IncrementCombatStat(client, GetClientTeam(client) == GetInvisantTeam() ? "invisant_assists" : "armitive_assists");
        AwardPlayerXp(client, invisibleRole, assistXp);
        SetNotice(client, 1, g_CvarHudAssistSeconds.FloatValue, "Assisted killing %N | +%d XP", victim, assistXp);
    }
}

void AwardRoundWinXp(int winningTeam)
{
    if (CountRoundParticipants() < 2)
    {
        return;
    }

    if (winningTeam != GetInvisantTeam() && winningTeam != GetVisibleTeam())
    {
        LogError("Completed Shroudfire round reported invalid winning team %d; no round-win XP was awarded.", winningTeam);
        return;
    }

    bool invisibleRole = winningTeam == GetInvisantTeam();
    int amount = invisibleRole
        ? g_CvarXpRoundWinInvisant.IntValue
        : g_CvarXpRoundWinArmitive.IntValue;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsActiveHuman(client)
            && GetClientTeam(client) == winningTeam
            && !g_WaitingForNextRound[client])
        {
            AwardPlayerXp(client, invisibleRole, amount);
            SetNotice(client, 3, g_CvarHudRoundWinXpSeconds.FloatValue, "Round win | +%d XP", amount);
        }
    }
}

void AwardPlayerXp(int client, bool invisibleRole, int amount)
{
    if (!IsHumanClient(client) || amount <= 0)
    {
        return;
    }

    if (!g_XpLoaded[client])
    {
        if (invisibleRole)
        {
            g_PendingInvisibleXp[client] = AddXpWithoutOverflow(g_PendingInvisibleXp[client], amount);
        }
        else
        {
            g_PendingVisibleXp[client] = AddXpWithoutOverflow(g_PendingVisibleXp[client], amount);
        }
        LoadPlayerXp(client);
        return;
    }

    int currentXp = invisibleRole ? g_InvisibleXp[client] : g_VisibleXp[client];
    if (currentXp >= GetMaximumPlayerXp())
    {
        return;
    }

    int oldLevel;
    int newLevel;
    if (invisibleRole)
    {
        oldLevel = GetXpLevel(g_InvisibleXp[client]);
        g_InvisibleXp[client] = AddXpWithoutOverflow(g_InvisibleXp[client], amount);
        newLevel = GetXpLevel(g_InvisibleXp[client]);
    }
    else
    {
        oldLevel = GetXpLevel(g_VisibleXp[client]);
        g_VisibleXp[client] = AddXpWithoutOverflow(g_VisibleXp[client], amount);
        newLevel = GetXpLevel(g_VisibleXp[client]);
    }

    ReconcileUpgradePoints(client, invisibleRole);
    SavePlayerXp(client);
    if (newLevel > oldLevel)
    {
        SetNotice(client, 2, g_CvarHudLevelupSeconds.FloatValue, "%s level %d", invisibleRole ? "Invisant" : "Armitive", newLevel);
        PrintToChat(
            client,
            "%s %s\x01 level \x0793C47D%d\x01! Upgrade menu \x07D6B86Anext round\x01 as %s",
            CHAT_PREFIX,
            invisibleRole ? "\x077FA7FFInvisant" : "\x07E07A6AArmitive",
            newLevel,
            invisibleRole ? "\x077FA7FFInvisant" : "\x07E07A6AArmitive"
        );
    }
}

int ClampUpgradeStage(int stage)
{
    if (stage < 0)
    {
        return 0;
    }
    if (stage > MAX_UPGRADE_STAGE)
    {
        return MAX_UPGRADE_STAGE;
    }
    return stage;
}

int ClampUpgradePoints(int points, int spentStages)
{
    if (points < 0)
    {
        return 0;
    }

    int capacity = (MAX_UPGRADE_STAGE * UPGRADES_PER_ROLE) - spentStages;
    return points > capacity ? capacity : points;
}

bool ReconcileUpgradePoints(int client, bool invisantRole)
{
    int spent;
    for (int index = 0; index < UPGRADES_PER_ROLE; index++)
        spent += g_UpgradeStage[client][UPGRADE_ORDER[invisantRole ? 0 : 1][index]];
    int points = GetXpLevel(invisantRole ? g_InvisibleXp[client] : g_VisibleXp[client]) - spent;
    if (points < 0) points = 0;
    int previous = invisantRole ? g_InvisibleUpgradePoints[client] : g_VisibleUpgradePoints[client];
    if (invisantRole) g_InvisibleUpgradePoints[client] = points;
    else g_VisibleUpgradePoints[client] = points;
    return points != previous;
}

int GetUpgradeStageRequiredLevel(int stage, bool ultimate = false)
{
    if (stage < 1 || stage > MAX_UPGRADE_STAGE) return MAX_PLAYER_LEVEL + 1;
    char name[64];
    FormatEx(name, sizeof(name), "sf_%s_stage%d_level", ultimate ? "ultimate" : "normal", stage);
    return FindConVar(name).IntValue;
}

void CloseUpgradeMenu(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    g_UpgradeMenuToken[client]++;
    g_UpgradeMenuQueued[client] = false;
    if (g_UpgradeMenuOpen[client] && IsClientInGame(client))
    {
        g_UpgradeMenuOpen[client] = false;
        CancelClientMenu(client, true);
    }
    else
    {
        g_UpgradeMenuOpen[client] = false;
    }
}

void QueueUpgradeMenu(int client, bool invisibleRole, float delay, bool allowEmpty = false)
{
    if (!IsHumanClient(client) || !g_XpLoaded[client]
        || g_UpgradeMenuQueued[client] || g_UpgradeMenuOpen[client])
    {
        return;
    }

    int points = invisibleRole ? g_InvisibleUpgradePoints[client] : g_VisibleUpgradePoints[client];
    if (!allowEmpty && points <= 0)
    {
        return;
    }

    DataPack pack;
    CreateDataTimer(delay, Timer_ShowUpgradeMenu, pack, TIMER_FLAG_NO_MAPCHANGE);
    pack.WriteCell(GetClientSerial(client));
    pack.WriteCell(invisibleRole);
    g_UpgradeMenuToken[client]++;
    pack.WriteCell(g_UpgradeMenuToken[client]);
    pack.WriteCell(allowEmpty);
    g_UpgradeMenuQueued[client] = true;
}

public Action Timer_ShowUpgradeMenu(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientFromSerial(pack.ReadCell());
    bool invisibleRole = pack.ReadCell() != 0;
    int token = pack.ReadCell();
    bool allowEmpty = pack.ReadCell() != 0;
    if (!IsHumanClient(client) || token != g_UpgradeMenuToken[client])
    {
        return Plugin_Stop;
    }

    g_UpgradeMenuQueued[client] = false;
    ShowUpgradeMenu(client, invisibleRole, allowEmpty);
    return Plugin_Stop;
}

void ShowUpgradeMenu(int client, bool invisibleRole, bool allowEmpty)
{
    if (!IsModActive() || !IsHumanClient(client) || !g_XpLoaded[client]) return;
    if (GetClientTeam(client) != (invisibleRole ? GetInvisantTeam() : GetVisibleTeam())) return;
    int points = invisibleRole ? g_InvisibleUpgradePoints[client] : g_VisibleUpgradePoints[client];
    if (!allowEmpty && points <= 0) return;

    Menu menu = new Menu(MenuHandler_Upgrade, MENU_ACTIONS_DEFAULT | MenuAction_Display);
    menu.OptionFlags |= MENUFLAG_NO_SOUND;
    menu.Pagination = MENU_NO_PAGINATION;
    menu.SetTitle("%s Upgrades\nPoints: %d", invisibleRole ? "Invisant" : "Armitive", points);

    int level = GetXpLevel(invisibleRole ? g_InvisibleXp[client] : g_VisibleXp[client]);
    int spent;
    for (int index = 0; index < UPGRADES_PER_ROLE; index++)
    {
        UpgradeSlot slot = UPGRADE_ORDER[invisibleRole ? 0 : 1][index];
        int stage = g_UpgradeStage[client][slot];
        spent += stage;
        bool ultimate = slot == UpgradeSlot_Surge || slot == UpgradeSlot_Ward;
        int required = GetUpgradeStageRequiredLevel(stage + 1, ultimate);
        char label[192], details[96];
        if (ultimate && stage == 0 && level < required)
            FormatEx(details, sizeof(details), "unlocks level %d", required);
        else
            FormatUpgradeDetails(slot, stage, details, sizeof(details));

        // Padding follows the stock proportional Verdana menu font.
        switch (slot)
        {
            case UpgradeSlot_Lightweight: FormatEx(label, sizeof(label), "Lightweight [%d/5]       (%s)", stage, details);
            case UpgradeSlot_Momentum: FormatEx(label, sizeof(label), "Momentum [%d/5]         (%s)", stage, details);
            case UpgradeSlot_Resilience: FormatEx(label, sizeof(label), "Resilience [%d/5]          (%s)", stage, details);
            case UpgradeSlot_Reforging: FormatEx(label, sizeof(label), "Reforging [%d/5]           (%s)", stage, details);
            case UpgradeSlot_Vampirism: FormatEx(label, sizeof(label), "Vampirism [%d/5]         (%s)", stage, details);
            case UpgradeSlot_Bloodlust: FormatEx(label, sizeof(label), "Bloodlust [%d/5]            (%s)", stage, details);
            case UpgradeSlot_Mobility: FormatEx(label, sizeof(label), "Mobility [%d/5]              (%s)", stage, details);
            case UpgradeSlot_Surge: FormatEx(label, sizeof(label), "Ultimate: Surge [%d/5] (%s)", stage, details);
            case UpgradeSlot_Fortitude: FormatEx(label, sizeof(label), "Fortitude [%d/5]            (%s)", stage, details);
            case UpgradeSlot_Recovery: FormatEx(label, sizeof(label), "Recovery [%d/5]            (%s)", stage, details);
            case UpgradeSlot_Overload: FormatEx(label, sizeof(label), "Overload [%d/5]            (%s)", stage, details);
            case UpgradeSlot_Stockpile: FormatEx(label, sizeof(label), "Stockpile [%d/5]            (%s)", stage, details);
            case UpgradeSlot_Barrage: FormatEx(label, sizeof(label), "Barrage [%d/5]              (%s)", stage, details);
            case UpgradeSlot_Control: FormatEx(label, sizeof(label), "Control [%d/5]               (%s)", stage, details);
            case UpgradeSlot_Dexterity: FormatEx(label, sizeof(label), "Dexterity [%d/5]            (%s)", stage, details);
            case UpgradeSlot_Ward: FormatEx(label, sizeof(label), "Ultimate: Ward [%d/5]  (%s)", stage, details);
        }
        menu.AddItem(UPGRADE_KEYS[slot], label,
            points > 0 && stage < MAX_UPGRADE_STAGE && level >= required ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }
    menu.AddItem(invisibleRole ? "reset_invisant" : "reset_armitive", "Reset points", spent > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.ExitButton = true;
    if (menu.Display(client, MENU_TIME_FOREVER)) g_UpgradeMenuOpen[client] = true;
    else delete menu;
}

public int MenuHandler_Upgrade(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_End)
    {
        delete menu;
        return 0;
    }
    if (action == MenuAction_Display) PlayMenuSound(param1);
    if (action == MenuAction_Cancel)
    {
        if (param2 == MenuCancel_Exit) PlayMenuSound(param1, "buttons/button19.wav");
        if (param1 >= 1 && param1 <= MaxClients)
        {
            g_UpgradeMenuOpen[param1] = false;
        }
        return 0;
    }
    if (action != MenuAction_Select || !IsHumanClient(param1) || !g_XpLoaded[param1])
    {
        return 0;
    }

    char info[32];
    menu.GetItem(param2, info, sizeof(info));
    g_UpgradeMenuOpen[param1] = false;
    PlayMenuSound(param1, "buttons/button3.wav");
    ApplyUpgradeChoice(param1, info);
    return 0;
}

int ApplyUpgradeChoice(int client, const char[] info)
{
    if (!IsModActive() || !IsActiveHuman(client) || !g_XpLoaded[client]) return 0;
    CloseUpgradeMenu(client);
    bool lightweight = StrEqual(info, "lightweight");
    bool momentum = StrEqual(info, "momentum");
    bool resilience = StrEqual(info, "resilience");
    bool vampirism = StrEqual(info, "vampirism");
    bool reforging = StrEqual(info, "reforging");
    bool bloodlust = StrEqual(info, "bloodlust");
    bool mobility = StrEqual(info, "mobility");
    bool surge = StrEqual(info, "surge");
    bool fortitude = StrEqual(info, "fortitude");
    bool overload = StrEqual(info, "overload");
    bool stockpile = StrEqual(info, "stockpile");
    bool barrage = StrEqual(info, "barrage");
    bool recovery = StrEqual(info, "recovery");
    bool dexterity = StrEqual(info, "dexterity");
    bool control = StrEqual(info, "control");
    bool ward = StrEqual(info, "ward");
    bool resetInvisant = StrEqual(info, "reset_invisant");
    bool resetArmitive = StrEqual(info, "reset_armitive");
    bool invisibleRole = lightweight || momentum || resilience || vampirism || reforging || bloodlust || mobility || surge || resetInvisant;
    if (!IsModActive())
    {
        return 0;
    }

    if (GetClientTeam(client) != (invisibleRole ? GetInvisantTeam() : GetVisibleTeam())) return 0;
    bool applyUpgradeChanges = CanApplyUpgradeChangesImmediately();
    char timingSuffix[48];
    FormatEx(
        timingSuffix,
        sizeof(timingSuffix),
        applyUpgradeChanges ? " \x01as %s" : " \x07D6B86Anext round\x01 as %s",
        invisibleRole ? "\x077FA7FFInvisant" : "\x07E07A6AArmitive"
    );
    bool applyingSelectedRole = applyUpgradeChanges
        && IsPlayerAlive(client)
        && GetClientTeam(client) == (invisibleRole ? GetInvisantTeam() : GetVisibleTeam());

    int points = invisibleRole ? g_InvisibleUpgradePoints[client] : g_VisibleUpgradePoints[client];
    if (resetInvisant || resetArmitive)
    {
        int resetStages = invisibleRole
            ? g_UpgradeStage[client][UpgradeSlot_Lightweight] + g_UpgradeStage[client][UpgradeSlot_Momentum] + g_UpgradeStage[client][UpgradeSlot_Resilience] + g_UpgradeStage[client][UpgradeSlot_Vampirism] + g_UpgradeStage[client][UpgradeSlot_Reforging] + g_UpgradeStage[client][UpgradeSlot_Bloodlust] + g_UpgradeStage[client][UpgradeSlot_Mobility] + g_UpgradeStage[client][UpgradeSlot_Surge]
            : g_UpgradeStage[client][UpgradeSlot_Fortitude] + g_UpgradeStage[client][UpgradeSlot_Overload] + g_UpgradeStage[client][UpgradeSlot_Stockpile] + g_UpgradeStage[client][UpgradeSlot_Barrage] + g_UpgradeStage[client][UpgradeSlot_Recovery] + g_UpgradeStage[client][UpgradeSlot_Dexterity] + g_UpgradeStage[client][UpgradeSlot_Control] + g_UpgradeStage[client][UpgradeSlot_Ward];
        if (resetStages <= 0)
        {
            QueueUpgradeMenu(client, invisibleRole, 0.1);
            return 0;
        }

        int healthBeforeReset = IsPlayerAlive(client) ? GetClientHealth(client) : 0;
        int armorBeforeReset = -1;
        float shieldAvailableBeforeReset = g_ArmitiveWardAvailableAt[client];
        if (invisibleRole
            && applyingSelectedRole
            && HasEntProp(client, Prop_Send, "m_ArmorValue"))
        {
            armorBeforeReset = GetEntProp(client, Prop_Send, "m_ArmorValue");
        }
        if (applyingSelectedRole)
        {
            ClearPlayerUpgradeEffects(client);
            if (!invisibleRole)
            {
                g_ArmitiveWardAvailableAt[client] = shieldAvailableBeforeReset;
            }
        }
        points = ClampUpgradePoints(points + resetStages, 0);
        if (invisibleRole)
        {
            g_UpgradeStage[client][UpgradeSlot_Lightweight] = 0;
            g_UpgradeStage[client][UpgradeSlot_Momentum] = 0;
            g_UpgradeStage[client][UpgradeSlot_Resilience] = 0;
            g_UpgradeStage[client][UpgradeSlot_Vampirism] = 0;
            g_UpgradeStage[client][UpgradeSlot_Reforging] = 0;
            g_UpgradeStage[client][UpgradeSlot_Bloodlust] = 0;
            g_UpgradeStage[client][UpgradeSlot_Mobility] = 0;
            g_UpgradeStage[client][UpgradeSlot_Surge] = 0;
            g_InvisibleUpgradePoints[client] = points;
            if (applyingSelectedRole)
            {
                if (armorBeforeReset >= 0 && HasEntProp(client, Prop_Send, "m_ArmorValue"))
                {
                    if (armorBeforeReset > INVISANT_BASE_ARMOR)
                    {
                        armorBeforeReset = INVISANT_BASE_ARMOR;
                    }
                    SetEntProp(client, Prop_Send, "m_ArmorValue", armorBeforeReset);
                }
                if (HasEntProp(client, Prop_Send, "m_bHasHelmet"))
                {
                    SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
                }
                g_ResilienceApplied[client] = true;
            }
        }
        else
        {
            g_UpgradeStage[client][UpgradeSlot_Fortitude] = 0;
            g_UpgradeStage[client][UpgradeSlot_Overload] = 0;
            g_UpgradeStage[client][UpgradeSlot_Stockpile] = 0;
            g_UpgradeStage[client][UpgradeSlot_Barrage] = 0;
            g_UpgradeStage[client][UpgradeSlot_Recovery] = 0;
            g_UpgradeStage[client][UpgradeSlot_Dexterity] = 0;
            g_UpgradeStage[client][UpgradeSlot_Control] = 0;
            g_UpgradeStage[client][UpgradeSlot_Ward] = 0;
            g_VisibleUpgradePoints[client] = points;
        }
        if (applyUpgradeChanges)
        {
            SyncAppliedUpgradeStages(client, invisibleRole);
            if (applyingSelectedRole)
            {
                ApplyResetUpgrades(client, invisibleRole);
                if (!invisibleRole && healthBeforeReset > 0)
                    SetEntityHealth(client, healthBeforeReset > g_CvarArmitiveBaseHealth.IntValue ? g_CvarArmitiveBaseHealth.IntValue : healthBeforeReset);
            }
        }

        SavePlayerXp(client);
        UpdateClientXpHud(client);
        PrintToChat(
            client,
            "%s \x01Reset \x0793C47D%d %s\x01 point%s (\x0793C47D%d\x01 available)",
            CHAT_PREFIX,
            resetStages,
            invisibleRole ? "\x077FA7FFInvisant" : "\x07E07A6AArmitive",
            resetStages == 1 ? "" : "s",
            points
        );
        QueueUpgradeMenu(client, invisibleRole, 0.2);
        return 0;
    }

    int stage;
    UpgradeSlot upgradeSlot;
    if (lightweight)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Lightweight];
        upgradeSlot = UpgradeSlot_Lightweight;
    }
    else if (momentum)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Momentum];
        upgradeSlot = UpgradeSlot_Momentum;
    }
    else if (resilience)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Resilience];
        upgradeSlot = UpgradeSlot_Resilience;
    }
    else if (vampirism)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Vampirism];
        upgradeSlot = UpgradeSlot_Vampirism;
    }
    else if (reforging)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Reforging];
        upgradeSlot = UpgradeSlot_Reforging;
    }
    else if (bloodlust)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Bloodlust];
        upgradeSlot = UpgradeSlot_Bloodlust;
    }
    else if (mobility)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Mobility];
        upgradeSlot = UpgradeSlot_Mobility;
    }
    else if (surge)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Surge];
        upgradeSlot = UpgradeSlot_Surge;
    }
    else if (fortitude)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Fortitude];
        upgradeSlot = UpgradeSlot_Fortitude;
    }
    else if (overload)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Overload];
        upgradeSlot = UpgradeSlot_Overload;
    }
    else if (stockpile)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Stockpile];
        upgradeSlot = UpgradeSlot_Stockpile;
    }
    else if (barrage)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Barrage];
        upgradeSlot = UpgradeSlot_Barrage;
    }
    else if (recovery)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Recovery];
        upgradeSlot = UpgradeSlot_Recovery;
    }
    else if (dexterity)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Dexterity];
        upgradeSlot = UpgradeSlot_Dexterity;
    }
    else if (control)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Control];
        upgradeSlot = UpgradeSlot_Control;
    }
    else if (ward)
    {
        stage = g_UpgradeStage[client][UpgradeSlot_Ward];
        upgradeSlot = UpgradeSlot_Ward;
    }
    else
    {
        return 0;
    }
    int roleLevel = GetXpLevel(invisibleRole ? g_InvisibleXp[client] : g_VisibleXp[client]);
    if (stage >= MAX_UPGRADE_STAGE || points <= 0
        || roleLevel < GetUpgradeStageRequiredLevel(
            stage + 1,
            upgradeSlot == UpgradeSlot_Surge || upgradeSlot == UpgradeSlot_Ward
        ))
    {
        QueueUpgradeMenu(client, invisibleRole, 0.1);
        return 0;
    }

    stage++;
    points--;
    g_UpgradeStage[client][upgradeSlot] = stage;
    if (invisibleRole) g_InvisibleUpgradePoints[client] = points;
    else g_VisibleUpgradePoints[client] = points;
    if (applyUpgradeChanges)
    {
        g_AppliedUpgradeStage[client][upgradeSlot] = stage;
        if (applyingSelectedRole) ApplyPurchasedUpgrade(client, upgradeSlot, stage);
    }
    switch (upgradeSlot)
    {
        case UpgradeSlot_Lightweight:
            PrintToChat(client, "%s \x077FA7FFLightweight [%d/5]\x01 You have \x0793C47D%d%%\x01 less gravity%s",
                CHAT_PREFIX, stage, stage * g_CvarLightweightGravityPercent.IntValue, timingSuffix);
        case UpgradeSlot_Momentum:
            PrintToChat(client, "%s \x077FA7FFMomentum [%d/5]\x01 You run \x0793C47D%d%%\x01 faster%s",
                CHAT_PREFIX, stage, stage * g_CvarMomentumRunPercent.IntValue, timingSuffix);
        case UpgradeSlot_Resilience:
            PrintToChat(client,
                stage >= g_CvarResilienceHelmetStage.IntValue
                    ? "%s \x077FA7FFResilience [%d/5]\x01 You have \x0793C47D%d\x01 max armor and helmet%s"
                    : "%s \x077FA7FFResilience [%d/5]\x01 You have \x0793C47D%d\x01 max armor%s",
                CHAT_PREFIX, stage, INVISANT_BASE_ARMOR + stage * RESILIENCE_ARMOR_PER_STAGE, timingSuffix);
        case UpgradeSlot_Reforging:
            PrintToChat(client, "%s \x077FA7FFReforging [%d/5]\x01 You gain \x0793C47D%d\x01 armor every \x0793C47D%ds\x01 while not taking damage%s",
                CHAT_PREFIX, stage, stage * g_CvarReforgingArmorPerStage.IntValue, g_CvarReforgingInterval.IntValue, timingSuffix);
        case UpgradeSlot_Vampirism:
            PrintToChat(client, "%s \x077FA7FFVampirism [%d/5]\x01 You heal \x0793C47D%d\x01 health per hit%s", CHAT_PREFIX, stage, stage * VAMPIRISM_HEALTH_PER_STAGE, timingSuffix);
        case UpgradeSlot_Bloodlust:
            PrintToChat(client, "%s \x077FA7FFBloodlust [%d/5]\x01 You heal \x0793C47D%d\x01 health per kill%s", CHAT_PREFIX, stage, stage * BLOODLUST_HEALTH_PER_STAGE, timingSuffix);
        case UpgradeSlot_Mobility:
            PrintToChat(client, "%s \x077FA7FFMobility [%d/5]\x01 You crouch \x0793C47D%d%%\x01 faster%s",
                CHAT_PREFIX, stage, stage * g_CvarMobilityCrouchPercent.IntValue, timingSuffix);
        case UpgradeSlot_Surge:
            PrintToChat(client, "%s \x077FA7FFUltimate: Surge [%d/5]\x01 Press \x0793C47DE\x01 for a \x0793C47D%d units/s\x01 impulse%s",
                CHAT_PREFIX, stage, g_CvarSurgeBaseSpeed.IntValue + (stage - 1) * g_CvarSurgeSpeedPerStage.IntValue,
                timingSuffix);
        case UpgradeSlot_Fortitude:
            PrintToChat(client, "%s \x07E07A6AFortitude [%d/5]\x01 You have \x0793C47D%d\x01 max health%s",
                CHAT_PREFIX, stage, g_CvarArmitiveBaseHealth.IntValue + stage * FORTITUDE_HEALTH_PER_STAGE, timingSuffix);
        case UpgradeSlot_Recovery:
            PrintToChat(client, "%s \x07E07A6ARecovery [%d/5]\x01 You heal \x0793C47D%d\x01 health every \x0793C47D%ds\x01 while not taking damage%s",
                CHAT_PREFIX, stage, stage * g_CvarRecoveryHealthPerStage.IntValue, g_CvarRecoveryInterval.IntValue, timingSuffix);
        case UpgradeSlot_Overload:
            PrintToChat(client, "%s \x07E07A6AOverload [%d/5]\x01 You have \x0793C47D%d%%\x01 larger ammo capacity%s",
                CHAT_PREFIX, stage, stage * g_CvarOverloadMagazinePercent.IntValue, timingSuffix);
        case UpgradeSlot_Stockpile:
        {
            int clips = stage * g_CvarStockpileClipsPerStage.IntValue;
            PrintToChat(client, "%s \x07E07A6AStockpile [%d/5]\x01 You carry \x0793C47D%d\x01 extra reserve clip%s%s",
                CHAT_PREFIX, stage, clips, clips == 1 ? "" : "s", timingSuffix);
        }
        case UpgradeSlot_Barrage:
            PrintToChat(client, "%s \x07E07A6ABarrage [%d/5]\x01 You fire weapons \x0793C47D%d%%\x01 faster%s",
                CHAT_PREFIX, stage, stage * g_CvarBarrageFireRatePercent.IntValue, timingSuffix);
        case UpgradeSlot_Control:
            PrintToChat(client, "%s \x07E07A6AControl [%d/5]\x01 You have \x0793C47D%d%%\x01 less weapon recoil and spread%s",
                CHAT_PREFIX, stage, stage * g_CvarControlReductionPercent.IntValue, timingSuffix);
        case UpgradeSlot_Dexterity:
            PrintToChat(client, "%s \x07E07A6ADexterity [%d/5]\x01 Your reload and weapon switch times are \x0793C47D%d%%\x01 shorter%s",
                CHAT_PREFIX, stage, stage * g_CvarDexteritySpeedPercent.IntValue, timingSuffix);
        case UpgradeSlot_Ward:
            PrintToChat(client, "%s \x07E07A6AUltimate: Ward [%d/5]\x01 Press \x0793C47DE\x01 for \x0793C47D%.1f seconds\x01 of immunity%s",
                CHAT_PREFIX, stage, g_CvarWardBaseSeconds.FloatValue + float(stage - 1) * g_CvarWardSecondsPerStage.FloatValue,
                timingSuffix);
    }

    SavePlayerXp(client);
    QueueUpgradeMenu(client, invisibleRole, 0.2);
    return 0;
}

int AddXpWithoutOverflow(int current, int amount)
{
    int maximumXp = GetMaximumPlayerXp();
    if (current < 0)
    {
        current = 0;
    }
    if (current >= maximumXp)
    {
        return maximumXp;
    }
    if (amount <= 0)
    {
        return current;
    }
    if (amount >= maximumXp - current)
    {
        return maximumXp;
    }
    return current + amount;
}

int GetXpLevel(int xp)
{
    if (xp <= 0)
    {
        return 0;
    }

    int low = 0;
    int high = MAX_PLAYER_LEVEL;
    while (low < high)
    {
        int middle = (low + high + 1) / 2;
        if (xp >= GetXpRequiredForLevel(middle))
        {
            low = middle;
        }
        else
        {
            high = middle - 1;
        }
    }
    return low;
}

int GetXpRequiredForLevel(int level)
{
    if (level <= 0)
    {
        return 0;
    }

    if (level > MAX_PLAYER_LEVEL)
    {
        level = MAX_PLAYER_LEVEL;
    }

    return g_CvarXpLevelBase.IntValue * level * (level + 1) / 2;
}

int GetMaximumPlayerXp()
{
    return GetXpRequiredForLevel(MAX_PLAYER_LEVEL);
}

void ShowRoleXp(int client, bool invisibleRole)
{
    int xp = invisibleRole ? g_InvisibleXp[client] : g_VisibleXp[client];
    int level = GetXpLevel(xp);
    if (level >= MAX_PLAYER_LEVEL)
    {
        ReplyToCommand(
            client,
            "[Shroudfire] %s: level %d (MAX)",
            invisibleRole ? "Invisant" : "Armitive",
            level
        );
        return;
    }

    int levelStart = GetXpRequiredForLevel(level);
    int nextLevel = GetXpRequiredForLevel(level + 1);
    ReplyToCommand(
        client,
        "[Shroudfire] %s: level %d | %d/%d XP to level %d",
        invisibleRole ? "Invisant" : "Armitive",
        level,
        xp - levelStart,
        nextLevel - levelStart,
        level + 1
    );
}

void GetRoleTeamNames(char[] invisantName, int invisantLength, char[] visibleName, int visibleLength)
{
    if (GetInvisantTeam() == CS_TEAM_T)
    {
        strcopy(invisantName, invisantLength, "Terrorists");
        strcopy(visibleName, visibleLength, "Counter-Terrorists");
    }
    else
    {
        strcopy(invisantName, invisantLength, "Counter-Terrorists");
        strcopy(visibleName, visibleLength, "Terrorists");
    }
}
