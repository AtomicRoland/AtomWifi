#!/bin/bash

beebasm -i version.asm -v > version.lst
cp VERSION bin

beebasm -i ping.asm -v > ping.lst
cp PING bin

beebasm -i time.asm -v > time.lst
cp TIME bin

beebasm -i date.asm -v > date.lst
cp DATE bin

beebasm -i prd.asm -v > prd.lst
cp PRD bin

beebasm -i ifcfg.asm -v > ifcfg.lst
cp IFCFG bin

beebasm -i join.asm -v > join.lst
cp JOIN bin

beebasm -i leave.asm -v > leave.lst
cp LEAVE bin

beebasm -i wificmd.asm -v > wificmd.lst
cp WIFI bin

beebasm -i mode.asm -v > mode.lst
cp MODE bin

beebasm -i lap.asm -v > lap.lst
cp LAP bin

beebasm -i lapopt.asm -v > lapopt.lst
cp LAPOPT bin

beebasm -i disconnect.asm -v > disconnect.lst
cp DISCON bin
cp DISCON bin/DISCO

beebasm -i wget.asm -v > wget.lst
cp WGET bin

