mixin class DampedSpringWep
{
	// Damped spring offset handling.
	// Does all your offsets for you while you wait.

	// Offset position and velocity.
	Vector3 offpos, offvel, offgoal;

	CVar xint, yint, zint; // X, Y, Z intensity

	double ycap; // how far the sprite is allowed to go on the z axis
	Property jumpcap : ycap;

	override void PostBeginPlay()
	{
		offpos = (0,128,1);
		offvel = (0,0,0);
		offgoal = (0,0,1);
	}
	// Z should default to 1 because it's a scale, not a position.

	// There are three ways to change the position of the weapon onscreen:
	// changing offvel adds velocity without changing position immediately.
	// changing offgoal gives a more permanent point to move toward.
	// changing offpos directly snaps the weapon to that point.

	// The below functions were stolen outright from
	// https://theorangeduck.com/page/spring-roll-call#implicitspringdamper
	// Fucking christ this math is dense.
	action float fast_negexp(float x)
{
    return 1.0 / (1.0 + x + 0.48*x*x + 0.235*x*x*x);
}
	action double, double impl_damp(
    float x, 
    float v, 
    float x_goal, 
    float v_goal, 
    float stiffness, 
    float damping, 
    float dt, 
    float eps = 1e-5f)
{
    float g = x_goal;
    float q = v_goal;
    float s = stiffness;
    float d = damping;
    float c = g + (d*q) / (s + eps);
    float y = d / 2.0f; 
    
    if (abs(s - (d*d) / 4.0f) < eps) // Critically Damped
    {
        float j0 = x - c;
        float j1 = v + j0*y;
        
        float eydt = fast_negexp(y*dt);
        
        x = j0*eydt + dt*j1*eydt + c;
        v = -y*j0*eydt - y*dt*j1*eydt + j1*eydt;
    }
    else if (s - (d*d) / 4.0f > 0.0) // Under Damped
    {
        float w = sqrt(s - (d*d)/4.0f);
        float j = sqrt(((v + y*(x - c))**2) / (w*w + eps) + ((x - c)**2));
        float p = atan((v + (x - c) * y) / (-(x - c)*w + eps));
        
        j = (x - c) > 0.0f ? j : -j;
        
        float eydt = fast_negexp(y*dt);
        
        x = j*eydt*cos(w*dt + p) + c;
        v = -y*j*eydt*cos(w*dt + p) - w*j*eydt*sin(w*dt + p);
    }
    else if (s - (d*d) / 4.0f < 0.0) // Over Damped
    {
        float y0 = (d + sqrt(d*d - 4*s)) / 2.0f;
        float y1 = (d - sqrt(d*d - 4*s)) / 2.0f;
        float j1 = (c*y0 - x*y0 - v) / (y1 - y0);
        float j0 = x - j1 - c;
        
        float ey0dt = fast_negexp(y0*dt);
        float ey1dt = fast_negexp(y1*dt);

        x = j0*ey0dt + j1*ey1dt + c;
        v = -y0*j0*ey0dt - y1*j1*ey1dt;
    }
    return x,v;
}
	action double damp(double x, double v, double xgoal, double vgoal)
	{
		// Takes current position and current velocity and gives
		// a new velocity.
		/*double dt = 1./35.;
		double stiffness = 5.0;
		double damping = 0.001;
		double g = xgoal;
		double q = vgoal;
		v = dt * stiffness * (g - x) + dt * damping * (q - v);
		return v;*/

		[x,v] = impl_damp(x,v,xgoal,vgoal,500.,30,1./35.);
		return v;
	}

	action void A_OffSetGoal(Vector3 new)
	{
		invoker.offgoal = new;
	}

	action void A_OffsetKick(Vector3 vel, bool add = false)
	{
		if(add)
		{
			invoker.offvel += vel;
		}
		else
		{
			invoker.offvel = vel;
		}
	}

	action void A_OffsetVec(Vector3 new)
	{
		invoker.offpos = new;
	}

	action void A_OffsetTick()
	{
		let psp = invoker.owner.player.GetPSprite(PSP_WEAPON);
		let psp2 = invoker.owner.player.GetPSprite(PSP_FLASH);

		let plr = invoker.owner.player;
		let plrvel = (plr.cmd.sidemove,plr.cmd.forwardmove);
		let plryaw = plr.cmd.yaw * (360./65536.);
		if(!(plrvel.x == 0 && plrvel.y == 0))
		{
			plrvel = plrvel.Unit();
		}

		double plrz = invoker.owner.vel.z;


		/*
		double fac = 10.;

		invoker.offvel.x -= plrvel.x;
		invoker.offvel.z += plrvel.y/50;
		invoker.offvel.y += plrz;
		*/

		invoker.offpos.x = invoker.offpos.x + invoker.offvel.x;
		invoker.offpos.y = max(-invoker.ycap, invoker.offpos.y + invoker.offvel.y); // Don't let it go too far upward.
		invoker.offpos.z = invoker.offpos.z + invoker.offvel.z;
		


		invoker.offvel.x = damp(invoker.offpos.x,
			invoker.offvel.x - (plrvel.x*5) + plryaw/2.,
			invoker.offgoal.x,
			0);
		invoker.offvel.y = damp(invoker.offpos.y,
			invoker.offvel.y + plrz/2,
			invoker.offgoal.y,
			0);
		invoker.offvel.z = damp(invoker.offpos.z,
			invoker.offvel.z + plrvel.y/50,
			invoker.offgoal.z,
			0);

		//console.printf("Vel: "..invoker.offvel);

		//console.printf("Offsets: "..invoker.offpos);

		//A_WeaponOffset(invoker.offpos.x,invoker.offpos.y,WOF_INTERPOLATE);
		//A_OverlayScale(1,invoker.offpos.z);
		if(invoker.owner.player.readyweapon == invoker)
		{
			invoker.xint = CVar.GetCVar("sway_intensity_x",players[consoleplayer]);
			invoker.yint = CVar.GetCVar("sway_intensity_y",players[consoleplayer]);
			invoker.zint = CVar.GetCVar("sway_intensity_z",players[consoleplayer]);

			Vector3 finaloffs = (
				invoker.offpos.x * invoker.xint.getFloat(),
				(invoker.offpos.y * invoker.yint.getFloat()) + 32,
				(invoker.offpos.z * invoker.zint.getFloat()) + 1.0
				);
			
			psp.pivot.x = 0.5;
			psp.pivot.y = 1.0;

			psp.x = finaloffs.x;
			psp.y = finaloffs.y;
			psp.scale.x = finaloffs.z;
			psp.scale.y = finaloffs.z;

			psp2.pivot.x = 0.5;
			psp2.pivot.y = 1.0;

			psp2.x = finaloffs.x;
			psp2.y = finaloffs.y;
			psp2.scale.x = finaloffs.z;
			psp2.scale.y = finaloffs.z;
		}
	}

	action void A_DampedRaise(int speed)
	{
		A_OffsetGoal((0,0,0));
		A_Raise(speed);
	}

	action void A_DampedLower(int speed)
	{
		A_OffsetGoal((0,128,0));
		A_Lower(speed);
	}
}