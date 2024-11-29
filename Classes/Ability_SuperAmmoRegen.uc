class Ability_SuperAmmoRegen extends RPGAbility;

var config float RegenInterval;

var MutTitanRPG RPGMut; //to avoid the nasty accessed none's at the end of a match

replication
{
	reliable if(Role == ROLE_Authority)
		RegenInterval;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	RPGMut = class'MutTitanRPG'.static.Instance(Level);
}

function ModifyPawn(Pawn Other)
{
	Super.ModifyPawn(Other);
	SetTimer(RegenInterval, true);
}

function Timer()
{
	local Inventory Inv;
	local Ammunition Ammo;
	local Weapon W;

	if(Instigator == None || Instigator.Health <= 0)
	{
		SetTimer(0.0f, false);
		return;
	}	
	
	// essentially a manual implementation of `SuperMaxOutAmmo`
	for(Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		W = Weapon(Inv);
		if(W != None)
		{
			//W.SuperMaxOutAmmo();
			
			if ( W.bNoAmmoInstances )
			{
				if ( W.AmmoClass[0] != None )
					W.AmmoCharge[0] = 999;
				if ( (W.AmmoClass[1] != None) && (W.AmmoClass[0] != W.AmmoClass[1]) )
					W.AmmoCharge[1] = 999;
			}
		}
		else
		{
			Ammo = Ammunition(Inv);
			
			if(Ammo != None)
			{
				Ammo.AmmoAmount = 999;
			}
		}
	}
}

simulated function string DescriptionText()
{
	return Repl(Super.DescriptionText(), "$1", class'Util'.static.FormatFloat(RegenInterval));
}

defaultproperties
{
	RegenInterval=3.000000
	
	AbilityName="Super Resupply"
	Description="Adds max ammo to each ammo type you own every $1 seconds."
	StartingCost=10
	CostAddPerLevel=0
	MaxLevel=1
	Category=class'AbilityCategory_Weapons'
}
