class LaserStatusScreen : DoomStatusScreen
{
	int cnt_score;
	int cnt_total;
	int plrscore;
	int plrtotal;

	override void initStats ()
	{
		intermissioncounter = gameinfo.intermissioncounter;
		let plr = LaserPaladin(players[me].mo);
		if(plr)
		{
			plrscore = plr.scorelast;
			plrtotal = plr.scoretotal;
		}
		CurState = StatCount;
		acceleratestage = 0;
		sp_state = 1;
		cnt_kills[0] = cnt_items[0] = cnt_secret[0] = -1;
		cnt_score = 0;
		cnt_total = 0;
		cnt_time = cnt_par = -1;
		cnt_pause = GameTicRate;
	
		cnt_total_time = -1;
	}

	override void updateStats ()
	{
		if (acceleratestage && sp_state != 10)
		{
			acceleratestage = 0;
			sp_state = 10;
			PlaySound("intermission/nextstage");

			cnt_kills[0] = Plrs[me].skills;
			cnt_items[0] = Plrs[me].sitems;
			cnt_secret[0] = Plrs[me].ssecret;

			cnt_score = plrscore;
			cnt_total = plrtotal;

			cnt_time = Thinker.Tics2Seconds(Plrs[me].stime);
			cnt_par = wbs.partime / GameTicRate;
			cnt_total_time = Thinker.Tics2Seconds(wbs.totaltime);
		}

		if (sp_state == 2)
		{
			if (intermissioncounter)
			{
				cnt_kills[0] += max(1,Plrs[me].skills/10);
				cnt_score += max(100, plrscore/10);

				if (!(bcnt&3))
					PlaySound("intermission/tick");
			}
			if (!intermissioncounter || cnt_score > plrscore)
			{
				cnt_kills[0] = Plrs[me].skills;
				cnt_score = plrscore;
				PlaySound("intermission/nextstage");
				sp_state++;
			}
		}
		else if (sp_state == 4)
		{
			if (intermissioncounter)
			{
				cnt_items[0] = max(Plrs[me].sitems, cnt_items[0]+1+(Plrs[me].sitems/10));
				cnt_total += max(100, plrtotal/10);

				if (!(bcnt&3))
					PlaySound("intermission/tick");
			}
			if (!intermissioncounter || cnt_total >= plrtotal)
			{
				cnt_items[0] = Plrs[me].sitems;
				cnt_total = plrtotal;
				PlaySound("intermission/nextstage");
				sp_state++;
			}
		}
		else if (sp_state == 6)
		{
			if (intermissioncounter)
			{
				cnt_secret[0] += 2;

				if (!(bcnt&3))
					PlaySound("intermission/tick");
			}
			if (!intermissioncounter || cnt_secret[0] >= Plrs[me].ssecret)
			{
				cnt_secret[0] = Plrs[me].ssecret;
				PlaySound("intermission/nextstage");
				sp_state++;
			}
		}
		else if (sp_state == 8)
		{
			if (intermissioncounter)
			{
				if (!(bcnt&3))
					PlaySound("intermission/tick");

				cnt_time += 3;
				cnt_par += 3;
				cnt_total_time += 3;
			}

			int sec = Thinker.Tics2Seconds(Plrs[me].stime);
			if (!intermissioncounter || cnt_time >= sec)
				cnt_time = sec;

			int tsec = Thinker.Tics2Seconds(wbs.totaltime);
			if (!intermissioncounter || cnt_total_time >= tsec)
				cnt_total_time = tsec;

			int psec = wbs.partime / GameTicRate;
			if (!intermissioncounter || cnt_par >= psec)
			{
				cnt_par = psec;

				if (cnt_time >= sec)
				{
					cnt_total_time = tsec;
					PlaySound("intermission/nextstage");
					sp_state++;
				}
			}
		}
		else if (sp_state == 10)
		{
			if (acceleratestage)
			{
				PlaySound("intermission/paststats");
				initShowNextLoc();
			}
		}
		else if (sp_state & 1)
		{
			if (!--cnt_pause)
			{
				sp_state++;
				cnt_pause = GameTicRate;
			}
		}
	}

