///changeWeapon(weapon);
var
pres = 0;
delay = 0;
dmg = 0;
maxRange = 0;
useDelay = false;
switch (argument0){
    case 0:
        pres = 0;
        delay = 3;
        dmg = 5;
        maxRange = 500;
        useDelay = false;
    break;
    case 1:
        pres = 1;
        delay = 5;
        dmg = 1;        
        maxRange = 600;
        useDelay = true;
    break;
}


with(obj_player){
    precision = pres;
    shoot_delay = delay;   
    weaponDamage = dmg;
    automaticFire = useDelay;
    weaponRange = maxRange;
}
