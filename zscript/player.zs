class Multiplier : Inventory
{
	// Exists to multiply score items.

	int mercytimer;

	default
	{
		Inventory.MaxAmount 999; // If you can get this high a multiplier, you're a god.
		Inventory.Amount 1;
		+Inventory.KEEPDEPLETED;
	}

	override void DoEffect()
	{
		mercytimer = max(mercytimer-1,0);
	}

	override void AbsorbDamage(int dmg, Name mod, out int newdmg, Actor inf, Actor src, int flags)
	{
		if(dmg != 0 && mercytimer == 0)
		{
			owner.A_TakeInventory("Multiplier",ceil(owner.CountInv("Multiplier")/2.));
			owner.score = floor(owner.score/2.);
			mercytimer = 35;
		}
		Super.AbsorbDamage(dmg,mod,newdmg,inf,src,flags);
	}
}

class Bomb : Inventory
{
	// Blow up your foes for great justice.
	default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 5;
	}
}

class LaserPaladin : DoomPlayer
{
	// A Paladin of Laser Justice.

	int dodgetimer; // How long until we can dodge again; counts down.
	int iframes; // How long we've been intangible; counts up.
	bool bombed; // Have we triggered a parry bomb yet?
	int maxiframes; // How long we get iframes for when dodging.
	bool invuln; // Are we currently intangible?

	int combometer; // Once it reaches a certain point, you get a Multiplier.

	Property iframes : maxiframes;

	int bombtimer; // For real bombs.

	default
	{
		LaserPaladin.iframes 10;
		Player.StartItem "LaserGun";
		Player.StartItem "Multiplier";
		+BUDDHA;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		dodgetimer = 1; // Don't dodge on frame zero, silly.
	}

	void UseBomb(int radius, bool wipe = false)
	{
		A_Explode(32,radius,flags:XF_NOTMISSILE);
		ThinkerIterator bomb = ThinkerIterator.Create("Actor");
		Actor mo;
		while(mo = Actor(bomb.Next()))
		{
			double dist = Vec3To(mo).Length();
			if(mo.bMISSILE)
			{
				if(wipe)
				{
					mo.SetState(mo.ResolveState("Death"));
					mo.bMISSILE = false;
					mo.vel = (0,0,0);
				}
				else if(dist < radius)
				{
					mo.target = self;
					mo.vel = Vec3To(mo).Unit() * mo.vel.Length();
				}
				continue;
			}

			if(mo is "LaserPaladin" || !(mo.bSHOOTABLE))
			{
				continue;
			}

			if(Vec3To(mo).Length() <= radius)
			{
				double scalar = 0.5 + (radius - dist)/radius;
				mo.bSKULLFLY = true;
				mo.vel = Vec3To(mo).Unit() * (1024 * scalar) / float(mo.mass);
				mo.vel.z += 12 * scalar;
			}
		}

		if(wipe) { Spawn("BombBurst",pos); }
	}

	void DrawInvSparkles()
	{
		int i = 5 + GetAge() % 10; // should do 5, 6, 7, 5, 6, 7
		if(A_Overlay(i,"Sparkle",true)) // Only set the overlay's position on a new frame.
		{
			A_OverlayOffset(i,frandom(-24,24),frandom(-24,-72));
		}
	}

	override int DamageMobj(Actor inf, Actor src, int dmg, Name mod, int flags, double ang)
	{
		if(invuln)
		{
			if(iframes < 3 && !bombed)
			{
				A_StartSound("weapons/mbombf");
				UseBomb(512);
				bombed = true;
			}
			return 0;
		}
		else
		{
			return super.DamageMobj(inf,src,dmg,mod,flags,ang);
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

		if(combometer >= 250 - health)
		{
			console.printf("Multiplier Up!");
			A_GiveInventory("Multiplier");
			if(CountInv("Multiplier")%5 == 0)
			{
				A_GiveInventory("Bomb");
			}
			combometer -= (250 - health);
		}

		bombtimer = max(bombtimer-1, 0);
		if(bombtimer == 0 && btn & BT_ALTATTACK)
		{
			UseBomb(1024,true);
			bombtimer = 20;
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

class BombBurst : Actor
{
	int blasts;
	// Remains for a bit, cleaning up projectiles in an area.
	override void Tick()
	{
		super.tick();
		blasts += 1;

		// Visuals.
		if(GetAge()%5 == 0)
		{
			for(int i = 0; i < 4; i++)
			{
				for(int j = 0; j < 360; j += 45)
				{
					A_SpawnItemEX("BombSparkle",128*(i+1),xvel:frandom(-2,2),yvel:frandom(-2,2),zvel:2,angle:j+(15*i));
				}
			}
		}

		ThinkerIterator bomb = ThinkerIterator.Create("Actor");
		Actor mo;
		while(mo = Actor(bomb.Next()))
		{
			if(Vec3To(mo).Length()<=512)
			{
				if(mo.bMISSILE && mo.species != "Laser")
				{
					mo.SetState(mo.ResolveState("Death"));
					mo.vel = (0, 0, 0);
					mo.bMISSILE = false;
				}

				if(!(mo is "LaserPaladin") && mo.bISMONSTER && !mo.bCORPSE && !(mo.InStateSequence(mo.curstate,mo.ResolveState("Pain"))))
				{
					mo.SetState(mo.ResolveState("Pain"));
				}
			}
		}
	}

	states
	{
		Spawn:
			LSML A 3 A_SetScale(2); 
			LAS1 B 1 A_SetScale(3);
			LRNG A 1 A_SetScale(3.5);
			LRNG B 1 A_SetScale(4);
			LRNG A 0 
			{
				if(blasts < 70)
				{
					return ResolveState("Spawn");
				}
				else
				{
					return ResolveState("null");
				}
			}
			TNT1 A 0;
			Stop;
	}
}

class BombSparkle : Actor
{
	// Sparkly.

	default
	{
		+NOINTERACTION;
		+BRIGHT;
	}

	states
	{
		Spawn:
			SPK2 ABCDABCD 4;
			Stop;
	}
}