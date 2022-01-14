class Multiplier : Inventory
{
	// Exists to multiply score items.

	default
	{
		Inventory.MaxAmount 999; // If you can get this high a multiplier, you're a god.
		Inventory.Amount 1;
	}

	/*
	override bool HandlePickup(Inventory item)
	{
		Console.printf("Handling items!");
		if(item is "ScoreItem")
		{
			int amt = item.amount * owner.CountInv("Multiplier");
			owner.A_GiveInventory("ScoreItem", amt); // Start at x2.
			console.printf("Points <"..amt..">");
			item.bPickupGood = true;

			return true;
		}
		else
		{
			return super.HandlePickup(item);
		}

	}*/

	override void AbsorbDamage(int dmg, Name mod, out int newdmg, Actor inf, Actor src, int flags)
	{
		console.printf("Dmg: "..dmg.." Newdmg: "..newdmg);
		if(dmg != 0)
		{
			console.printf("Multiplier damage check!");
			owner.A_TakeInventory("Multiplier",ceil(owner.CountInv("Multiplier")/2.));
		}
		Super.AbsorbDamage(dmg,mod,newdmg,inf,src,flags);
	}
}

class LaserPaladin : DoomPlayer
{
	// A Paladin of Laser Justice.

	int dodgetimer; // How long until we can dodge again; counts down.
	int iframes; // How long we've been intangible; counts up.
	int maxiframes; // How long we get iframes for when dodging.
	bool invuln; // Are we currently intangible?

	int combometer; // Once it reaches a certain point, you get a Multiplier.

	Property iframes : maxiframes;

	default
	{
		LaserPaladin.iframes 10;
		Player.StartItem "LaserGun";
		Player.StartItem "Multiplier";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		dodgetimer = 1; // Don't dodge on frame zero, silly.
	}


	void DrawInvSparkles()
	{
		int i = 5 + GetAge() % 10; // should do 5, 6, 7, 5, 6, 7
		if(A_Overlay(i,"Sparkle",true)) // Only set the overlay's position on a new frame.
		{
			A_OverlayOffset(i,frandom(-24,24),frandom(-24,-72));
		}
	}

	override void Tick()
	{
		Super.Tick();

		int btn = GetPlayerInput(INPUT_BUTTONS);
		int oldbtn = GetPlayerInput(INPUT_OLDBUTTONS);

		if(dodgetimer == 0 && (btn & BT_SPEED) && !(oldbtn & BT_SPEED))
		{
			// Just tapped the Run key.
			//Console.printf("Dodge!");
			dodgetimer = 35; //1-second cooldown between dodges.
			iframes = 0;
			invuln = true;
			if(vel.length() > 5 || (btn & BT_JUMP))
			{
				vel = vel.Unit() * 24;
			}
		}

		if(invuln)
		{
			if(iframes < maxiframes)
			{
				bINVULNERABLE = true;
				iframes += 1;
				DrawInvSparkles();
			}
			else
			{
				invuln = false;
				iframes = 0;
				bINVULNERABLE = false;
				player.readyweapon.RestoreRenderStyle();
			}
		}

		if(dodgetimer > 0)
		{
			dodgetimer -= 1;
		}

		if(combometer >= 250)
		{
			console.printf("Multiplier Up!");
			A_GiveInventory("Multiplier");
			combometer -= 250;
		}
	}

	states
	{
		Sparkle:
			SPRK ABC 2;
			TNT1 A 0;
			Stop;
	}
}