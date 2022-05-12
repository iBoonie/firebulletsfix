#pragma newdecls required
#pragma semicolon 1 

#include <sourcemod>
#include <dhooks>

DynamicHook g_hWeapon_ShootPosition;
float g_vecOldWeaponShootPos[MAXPLAYERS + 1][3];

public Plugin myinfo = 
{
	name = "Bullet position fix", 
	author = "xutaxkamay", 
	description = "Fixes shoot position", 
	version = "1.1", 
	url = "https://forums.alliedmods.net/showthread.php?p=2646571"
};

public void OnPluginStart()
{
	GameData gameData = new GameData("dhooks.weapon_shootposition");
	if (!gameData)
	{
		SetFailState("[FireBullets Fix] No game data present");
	}
	
	int offset = gameData.GetOffset("Weapon_ShootPosition");
	if (offset == -1)
	{
		delete gameData;
		SetFailState("[FireBullets Fix] failed to find offset");
	}
	
	delete gameData;
	
	g_hWeapon_ShootPosition = new DynamicHook(offset, HookType_Entity, ReturnType_Vector, ThisPointer_CBaseEntity);
	if (g_hWeapon_ShootPosition == null)
	{
		SetFailState("[FireBullets Fix] couldn't hook Weapon_ShootPosition");
	}
	
	for (int client = 1; client <= MaxClients + 1; client++)
	{
		OnClientPutInServer(client);
	}
}

public void OnClientPutInServer(int client)
{
	if (IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client) && !IsClientSourceTV(client))
	{
		g_hWeapon_ShootPosition.HookEntity(Hook_Post, client, Weapon_ShootPosition_Post);
	}
}

public void OnPlayerRunCmdPre(int client)
{
	if (IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client) && !IsClientSourceTV(client))
	{
		GetClientEyePosition(client, g_vecOldWeaponShootPos[client]);
	}
}

public MRESReturn Weapon_ShootPosition_Post(int client, DHookReturn hReturn)
{
	hReturn.SetVector(g_vecOldWeaponShootPos[client]);
	return MRES_Supercede;
}
