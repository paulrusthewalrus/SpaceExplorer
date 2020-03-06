unit unTravel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms,
  Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TfrmTravel }

  sectors = class(TImage) //sector class (destinations)
    public
      role    : string; //'shop' or 'normal' or 'mission' or 'fight' or 'portal'
      visited : boolean; //when it is generated visited := false. When visited, true.
      lab     : TLabel; //testing var
      current : boolean; //where is the ship now?
      locked  : boolean; //are you allowed to go the sector?
  end;

  TfrmTravel = class(TForm)
    imgLocked: TImage;
    labEnergytitle: TLabel;
    labEnergy: TLabel;
    shEnergyBack: TShape;
    imgSnatch: TImage;
    imgBack: TImage;
    imgShip: TImage;
    imgSector: TImage;
    imgBackBtn: TImage;
    labBack: TLabel;
    labDescrip: TLabel;
    labWarning: TLabel;
    labMapHelp: TLabel;
    labTest: TLabel;
    labStarMap: TLabel;
    labRole: TLabel;
    backtoshipBACK: TShape;
    shSectorBack: TShape;
    timUpdate: TTimer;
    timWait: TTimer;
    timWARNING: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure SectorMouseLeave(Sender: TObject);
    procedure SectorMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgBackBtnClick(Sender: TObject);
    procedure find;
    procedure timUpdateTimer(Sender: TObject);
    procedure timWaitTimer(Sender: TObject);
    procedure timWARNINGTimer(Sender: TObject);
    procedure update; //update ship location
    procedure SectorClick(Sender: TObject);
    procedure notcurrent; //make the sector NON-CURRENT
    procedure currentS(sector : sectors); //make the sector CURRENT
    procedure energyerror; //when there is not enough energy
    procedure setup(sector : sectors); //setting up for new forms
    procedure unlocksectors; //change available sectors
    procedure checksectors; //check the sectors (see if there ARE any)
    procedure jump;
  private

  public
    //public variables
        created : boolean; //this variable is set FALSE when game form is generated
        current : sectors; //where the ship is currently - frmGame management
        shop    : boolean; //is the shop enabled or not?
        mission : boolean; //is the NEW sector a mission?
        enemy   : boolean; //is the NEW sector an enemy?
        oldx    : integer;
        oldy    : integer; //old loco for the ship
        prevform    : TForm; //previous form
        jumping   : boolean; //is it in jump?
        which     : sectors;
  end;

var
  frmTravel: TfrmTravel;

implementation

uses unGame,unEnemy,unJump; //able to see frmGame - main form

{$R *.lfm}

{ TfrmTravel }

Var grid  : array of sectors; //Dynamic array for the amount of sectors there are on the screen
    available : array of byte; //Available sectors to jump to
    num       : byte; //number of allowed sectors

//CHECK THE SECTORS
procedure TfrmTravel.checksectors;
begin
  //check the current num
  if (num < 4)
     //run unlock sectors again
     then unlocksectors;
end;

//CHANGE AVAILABLE SECTORS
procedure TfrmTravel.unlocksectors;
var i      : byte;
    sector : sectors;
    ran    : byte;
begin
  //set num back down
  num := 0;
  //go through all the sectors
  for i := (componentcount-1) downto 0 do
     if (components[i] is sectors)
        then begin
                //typecast it
                sector := components[i] as sectors;
                //generate a random number
                ran := random(201);
                //chances
                if (ran < 100)
                   then begin
                          //set the picture
                          sector.picture := imgSector.picture;
                          //unlock boolean
                          sector.locked := false;
                          //increment the number of open sectors
                          inc(num);
                        end
                   else begin
                          //check if the sector isn't you
                          if (sector.current = false)
                             then begin
                                      //set locked picture
                                      sector.picture := imgLocked.picture;
                                      //lock the boolean
                                      sector.locked := true;
                                  end
                                  else begin
                                          //set the picture
                                          sector.picture := imgSector.picture;
                                          //unlock boolean
                                          sector.locked := false;
                                       end
                        end;
             end;
  //run check sectors
  //checksectors; can't be inside the same procedure

end;

//BACK BUTTON CLICK
procedure TfrmTravel.imgBackBtnClick(Sender: TObject);
begin
  //hide this form
  frmTravel.hide;
  //bring back game form
  frmGame.show;
  //check if a battle was on
  if (FrmGame.battle)
     then begin
            //turemy.timHP_MOVE.enabled := false;
            //restart the battle
            frmEnemy.timBattle.enabled := true;
            frmEnemy.timHP_MOVE.enabled := true;
            //battle := false;
            //hide the battle form
            frmEnemy.show;
          end;
