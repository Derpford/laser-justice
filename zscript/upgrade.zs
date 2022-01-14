class UpgradeToken : Ammo
{
	// Upgrade Tokens come in various sizes.

	default
	{
		Inventory.MaxAmount 9999;
		Inventory.PickupMessage "Upgrade Token";
		+BRIGHT;
	}

	override string PickupMessage()
	{
		return super.PickupMessage().." ["..amount.."]";
	}

	override void Travelled()
	{
		// Take all Upgrade Tokens between maps, and convert them into score.
		owner.A_GiveInventory("ScoreItem",countinv("UpgradeToken")*10);
		owner.A_TakeInventory("UpgradeToken",99999);
	}
}

class ClipUpgradeToken : UpgradeToken replaces Clip
{
	default
	{
		Inventory.Amount 1;
	}

	states
	{
		Spawn:
			GEM1 A -1;
			Loop;
	}
}

class ShellUpgradeToken : UpgradeToken replaces Shell
{
	
	default
	{
		Inventory.Amount 2;
	}

	states
	{
		Spawn:
			GEM1 B -1;
			Loop;
	}
}

class RocketUpgradeToken : UpgradeToken replaces RocketAmmo
{
	default
	{
		Inventory.Amount 3;
	}

	states
	{
		Spawn:
			GEM1 C -1;
			Loop;
	}
}

class CellUpgradeToken : UpgradeToken replaces Cell
{
	default
	{
		Inventory.Amount 5;
	}

	states
	{
		Spawn:
			GEM1 D -1;
			Loop;
	}
}

class ClipBoxUpgradeToken : UpgradeToken replaces ClipBox
{
	default
	{
		Inventory.Amount 10;
	}

	states
	{
		Spawn:
			GEM2 A -1;
			Loop;
	}
}

class ShellBoxUpgradeToken : UpgradeToken replaces ShellBox
{
	default
	{
		Inventory.Amount 20;
	}

	states
	{
		Spawn:
			GEM2 B -1;
			Loop;
	}
}

class RocketBoxUpgradeToken : UpgradeToken replaces RocketBox
{
	default
	{
		Inventory.Amount 30;
	}

	states
	{
		Spawn:
			GEM2 C -1;
			Loop;
	}
}

class CellPackUpgradeToken : UpgradeToken replaces CellPack
{
	default
	{
		Inventory.Amount 50;
	}

	states
	{
		Spawn:
			GEM2 D -1;
			Loop;
	}
}

class WeaponUpgradeToken : UpgradeToken
{
	default
	{
		Inventory.Amount 100;
	}

	states
	{
		Spawn:
			GEM3 ABCDE 2;
			Loop;
	}
}