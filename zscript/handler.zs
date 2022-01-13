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