end;

//NOT ENOUGH ENERGY
procedure TfrmTravel.energyerror;
begin
  //make the labwarning visible and labmaphelp invisible
  labWarning.visible := true;
  labMapHelp.visible := false;
  //turn timWait and timWarning on
  timWarning.enabled := true;
  timWait.enabled := true;
end;

//SETUP THE NEW FORMS AFTER ONCLICK SECTOR
procedure TfrmTravel.setup(sector : sectors);
var new : string;
begin
  //check if battle is true
  if (frmGame.battle)
     //no longer in battle
     then begin
            //set battle to false
            frmGame.battle := false;
            //clear all projectiles
            //frmEnemy.clear := true;
          end;
  frmEnemy.clear := true;
  //find the role of the sector
  new := sector.role;
  case new of
    //is the new sector an enemy?
    'ENEMY'   : begin
                  //save the current game form position
                  oldx := frmGame.left;
                  oldy := frmGame.top;
                  //position the game form a bit further left
                  frmGame.left := 15;
                  frmGame.top := 105;
                  //frmGame.top := (clientheight div 2)-(frmGame.height div 2);
                  //show the enemy form
                  frmEnemy.show;
                  //swap forms around
                  frmTravel.hide;
                  frmGame.show;
                  //change boolean
                  frmGame.battle := true;
                  //setup new fighter
                  frmEnemy.newgame;
                end;
    //is the new sector a mission?
    'MISSION' : begin
                  //show the game form
                  frmGame.show;
                  //position the game form
                  frmGame.left := 283;
                  frmGame.top := 114;
                  //hide the current form
                  frmTravel.hide;
                  //show the message
                  showmessage('Missions to come in Version 2!');
                end;
    else begin
           //show the game form
           frmGame.show;
           //position the game form
           frmGame.left := 283;
           frmGame.top := 114;
           //hide the current form
           frmTravel.hide;
         end;
   end;

  //change the frmGame background to something new and different
  //NOT ENOUGH MEMORY
  //frmGame.imgBackground.picture;

end;

//TURN CURRENT INTO NON CURRENT
procedure TfrmTravel.notcurrent;
var sector : sectors;
    i      : byte;
begin
   //do a search for all
   for i := (componentcount-1) downto 0 do
      //check if it's a sector
      if (components[i] is sectors)
         then begin
                 //typecast it
                 sector := components[i] as sectors;
                 //check if it's current
                 if (sector.current)
                    then begin
                            //make it non current
                            sector.current := false;
                            //change the image

                            //visited
                            sector.visited := true;

                            //assign it it's old role
                            //sector.role := sector.oldrole;
                         end;
              end;
end;

//TURN NON CURRENT INTO CURRENT
procedure TfrmTravel.currentS(sector : sectors);
begin
   //set current to true
   sector.current := true;
   //move the ship to said new location
   update;
end;

//FORM CREATE
procedure TfrmTravel.FormCreate(Sender: TObject);
var T,L                  : byte;
    sector               : sectors;
    topoffput,leftoffput : integer;
    tran,roleran         : byte;
    lab                  : TLabel;

begin
  randomize;
  //setup left and top
  frmTravel.left := frmGame.left;
  frmTravel.top := frmGame.top;
  //copy the caption from frmGame
  frmTravel.caption := frmGame.caption;
  //set the length of the grid
  setlength(grid,0);
  //labRole.caption := inttostr(length(grid));
  //set up with the exact same dimensions as game form
  with frmTravel do
    begin
      //left := frmGame.left;
      //top := frmGame.top;
      height := 572;
      Width := 820;
    end;

  //check if there is a current active space grid
  if (not created)
     //create a space grid
     then begin
            //use a for loop to spontaneously create a random amt. of "sectors"
            for T := 8 to 10 do
               for L := 6 to 12 do
                  begin
                    //create a new sector with said top and left
                    sector := sectors.create(self);
                    sector.parent := frmTravel;
                    sector.stretch := true;
                    sector.picture := imgSector.picture;
                    sector.tag := (length(grid)+1);
                    //dimension the sector up properly
                    sector.height := 30;
                    sector.width := 30;
                    //positioning offputs
                    topoffput := -360;
                    leftoffput := -525;
                    //top random selection
                    case T of
                     10: tran := random(41)+40;
                     8: tran := random(41)-40;
                     else tran := random(41);
                    end;
                    //position it
                    //sector.top := (T*clientheight) + topoffput + (T*sector.height) + tran;
                    sector.left := (L*trunc(clientwidth/8)) + leftoffput + (random(61)-30);
                    sector.top := (T*trunc(clientheight/10)) + topoffput + tran + sector.height;
                    //sector.left := 50;
                    //sector.top := 50 + random(50);
                    //visited false
                    sector.visited := false;
                    //visible := true;
                    //teach it some events
                    sector.onMouseMove := @SectorMouseMove;
                    sector.onMouseLeave := @SectorMouseLeave;
                    sector.onClick := @SectorClick;
                    //assign a place for the player to spawn in
                    if ((T = 8) and (L = 6))
                       then begin
                               //current sector is true
                               sector.current := true;
                            end
                       else sector.current := false;
                    //randomly give it a role from shop,normal,enemy,mission
                    roleran := random(100);
                    //35% chance for an enemy
                    if (roleran > 45)
                       then sector.role := 'ENEMY'
                       //35% chance for a normal
                       else if (roleran > 30)
                          then sector.role := 'NORMAL'
                          else if (roleran > 15)
                             //15% chance for SHOP and a MISSION
                             then sector.role := 'SHOP'
                             else sector.role := 'MISSION';

                    //add it to the array of sectors
                    setlength(grid,length(grid)+1);
                    grid[length(grid)-1] := sector;

                    //lock sectors
                    unlocksectors;
                    //check sectors
                    checksectors;
              end;

            //set created to true
            frmTravel.created := true;
          end;

  //update the ship location
  update;
  //find available locations
  //find;
  //record component amt.
  //labRole.caption := inttostr(componentcount);