	override void drawStats (void)
	{
		// line height
		int lh = IntermissionFont.GetHeight() * 3 / 2;

		drawLF();
		
		let tcolor = content.mColor;

		Font printFont;
		Font textFont = generic_ui? NewSmallFont : content.mFont;
		int statsx = SP_STATSX;

		int timey = SP_TIMEY;
		if (wi_showtotaltime)
			timey = min(SP_TIMEY, 200 - 2 * lh);

		{
			// Check if everything fits on the screen.
			String percentage = wi_percents? " 0000%" : " 0000/0000";
			int perc_width = textFont.StringWidth(percentage);
			int k_width = textFont.StringWidth("SCORE: ");
			int i_width = textFont.StringWidth("TOTAL: ");
			int s_width = textFont.StringWidth("$TXT_IMSECRETS");
			int allwidth = max(k_width, i_width, s_width) + perc_width;
			if ((SP_STATSX*2 + allwidth) > 320)	// The content does not fit so adjust the position a bit.
			{
				statsx = max(0, (320 - allwidth) / 2);
			}

			printFont = generic_ui? IntermissionFont : content.mFont;
			DrawText (textFont, tcolor, statsx, SP_STATSY, "TOTAL: ");
			DrawText (textFont, tcolor, statsx, SP_STATSY+lh, "SCORE: ");
			DrawText (textFont, tcolor, statsx, SP_STATSY+2*lh, "$TXT_IMSECRETS");
			DrawText (textFont, tcolor, SP_TIMEX, timey, "$TXT_IMTIME");
			if (wbs.partime) DrawText (textFont, tcolor, 160 + SP_TIMEX, timey, "$TXT_IMPAR");
		}
			 
		//drawPercent (printFont, 320 - statsx, SP_STATSY, cnt_kills[0], wbs.maxkills, true, tcolor);
		drawNum(printFont, 320 - statsx , SP_STATSY, cnt_score,10,true,tcolor);
		//drawPercent (printFont, 320 - statsx, SP_STATSY+lh, cnt_items[0], wbs.maxitems, true, tcolor);
		drawNum(printFont, 320 - statsx , SP_STATSY+lh, cnt_total,10,true,tcolor);
		drawPercent (printFont, 320 - statsx, SP_STATSY+2*lh, cnt_secret[0], wbs.maxsecret, true, tcolor);
		drawTimeFont (printFont, 160 - SP_TIMEX, timey, cnt_time, tcolor);
			 
		// This really sucks - not just by its message - and should have been removed long ago!
		// To avoid problems here, the "sucks" text only gets printed if the lump is present, this even applies to the text replacement.
			 
		if (cnt_time >= wbs.sucktime * 60 * 60 && wbs.sucktime > 0 && Sucks.IsValid())
		{ // "sucks"
			int x = 160 - SP_TIMEX;
			int y = timey;
			if (TexMan.OkForLocalization(Sucks, "$TXT_IMSUCKS"))
			{
				let size = TexMan.GetScaledSize(Sucks);
				DrawTexture (Sucks, x - size.X, y - size.Y - 2);
			}
			else
			{
				DrawText (textFont, tColor, x  - printFont.StringWidth("$TXT_IMSUCKS"), y - printFont.GetHeight() - 2,	"$TXT_IMSUCKS");
			}
		}

		if (wi_showtotaltime)
		{
			 drawTimeFont (printFont, 160 - SP_TIMEX, timey + lh, cnt_total_time, tcolor);
		}

		if (wbs.partime)
		{
			drawTimeFont (printFont, 320 - SP_TIMEX, timey, cnt_par, tcolor);
		}
	}
}