class WeaponTokenHandler : EventHandler
{
	override void WorldThingSpawned(WorldEvent e)
	{
		let wpn = Weapon(e.Thing);
		if(wpn)
		{
			if(e.Thing is "LaserGun") { return; }
			if(e.Thing.bDROPPED)
			{
				e.Thing.spawn("ShellBoxUpgradeToken",e.Thing.pos);
			}
			else
			{
				e.Thing.spawn("WeaponUpgradeToken",e.Thing.pos);
			}

			wpn.Destroy();
		}
	}
}

class CoinHandler : EventHandler
{
	void TossDrop(Actor src, Name it)
	{
		let this = src.Spawn(it,src.pos);
		double rad = clamp(0,src.radius/3,10);
		this.vel = (frandom(-rad/2,rad/2), frandom(-rad/2,rad/2), frandom(rad,rad*2));
	}

	override void WorldThingDied(WorldEvent e)
	{
		int amt = e.Thing.SpawnHealth();
		while(amt > 5)
		{
			if(amt > 125)
			{
				TossDrop(e.Thing,"GoldCoin");
				amt -= 125;
			}
			if(amt > 25)
			{
				TossDrop(e.Thing,"SilverCoin");
				amt -= 25;
			}
			if(amt > 5)
			{
				TossDrop(e.Thing,"CopperCoin");
				amt -= 5;
			}
		}
	}
}

class ComboHandler : EventHandler
{
	override void WorldThingDied(WorldEvent e)
	{
		if(e.inflictor && e.inflictor.target)
		{
			let plr = LaserPaladin(e.inflictor.target);
			if(plr)
			{
				plr.combometer += e.thing.SpawnHealth();
			}
		}
	}
}

class EndScoreHandler : EventHandler
{
	Array<Name> type;
	Array<int> val;
	int hpval; // How much to give per point of health

	override void PostBeginPlay
	{
		// Each Type and Val is a pair.
		type = [
			"UpgradeToken",
			"ShieldToken",
			"Multiplier" // Should always be last!
		];

		val = [
			100,
			100,
			2 // Multiplier is exponential!
		];

		hpval = 1000;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for(int cplr = 0; cplr < consoleplayers.Size(); cplr++)
		{
			let plr = consoleplayers[cplr];
			if(plr)
			{
				// First, get the multiplier for this player.
				int mult = plr.CountInv("Multiplier");

				// Next, count up their health.
				plr.A_GiveInventory("ScoreItem",plr.health*mult);
				plr.A_ResetHealth();
				
				// Next, handle all their items.
				for(int i = 0; i < type.Size(); i++)
				{
					int cnt = plr.CountInv(type[i]);
					plr.A_GiveInventory("ScoreItem",cnt*val[i]*mult);
					plr.A_TakeInventory(type[i],cnt);
				}
			}
		}
	}
}