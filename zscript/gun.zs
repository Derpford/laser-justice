class Gunlimiter : PowerupGiver replaces Berserk
{
	// GUNLIMITED POWER
	default
	{
		+COUNTITEM;
		+BRIGHT;
		Inventory.PickupMessage "GUNLIMITED POWER!!!";
		Inventory.MaxAmount 0;
		Powerup.Type "PowerWeaponLevel2";
		+Inventory.AUTOACTIVATE;
		+Inventory.ALWAYSPICKUP;
		Powerup.Colormap 0, 0, 0, 1, .2, .2;
		Powerup.Duration -15;
		inventory.respawntics 4230;
	}

	states
	{
		Spawn:
			PSTR A -1;
			Stop;
	}
}

class Bomb : Inventory
{
	// Blow up your foes for great justice.
	default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 5;
	}
}

class LaserGun : Weapon
{
	// The only gun a Paladin of LASER JUSTICE needs.

	int bombtimer;

	default
	{

	}

	override void Tick()
	{
		Super.Tick();
		bombtimer = max(bombtimer-1, 0);
	}

	action clearscope int GetLevel()
	{
		int tokens = invoker.owner.countinv("UpgradeToken");
		int lvl = min(floor(tokens/200.),5);
		return lvl;
	}

	action void FireLaserGun(int lvl)
	{
		// Handles firing the various stages of the LaserGun.
		int gunlimited = invoker.owner.CountInv("PowerWeaponLevel2");
		if(gunlimited > 0 && lvl == 0) { lvl = 1; }
		switch(lvl)
		{
			case 5: // omega shot
				A_SetTics(5);
				A_FireProjectile("SmallBeamShot");
				A_StartSound("weapons/laserf3");
				if(gunlimited < 1) { break; }
			case 4: // buster shot
				A_FireProjectile("BusterLaser");
				A_StartSound("weapons/laserf2");
				A_SetTics(4);
				if(gunlimited < 1) { break; }
			case 3: // spread shot
				A_StartSound("weapons/laserf3");
				A_FireProjectile("SmallLaserShot",8,spawnofs_xy:-8);
				A_FireProjectile("SmallLaserShot",-8,spawnofs_xy:8);
				A_FireProjectile("LaserShot",4,spawnofs_xy:-4);
				A_FireProjectile("LaserShot",-4,spawnofs_xy:4);
				A_FireProjectile("SmallLaserShot");
				if(gunlimited < 1) { break; }
			case 2: // beam shot
				A_FireProjectile("BeamShot");
				A_SetTics(3);
				A_StartSound("weapons/laserf2");
				if(gunlimited < 1) { break; }
			case 1: // double shot
				A_SetTics(2);
				A_FireProjectile("SmallLaserShot",spawnofs_xy:-6);
				A_FireProjectile("SmallLaserShot",spawnofs_xy:6);
				A_StartSound("weapons/laserf4");
				if(gunlimited < 1) { break; }
			case 0: // starting shot
				A_FireProjectile("LaserShot");
				A_StartSound("weapons/laserf3");
				if(gunlimited < 1) { break; }

		}
	}

	action void UseBomb()
	{
		if(invoker.bombtimer == 0 && invoker.owner.CountInv("Bomb")>0)
		{
			A_StartSound("weapons/bombf",666);
			invoker.owner.A_Explode(32,512,flags:XF_NOTMISSILE);
			ThinkerIterator bomb = ThinkerIterator.Create("Actor");
			Actor mo;
			while(mo = Actor(bomb.Next()))
			{
				if(mo == invoker.owner || !(mo.bSHOOTABLE))
				{
					continue;
				}
				if(mo.bMISSILE)
				{
					mo.SetState(mo.ResolveState("Death"));
					continue;
				}
				if(invoker.owner.Vec3To(mo).Length() <= 512)
				{
					double scalar = (256 - invoker.owner.Vec3To(mo).Length())/256.;
					mo.bSKULLFLY = true;
					mo.vel = invoker.owner.Vec3To(mo).Unit() * (1024 * scalar) / float(mo.mass);
					mo.vel.z += 12 * scalar;
				}
			}

			invoker.bombtimer = 20;
			invoker.owner.A_TakeInventory("Bomb",1);
		}
	}

	action void SetFireTics(int lvl, bool secondframe = false)
	{
		int gunlimited = invoker.owner.CountInv("PowerWeaponLevel2");
		if(gunlimited > 0 && lvl == 0) { lvl = 1; }

		switch(lvl)
		{
			case 5: // omega shot
				A_SetTics(5);
				if(secondframe)
				{
					A_StartSound("weapons/laserf",10);
					A_FireProjectile("SmallBeamShot",12,spawnofs_xy:-12);
					A_FireProjectile("SmallBeamShot",-12,spawnofs_xy:12);
				}
				else
				{
					A_StartSound("weapons/laserf2",20);
					A_FireProjectile("LaserShot",4,spawnofs_xy:-4);
					A_FireProjectile("LaserShot",-4,spawnofs_xy:4);
				}
				if(gunlimited < 1) { break; }
			case 4: // buster shot
				A_SetTics(6);
				if(gunlimited < 1) { break; }
			case 3: // spread shot
				A_SetTics(3);
				if(gunlimited < 1) { break; }
			case 2: // beam shot
				A_SetTics(4);
				if(gunlimited < 1) { break; }
			case 1: // double shot
				if(secondframe)
				{
					A_SetTics(4);
					A_StartSound("weapons/laserf4");
					A_FireProjectile("SmallLaserShot",spawnofs_xy:-8);
					A_FireProjectile("SmallLaserShot",spawnofs_xy:8);
				}
				else
				{
					A_SetTics(2);
				}
				if(gunlimited < 1) { break; }
			case 0: // starting shot
				A_SetTics(2);
				if(gunlimited < 1) { break; }
		}
	}

	states
	{
		Select:
			PISG A 1 A_Raise(35);
			Loop;
		Deselect:
			PISG A 1 A_Lower(35);
			Loop;

		Ready:
			PISG A 1 A_WeaponReady();
			Loop;

		Fire:
			PISG A 1 FireLaserGun(GetLevel());
			PISG B 2 SetFireTics(GetLevel(),false);
			PISG C 2 SetFireTics(GetLevel(),true);
			Goto Ready;

		AltFire:
			PISG A 0 UseBomb();
			Goto Ready;
	}
}