end;

//UPDATE SHIP LOCATION
procedure TfrmTravel.update;
var i      : byte;
    sector : sectors;
begin
   //iterate through the components looking for current = true
   for i := (componentcount-1) downto 0 do
      if (components[i] is sectors)
         then begin
                 //typecast it
                 sector := components[i] as sectors;
                 //labRole.caption := 'hey';
                 //check if it's current
                 if (sector.current)
                    //change the image to a ship
                    then begin
                           //move the ship
                           imgShip.Left := sector.left-8;
                           imgShip.top := sector.top-8;
                           imgShip.width := sector.width+10;
                           imgShip.height := sector.height+10;
                           imgShip.visible := true;
                         end
              end;
   //labrole.caption := inttostr(componentcount);
end;

//WHEN MOUSE HOVERS OFF THE SECTOR
procedure TfrmTravel.SectorMouseLeave(Sender: TObject);
var sector : sectors;
begin
   //clear lab descrip
   labDescrip.caption := '';
   //set back normal size
   sector := Sender as sectors;
   sector.height := 30;
   sector.width := 30;

end;

//WHEN MOUSE HOVERS OVER THE SECTOR
procedure TfrmTravel.SectorMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var sector : sectors;
    i      : byte;
begin
  //typecast it
  sector := Sender as sectors;
  //position the label
  labDescrip.left := sector.left;
  labDescrip.Top := sector.top+sector.height;
  //check if it is current
  if (sector.current)
     //caption it
     then labDescrip.caption := 'You'
     else begin
            //it IS NOT the current sector
            //check if it's locked
            if (sector.locked)
               //update the caption
               then labDescrip.caption := 'Locked'
               else labDescrip.caption := sector.role;
            //labDescrip.caption := sector.role;
            //showmessage(sector.role);
            //enlarge it
            sector.height := 35;
            sector.width := 35;
          end;

end;

//START THE JUMP
procedure TfrmTravel.jump;
begin
  //change the boolean
  jumping := true;
  //display the jump form
  frmJumping.show;
  //hide the travel form
  frmTravel.hide;

end;

//SECTOR CLICKED
procedure TfrmTravel.SectorClick(Sender: TObject);
var sector : sectors;
    new    : string;
begin
   //typecast it
   sector := Sender as sectors;
   //check if it's locked
   if (sector.locked = false)
      //it's not, go ahead
      then begin
             //update the new string with sector role
             new := sector.role;
             //do a shop check
             if (new = 'SHOP')
                then begin
                        //enable the shop button
                        shop := true;
                        //set colours
                        frmGame.shShopRecBack.brush.color := clWhite;
                        frmGame.shShopBack.brush.color := clWhite
                     end
                     else begin
                             //disable button
                             shop := false;
                             //set colours
                             frmGame.shShopRecBack.brush.color := clWindowFrame;
                             frmGame.shShopBack.brush.color := clWindowFrame
                          end;

             if (not sector.current)
                then begin
                       //check if there is enough energy
                       if (frmGame.energy > 50)
                          then begin
                                 //change energy
                                 if ((frmGame.energy - 50) >= 0)
                                    then frmGame.energy := frmGame.energy-50;
                                 //not current procedure
                                 notcurrent;
                                 //set this place as the new sector current
                                 currentS(sector);
                                 //show the game form
                                 //frmGame.show;
                                 //hide this form
                                 //frmTravel.hide;
                                 //START THE JUMP
                                 which := sector;
                                 //setup the pb
                                 frmJumping.pbLoading.position := 0;
                                 frmJumping.pos := 0;
                                 //enable timer on jumping
                                 frmJumping.timWait.enabled := true;
                                 //load the jumping screen
                                 jump;
                                 //SET UP THE NEW FORMS
                                 //setup(sector);
                               end
                               //show a nOT ENOUGH ENERGY message
                               else energyerror;
                     end;
             //run a new set of sectors and check that it's all dandy
             unlocksectors;
             checksectors;
             end;

