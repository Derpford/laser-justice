class MultiScore : ScoreItem
{
	//ThinkerIterator pfind;
	default
	{
		+BRIGHT;
	}

/*
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		//pfind = ThinkerIterator.Create("LaserPaladin"); //this is ineffective. It stores the playerlist for every type of entity.
	}

	override void Tick()
	{
		Super.Tick();
		Actor plr;
		plr = Actor(pfind.next());
		//TODO: invert this interaction, that is check if we have any MultiScore things in player's proximity.
		while(plr)
		{
			if(Vec3To(plr).Length() < 128) //128u sphere around player
			{
				//VelIntercept(plr,12);
				vel = Vec3To(plr).Unit() * 12; // move 12u per seconds toward player.
			}
			plr = Actor(pfind.next());
		} 
	}
	
	*/
	

	// A multiplier-aware ScoreItem.
	override bool TryPickup(in out Actor toucher)
	{
		let mult = max(toucher.CountInv("Multiplier"),1);
		amount = amount * mult;

		let plr = LaserPaladin(toucher);
		if(plr) { plr.combometer += 1; }

		return super.TryPickup(toucher);
	}
}

class CopperCoin : MultiScore
{
	// Small coin. 1 point.

	default
	{
		Inventory.Amount 1;
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
	// Medium coin. 2 points.

	default
	{
		Inventory.Amount 2;
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
	// Big coin. 3 points.

	default
	{
		Inventory.Amount 3;
	}

	states
	{
		Spawn:
			SCRG ABCDEFGH 2;
			Loop;
	}
}