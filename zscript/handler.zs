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
		double rad = clamp(0,src.radius/5,10);
		this.vel = (frandom(-rad/2,rad/2), frandom(-rad/2,rad/2), frandom(rad,rad*2));
	}

	override void WorldThingDied(WorldEvent e)
	{
		int amt = e.Thing.SpawnHealth();
		while(amt > 0)
		{
			if(amt > 250)
			{
				TossDrop(e.Thing,"GoldCoin");
			}
			else if(amt > 100)
			{
				TossDrop(e.Thing,"SilverCoin");
			}
			else
			{
				TossDrop(e.Thing,"CopperCoin");
			}
			amt -= 10;
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
	Dictionary vals;
	int hpval; // How much to give per point of health

	override void OnRegister()
	{
		// Each Type and Val is a pair.
		vals = Dictionary.Create();

		vals.Insert("UpgradeToken","5");
		vals.Insert("ShieldToken","10");
		vals.Insert("Multiplier","2");

		hpval = 1000;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for(int cplr = 0; cplr < players.Size(); cplr++)
		{
			PlayerInfo pi = players[cplr];
			console.printf("Checking player "..cplr);
			if(pi.mo)
			{
				let plr = pi.mo;
				// First, get the multiplier for this player.
				int mult = plr.CountInv("Multiplier");

				// Next, count up their health.
				plr.A_GiveInventory("ScoreItem",plr.health*mult);
				plr.A_ResetHealth();

				let iter = DictionaryIterator.Create(vals);
				while(iter.Next())
				{
					int cnt = plr.CountInv(iter.Key());
					int val = iter.Value().ToInt();
					console.printf("Score from "..iter.Key()..": "..cnt*val*mult);
					plr.A_GiveInventory("ScoreItem",cnt*val*mult);
					plr.A_TakeInventory(iter.Key(),cnt);
				}
			}
		}
	}
}