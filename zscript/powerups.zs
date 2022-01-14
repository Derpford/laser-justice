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
	}
	// Gives 200 health and max shield.
	override bool TryPickup(in out actor toucher)
	{
		toucher.A_GiveInventory("HealthBonus",200);
		toucher.A_GiveInventory("BigShield");
		GoAwayAndDie();
		return true;
	}

	states
	{
		Spawn:
			MEGA ABCD 5;
	}
}