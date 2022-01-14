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
		double rad = src.radius/3;
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
		let plr = LaserPaladin(e.inflictor.target);
		if(plr)
		{
			plr.combometer += e.thing.SpawnHealth();
		}
	}
}