class AbilityVampire extends RPGAbility;

var config float HealthBonusMax;
var config int HealthBonusAbsoluteCap;

var localized string AbsoluteCapText;

replication
{
	reliable if(Role == ROLE_Authority)
		HealthBonusMax, HealthBonusAbsoluteCap;
}

function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator)
{
	local Pawn HealMe;
	local int Health, HealthBonus;

	if(!bOwnedByInstigator || Injured == Instigator || Instigator == None || DamageType == class'DamTypeRetaliation')
		return;

	Health = int(float(Damage) * BonusPerLevel * float(AbilityLevel));
	if(Health == 0 && Damage > 0)
	{
		Health = 1;
	}
	if (Instigator.Controller != None)
	{
		//now works in vehicle side turrets!
		if(ONSWeaponPawn(Instigator) != None)
			HealMe = ONSWeaponPawn(Instigator).VehicleBase;
		else
			HealMe = Instigator;
	
		if(HealMe != None)
		{
			HealthBonus = HealMe.HealthMax * HealthBonusMax;
			
			if(HealthBonusAbsoluteCap > 0)
				HealthBonus = Min(HealthBonus, HealthBonusAbsoluteCap);

			HealMe.GiveHealth(Health, HealMe.HealthMax + HealthBonus);
		}
	}
}

simulated function string DescriptionText()
{
	local string Text;

	Text = repl(
		repl(Super.DescriptionText(), "$1", class'Util'.static.FormatPercent(BonusPerLevel)),
		"$2", class'Util'.static.FormatPercent(HealthBonusMax));
		
	if(HealthBonusAbsoluteCap > 0)
		Text = repl(Text, "$3", repl(AbsoluteCapText, "$4", HealthBonusAbsoluteCap));
	else
		Text = repl(Text, "$3", "");
		
	return Text;
}

defaultproperties
{
	AbilityName="Vampirism"
	Description="Whenever you damage an opponent, you are healed for $1 of the damage per level (up to your starting health amount + $2$3). You can't gain health from self-damage."
	AbsoluteCapText=" or maximally +$4"
	StartingCost=10
	CostAddPerLevel=5
	MaxLevel=10
	ForbiddenAbilities(0)=(AbilityClass=class'AbilityEnergyLeech',Level=1)
	RequiredAbilities(0)=(AbilityClass=class'AbilityDamageBonus',Level=6)
	BonusPerLevel=0.050000
	HealthBonusMax=0.333333
	HealthBonusAbsoluteCap=0
}
