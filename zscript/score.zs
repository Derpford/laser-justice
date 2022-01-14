class MultiScore : ScoreItem
{
	ThinkerIterator pfind;
	default
	{
		+BRIGHT;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		pfind = ThinkerIterator.Create("LaserPaladin");
	}

	override void Tick()
	{
		Super.Tick();
		Actor plr;
		plr = Actor(pfind.next());
		while(plr)
		{
			if(Vec3To(plr).Length() < 128)
			{
				//VelIntercept(plr,12);
				vel = Vec3To(plr).Unit() * 12;
			}
			plr = Actor(pfind.next());
		}
	}

	// A multiplier-aware ScoreItem.
	override bool TryPickup(in out Actor toucher)
	{
		let mult = max(toucher.CountInv("Multiplier"),1);
		amount = amount * mult;
		return super.TryPickup(toucher);
	}
}

class CopperCoin : MultiScore
{
	// Small coin. 5 points.

	default
	{
		Inventory.Amount 5;
		Scale 0.4;
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
		Inventory.Amount 10;
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
		Inventory.Amount 25;
	}

	states
	{
		Spawn:
			SCRG ABCDEFGH 2;
			Loop;
	}
}