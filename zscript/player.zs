class LaserPaladin : DoomPlayer
{
	// A Paladin of Laser Justice.

	int dodgetimer; // How long until we can dodge again; counts down.
	int iframes; // How long we've been intangible; counts up.
	int maxiframes; // How long we get iframes for when dodging.
	bool invuln; // Are we currently intangible?

	Property iframes : maxiframes;

	default
	{
		LaserPaladin.iframes 10;
	}

	override void Tick()
	{
		Super.Tick();

		int btn = GetPlayerInput(INPUT_BUTTONS);
		int oldbtn = GetPlayerInput(INPUT_OLDBUTTONS);

		if(dodgetimer == 0 && btn & BT_RUN && !(oldbtn & BT_RUN))
		{
			// Just tapped the Run key.
			dodgetimer = 35; //1-second cooldown between dodges.
			iframes = 0;
			invuln = true;
		}

		if(invuln)
		{
			if(iframes < maxiframes)
			{
				bINVULNERABLE = true;
				iframes += 1;
				if(GetAge() % 3 == 0)
				{
					player.readyweapon.A_SetRenderStyle(1,STYLE_Stencil);
				}
				else
				{
					player.readyweapon.RestoreRenderStyle();
				}
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
	}
}