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

class PerfectDodge : PowerupGiver
{
	// A way to get a screen flash.
	default
	{
		Powerup.Type "PowerTimeFreezer";
		Inventory.Amount 0;
		+Inventory.AUTOACTIVATE;
		Powerup.Duration 10;
		Powerup.ColorMap 0.4,0.4,1.0;
	}
}

class LaserPaladin : DoomPlayer
{
	// A Paladin of Laser Justice.
	const pullRadius = 128; //sphere radius within which coins are pulled.
	int dodgetimer; // How long until we can dodge again; counts down.
	int iframes; // How long we've been intangible; counts up.
	bool bombed; // Have we triggered a parry bomb yet?
	int maxiframes; // How long we get iframes for when dodging.
	bool invuln; // Are we currently intangible?

	int combometer; // Once it reaches a certain point, you get a Multiplier.

	Property iframes : maxiframes;

	int bombtimer; // For real bombs.

	int scoretotal; // Stores the total score across all maps.
	int scorelast; // How much did we score in the last map? Used in the stat screen.
	
	//transient BlockMapIterator roughCoinPuller;

	default
	{
		LaserPaladin.iframes 10;
		Player.StartItem "LaserGun";
		Player.StartItem "Multiplier";
		Player.StartItem "Bomb";
		+BUDDHA;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		dodgetimer = 1; // Don't dodge on frame zero, silly.
	}

	void UseBomb(int radius, bool wipe = false)
	{
		if(wipe) { A_StartSound("weapons/bombf",555); }
		A_Explode(32,radius,flags:XF_NOTMISSILE,fulldamagedistance:radius);
		ThinkerIterator bomb = ThinkerIterator.Create("Actor");
		Actor mo;
		while(mo = Actor(bomb.Next()))
		{
			double dist = Vec3To(mo).Length();
			if(mo.IsZeroDamage()) { continue; } // Rampancy compat
			if(mo.bMISSILE && mo.target != self && dist < radius) 
			{
				if(wipe)
				{
					mo.SetState(mo.ResolveState("Death"));
					if(CountInv("UpgradeToken") < 1000)
					{
						mo.Spawn("UpgradeTokenRandom",mo.pos);
					}
					else
					{
						mo.Spawn("HealthBonus",mo.pos);
					}
					mo.bMISSILE = false;
					mo.vel = (0,0,0);
				}
				else
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

		if(wipe)
		{ 
			let burst = Spawn("BombBurst",pos); 
			burst.target = self;
		}
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
				ComboUp();
				A_StartSound("weapons/bombf");
				A_GiveInventory("PerfectDodge");
				UseBomb(512,true);
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
			if(vel.length() > 5)
			{
				vel = vel.Unit() * 24;
			}
			if(btn & BT_JUMP)
			{
				vel.z += 15;
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
			ComboUp();
			combometer -= (250 - health);
		}

		bombtimer = max(bombtimer-1, 0);
		if(CountInv("Bomb") > 0 && bombtimer == 0 && btn & BT_ALTATTACK)
		{
			UseBomb(1024,true);
			A_TakeInventory("Bomb",1);
			bombtimer = 20;
		}
		//refactor the coin pull code.
		// see https://forum.zdoom.org/viewtopic.php?f=122&t=69168#p1157830 for details
		ThinkerIterator CoinFinder = ThinkerIterator.Create("MultiScore");
		Actor mo;
		while (mo = MultiScore(CoinFinder.Next()))
		{
			//carve out our sphere.
			if (Vec3To(mo).Length()>=pullRadius)
			{
				continue; // out of range
			}
			mo.vel = Vec3To(mo).Unit() * -12;
		}
		
	}

	void ComboUp()
	{
		console.printf("Multiplier Up!");
		A_GiveInventory("Multiplier");
		if(CountInv("Multiplier")%5 == 0)
		{
			A_GiveInventory("Bomb");
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
		double radius = 512;
		A_Explode(1,radius,flags:0,fulldamagedistance:radius);
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
			if(mo.IsZeroDamage()) { continue; } // Rampancy compat
			if(Vec3To(mo).Length()<=512)
			{
				if(mo.bMISSILE && mo.species != "Laser")
				{
					mo.SetState(mo.ResolveState("Death"));
					mo.vel = (0, 0, 0);
					mo.bMISSILE = false;
					if(target.CountInv("UpgradeToken") < 1000)
					{
						mo.Spawn("UpgradeTokenRandom",mo.pos);
					}
					else
					{
						mo.Spawn("HealthBonus",mo.pos);
					}
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