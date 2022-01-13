class LaserGun : Weapon
{
	// The only gun a Paladin of LASER JUSTICE needs.

	default
	{

	}

	states
	{
		Select:
			PISG A 1 A_Raise(35);
			Loop;
		Deselect:
			PISG A 1 A_Lower(35);
			Loop;

		Ready:
			PISG A 1 A_ReadyWeapon();
			Loop;

		Fire:
			PISG BC 2;
			Goto Ready;
	}
}