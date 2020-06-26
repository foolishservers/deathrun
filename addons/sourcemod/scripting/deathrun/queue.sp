int Queue_GetPlayerInQueuePos(int pos)
{
	ArrayList queue = new ArrayList(2, MaxClients);
	int length = 0;
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (Queue_IsClientAllowed(client))
		{
			queue.Set(length, DRPlayer(client).QueuePoints, 0); //block 0 gets sorted
			queue.Set(length, client, 1);
			length++;
		}
	}
	
	if (pos > length || pos < 1)
		return -1;
	
	queue.Resize(length);
	queue.Sort(Sort_Descending, Sort_Integer);
	int client = queue.Get(pos - 1, 1);
	delete queue;
	
	return client;
}

void Queue_SetNextActivator()
{
	int client = Queue_GetPlayerInQueuePos(1);
	if (IsValidClient(client))
	{
		g_CurrentActivator = client;
		Queue_SetPoints(client, 0);
		TF2_ChangeClientTeamAlive(client, TFTeam_Blue);
	}
}

ArrayList Queue_GetQueueList()
{
	ArrayList queue = new ArrayList(2, MaxClients);
	int length = 0;
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (Queue_IsClientAllowed(client))
		{
			queue.Set(length, DRPlayer(client).QueuePoints, 0); //block 0 gets sorted
			queue.Set(length, client, 1);
			length++;
		}
	}
	
	queue.Resize(length);
	queue.Sort(Sort_Descending, Sort_Integer);
	return queue;
}

void Queue_AddPoints(int client, int points)
{
	DRPlayer player = DRPlayer(client);
	
	if (player.QueuePoints == -1)
	{
		PrintToChat(client, DEATHRUN_TAG..." An error occured while trying to award you queue points.");
		return;
	}
	else if (!DRPlayer(client).GetPreference(Preference_AvoidBecomingActivator))
	{
		CPrintToChat(client, DEATHRUN_TAG..." You have not been awarded any queue points based on your activator preferences.");
		return;
	}
	
	player.QueuePoints += points;
	Cookies_SaveQueue(client, player.QueuePoints);
	
	CPrintToChat(client, DEATHRUN_TAG..." You have been awarded {green}%d {default}queue point(s) (Total: {green}%d{default}).", dr_queue_points.IntValue, player.QueuePoints);
}

void Queue_SetPoints(int client, int points)
{
	DRPlayer player = DRPlayer(client);
	player.QueuePoints = points;
	Cookies_SaveQueue(client, player.QueuePoints);
}

bool Queue_IsClientAllowed(int client)
{
	if (0 < client <= MaxClients
		 && IsClientInGame(client)
		 && TF2_GetClientTeam(client) > TFTeam_Spectator //Is client not in spectator
		 && DRPlayer(client).QueuePoints != -1 //Does client have his queue points loaded
		 && DRPlayer(client).GetPreference(Preference_AvoidBecomingActivator))
	{
		return true;
	}
	else
	{
		return false;
	}
}
