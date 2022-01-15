class LaserUI : BaseStatusBar
{
	double size; // size of the bars

	int hpval; // health
	double armoramount, armormax; // armor details
	int leftbarf, rightbarf, cbarf, ctextf, ltextf, rtextf,multif;

	Array<String> gunlabels;

	HUDFont mConFont; // Console font.
	HUDFont mBigFont;

	override void Init()
	{
		// Set the size value here.
		size = 128.0;
		mConFont = HUDFont.Create("CONFONT");
		mBigFont = HUDFont.Create("BIGFONT");

		// Set up some common position flags.
		leftbarf = DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM;
		rightbarf = DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM;
		cbarf = DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER_BOTTOM;
		ctextf = DI_SCREEN_CENTER_BOTTOM | DI_ITEM_CENTER_BOTTOM | DI_TEXT_ALIGN_CENTER;
		ltextf = DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM | DI_TEXT_ALIGN_LEFT;
		multif = DI_SCREEN_RIGHT_TOP | DI_ITEM_RIGHT_TOP | DI_TEXT_ALIGN_RIGHT;
		rtextf = DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM | DI_TEXT_ALIGN_RIGHT;

		gunlabels.Push("Laser Beam");
		gunlabels.Push("Dual Laser");
		gunlabels.Push("Long Laser");
		gunlabels.Push("Wide Laser");
		gunlabels.Push("Buster Laser");
		gunlabels.Push("Omega Beam");

	}

	void DrawHudBar(String img, Vector2 pos, double size, double xclip, double yclip, int flags)
	{
		// Draws a bar on the HUD, carefully.
		// Originally in cyberpunkshootout.

		int cx, cy, cw, ch; // save our current cliprect
		[cx,cy,cw,ch] = Screen.GetClipRect();

		Vector2 clipPos;
		int clipFlags;
		[clipPos, clipFlags] = AdjustPosition(pos, flags, size*xclip, size*yclip);
		SetClipRect(clipPos.x, clipPos.y, size*xclip, size*yclip, clipFlags);
		DrawImage(img,pos,flags);

		Screen.SetClipRect(cx,cy,cw,ch);//restore it
	}

	override void Draw(int state, double ticfrac)
	{
		super.draw(state,ticfrac);
		let plr = LaserPaladin(CPlayer.mo);
		// Start by gathering all our numbers.
		hpval = plr.health;
		armoramount = plr.CountInv("ShieldToken");

		let scr = plr.score;

		let multiplier = plr.CountInv("Multiplier");
		let combo = clamp(0, plr.combometer,250.)/250.;
		let combometer = plr.combometer; // placeholder

		let wpn = LaserGun(plr.player.readyweapon);
		let upg = plr.CountInv("UpgradeToken");
		let bombs = plr.CountInv("Bomb");
		let lvl = 0;
		if(wpn)
		{
			lvl = wpn.GetLevel(); 
			if(lvl < 5) { upg = upg % 200; }
		}

		// And now the fun part.
		beginHUD();

		// Left panel, health and armor.
		DrawString(mBigFont, FormatNumber(armoramount,3,format:FNF_FILLZEROS),(44,-16),ltextf, Font.CR_CYAN);
		DrawString(mBigFont, FormatNumber(hpval,3,format:FNF_FILLZEROS),(44,-36),ltextf, Font.CR_BRICK);

		// Top Right panel, multiplier and combo state.
		DrawString(mBigFont, "X"..FormatNumber(multiplier,3),(-44,36),multif,Font.CR_RED);
		DrawString(mConFont, FormatNumber(combometer,3,format:FNF_FILLZEROS),(-44,16),multif,Font.CR_DARKRED);

		// Bottom Right panel, weapon/bomb info.
		DrawString(mBigFont, gunlabels[lvl],(-44,-36),rtextf,Font.CR_GREEN);
		DrawString(mConFont, FormatNumber(upg,3,format:FNF_FILLZEROS),(-44,-16),rtextf,Font.CR_BLUE);

		for(int i = 0; i < bombs; i++)
		{
			DrawImage("ROCKA0",(-144+(18*i),-36),rightbarf);
		}
		//DrawString(mBigFont, FormatNumber(bombs,1),(-128, -36),rtextf, Font.CR_BLUE);

		// Score.
		DrawString(mConFont, FormatNumber(scr,10,format:FNF_FILLZEROS), (0,-32), ctextf, Font.CR_WHITE);
		// Inventory icon.
		if(plr.invsel)
		{
			DrawInventoryIcon(plr.invsel, (-16,-16), rightbarf);
			DrawString(mConFont,FormatNumber(plr.invsel.Amount),(-8,-16), rtextf);
		}

		// Keys.
		String keySprites[6] =
		{
			"STKEYS2",
			"STKEYS0",
			"STKEYS1",
			"STKEYS5",
			"STKEYS3",
			"STKEYS4"
		};

		for(int i = 0; i < 6; i++)
		{
			if(plr.CheckKeys(i+1,false,true)) { DrawImage(keySprites[i],(-40+(16*i),-8),cbarf,scale:(2,2)); }
		}
	}
}