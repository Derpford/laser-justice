
class PlayerHolderSingletonThinker : Thinker
{
	
	transient ThinkerIterator pfind;

	PlayerHolderSingletonThinker Init()
	{
		ChangeStatNum(STAT_INFO); // Change this to STAT_STATIC if persisting between maps is desired.
		pfind = ThinkerIterator.Create("LaserPaladin");
		return self;
	}

	static PlayerHolderSingletonThinker Get()
	{
		ThinkerIterator it = ThinkerIterator.Create("PlayerHolderSingletonThinker",STAT_INFO); // Change this to STAT_STATIC if persisting between maps is desired.
		let p = PlayerHolderSingletonThinker(it.Next());
		if (p == null)
		{
			p = new("PlayerHolderSingletonThinker").Init();
		}
		return p;
	}
}


class MultiScore : ScoreItem
{
	//transient ThinkerIterator pfind;
	default
	{
		+BRIGHT;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		//pfind = ThinkerIterator.Create("LaserPaladin"); //TODO: Account players who can respawn, despawn and die mid-map. Should be map global.
	}

	override void Tick()
	{
		Super.Tick();
		Actor plr;
		plr = Actor(PlayerHolderSingletonThinker.Get().pfind.next());
		while(plr)
		{
			if(Vec3To(plr).Length() < 128)
			{
				//VelIntercept(plr,12);
				vel = Vec3To(plr).Unit() * 12;
			}
			plr = Actor(PlayerHolderSingletonThinker.Get().pfind.next());
		}
	}

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