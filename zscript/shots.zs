class LaserShot : Actor
{
	// A basic laser blast.
	Default
	{
		Species "Laser";
		+THRUSPECIES;
		+BRIGHT;
		Projectile;
		//RenderStyle "Add";
		DamageFunction (8);
		Speed 45;
		Radius 2;
		Height 6;
		DeathSound "weapons/laserx";
	}

	states
	{
		Spawn:
			LAS1 AB 3 
			{
				let ring = Spawn("LaserTrail",pos);
				ring.vel = vel * .5;
			}
			Loop;

		Death:
			//LAS1 AB 3;
			LRNG ABAB 3 A_SetScale(Scale.x * 1.2, Scale.y * 1.2);
			TNT1 A 0;
			Stop;
	}
}

class SmallLaserShot : LaserShot
{
	// A smaller laser blast.
	Default
	{
		DamageFunction (6);
	}

	states
	{
		Spawn:
			LSML AB 3
			{
				let ring = Spawn("SmallLaserTrail",pos);
				ring.vel = vel * .5;
			}
			Loop;
		Death:
			LSML CDCD 3 A_SetScale(Scale.x * 1.2, Scale.y * 1.2);
			TNT1 A 0;
			Stop;
	}
}

class BeamShot : LaserShot
{
	// A big beam shot that comes with four smaller shots behind it.

	int beams;

	Default
	{
		DamageFunction (16);
		+ROLLSPRITE;
	}

	override void Tick()
	{
		Super.Tick();
		if(InStateSequence(curstate, ResolveState("Spawn")))
		{
			roll += 10;
			if(beams < 4)
			{
				Vector3 spawnpos = pos + (vel * -(beams+1));
				let it = Spawn("BeamTrailShot",spawnpos);
				it.target = target;
				it.vel = vel;
				it.roll = -(beams+1)*20;
				beams += 1;
			}
		}
	}

	states
	{
		Spawn:
			LBEM AB 4;
			Loop;

		Death:
			LBEM A 0 { roll = 0; A_SetScale(2,2); }
			LRNG ABAB 3 A_SetScale(Scale.x * 1.2, Scale.y * 1.2);
			TNT1 A 0;
			Stop;
	}

}

class SmallBeamShot : BeamShot
{
	// Literally just a smaller BeamShot.

	states
	{
		Spawn:
			LAS1 AB 4;
			Loop;
	}
}

class BeamTrailShot : LaserShot
{
	// Smaller spinny trail, otherwise identical to the LaserShot.

	Default
	{
		+ROLLSPRITE;
		Scale 0.5;
	}

	override void Tick()
	{
		Super.Tick();
		if(InStateSequence(curstate, ResolveState("Spawn")))
		{
			roll += 10;
		}
	}

	states
	{
		Spawn:
			LBEM AB 4;
			Loop;

		Death:
			LBEM A 0 { roll = 0; A_SetScale(1,1); }
			LRNG ABAB 3 A_SetScale(Scale.x * 1.2, Scale.y * 1.2);
			TNT1 A 0;
			Stop;
	}
}

class BusterLaser : LaserShot
{
	// A laser that explodes repeatedly on impact.
	// Physics can go fuck itself.
	int blasts;

	Default
	{
		Scale 2;
	}

	states
	{
		Spawn:
			LAS1 AAAAABBBBB 1
			{
				A_SetScale(2+sin(GetAge()*35));
				let ring = Spawn("LaserTrail",pos);
				ring.vel = vel * .5;
			}
			Loop;
		Death:
			LSML A 3 
			{ 
				A_Explode(16,128,0,fulldamagedistance:128); blasts += 1; 
				A_StartSound("weapons/busterx");
				for(int i = 0; i < 360; i += 45)
				{
					A_SpawnItemEX("LaserTrail",xvel:16,angle:i);
				}
				A_SetScale(2);
			}
			LAS1 B 1 A_SetScale(3);
			LRNG A 1 A_SetScale(3.5);
			LRNG B 1 A_SetScale(4);
			LRNG A 0 
			{
				if(blasts < 6)
				{
					return ResolveState("Death");
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

class MiniBusterLaser : BusterLaser
{
	// Only one explosion.

	states
	{
		Death:
			LSML A 3 
			{ 
				A_Explode(16,128,0,fulldamagedistance:128); blasts += 1; 
				A_StartSound("weapons/busterx");
				for(int i = 0; i < 360; i += 45)
				{
					A_SpawnItemEX("LaserTrail",xvel:16,angle:i);
				}
				A_SetScale(2);
			}
			LAS1 B 1 A_SetScale(3);
			LRNG A 1 A_SetScale(3.5);
			LRNG B 1 A_SetScale(4);
			LRNG A 0 ;
			TNT1 A 0;
			Stop;
	}
}

class LaserTrail : Actor
{
	// A trail of rings behind a laser shot.
	Default
	{
		+NOINTERACTION;
		+BRIGHT;
		Scale 0.5;
		//RenderStyle "Add";
	}

	states
	{
		Spawn:
			LRNG ABAB 2;
			TNT1 A 0;
			Stop;
	}

}

class SmallLaserTrail : LaserTrail
{
	// Smaller rings.

	states
	{
		Spawn:
			LSML CDCD 2;
			TNT1 A 0;
			Stop;
	}
}