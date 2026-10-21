// Gameplay shared with Shroudfire CS2, adapted to SourceMod's menus and engine.
enum AudioCategory { Audio_RoundStart, Audio_RoundEnd, Audio_KillStreak, Audio_Starvation, Audio_Afk, Audio_Timeout, Audio_Camping, Audio_Menu };
enum VoiceGroup { Voice_InvisantStart, Voice_ArmitiveStart, Voice_InvisantWin, Voice_ArmitiveWin, Voice_Draw, Voice_Starvation, Voice_Afk, Voice_Camping, Voice_Timeout };
char AUDIO_NAMES[][] = { "Round Start", "Round End", "Kill Streak", "Starvation", "AFK", "Timeout", "Camping", "Menu" };
UpgradeSlot UPGRADE_ORDER[2][8] = {
    { UpgradeSlot_Lightweight, UpgradeSlot_Momentum, UpgradeSlot_Resilience, UpgradeSlot_Reforging, UpgradeSlot_Vampirism, UpgradeSlot_Bloodlust, UpgradeSlot_Mobility, UpgradeSlot_Surge },
    { UpgradeSlot_Fortitude, UpgradeSlot_Recovery, UpgradeSlot_Overload, UpgradeSlot_Stockpile, UpgradeSlot_Barrage, UpgradeSlot_Control, UpgradeSlot_Dexterity, UpgradeSlot_Ward }
};
char UPGRADE_KEYS[][] = {
    "lightweight", "momentum", "resilience", "vampirism", "reforging", "bloodlust", "mobility", "surge",
    "fortitude", "overload", "stockpile", "barrage", "recovery", "dexterity", "control", "ward"
};
#include <shroudfire/voices>

Cookie g_AudioCookie;
int g_MutedAudio[MAXPLAYERS + 1];
int g_LastVoice[MAXPLAYERS + 1][9];
bool g_MovedThisRound[MAXPLAYERS + 1];
bool g_CampingAnchorReady[MAXPLAYERS + 1];
bool g_CampingWarned[MAXPLAYERS + 1];
bool g_CampingActive[MAXPLAYERS + 1];
bool g_CampingForcedDeath[MAXPLAYERS + 1];
bool g_TimeoutForcedDeath[MAXPLAYERS + 1];
bool g_IneligibleRoundDeath[MAXPLAYERS + 1];
float g_CampingAnchor[MAXPLAYERS + 1][3];
float g_CampingAnchorAt[MAXPLAYERS + 1];
bool g_StarvationActive[MAXPLAYERS + 1];
float g_StarvationStartedAt[MAXPLAYERS + 1];
float g_NextStarvationTickAt[MAXPLAYERS + 1];
float g_StarvationHudRefreshAt[MAXPLAYERS + 1];
ArrayList g_BlockedWeaponIds;
float g_LastRecoveryAt[MAXPLAYERS + 1];
float g_LastReforgeAt[MAXPLAYERS + 1];
float g_HintAvailableAt[7];
float g_NextDiscordAt;
bool g_TimeoutReveal;
bool g_TimeoutVoicePlayed;
float g_TimeoutRevealAt;
float g_MapPlayedSeconds;
float g_MapLastSample;
float g_MapChangeAt;
float g_MapRetryAt;
int g_MapCompletedRounds;
char g_NextMapOverride[PLATFORM_MAX_PATH];
Handle g_NoticeHud;
char g_NoticeText[MAXPLAYERS + 1][6][192];
float g_NoticeUntil[MAXPLAYERS + 1][6];
ConVar g_MapEngineLimits[3];
float g_OriginalMapEngineLimits[3];
bool g_MapLimitsSaved;

void InitializeParity()
{
    g_AudioCookie = new Cookie("shroudfire_muted_audio", "Shroudfire muted voice and menu categories.", CookieAccess_Private);
    g_NoticeHud = CreateHudSynchronizer();
    RegAdminCmd("sf_cvar", Command_ShroudfireCvar, ADMFLAG_GENERIC, "Reads or sets a server cvar from the console. Requires the generic admin flag.");
    RegAdminCmd("sf_nextmap", Command_ShroudfireNextMap, ADMFLAG_GENERIC, "Displays or sets the next map; use reset to follow the configured rotation.");
    RegAdminCmd("sf_armitive", Command_ShroudfireArmitive, ADMFLAG_ROOT, "Moves you to the Armitive team and respawns you at its spawn.");
    RegConsoleCmd("sf_update_notice", Command_ShroudfireUpdateNotice, "Announces an upcoming CS:S update restart in chat. Server console only.");
    g_MapEngineLimits[0] = FindConVar("mp_maxrounds");
    g_MapEngineLimits[1] = FindConVar("mp_timelimit");
    g_MapEngineLimits[2] = FindConVar("mp_winlimit");
    ResetMapRotation();
    CreateTimer(1.0, Timer_Parity, _, TIMER_REPEAT);
    for (int client = 1; client <= MaxClients; client++)
        if (IsHumanClient(client) && AreClientCookiesCached(client)) LoadAudioPreferences(client);
}

void ResetClientParity(int client)
{
    g_MutedAudio[client] = 0;
    g_StarvationActive[client] = false;
    g_StarvationStartedAt[client] = 0.0;
    g_NextStarvationTickAt[client] = 0.0;
    g_MovedThisRound[client] = false;
    g_CampingAnchorReady[client] = false;
    g_CampingWarned[client] = false;
    g_CampingActive[client] = false;
    g_CampingForcedDeath[client] = false;
    g_TimeoutForcedDeath[client] = false;
    g_IneligibleRoundDeath[client] = false;
    g_LastRecoveryAt[client] = GetEngineTime();
    g_LastReforgeAt[client] = GetEngineTime();
    for (int i = 0; i < 9; i++) g_LastVoice[client][i] = -1;
    for (int i = 0; i < 6; i++) g_NoticeUntil[client][i] = 0.0;
}

void ResetRoundParity()
{
    g_TimeoutReveal = false;
    g_TimeoutVoicePlayed = false;
    for (int client = 1; client <= MaxClients; client++)
    {
        g_MovedThisRound[client] = false;
        g_CampingAnchorReady[client] = false;
        g_CampingWarned[client] = false;
        g_CampingActive[client] = false;
        g_CampingForcedDeath[client] = false;
        g_TimeoutForcedDeath[client] = false;
        g_IneligibleRoundDeath[client] = false;
        for (int i = 0; i < 6; i++) g_NoticeUntil[client][i] = 0.0;
        if (IsHumanClient(client))
        {
            SetEntityRenderMode(client, RENDER_NORMAL);
            SetEntityRenderColor(client, 255, 255, 255, 255);
        }
    }
}

