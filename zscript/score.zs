class CopperCoin : ScoreItem
{
	// Small coin. 5 points.

	default
	{
		Inventory.Amount 5;
		Inventory.PickupMessage "Points";
	}

	override string PickupMessage()
	{
		return super.PickupMessage().." <"..amount..">";
	}

	states
	{
		Spawn:
			SCRC ABCDEFGH 2;
			Loop;
	}
}

class SilverCoin : CopperCoin
{
	// Medium coin. 25 points.

	default
	{
		Inventory.Amount 25;
	}

	states
	{
		Spawn:
			SCRS ABCDEFGH 2;
			Loop;
	}
}

class GoldCoin : SilverCoin
{
	// Big coin. 125 points.

	default
	{
		Inventory.Amount 125;
	}

	states
	{
		Spawn:
			SCRG ABCDEFGH 2;
			Loop;
	}
}