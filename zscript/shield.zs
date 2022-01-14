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
			if(owner.CountInv("ShieldToken")>5)
			{
				owner.A_StartSound("misc/shieldf");
			}
			else
			{
				owner.A_StartSound("misc/shieldx");
			}
			if(!blocked)
			{
				// Mini-bomb.
				owner.A_Explode(32,256,flags:XF_NOTMISSILE);
				owner.A_RadiusThrust(128,256,RTF_THRUSTZ|RTF_NOTMISSILE);
				owner.A_RadiusThrust(1024,256,RTF_NOTMISSILE); // gross hack for separate XY and Z vels

				owner.A_TakeInventory("ShieldToken",10);
				blocked = true;
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