class UpgradeToken : Ammo
{
	// Upgrade Tokens come in various sizes.

	default
	{
		Inventory.MaxAmount 1000;
	}

	override void Travelled()
	{
		// Take all Upgrade Tokens between maps, and convert them into score.
		owner.A_GiveInventory("ScoreItem",countinv("UpgradeToken")*10);
		owner.A_TakeInventory("UpgradeToken",1000);
	}
}