class Orbiter : Actor
{
	// Spins around you and absorbs incoming damage.
	default
	{
		+SHOOTABLE;
		-VULNERABLE; // AoE damage does not affect orbs.
		Health 50;
		Height 32;
		RenderStyle "Add";
		Species "Laser";
	}

	override void Tick()
	{
		Super.Tick();
		alpha = 0.2 + (0.8 * health/50.);
	}

	states
	{
		Spawn:
			PINS ABCD 5;
			Loop;
	}
}

class OrbiterManager : Inventory replaces Blursphere
{
	// Handles spreading Orbiters out.

	Array<Actor> orbs;

	default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 5;
		+BRIGHT;
		+COUNTITEM;
		inventory.PickupMessage "Deflector Orb!";
	}

	override void DoEffect()
	{
		// Spawn orbs to match the amount of orb managers in inventory.
		if(orbs.size() < owner.CountInv("OrbiterManager"))
		{
			let orb = Spawn("Orbiter",owner.pos);
			orb.master = owner;
			orbs.push(orb);
		}

		// Handle orbs. Heh.
		angle += 5;
		for(int i = 0; i < orbs.size(); i++)
		{
			if(orbs[i])
			{
				double dangle = i * (360./float(orbs.size()));
				orbs[i].Warp(owner,64,angle:angle+dangle,flags:WARPF_NOCHECKPOSITION);
			}
		}
	}

	states
	{
		Spawn:
			PINS ABCD 5;
			Loop;
	}

}

class Megashield : Inventory replaces Megasphere
{
	default
	{
		+BRIGHT;
		+COUNTITEM;
		Inventory.PickupMessage "Mega Shield Booster!";
	}
	// Gives 200 health and max shield.
	override bool TryPickup(in out actor toucher)
	{
		toucher.A_GiveInventory("HealthBonus",200);
		toucher.A_GiveInventory("ShieldToken",100);
		GoAwayAndDie();
		return true;
	}

	states
	{
		Spawn:
			MEGA ABCD 5;
	}
}

class MoneyBags : Inventory replaces Backpack
{
	// A boatload of cash!
	default
	{
		Inventory.PickupMessage "Found a bag full of cash!";
	}

	override bool TryPickup(in out actor toucher)
	{
		toucher.Spawn("MoneyFountain",toucher.pos);
		GoAwayAndDie();
		return true;
	}

	states
	{
		Spawn:
			BPAK A -1;
			Stop;
	}
}

class MoneyFountain : Actor
{
	// Spawns a bunch of random coins over time.
	default
	{
		ReactionTime 15;
	}

	void TossDrop(Name it)
	{
		double rad = 10;
		let drop = Spawn(it,pos);
		drop.vel = (frandom(-rad/2,rad/2), frandom(-rad/2,rad/2), frandom(rad,rad*2));
	}

	states
	{
		Spawn:
			TNT1 A 4
			{
				switch(random(0,4))
				{
					case 0:
						TossDrop("CopperCoin");
						break;
					case 1:
						TossDrop("SilverCoin");
						break;
					case 2:
						TossDrop("SilverCoin");
						TossDrop("SilverCoin");
						break;
					case 3:
						TossDrop("GoldCoin");
						break;
					case 4:
						TossDrop("SilverCoin");
						TossDrop("SilverCoin");
						TossDrop("GoldCoin");
						break;
				}

				A_CountDown();
			}
			loop;
		Death:
			TNT1 A 0;
			Stop;
	}
}