end;

//FIND AVAILABLE SECTORS
procedure TfrmTravel.find;
var radius,i,k  : byte;
    shipL,shipT : byte;
    destL,destT : byte;
    sector      : sectors;
    dis         : real;
    decide,begun: boolean;
begin
  //clear the current available places
  setlength(available,0);
  //setup a starting radius and set begun to false
  radius := 1;
  i := 0;
  //find the ship left and top
  shipL := imgShip.left;
  shipT := imgShip.top;
  //for i := (componentcount-1) downto 0 do
  while (length(available) <> 3) do
    begin
       if (components[i] is sectors)
           then begin
                   //typecast it
                   sector := components[i] as sectors;
                   //setup vars
                   decide := true;
                   k := 0;
                   //check if there is at least ONE element in there
                   if (length(available) > 0)
                      //check if it's already in the array
                      then while ((k < 4) and (decide)) do
                              begin
                               if (sector.tag = available[k])
                                  then decide := false
                                  else inc(k)
                              end;
                   //check if it's NOT the current sector
                   if ((not sector.current) and (decide))
                      then begin
                             //grab the location
                             destL := sector.left;
                             destT := sector.top;
                             //calc. distance
                             //dis := sqrt((destT-shipT)*(destT-shipT)+(destL-shipL)*(destL-shipL));
                             //check if it's in the radius
                             labTest.caption := 'Destination: ' + inttostr(destT) +' ' +inttostr(destL) + ' Current: '+inttostr(shipL) + ' '+inttostr(shipT);
                             if ((destT < shipT + radius) and (destL < shipL + radius))
                                then begin
                                        //adjust length of available array
                                        setlength(available,length(available)+1);
                                        //add the sector to the array
                                        available[length(available)-1] := sector.tag;
                                        labTest.caption := labTest.caption + inttostr(sector.tag) + ' ';
                                     end
                           end
                end;

       //check how many sectors available
       if (length(available) <> 3)
          //increase i
          then begin
                 if (i+1 < componentcount)
                    then inc(i)
               end
end;
end;

//UPDATE ENERGY
procedure TfrmTravel.timUpdateTimer(Sender: TObject);
var energy : byte;
begin
  //get energy
  energy := frmGame.energy;
  //check where it is
  if (energy < 50)
     then labEnergy.Font.Color := clRed
     else if (energy < 75)
        then labEnergy.font.color := clYellow
        else labEnergy.font.color := clLime;
  //update the energy level
  labEnergy.caption := inttostr(energy) + '%';
end;

//TIM FOR CONTROLLING WARNING TIMER
procedure TfrmTravel.timWaitTimer(Sender: TObject);
begin
   //turn off timWarning and timwait
   timWarning.enabled := false;
   timWait.enabled := false;
   //make respective labels visible and non visible
   labWarning.visible := false;
   labMapHelp.visible := true;
end;

//WARNING SIGN TIMER
procedure TfrmTravel.timWARNINGTimer(Sender: TObject);
begin
   //make the labWarning not(visible)
  labWarning.visible := not(labWarning.visible)
end;

end.

{
 //Travel form TO DO LIST
 - with sector do?
 - teleporting form screen
 - CHANGE BACKGROUND ON TELEPORT
}