void LoadAudioPreferences(int client)
{
    if (g_AudioCookie == null || !IsHumanClient(client) || !AreClientCookiesCached(client)) return;
    char value[16];
    g_AudioCookie.Get(client, value, sizeof(value));
    g_MutedAudio[client] = StringToInt(value) & 255;
}

bool AudioEnabled(int client, AudioCategory category)
{
    return (category == Audio_Menu || g_CvarCustomSounds.BoolValue)
        && (g_MutedAudio[client] & (1 << view_as<int>(category))) == 0;
}

void PlayVoice(int client, const char[] sample, AudioCategory category)
{
    if (IsHumanClient(client) && AudioEnabled(client, category))
        EmitSoundToClient(client, sample, client, SNDCHAN_STATIC, SNDLEVEL_NORMAL);
}

void PlayRandomVoice(int client, AudioCategory category, VoiceGroup group)
{
    if (!IsHumanClient(client) || !AudioEnabled(client, category)) return;
    int start = VOICE_START[group], count = VOICE_COUNT[group];
    int choice = GetRandomInt(0, count - 1);
    if (count > 1 && choice == g_LastVoice[client][group]) choice = (choice + GetRandomInt(1, count - 1)) % count;
    g_LastVoice[client][group] = choice;
    PlayVoice(client, VOICE_FILES[start + choice], category);
}

void PrecacheShroudfireVoices()
{
    for (int i = 0; i < sizeof(VOICE_FILES); i++)
    {
        char path[PLATFORM_MAX_PATH];
        FormatEx(path, sizeof(path), "sound/%s", VOICE_FILES[i]);
        if (FileExists(path, true))
        {
            AddFileToDownloadsTable(path);
            PrecacheSound(VOICE_FILES[i], true);
        }
    }
}

CSWeaponID PurchaseWeaponId(const char[] input)
{
    char name[64], translated[64];
    strcopy(name, sizeof(name), input);
    TrimString(name);
    for (int i = 0; name[i] != '\0'; i++) name[i] = CharToLower(name[i]);
    if (StrContains(name, "weapon_") == 0) strcopy(name, sizeof(name), name[7]);
    CS_GetTranslatedWeaponAlias(name, translated, sizeof(translated));
    CSWeaponID id = CS_AliasToWeaponID(translated);
    // CS:S has no CS2 loadout variants, Zeus, or incendiary grenades.
    return id > CSWeapon_NONE && id <= CSWeapon_NIGHTVISION ? id : CSWeapon_NONE;
}

void ConfigureBlockedWeapons()
{
    if (g_BlockedWeaponIds == null) g_BlockedWeaponIds = new ArrayList();
    g_BlockedWeaponIds.Clear();
    char list[2048];
    g_CvarArmitiveBlockedWeapons.GetString(list, sizeof(list));
    ReplaceString(list, sizeof(list), ",", " ");
    ReplaceString(list, sizeof(list), "\t", " ");
    ReplaceString(list, sizeof(list), "\n", " ");
    ReplaceString(list, sizeof(list), "\r", " ");
    int position;
    while (list[position] != '\0')
    {
        char token[64];
        int consumed = BreakString(list[position], token, sizeof(token));
        if (token[0] != '\0')
        {
            CSWeaponID id = PurchaseWeaponId(token);
            if (id == CSWeapon_NONE)
                PrintToServer("[Shroudfire] Unknown CS:S weapon in sf_armitive_blocked_weapons: %s", token);
            else if (g_BlockedWeaponIds.FindValue(id) == -1) g_BlockedWeaponIds.Push(id);
        }
        if (consumed == -1) break;
        position += consumed;
    }
}

void PlayMenuSound(int client, const char[] sample = "buttons/button14.wav")
{
    if (IsHumanClient(client) && AudioEnabled(client, Audio_Menu)) EmitSoundToClient(client, sample);
}

