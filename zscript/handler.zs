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
				e.Thing.spawn("BigUpgradeTokenRandom",e.Thing.pos);
			}
			else
			{
				let gem = e.Thing.spawn("WeaponUpgradeToken",e.Thing.pos);
				gem.A_SetSpecial(e.Thing.special, 
					e.Thing.args[0],
					e.Thing.args[1],
					e.Thing.args[2],
					e.Thing.args[3],
					e.Thing.args[4]);
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

		vals.Insert("UpgradeToken",".1");
		vals.Insert("ShieldToken","5");
		vals.Insert("Bomb","10");
		vals.Insert("Multiplier","2");

		hpval = 1000;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for(int cplr = 0; cplr < players.Size(); cplr++)
		{
			PlayerInfo pi = players[cplr];
			if(pi.mo)
			{
				let plr = pi.mo;
				// First, get the multiplier for this player.
				int mult = plr.CountInv("Multiplier");

				// Next, count up their health.
				plr.A_GiveInventory("ScoreItem",plr.health*mult);
				plr.A_ResetHealth();

				let iter = DictionaryIterator.Create(vals);
				// Now we take each item and give its point value.
				while(iter.Next())
				{
					int cnt = plr.CountInv(iter.Key());
					double val = iter.Value().ToDouble();
					int scr = floor(cnt*val*mult);
					console.printf("Score from "..iter.Key()..": "..scr);
					plr.A_GiveInventory("ScoreItem",scr);
					plr.A_TakeInventory(iter.Key(),cnt);
				}

				// Finally, wrap up and prep for next level.
				plr.A_GiveInventory("Bomb",1); // Start each level with one (1) bomb
				// If this is a LaserPaladin (which it should be) we need to set up for the stat screen's score totals.
				let pal = LaserPaladin(plr);
				if(pal)
				{
					pal.scorelast = pal.score;
					pal.scoretotal += pal.score;
					pal.score = 0;
				}
			}
		}
	}
}

class MultiplayerAwareScoreItemHandler : EventHandler
{

}