{//initialise k var and decide
                          k := 0;
                          decide := false;
                          //has anything actually BEEN put in there?
                          if (begun)
                             then begin
                                      //check if it already has been tested
                                      while ((k < 4) and (not decide)) do
                                        begin
                                         if (sector.tag = available[k])
                                            then decide := true
                                            else inc(k)
                                        end
                                  end;
                          //if it hasn't been tested, check it OR nothing has been placed inside the array yet
                          if ((not decide) or (not begun))
                             then if (sector.current = false)
                                     then begin
                                              //grab the left and top
                                              destL := sector.left;
                                              destT := sector.top;
                                              //calculate distance
                                              dis := sqrt((destT-shipT)*(destT-shipT)+(destL-shipL)*(destL-shipL));
                                              labTest.caption := 'Destination: ' + inttostr(destT) +' ' +inttostr(destL) + ' Current: '+inttostr(shipL) + ' '+inttostr(shipT);
                                              labTest.caption := floattostr(dis);
                                              //labTest.caption := 'asd';
                                              //labBack.caption := 'asd';
                                              //if it's below the radius add it to the available set
                                              if ((dis < radius) and (length(available)<>3))
                                                 then begin
                                                         //set the length
                                                         setlength(available,length(available)+1);
                           //IT PICKS THE SAME ONE       //add it
                                                         available[length(available)-1] := sector.tag;
                                                         labBack.caption := inttostr(available[1]) + '' +inttostr(available[2])+'' +inttostr(available[0]);
                                                         begun := true;
                                                         //available[length(available)-1] := sector
                                                      end
                                          end}

{//check if a sector has been spawned yet
     if (count > 1)
        then begin
               //find all components
               for i := (componentcount-1) downto 0 do
                  //check if it's a sector
                  if (components[i] is sectors)
                     then begin
                            //typecast it
                            chosen := components[i] as sectors;
                            //find the distance between them
                            dis := sqrt((chosen.top-topAMT)*(chosen.top-topAMT)+(chosen.left-leftAMT)*(chosen.left - leftAMT));
                            //check if the dis is ACCEPTABLE
                            if (dis < (50*chosen.width))
                               //it is acceptable
                               then found := true
                          end
             end
             //no sectors exist yet auto found := true
             else found := true;
     //found := true; }

//use a for loop to spontaneously create a random amt. of "sectors"
            {for T := 8 to 10 do
               for L := 6 to 12 do
                  begin
                    //create a new sector with said top and left
                    sector := sectors.create(nil);

                    //SEARCH PROCEDURE
                    //search(T,L);

                    topoffput := -80;
                    leftoffput := -180;
                    with sector do
                      begin
                         parent := frmTravel;
                         stretch := true;
                         picture := imgSector.picture;
                         //dimension the sector up properly
                         height := 30;
                         width := 30;
                         //position it
                         topAMT := 0;
                         leftAMT := 0;
                         top := 0;
                         left := 0;
                         //increment count
                         //inc(count)

                         //top := T*trunc(clientheight/4) + sector.height*T + topoffput + random(101);
                         //left := L*trunc(clientwidth) + 30 + sector.width*L + leftoffput + random(201);
                    end;
                    //add it to the set
                    setlength(grid,length(grid)+1);
                    grid[length(grid)-1] := sector
              end;

            //set created to true
            frmTravel.created := true;}
  {
//set count to 0
  count := 0;
  //figure out a top and left
  repeat
     //set the found boolean to false
     found := false;
     //generate a top and left
     leftAMT := L*trunc(clientwidth)+random(50);
     topAMT := T*trunc(clientheight)+random(50);
     //check if the sector set is empty
     if (length(grid) = 0)
        //nothing to compare too, leave the loop
        then found := true
        else begin
               //iterate through the sector array
               for i := 0 to (length(grid)-1) do
                  begin
                      //assign it a variable
                      chosen := grid[i];
                      //find the distance between them
                      dis := 70;
                      //labRole.caption := inttostr(length(grid));
                      //check if there is enough distance between them
                      if (dis > 50)
                         //it is acceptable
                         then found := true
                  end;
             end;
  until(found);



DISTANCE LOOP SEARCH
//iterate through the sector array
   //for i := 0 to (length(grid)-1) do
   check := true;
   //check if an element 0 exists
   if (length(grid) > 0)
      then begin
             i := 0;
             while (check) do
                begin
                    //assign it a variable
                    //chosen := grid[i];
                    //find the distance between them
                    dis := sqrt((grid[i].top-topAMT)*(grid[i].top-topAMT)+(grid[i].left-leftAMT)*(grid[i].left-leftAMT));
                    //labRole.caption := inttostr(length(grid));
                    //check if there is enough distance between them
                    if (dis < (grid[i].width)*2)
                       //it is not acceptable
                       then begin
                              //pick new top and left
                              leftAMT := L*trunc(clientwidth)+random(51);
                              topAMT := T*trunc(clientheight)+random(51);
                              //set i back
                              i := 0;
                            end
                            else begin
                                    //if i has not reached max grid length inc it
                                    if (i <> (length(grid)-1))
                                       //test next sector
                                       then inc(i)
                                       //the loop has finished - leave
                                       else check := false;
                                 end;
                end;
end;
}

