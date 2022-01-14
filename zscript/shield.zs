class ShieldToken : Inventory
{
	// Blocks one hit, mini-bombs, and prevents your combo from dropping.	

	bool blocked; // Have we blocked damage this frame?

	default
	{
		Inventory.MaxAmount 100; // You can't cheese shield tokens nearly as far as your multiplier.
	}

	override void Tick()
	{
		Super.Tick();
		blocked = false;
	}


	override void ModifyDamage(int dmg, Name mod, out int newdmg, bool passive, Actor inf, Actor src, int flags)
	{
		if(passive)
		{

			newdmg = 0;
			if(!blocked)
			{
				if(src) // Ignore damage that doesn't have a source.
				{ 
					if(owner.CountInv("ShieldToken")>5)
					{
						owner.A_StartSound("misc/shieldf");
					}
					else
					{
						owner.A_StartSound("misc/shieldx");
					}
					// Mini-bomb and take some shieldtokens, but only if this is not floor damage.
					let plr = LaserPaladin(owner);
					if(plr) { plr.MiniBomb(); }
					owner.A_TakeInventory("ShieldToken",10); 
					blocked = true;
				}
			}
		}
	}
}

class ShieldTokenGiver : Inventory
{

	default
	{
		+BRIGHT;
	}

	override string PickupMessage()
	{
		return super.PickupMessage().." <"..amount..">";
	}

	override bool TryPickup(in out Actor other)
	{
		// All subclasses of ShieldToken give ShieldTokens.
		other.A_GiveInventory("ShieldToken",amount);
		GoAwayAndDie();
		return true;
	}
}

class ShieldBit : ShieldTokenGiver replaces ArmorBonus
{
	default
	{
		Inventory.Amount 1;
		Inventory.PickupMessage "Shield bit!";
	}

	states
	{
		Spawn:
			BON2 ABCBA 2;
			Loop;
	}
}

class MiniShield : ShieldTokenGiver replaces Radsuit
{
	default
	{
		Inventory.Amount 25;
		Inventory.PickupMessage "Mini Shield!";
	}

	states
	{
		Spawn:
			CELP A -1;
			Stop;
	}
}

class SmallShield : ShieldTokenGiver replaces GreenArmor
{
	default
	{
		Inventory.Amount 50;
		Inventory.PickupMessage "Small shield!";
	}

	states
	{
		Spawn:
			ARM1 AB 6;
			Loop;
	}
}

class BigShield : ShieldTokenGiver replaces BlueArmor
{
	default
	{
		Inventory.Amount 100;
		Inventory.PickupMessage "Big shield!";
	}

	states
	{
		Spawn:
			ARM2 AB 6;
			Loop;
	}
}