void ShowAudioMenu(int client)
{
    if (!IsHumanClient(client)) return;
    CloseUpgradeMenu(client);
    Menu menu = new Menu(MenuHandler_Audio);
    menu.OptionFlags |= MENUFLAG_NO_SOUND;
    menu.Pagination = MENU_NO_PAGINATION;
    menu.SetTitle("Shroudfire audio\nSettings persist between sessions");
    // Keep category bits stable; the displayed order is independent.
    static const AudioCategory order[] = { Audio_RoundStart, Audio_RoundEnd, Audio_KillStreak,
        Audio_Starvation, Audio_Timeout, Audio_Camping, Audio_Afk, Audio_Menu };
    for (int row = 0; row < sizeof(order); row++)
    {
        int category = view_as<int>(order[row]);
        char key[16], label[80];
        IntToString(category, key, sizeof(key));
        FormatEx(label, sizeof(label), "%s: %s", AUDIO_NAMES[category], (g_MutedAudio[client] & (1 << category)) ? "OFF" : "ON");
        menu.AddItem(key, label, AreClientCookiesCached(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Audio(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) delete menu;
    else if (action == MenuAction_Cancel && item == MenuCancel_Exit) PlayMenuSound(client, "buttons/button19.wav");
    else if (action == MenuAction_Select && IsHumanClient(client))
    {
        if (!AreClientCookiesCached(client))
        {
            PrintToChat(client, "%s Audio preferences are still loading.", CHAT_PREFIX);
            return 0;
        }
        char key[16];
        menu.GetItem(item, key, sizeof(key));
        int category = StringToInt(key);
        if (category < 0 || category >= sizeof(AUDIO_NAMES)) return 0;
        g_MutedAudio[client] ^= 1 << category;
        IntToString(g_MutedAudio[client], key, sizeof(key));
        g_AudioCookie.Set(client, key);
        PlayMenuSound(client, (g_MutedAudio[client] & (1 << category)) ? "buttons/blip2.wav" : "buttons/blip1.wav");
        ShowAudioMenu(client);
    }
    return 0;
}

void FormatUpgradeDetails(UpgradeSlot slot, int stage, char[] text, int length)
{
    switch (slot)
    {
        case UpgradeSlot_Lightweight:
            FormatEx(text, length, "%d%% gravity", 100 - stage * g_CvarLightweightGravityPercent.IntValue);
        case UpgradeSlot_Momentum:
            FormatEx(text, length, "%d%% run speed", 100 + stage * g_CvarMomentumRunPercent.IntValue);
        case UpgradeSlot_Resilience:
            FormatEx(text, length, "%d max armor%s", INVISANT_BASE_ARMOR + stage * RESILIENCE_ARMOR_PER_STAGE,
                stage >= g_CvarResilienceHelmetStage.IntValue ? " + helmet" : "");
        case UpgradeSlot_Reforging:
            FormatEx(text, length, "%d armor regen/%ds", stage * g_CvarReforgingArmorPerStage.IntValue, g_CvarReforgingInterval.IntValue);
        case UpgradeSlot_Vampirism:
            FormatEx(text, length, "%d damage heal", stage * VAMPIRISM_HEALTH_PER_STAGE);
        case UpgradeSlot_Bloodlust:
            FormatEx(text, length, "%d kill heal", stage * BLOODLUST_HEALTH_PER_STAGE);
        case UpgradeSlot_Mobility:
            FormatEx(text, length, "%d%% crouch speed", 100 + stage * g_CvarMobilityCrouchPercent.IntValue);
        case UpgradeSlot_Surge:
            FormatEx(text, length, "%d units/s",
                g_CvarSurgeBaseSpeed.IntValue + (stage > 0 ? stage - 1 : 0) * g_CvarSurgeSpeedPerStage.IntValue);
        case UpgradeSlot_Fortitude:
            FormatEx(text, length, "%d max health", g_CvarArmitiveBaseHealth.IntValue + stage * FORTITUDE_HEALTH_PER_STAGE);
        case UpgradeSlot_Recovery:
            FormatEx(text, length, "%d health regen/%ds", stage * g_CvarRecoveryHealthPerStage.IntValue, g_CvarRecoveryInterval.IntValue);
        case UpgradeSlot_Overload:
            FormatEx(text, length, "%d%% ammo capacity", 100 + stage * g_CvarOverloadMagazinePercent.IntValue);
        case UpgradeSlot_Stockpile:
        {
            int clips = stage * g_CvarStockpileClipsPerStage.IntValue;
            FormatEx(text, length, "%d extra reserve clip%s", clips, clips == 1 ? "" : "s");
        }
        case UpgradeSlot_Barrage:
            FormatEx(text, length, "%d%% weapon speed", 100 + stage * g_CvarBarrageFireRatePercent.IntValue);
        case UpgradeSlot_Control:
            FormatEx(text, length, "%d%% less recoil/spread", stage * g_CvarControlReductionPercent.IntValue);
        case UpgradeSlot_Dexterity:
            FormatEx(text, length, "%d%% reload/switch time", 100 - stage * g_CvarDexteritySpeedPercent.IntValue);
        case UpgradeSlot_Ward:
            FormatEx(text, length, "%.1fs immunity",
                g_CvarWardBaseSeconds.FloatValue + float(stage > 0 ? stage - 1 : 0) * g_CvarWardSecondsPerStage.FloatValue);
    }
}

void SanitizeChat(char[] text, int length)
{
    int out;
    for (int i = 0; text[i] != '\0' && out < length - 1; i++)
        if (text[i] < 0 || text[i] >= 32) text[out++] = text[i];
    text[out] = '\0';
}

bool CanReceiveShroudfireChat(int sender, int receiver, bool teamOnly)
{
    return !teamOnly || GetClientTeam(sender) == GetClientTeam(receiver);
}

bool HandleShroudfireChat(int client, const char[] message)
{
    if (StrEqual(message,"close",false)) { PlayMenuSound(client, "buttons/button19.wav"); CloseUpgradeMenu(client); CancelClientMenu(client,true); ShowVGUIPanel(client,"info",null,false); return true; }
    if (StrEqual(message,"help",false)) { ShowGuideMenu(client,0); return true; }
    if (StrEqual(message,"upgrade",false) || StrEqual(message,"upgrades",false)) { ShowGuideMenu(client,1); return true; }
    if (StrEqual(message,"bugs",false)) { ShowGuideMenu(client,2); return true; }
    if (StrEqual(message,"cheat",false)) { ShowGuideMenu(client,3); return true; }
    if (StrEqual(message,"audio",false)) { PlayMenuSound(client); ShowAudioMenu(client); return true; }
    if (StrEqual(message,"rank",false)) { ShowRankStats(client); return true; }
    bool reset = StrEqual(message,"reset",false);
    if (StrEqual(message,"menu",false) || reset)
    {
        if (!IsActiveHuman(client)) PrintToChat(client,"%s Join a playing team to open upgrades.",CHAT_PREFIX);
        else if (!g_XpLoaded[client]) { LoadPlayerXp(client); PrintToChat(client,"%s Upgrades loading. Try again shortly.",CHAT_PREFIX); }
        else
        {
            bool invisant = GetClientTeam(client)==GetInvisantTeam();
            if (reset) ApplyUpgradeChoice(client,invisant?"reset_invisant":"reset_armitive");
            else { CloseUpgradeMenu(client); QueueUpgradeMenu(client,invisant,0.0,true); }
        }
        return true;
    }
    if (g_UpgradeMenuOpen[client] && strlen(message)==1 && message[0]>='1' && message[0]<='8')
    {
        int slot=view_as<int>(UPGRADE_ORDER[GetClientTeam(client)==GetInvisantTeam()?0:1][message[0]-'1']);
        PlayMenuSound(client, "buttons/button3.wav");
        ApplyUpgradeChoice(client,UPGRADE_KEYS[slot]);
        return true;
    }
    static const char hintNames[][]={"audio","cheat","upgrade","bugs","menu","reset","rank"};
    static const char hintActions[][]={
        "to toggle voice lines on or off",
        "to learn why cheating is impossible",
        "to learn about them",
        "to learn about footsteps and reloads",
        "to choose your upgrades",
        "to reset your upgrades",
        "to see your rank"
    };
    bool matches[7];
    matches[0]=StrContains(message,"audio",false)!=-1 || StrContains(message,"voice",false)!=-1 || StrContains(message,"sound",false)!=-1 || StrContains(message,"announce",false)!=-1;
    matches[1]=StrContains(message,"cheat",false)!=-1 || StrContains(message,"hack",false)!=-1;
    matches[2]=StrContains(message,"upgrade",false)!=-1;
    matches[3]=StrContains(message,"reload",false)!=-1 || StrContains(message,"animation",false)!=-1 || StrContains(message,"footstep",false)!=-1 || StrContains(message,"dexterity",false)!=-1;
    matches[4]=StrContains(message,"level",false)!=-1 || StrContains(message,"point",false)!=-1 || StrContains(message,"menu",false)!=-1 || StrContains(message,"xp",false)!=-1;
    matches[5]=StrContains(message,"reset",false)!=-1;
    matches[6]=StrContains(message,"rank",false)!=-1;
    for (int i=0;i<7;i++)
    {
        char name[64];
        FormatEx(name,sizeof(name),"sf_%s_hint",hintNames[i]);
        if (!matches[i] || !FindConVar(name).BoolValue || GetEngineTime()<g_HintAvailableAt[i]) continue;
        FormatEx(name,sizeof(name),"sf_%s_hint_cooldown",hintNames[i]);
        g_HintAvailableAt[i]=GetEngineTime()+FindConVar(name).FloatValue;
        PrintToChatAll("%s Type \x07D6B86A%s\x01 %s",CHAT_PREFIX,hintNames[i],hintActions[i]);
    }
    return false;
}

bool ShowHtmlGuide(int client, int guide)
{
    ConVar downloadUrl = FindConVar("sv_downloadurl");
    if (downloadUrl == null || guide < 0 || guide >= 4) return false;
    char baseUrl[PLATFORM_MAX_PATH];
    downloadUrl.GetString(baseUrl, sizeof(baseUrl));
    TrimString(baseUrl);
    int length = strlen(baseUrl);
    while (length > 0 && baseUrl[length - 1] == '/') baseUrl[--length] = '\0';
    if (StrContains(baseUrl, "https://", false) != 0 && StrContains(baseUrl, "http://", false) != 0) return false;
    static const char files[][] = { "help.html", "upgrades.html", "bugs.html", "cheat.html" };
    char url[PLATFORM_MAX_PATH];
    FormatEx(url, sizeof(url), "%s/shroudfire/%s?v=%s", baseUrl, files[guide], PLUGIN_VERSION);
    CloseUpgradeMenu(client);
    ShowMOTDPanel(client, "Shroudfire", url, MOTDPANEL_TYPE_URL);
    return true;
}

void ShowGuideMenu(int client, int guide, int page=0)
{
    if (page == 0 && ShowHtmlGuide(client, guide)) return;
    CloseUpgradeMenu(client);
    Menu menu=new Menu(MenuHandler_Guide, MENU_ACTIONS_DEFAULT | MenuAction_Display);
    menu.OptionFlags |= MENUFLAG_NO_SOUND;
    char title[1000];
    BuildGuidePage(guide,page,title,sizeof(title));
    menu.SetTitle("Shroudfire\n%s",title);
    char key[32];
    FormatEx(key,sizeof(key),"page:%d:%d",guide,page+1);
    menu.AddItem(key,"Next page");
    if (page>0) { FormatEx(key,sizeof(key),"page:%d:%d",guide,page-1); menu.AddItem(key,"Previous page"); }
    menu.AddItem("help","Gameplay guide");
    menu.AddItem("upgrade","Upgrade guide");
    menu.AddItem("menu","Upgrade menu");
    menu.AddItem("rank","Rankings");
    menu.AddItem("audio","Audio settings");
    menu.Display(client,MENU_TIME_FOREVER);
}

public int MenuHandler_Guide(Menu menu,MenuAction action,int client,int item)
{
    if (action==MenuAction_End) delete menu;
    else if (action==MenuAction_Display) PlayMenuSound(client);
    else if (action==MenuAction_Cancel && item==MenuCancel_Exit) PlayMenuSound(client, "buttons/button19.wav");
    else if (action==MenuAction_Select && IsHumanClient(client))
    {
        PlayMenuSound(client, "buttons/button3.wav");
        char key[32]; menu.GetItem(item,key,sizeof(key));
        if (StrContains(key,"page:")==0)
        {
            char parts[3][12]; ExplodeString(key,":",parts,sizeof(parts),sizeof(parts[]));
            ShowGuideMenu(client,StringToInt(parts[1]),StringToInt(parts[2]));
        }
        else HandleShroudfireChat(client,key);
    }
    return 0;
}

void SetNotice(int client,int kind,float seconds,const char[] format,any ...)
{
    if (!IsHumanClient(client) || kind<0 || kind>=6) return;
    VFormat(g_NoticeText[client][kind],sizeof(g_NoticeText[][]),format,5);
    g_NoticeUntil[client][kind]=seconds>0.0?GetEngineTime()+seconds:0.0;
}

void RenderNotices(int client)
{
    if (!IsHumanClient(client) || !g_CvarHud.BoolValue) return;
    char text[1024]; float now=GetEngineTime();
    for (int i=0;i<6;i++) if (g_NoticeUntil[client][i]>now) Format(text,sizeof(text),"%s%s%s",text,text[0]?"\n":"",g_NoticeText[client][i]);
    if (!text[0]) { ClearSyncHud(client,g_NoticeHud); return; }
    SetHudTextParams(-1.0,0.46,1.1,147,196,125,255);
    ShowSyncHudText(client,g_NoticeHud,"%s",text);
}

void InitializeCombatDatabase()
{
    if (!SQL_FastQuery(g_XpDatabase,"CREATE TABLE IF NOT EXISTS shroudfire_combat (steam_id TEXT PRIMARY KEY NOT NULL, invisant_kills INTEGER NOT NULL DEFAULT 0, invisant_assists INTEGER NOT NULL DEFAULT 0, invisant_deaths INTEGER NOT NULL DEFAULT 0, armitive_kills INTEGER NOT NULL DEFAULT 0, armitive_assists INTEGER NOT NULL DEFAULT 0, armitive_deaths INTEGER NOT NULL DEFAULT 0);"))
        LogError("Could not create Shroudfire combat rankings.");
}

void IncrementCombatStat(int client,const char[] stat)
{
    if (g_XpDatabase==null || !g_XpSchemaReady || !IsActiveHuman(client)) return;
    char steam[32],escaped[64],query[512];
    if (!ResolvePlayerSteamId(client,steam,sizeof(steam)) || !g_XpDatabase.Escape(steam,escaped,sizeof(escaped))) return;
    Transaction transaction=new Transaction();
    FormatEx(query,sizeof(query),"INSERT OR IGNORE INTO shroudfire_combat (steam_id) VALUES ('%s');",escaped);
    transaction.AddQuery(query);
    FormatEx(query,sizeof(query),"UPDATE shroudfire_combat SET %s=MIN(2147483647,%s+1) WHERE steam_id='%s';",stat,stat,escaped);
    transaction.AddQuery(query);
    g_XpDatabase.Execute(transaction,INVALID_FUNCTION,SQL_SaveCombatTransaction);
}

void RecordCombatDeath(int victim,int attacker,bool scoring)
{
    if (!scoring || !IsActiveHuman(victim) || g_WaitingForNextRound[victim]
        || CountActiveHumans()<2 || g_ManagingRoster || g_TimeoutForcedDeath[victim]
        || GameRules_GetProp("m_bFreezePeriod")!=0) return;
    bool enemy=IsActiveHuman(attacker) && attacker!=victim && GetClientTeam(attacker)!=GetClientTeam(victim);
    if (attacker>0 && attacker!=victim && !enemy) return;
    g_IneligibleRoundDeath[victim]=g_AfkForcedDeath[victim]
        || (attacker==victim && !g_StarvationForcedDeath[victim] && !g_CampingForcedDeath[victim]);
    IncrementCombatStat(victim,GetClientTeam(victim)==GetInvisantTeam()?"invisant_deaths":"armitive_deaths");
}


float CombatRating(int kills,int assists,int deaths)
{
    float contributions=float(kills)+float(assists);
    if (contributions<=0.0) return 0.0;
    float events=contributions+float(deaths), proportion=contributions/events;
    float lower=(proportion+3.8416/(2.0*events)-1.96*SquareRoot((proportion*(1.0-proportion)+3.8416/(4.0*events))/events))/(1.0+3.8416/events);
    return 1000.0*lower*contributions/(contributions+100.0);
}

bool g_RankViewingInvisant[MAXPLAYERS + 1];

void ShowRankStats(int client, int viewTeam = 0)
{
    if (!IsHumanClient(client)) return;
    CloseUpgradeMenu(client);
    int team = GetClientTeam(client);
    if (team != GetInvisantTeam() && team != GetVisibleTeam())
    {
        PrintToChat(client, "%s Join a team to view your statistics.", CHAT_PREFIX);
        return;
    }
    if (!g_XpSchemaReady) { PrintToChat(client, "%s Rankings loading.", CHAT_PREFIX); return; }
    if (viewTeam == 0) viewTeam = team;
    bool invisantRole = viewTeam == GetInvisantTeam();
    char role[16], query[256];
    strcopy(role, sizeof(role), invisantRole ? "invisant" : "armitive");
    FormatEx(query, sizeof(query), "SELECT steam_id, %s_kills, %s_assists, %s_deaths FROM shroudfire_combat;", role, role, role);
    DataPack pack = new DataPack();
    pack.WriteCell(GetClientSerial(client));
    pack.WriteCell(team);
    pack.WriteCell(invisantRole);
    g_XpDatabase.Query(SQL_ShowRank, query, pack);
}

public int MenuHandler_RankStats(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_Select && IsHumanClient(client))
    {
        if (item == 9)
        {
            PlayMenuSound(client, "buttons/button3.wav");
            ShowRankStats(client, g_RankViewingInvisant[client] ? GetVisibleTeam() : GetInvisantTeam());
        }
        else PlayMenuSound(client, "buttons/button19.wav");
    }
    return 0;
}

public void SQL_ShowRank(Database db,DBResultSet result,const char[] error,any data)
{
    DataPack pack=view_as<DataPack>(data); pack.Reset();
    int client=GetClientFromSerial(pack.ReadCell()), team=pack.ReadCell();
    bool invisantRole = pack.ReadCell() != 0; delete pack;
    if (!IsHumanClient(client) || GetClientTeam(client) != team) return;
    if (result==null) { LogError("Rank query failed: %s",error); return; }
    char steam[32],rowSteam[32]; if (!ResolvePlayerSteamId(client,steam,sizeof(steam))) return;
    int kills,assists,deaths,players; float ownRating;
    ArrayList ratings=new ArrayList();
    while (result.FetchRow())
    {
        result.FetchString(0,rowSteam,sizeof(rowSteam));
        int k=result.FetchInt(1),a=result.FetchInt(2),d=result.FetchInt(3);
        if (k==0 && a==0 && d==0) continue;
        float rating=CombatRating(k,a,d); ratings.Push(rating); players++;
        if (StrEqual(steam,rowSteam)) { kills=k; assists=a; deaths=d; ownRating=rating; }
    }
    int position=(kills>0 || assists>0 || deaths>0)?1:0;
    for (int i=0;i<ratings.Length;i++) if (position>0 && view_as<float>(ratings.Get(i))>ownRating) position++;
    delete ratings;
    char ratio[32];
    if (deaths>0) FormatEx(ratio,sizeof(ratio),"%.2f",(float(kills)+float(assists))/float(deaths));
    else strcopy(ratio,sizeof(ratio),kills>0 || assists>0?"inf":"0");
    char title[256];
    FormatEx(title, sizeof(title), "%s\nRank: %d of %d\nRating: %.1f\nKills: %d | Assists: %d | Deaths: %d\nK/A/D ratio: %s",
        invisantRole ? "Invisant" : "Armitive", position, players, ownRating, kills, assists, deaths, ratio);
    Panel panel = new Panel();
    panel.SetTitle(title);
    panel.DrawText(" ");
    panel.CurrentKey = 9;
    panel.DrawItem(invisantRole ? "Armitive" : "Invisant", ITEMDRAW_CONTROL);
    panel.CurrentKey = 10;
    panel.DrawItem("Exit", ITEMDRAW_CONTROL);
    if (panel.Send(client, MenuHandler_RankStats, MENU_TIME_FOREVER))
    {
        g_RankViewingInvisant[client] = invisantRole;
        PlayMenuSound(client);
    }
    delete panel;
}



int GetReserveBonus(int client,int weapon)
{
    char classname[64]; GetEntityClassname(weapon,classname,sizeof(classname));
    int overload=(StrEqual(classname,"weapon_m3") || StrEqual(classname,"weapon_xm1014"))?0:
        RoundToFloor(float(GetWeaponBaseReserve(weapon))*float(g_AppliedUpgradeStage[client][UpgradeSlot_Overload])*OVERLOAD_INCREASE_PER_STAGE);
    return overload + GetWeaponBaseClip(weapon) * g_AppliedUpgradeStage[client][UpgradeSlot_Stockpile] * g_CvarStockpileClipsPerStage.IntValue;
}

void ApplyStockpile(int client,int purchasedAmmo=-1)
{
    if (!IsModActive() || !IsActiveHuman(client) || !IsPlayerAlive(client) || !g_XpLoaded[client] || GetClientTeam(client)!=GetVisibleTeam()) return;
    int processed[MAX_TRACKED_AMMO_TYPES];
    for (int slot=CS_SLOT_PRIMARY;slot<=CS_SLOT_SECONDARY;slot++)
    {
        int weapon=GetPlayerWeaponSlot(client,slot);
        if (weapon<=MaxClients || !IsValidEntity(weapon) || !HasEntProp(weapon,Prop_Send,"m_iPrimaryAmmoType")) continue;
        int ammo=GetEntProp(weapon,Prop_Send,"m_iPrimaryAmmoType");
        if (ammo<0 || ammo>=MAX_TRACKED_AMMO_TYPES) continue;
        int bonus=GetReserveBonus(client,weapon),base=GetWeaponBaseReserve(weapon);
        if (bonus<=processed[ammo]) continue;
        processed[ammo]=bonus;
        int delta=bonus-g_OverloadGrantedReserveBonus[client][ammo];
        int reserve=GetEntProp(client,Prop_Send,"m_iAmmo",4,ammo);
        // A paid refill can replenish capacity; switching weapons never refills it.
        if (ammo==purchasedAmmo && reserve>=base) delta=base+bonus-reserve;
        if (delta>0)
        {
            int updated=reserve+delta;
            if (updated>base+bonus) updated=base+bonus;
            SetEntProp(client,Prop_Send,"m_iAmmo",updated,4,ammo);
        }
        if (bonus>g_OverloadGrantedReserveBonus[client][ammo]) g_OverloadGrantedReserveBonus[client][ammo]=bonus;
        if (bonus>0) g_OverloadApplied[client]=true;
    }
}

public void Frame_ApplyStockpile(any serial) { int client=GetClientFromSerial(serial); if (IsHumanClient(client)) ApplyStockpile(client); }

bool KnifeConeIntersects(const float offset[3],const float direction[3],float radius,float reach,float width)
{
    if (reach<=0.0 || width<0.0 || width>360.0 || radius<0.0) return false;
    float distance=GetVectorLength(offset);
    if (distance>reach+radius) return false;
    if (distance<=radius) return true;
    float cosine=GetVectorDotProduct(offset,direction)/distance;
    if (cosine>1.0) cosine=1.0;
    if (cosine< -1.0) cosine= -1.0;
    float angle=ArcCosine(cosine),halfAngle=DegToRad(width*0.5);
    if (angle<=halfAngle) return true;
    float projection=distance*Cosine(angle-halfAngle),edge=projection;
    if (edge<0.0) edge=0.0;
    if (edge>reach) edge=reach;
    float perpendicular=distance*Sine(angle-halfAngle),beyond=projection-edge;
    return perpendicular*perpendicular+beyond*beyond<=radius*radius+0.000001;
}

int FindKnifeConeTarget(int client,const float angles[3])
{
    float start[3],direction[3]; GetClientEyePosition(client,start); GetAngleVectors(angles,direction,NULL_VECTOR,NULL_VECTOR);
    float closest=16384.0*16384.0; int target= -1;
    for (int other=1;other<=MaxClients;other++)
    {
        if (!IsActiveHuman(other) || other==client || !IsPlayerAlive(other) || GetClientTeam(other)!=GetVisibleTeam()) continue;
        float origin[3],mins[3],maxs[3],point[3],offset[3];
        GetClientAbsOrigin(other,origin); GetClientMins(other,mins); GetClientMaxs(other,maxs);
        // Test overlapping body spheres from feet to head, with obstruction checks.
        for (int sample=0;sample<4;sample++)
        {
            point[0]=origin[0]; point[1]=origin[1]; point[2]=origin[2]+16.0+(maxs[2]-32.0)*float(sample)/3.0;
            SubtractVectors(point,start,offset);
            if (!KnifeConeIntersects(offset,direction,16.0,g_CvarKnifeRange.FloatValue,g_CvarKnifeCone.FloatValue)) continue;
            Handle trace=TR_TraceRayFilterEx(start,point,MASK_SHOT,RayType_EndPoint,TraceFilter_IgnoreClient,client);
            bool clear=TR_GetEntityIndex(trace)==other || TR_GetFraction(trace)>=0.999;
            delete trace;
            float distance=GetVectorLength(offset,true);
            if (clear && distance<closest) { closest=distance; target=other; }
        }
    }
    return target;
}

void HandleTimeoutSurvivors()
{
    g_TimeoutReveal=!g_CvarTimeoutKillInvisant.BoolValue;
    g_TimeoutRevealAt=GetGameTime();
    for (int client=1;client<=MaxClients;client++)
    {
        if (!IsInvisantPlayer(client) || !IsPlayerAlive(client)) continue;
        if (!g_TimeoutReveal) { g_TimeoutForcedDeath[client]=true; ForcePlayerSuicide(client); }
        else { SetEntityRenderMode(client,RENDER_TRANSCOLOR); SetEntityRenderColor(client,255,255,255,0); }
    }
}

void ResetMapRotation()
{
    g_MapCompletedRounds=0; g_MapPlayedSeconds=0.0; g_MapLastSample=GetEngineTime();
    g_MapChangeAt=0.0; g_MapRetryAt=0.0; g_NextMapOverride[0]='\0';
    g_NextDiscordAt=GetEngineTime()+g_CvarDiscordInterval.FloatValue;
    for (int i=0;i<7;i++) g_HintAvailableAt[i]=0.0;
}

bool RotationMapName(const char[] name)
{
    if (!name[0] || StrContains(name,"..")!=-1 || name[0]=='/' || name[0]=='\\') return false;
    for (int i=0;name[i];i++) if (!IsCharAlpha(name[i]) && !IsCharNumeric(name[i]) && name[i]!='_' && name[i]!='-' && name[i]!='/') return false;
    return IsMapValid(name);
}

bool NextRotationMap(char[] name, int length)
{
    if (g_NextMapOverride[0] && RotationMapName(g_NextMapOverride))
    {
        strcopy(name, length, g_NextMapOverride);
        return true;
    }
    char rotation[2048], tokens[128][PLATFORM_MAX_PATH], current[PLATFORM_MAX_PATH];
    g_CvarMapRotation.GetString(rotation, sizeof(rotation));
    GetCurrentMap(current, sizeof(current));
    ReplaceString(rotation, sizeof(rotation), ",", " ");
    ReplaceString(rotation, sizeof(rotation), "\t", " ");
    ReplaceString(rotation, sizeof(rotation), "\r", " ");
    ReplaceString(rotation, sizeof(rotation), "\n", " ");
    int rawCount = ExplodeString(rotation, " ", tokens, sizeof(tokens), sizeof(tokens[]));
    int count;
    for (int index = 0; index < rawCount; index++)
    {
        if (!RotationMapName(tokens[index])) continue;
        bool duplicate;
        for (int previous = 0; previous < count; previous++)
            if (StrEqual(tokens[previous], tokens[index], false)) duplicate = true;
        if (!duplicate)
        {
            if (count != index) strcopy(tokens[count], sizeof(tokens[]), tokens[index]);
            count++;
        }
    }
    if (count == 0)
    {
        name[0] = '\0';
        return false;
    }
    int next;
    for (int index = 0; index < count; index++)
        if (StrEqual(tokens[index], current, false)) { next = (index + 1) % count; break; }
    strcopy(name, length, tokens[next]);
    return true;
}

void RestoreMapEngineLimits()
{
    if (!g_MapLimitsSaved) return;
    for (int i=0;i<3;i++) if (g_MapEngineLimits[i]!=null) g_MapEngineLimits[i].FloatValue=g_OriginalMapEngineLimits[i];
    g_MapLimitsSaved=false;
}

void UpdateMapRotation(float now)
{
    float elapsed=now-g_MapLastSample; g_MapLastSample=now;
    if (elapsed<0.0 || elapsed>5.0) elapsed=0.0;
    if (IsModActive() && CountActiveHumans()>=2) g_MapPlayedSeconds+=elapsed;
    if (!IsModActive()) { RestoreMapEngineLimits(); g_MapChangeAt=0.0; return; }
    if (!g_MapLimitsSaved)
    {
        for (int i=0;i<3;i++) if (g_MapEngineLimits[i]!=null) g_OriginalMapEngineLimits[i]=g_MapEngineLimits[i].FloatValue;
        g_MapLimitsSaved=true;
    }
    for (int i=0;i<3;i++) if (g_MapEngineLimits[i]!=null && g_MapEngineLimits[i].IntValue!=0) g_MapEngineLimits[i].IntValue=0;
    bool reached=(g_CvarMapMaxRounds.IntValue>0 && g_MapCompletedRounds>=g_CvarMapMaxRounds.IntValue)
        || (g_CvarMapTimeLimit.FloatValue>0.0 && g_MapPlayedSeconds>=60.0*g_CvarMapTimeLimit.FloatValue);
    if (!reached) { g_MapChangeAt=0.0; return; }
    if (g_MapChangeAt<=0.0 && g_RoundInProgress && CountActiveHumans()>=2) return;
    char next[PLATFORM_MAX_PATH];
    if (!NextRotationMap(next,sizeof(next)))
    {
        if (now>=g_MapRetryAt) { g_MapRetryAt=now+5.0; LogMessage("Map limit reached, but no available next map; update sf_map_rotation or sf_nextmap."); }
        g_MapChangeAt=0.0; return;
    }
    if (g_MapChangeAt<=0.0) { g_MapChangeAt=now+5.0; PrintToChatAll("%s Changing map to %s in 5 seconds.",CHAT_PREFIX,next); }
    else if (now>=g_MapChangeAt) { g_MapChangeAt=now+60.0; ForceChangeLevel(next,"Shroudfire map limit reached"); }
}

public Action Timer_Parity(Handle timer)
{
    float now=GetEngineTime(); UpdateMapRotation(now);
    if (!IsModActive()) return Plugin_Continue;
    if (g_CvarDiscordMessage.BoolValue && now>=g_NextDiscordAt)
    {
        g_NextDiscordAt=now+g_CvarDiscordInterval.FloatValue;
        char link[256]; g_CvarDiscordLink.GetString(link,sizeof(link));
        if (link[0]) PrintToChatAll("%s Join our Discord: \x07D6B86A%s\x01",CHAT_PREFIX,link);
    }
    if (g_TimeoutReveal)
    {
        float duration=g_CvarTimeoutRevealSeconds.FloatValue;
        int alpha=duration<=0.0?255:RoundToNearest(255.0*(GetGameTime()-g_TimeoutRevealAt)/duration);
        if (alpha>255) alpha=255;
        for (int client=1;client<=MaxClients;client++) if (IsInvisantPlayer(client) && IsPlayerAlive(client)) SetEntityRenderColor(client,255,255,255,alpha);
    }
    bool live=g_RoundInProgress && g_ForcedRoundEndMode==FORCED_END_NONE && CountRoundParticipants()>=2 && GameRules_GetProp("m_bFreezePeriod")==0;
    float remaining=g_CvarRoundSeconds.FloatValue-(GetGameTime()-g_RoundLiveStartedAt);
    bool timeoutWarning=live && g_RoundLiveStartedAt>0.0 && !g_CvarTimeoutKillInvisant.BoolValue && g_CvarTimeoutWarningSeconds.IntValue>0 && remaining>0.0 && remaining<=g_CvarTimeoutWarningSeconds.FloatValue;
    for (int client=1;client<=MaxClients;client++)
    {
        if (!IsHumanClient(client)) continue;
        RenderNotices(client);
        if (timeoutWarning && IsInvisantPlayer(client) && IsPlayerAlive(client))
        {
            if (!g_TimeoutVoicePlayed) PlayRandomVoice(client,Audio_Timeout,Voice_Timeout);
            if (!g_AfkWarningShown[client]) SetNotice(client,5,1.1,"The shroud is fading\nFinish the hunt (%ds)",RoundToCeil(remaining));
        }
        bool camping=live && IsPlayerAlive(client) && GetClientTeam(client)==GetVisibleTeam() && !g_WaitingForNextRound[client] && g_CvarCampingDistance.FloatValue>0.0;
        if (!camping) { g_CampingAnchorReady[client]=false; g_CampingActive[client]=false; continue; }
        float position[3]; GetClientAbsOrigin(client,position);
        if (!g_CampingAnchorReady[client] || GetVectorDistance(position,g_CampingAnchor[client])>=g_CvarCampingDistance.FloatValue)
        {
            g_CampingAnchorReady[client]=true; g_CampingAnchorAt[client]=now; g_CampingWarned[client]=false; g_CampingActive[client]=false;
            for (int axis=0;axis<3;axis++) g_CampingAnchor[client][axis]=position[axis];
        }
        if (g_AfkWarningShown[client] || g_AfkForcedDeath[client]) continue;
        float elapsed=now-g_CampingAnchorAt[client];
        if (elapsed<g_CvarCampingWarningSeconds.FloatValue) continue;
        if (!g_CampingWarned[client]) { PlayRandomVoice(client,Audio_Camping,Voice_Camping); g_CampingWarned[client]=true; }
        SetNotice(client,5,1.1,"Move away from this position\nCamping damages your health");
        if (elapsed<g_CvarCampingWarningSeconds.FloatValue+g_CvarCampingDamageDelay.FloatValue) continue;
        g_CampingActive[client]=true;
        int health=GetClientHealth(client),amount=g_CvarCampingDamage.IntValue;
        if (health>amount) SetEntityHealth(client,health-amount);
        else { g_CampingForcedDeath[client]=true; ForcePlayerSuicide(client); }
    }
    if (timeoutWarning) g_TimeoutVoicePlayed=true;
    return Plugin_Continue;
}

public Action Command_ShroudfireCvar(int client,int args)
{
    if (args<1) { ReplyToCommand(client,"Usage: sf_cvar <name> [value]"); return Plugin_Handled; }
    char name[128],value[1024]; GetCmdArg(1,name,sizeof(name)); ConVar cvar=FindConVar(name);
    if (cvar==null) { ReplyToCommand(client,"[Shroudfire] Unknown cvar."); return Plugin_Handled; }
    if (args>1)
    {
        GetCmdArgString(value,sizeof(value)); int space=FindCharInString(value,' ');
        if (space<0) return Plugin_Handled;
        strcopy(value,sizeof(value),value[space+1]); TrimString(value); StripQuotes(value);
        cvar.SetString(value);
        LogAction(client,-1,"Shroudfire cvar %s changed to %s.",name,(cvar.Flags & FCVAR_PROTECTED)?"<protected>":value);
    }
    cvar.GetString(value,sizeof(value));
    ReplyToCommand(client,"[Shroudfire] %s = %s",name,(cvar.Flags & FCVAR_PROTECTED)?"<protected>":value);
    return Plugin_Handled;
}

public Action Command_ShroudfireNextMap(int client,int args)
{
    char map[PLATFORM_MAX_PATH];
    if (args>0)
    {
        GetCmdArg(1,map,sizeof(map));
        if (StrEqual(map,"reset",false)) g_NextMapOverride[0]='\0';
        else if (!RotationMapName(map)) { ReplyToCommand(client,"[Shroudfire] Map is unavailable or invalid."); return Plugin_Handled; }
        else strcopy(g_NextMapOverride,sizeof(g_NextMapOverride),map);
    }
    if (NextRotationMap(map,sizeof(map))) ReplyToCommand(client,"[Shroudfire] Next map: %s",map);
    else ReplyToCommand(client,"[Shroudfire] No available next map.");
    return Plugin_Handled;
}

public Action Command_ShroudfireUpdateNotice(int client,int args)
{
    if (client!=0) { ReplyToCommand(client,"[Shroudfire] Server console only."); return Plugin_Handled; }
    char value[32]; GetCmdArg(1,value,sizeof(value)); int seconds;
    if (args!=1 || StringToIntEx(value,seconds)!=strlen(value) || seconds<1 || seconds>3600) { ReplyToCommand(client,"Usage: sf_update_notice <seconds: 1-3600>"); return Plugin_Handled; }
    PrintToChatAll("%s Server update: restarting in %d seconds.",CHAT_PREFIX,seconds);
    return Plugin_Handled;
}

public Action Command_ShroudfireArmitive(int client,int args)
{
    if (!IsHumanClient(client) || !IsModActive()) { ReplyToCommand(client,"[Shroudfire] A connected player and active mode are required."); return Plugin_Handled; }
    CloseUpgradeMenu(client); g_SpectatorLocked[client]=false; g_ChoseSpectator[client]=false;
    g_WaitingForNextRound[client]=false; g_ForfeitedInvisantThisRound[client]=false; g_EarnedInvisant[client]=false; g_PromotedByKill[client]=false;
    bool managing=g_ManagingRoster; g_ManagingRoster=true; MoveClientToTeam(client,GetVisibleTeam()); CS_RespawnPlayer(client); g_ManagingRoster=managing;
    PutAtBackOfQueue(client); RecordClientActivity(client);
    LogAction(client,client,"\"%L\" manually joined the Armitive team.",client);
    return Plugin_Handled;
}



void ApplyPurchasedUpgrade(int client,UpgradeSlot slot,int stage)
{
    switch (slot)
    {
        case UpgradeSlot_Lightweight:
        {
            float gravity=1.0-float(stage)*LIGHTWEIGHT_GRAVITY_REDUCTION_PER_STAGE;
            SetEntityGravity(client,gravity>0.0?gravity:0.001); g_LightweightApplied[client]=true;
        }
        case UpgradeSlot_Momentum, UpgradeSlot_Mobility: ApplyInvisantMovementSpeed(client,IsInvisantCrouchMovementActive(client));
        case UpgradeSlot_Resilience:
        {
            int armor=GetEntProp(client,Prop_Send,"m_ArmorValue");
            int delta=stage-g_ResilienceGrantedStageThisLife[client];
            if (delta>0) { armor+=delta*RESILIENCE_ARMOR_PER_STAGE; g_ResilienceGrantedStageThisLife[client]=stage; }
            int maximum=INVISANT_BASE_ARMOR+stage*RESILIENCE_ARMOR_PER_STAGE;
            SetEntProp(client,Prop_Send,"m_ArmorValue",armor>maximum?maximum:armor);
            SetEntProp(client,Prop_Send,"m_bHasHelmet",stage>=g_CvarResilienceHelmetStage.IntValue?1:0);
            g_ResilienceApplied[client]=true;
        }
        case UpgradeSlot_Fortitude:
        {
            int health=GetClientHealth(client),delta=stage-g_FortitudeGrantedStageThisLife[client];
            if (delta>0) { health+=delta*FORTITUDE_HEALTH_PER_STAGE; g_FortitudeGrantedStageThisLife[client]=stage; }
            int maximum=g_CvarArmitiveBaseHealth.IntValue+stage*FORTITUDE_HEALTH_PER_STAGE;
            SetEntityHealth(client,health>maximum?maximum:health); g_FortitudeApplied[client]=true;
        }
        case UpgradeSlot_Overload: ApplyOverloadStageIncrease(client,stage);
        case UpgradeSlot_Stockpile: ApplyStockpile(client);
        case UpgradeSlot_Ward:
        {
            if (g_ArmitiveWardAvailableAt[client] > GetGameTime())
            {
                DataPack readyPack;
                CreateDataTimer(g_ArmitiveWardAvailableAt[client] - GetGameTime(), Timer_NotifyArmitiveWardReady, readyPack, TIMER_FLAG_NO_MAPCHANGE);
                readyPack.WriteCell(GetClientSerial(client));
                readyPack.WriteCell(g_ArmitiveWardCycleToken[client]);
                g_ArmitiveWardReadyCuePlayed[client] = false;
            }
        }
    }
}

void ApplyResetUpgrades(int client,bool invisant)
{
    if (invisant)
    {
        SetEntityGravity(client,1.0);
        if (HasEntProp(client,Prop_Send,"m_flLaggedMovementValue")) SetEntPropFloat(client,Prop_Send,"m_flLaggedMovementValue",1.0);
        int armor=GetEntProp(client,Prop_Send,"m_ArmorValue");
        if (armor>INVISANT_BASE_ARMOR) SetEntProp(client,Prop_Send,"m_ArmorValue",INVISANT_BASE_ARMOR);
        SetEntProp(client,Prop_Send,"m_bHasHelmet",0);
    }
    else
    {
        if (GetClientHealth(client)>g_CvarArmitiveBaseHealth.IntValue) SetEntityHealth(client,g_CvarArmitiveBaseHealth.IntValue);
        RestoreOverloadFromWeapons(client);
        float readyAt = g_ArmitiveWardAvailableAt[client];
        CancelArmitiveWard(client);
        g_ArmitiveWardAvailableAt[client] = readyAt;
    }
}

public Action Timer_RoundWinVoice(Handle timer,DataPack pack)
{
    pack.Reset(); int client=GetClientFromSerial(pack.ReadCell()); VoiceGroup group=view_as<VoiceGroup>(pack.ReadCell()); int round=pack.ReadCell();
    if (round==g_RoundSerial && IsModActive()) PlayRandomVoice(client,Audio_RoundEnd,group);
    return Plugin_Stop;
}

#include <shroudfire/guides>

public void OnParitySettingsChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    if (cvar == g_CvarArmitiveBlockedWeapons) ConfigureBlockedWeapons();
    if (cvar == g_CvarSilentLocalMovement) RefreshAllClientFootstepPrediction();
    if (cvar == g_CvarDiscordInterval) g_NextDiscordAt = GetEngineTime() + cvar.FloatValue;
    if (cvar == g_CvarHud && !cvar.BoolValue)
        for (int client = 1; client <= MaxClients; client++)
            if (IsHumanClient(client)) ClearSyncHud(client, g_NoticeHud);
}
