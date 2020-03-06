unit unenemy;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms,
  Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls;

type

  { TfrmEnemy }

  targets = class(TImage)
    public
      role     : string; //e.g. weapons, shields, hull, engine
      selected : string;
  end;

  projectiles = class(TImage)
    public
      dmg    : integer; //how much damage it's dealing
      seen   : boolean;
      img    : byte; //which img is it?
      swap   : boolean;
      user   : boolean; //who does the proj belong to?
      hit    : boolean;
  end;

  //weapons record
  items = record
    name     : string[20];
    weapon   : boolean; //whether it's a weapon or not
    dmg      : byte;    //how much damage it does
    interval : integer; //the time between attacks
    projimg  : TImage;
    projimgref : byte;
    equipped : byte; //where does the player have it?
  end;

  //explosion class
  expl = class(TImage)
    public
      user : boolean;
  end;

  TfrmEnemy = class(TForm)
    btnLootFinish: TButton;
    imgLaserProj: TImage;
    imgProj2: TImage;
    imgProj1: TImage;
    imgSpaceBack: TImage;
    imgFighter: TImage;
    imgLShips: TImageList;
    labNotReady: TLabel;
    labHPInfo: TLabel;
    memLoot: TMemo;
    pbHealth: TProgressBar;
    shBlock: TShape;
    shInfoBack: TShape;
    shLootBack: TShape;
    shNotReady: TShape;
    timBattle: TTimer;
    timNotReady: TTimer;
    timFinal: TTimer;
    timExplode: TTimer;
    timExplode2: TTimer;
    timHP_MOVE: TTimer;
    procedure btnLootFinishClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgFighterClick(Sender: TObject);
    procedure targetMouseLeave(Sender: TObject);
    procedure targetMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure timBattleTimer(Sender: TObject);
    procedure timExplode2Timer(Sender: TObject);
    procedure timExplodeTimer(Sender: TObject);
    procedure timFinalTimer(Sender: TObject);
    procedure timHP_MOVETimer(Sender: TObject);
    procedure targetClick(Sender: TObject);
    procedure create(who : projectiles);
    procedure applydamage;
    procedure endgame;
    function checkendgame(damage : byte) : boolean;
    procedure newgame;
    procedure projclear;
    procedure timNotReadyTimer(Sender: TObject);
    procedure UserCreate(item : items); //creating the proj on frmGame
    procedure moveUser;
    procedure UserEnemyCreate(proj : projectiles); //create a proj on frmEnemy
    procedure hurtenemy(proj : projectiles); //procedure for giving the enemy ship damage
    procedure enemyDied;

  private

  public
     aim : string; //What is the player targeting?
     amt : integer; //amount of projectiles going to the other form
     who : projectiles;
     clear   : boolean;
  end;

var
  frmEnemy: TfrmEnemy;

implementation

uses unTravel,unGame,unDead;

{$R *.lfm}

{ TfrmEnemy }

Var health  : byte;
    image   : TImage;
    shipnum : byte;
    tagnum  : integer;
    test    : boolean;
    num     : byte;
    bigexpl : boolean;

//move the user projectiles
procedure TfrmEnemy.moveUser;
var proj : projectiles;
    i    : byte;
begin
 //go through all components checking for projectiles
  for i := (componentcount-1) downto 0 do
      if (components[i] is projectiles)
          then begin
                 //typecast it
                 //showmessage('a');
                 proj := components[i] as projectiles;
                 //check if it's a user proj
                 if (proj.user)
                     then begin
                            //move it to the right
                            proj.left := proj.left + 30;
                            //check if it's gone off the screen
                            if (proj.left > clientwidth + proj.width)
                                then begin
                                       //call a function to create a new one on frmEnemy

                                       //destroy the projectile
                                       proj.destroy;
                                     end;
                          end;
               end;
end;

//THE ENEMY HAS DIED
procedure TfrmEnemy.enemyDied;
begin
  //set enemy health to 0
  health := 0;
  //turn off all the battle timers
  timBattle.enabled := false;
  timHP_MOVE.enabled := false;
  {frmGame.timWep1.enabled := false;
  frmGame.timWep2.enabled := false;
  frmGame.timWep3.enabled := false;
  frmGame.timWep4.enabled := false;}
  //start a timer to 1) remove the explosion 2) change forms around
  timFinal.enabled := true;
end;

//CREATE USER PROJ ON frmEnemy
procedure TfrmEnemy.UserEnemyCreate(proj : projectiles);
var new : projectiles;
begin
   //create the new projectile on frmEnemy
   new := projectiles.create(self);
   new.parent := frmEnemy;
   //details
   new.user := true;
   new.stretch := true;
   new.swap := true;
   new.dmg := proj.dmg;
   //mock it up
   new.height := 51;
   new.width := 51;
   new.left := -new.width;
   new.top := 50+random(clientheight-50); //fix this later so it goes towards mouse target
   new.picture := proj.picture;
end;

//CREATE THE PROJECTILE ON THE GAME FORM
procedure TfrmEnemy.UserCreate(item : items);
var proj : projectiles;
begin
   //create the projectile
   proj := projectiles.create(self);
   proj.parent := frmGame; //spawns on frmGame
   //mock it up
   proj.width := 51;
   proj.height := 51;
   proj.left := 439;
   proj.top := frmGame.imgShip.top + random(300) + 20;
   proj.stretch := true;
   proj.user := true;
   //hasn't gone to the next form yet
   proj.swap := false;
   //game vars
   proj.dmg := item.dmg;
   //the picture
   frmGame.imgLProj.getbitmap(item.projimgref,proj.picture.bitmap);
   //proj.picture := imgLaserProj.picture;
   proj.bringtofront;
   //inc(num);
   //frmGame.labShop.caption := inttostr(num);
   //set the picture
   //proj.picture := item.projimg.picture;
   //proj.tag := who.tag;


end;

//clear projectiles //doesn't work
procedure TfrmEnemy.projclear;
var i : byte;
    proj : projectiles;
begin
 //clear ALL projectiles
 for i := (componentcount-1) downto 0 do
     if (components[i] is projectiles)
       then begin
              //typecast it
              proj := components[i] as projectiles;
              //destroy it
              proj.destroy;
              //showmessage('a');
            end;
 clear := false;
end;

//DISABLE THE STUFF
procedure TfrmEnemy.timNotReadyTimer(Sender: TObject);
begin
   //turn stuff invisible
   labNotReady.visible := false;
   shNotReady.visible := false;
   //turn the timer off
   timNotReady.enabled := false;
end;

//WHEN THE FORM IS CREATED
procedure TfrmEnemy.FormCreate(Sender: TObject);
var target     : targets;
begin
  //randomize
  randomize;

  //setup form loc
  frmEnemy.left := 850;
  frmEnemy.top := 102;

  //setup booleans for big expl
  bigexpl := false;

  //if (clear)
    //then projclear;
  //new game
  //newgame;
  {//check which ship it is and setup targets accordingly
  case shipnum of
      //if it's ship num. 0
   0:     begin
              //move the weapons target
              imgWEPtar.left := 200;
              imgWEPtar.top := 300;
              //move the shield target
              imgSHIELDtar.left := 300;
              imgSHIELDtar.top := 200;
              //move the HULL target
              imgHULLtar.left := 115;
              imgHULLtar.top := 275;
              //move the ENGINE target
              imgENGINEtar.Left := 270;
              imgENGINEtar.top := 250;
           end;
   //if it's ship num. 1
   1:      begin
              //move the weapons target
              imgWEPtar.left := 200;
              imgWEPtar.top := 400;
              //move the shield target
              imgSHIELDtar.left := 200;
              imgSHIELDtar.top := 150;
              //move the HULL target
              imgHULLtar.left := 115;
              imgHULLtar.top := 230;
              //move the ENGINE target
              imgENGINEtar.Left := 130;
              imgENGINEtar.top := 340;
           end;

  end;}
end;

//FINISH WITH BUTTON LOOT
procedure TfrmEnemy.btnLootFinishClick(Sender: TObject);
begin
  //set battle to false   }
 frmGame.battle := false;
 //turn off all active weapons
 if (frmGame.att1B)
    then begin
           frmGame.att1B := false;
           frmGame.changecolor(1,clWhite);
         end;
 if (frmGame.att2B)
    then begin
           frmGame.att2B := false;
           frmGame.changecolor(2,clWhite);
         end;
 if (frmGame.att3B)
    then begin
           frmGame.att3B := false;
           frmGame.changecolor(3,clWhite);
         end;
 if (frmGame.att4B)
    then begin
           frmGame.att4B := false;
           frmGame.changecolor(4,clWhite);
         end;
 {frmGame.att2B := false;
 frmGame.att3B := false;
 frmGame.att4B := false;
 frmGame.changecolor(2,clWhite);
 frmGame.changecolor(1,clWhite);
 frmGame.changecolor(1,clWhite);}
 //loot
 //disable the timer
  //clear the memo box
  memLoot.lines.Clear;
  //position it back
  shLootBack.left := -456;
  memLoot.left := -440;
  btnLootFinish.left := -440;
  //move all forms back
  frmEnemy.hide;
  frmGame.left := 228;
  frmGame.top := 113;
end;

//WHEN THE IMAGE FIGHTER IS CLICKED <-----
procedure TfrmEnemy.imgFighterClick(Sender: TObject);
var which : UnGame.items;
    new   : items;
begin
  //when the enemy ship is clicked
  //check if any of the attack vars are true
  if (frmGame.att1B)
    then begin
           //check if the pb is ready
           if (frmGame.pbWep1.position > 99)
             then begin
                     //set the boolean to false
                     frmGame.att1B := false;
                     //update cursor
                     imgFighter.cursor := crDefault;
                     //change colours
                     frmGame.sh1Icon.Brush.color := clWhite;
                     frmGame.shNum1.brush.color := clWhite;
                     frmGame.labWep1.Font.Color := clWhite;
                     //setup which
                     which := frmGame.att1;
                     //convert
                     new.name := which.name;
                     new.dmg := which.dmg;
                     new.interval := which.interval;
                     new.projimg := which.projimg;
                     new.equipped := which.equipped;
                     new.projimgref:= which.projimgref;
                     new.weapon := which.weapon;
                     //set the pb back
                     frmGame.wep1sleep := 0;
                     //call user create
                     UserCreate(new);
                 end
                 else begin
                         //weapon is not ready yet
                         //turn stuff visible
                         labNotReady.Visible := true;
                         shNotReady.visible := true;
                         //turn the timer on
                         timNotReady.Enabled := true;
                      end;
         end;
  //check if 2 is active
  if (frmGame.att2B)
    then begin
           //check if ready
           if (frmGame.pbWep2.position > 99)
             then begin
                     //set the boolean to false
                     frmGame.att2B := false;
                     //update cursor
                     imgFighter.cursor := crDefault;
                     //change colours
                     frmGame.sh2Icon.Brush.color := clWhite;
                     frmGame.shNum2.brush.color := clWhite;
                     frmGame.labWep2.Font.Color := clWhite;
                     //setup which
                     which := frmGame.att2;
                     //convert
                     new.name := which.name;
                     new.dmg := which.dmg;
                     new.interval := which.interval;
                     new.projimg := which.projimg;
                     new.equipped := which.equipped;
                     new.projimgref:= which.projimgref;
                     new.weapon := which.weapon;
                     //set the pb back
                     frmGame.wep2sleep := 0;
                     //call user create
                     UserCreate(new);
                  end
                  else begin
                         //weapon is not ready yet
                         //turn stuff visible
                         labNotReady.Visible := true;
                         shNotReady.visible := true;
                         //turn the timer on
                         timNotReady.Enabled := true;
                       end;
         end;
  //check if 3 is active
  if (frmGame.att3B)
    then begin
           if (frmGame.pbWep3.position > 99)
             then begin
                      //set the boolean to false
                     frmGame.att3B := false;
                     //update cursor
                     imgFighter.cursor := crDefault;
                     //change colours
                     frmGame.sh3Icon.Brush.color := clWhite;
                     frmGame.shNum3.brush.color := clWhite;
                     frmGame.labWep3.Font.Color := clWhite;
                     //setup which
                     which := frmGame.att3;
                     //convert
                     new.name := which.name;
                     new.dmg := which.dmg;
                     new.interval := which.interval;
                     new.projimg := which.projimg;
                     new.equipped := which.equipped;
                     new.projimgref:= which.projimgref;
                     new.weapon := which.weapon;
                     //set the pb back
                     frmGame.wep3sleep := 0;
                     //call user create
                     UserCreate(new);
                end
                else begin
                        //weapon is not ready yet
                         //turn stuff visible
                         labNotReady.Visible := true;
                         shNotReady.visible := true;
                         //turn the timer on
                         timNotReady.Enabled := true;
                     end;
         end;
  //check if 4 is active
  if (frmGame.att4B)
    then begin
           if (frmGame.pbWep4.position > 98)
             then begin
                     //set the boolean to false
                     frmGame.att4B := false;
                     //update cursor
                     imgFighter.cursor := crDefault;
                     //change colours
                     frmGame.sh4Icon.Brush.color := clWhite;
                     frmGame.shNum4.brush.color := clWhite;
                     frmGame.labWep4.Font.Color := clWhite;
                     //setup which
                     which := frmGame.att4;
                     //convert
                     new.name := which.name;
                     new.dmg := which.dmg;
                     new.interval := which.interval;
                     new.projimg := which.projimg;
                     new.equipped := which.equipped;
                     new.projimgref:= which.projimgref;
                     new.weapon := which.weapon;
                     //set the pb back
                     frmGame.wep4sleep := 0;
                     //call user create
                     UserCreate(new);

                 end
                 else begin
                        //weapon is not ready yet
                         //turn stuff visible
                         labNotReady.Visible := true;
                         shNotReady.visible := true;
                         //turn the timer on
                         timNotReady.Enabled := true;
                      end;
         end;
end;

//NEW GAME
procedure TfrmEnemy.newgame;
begin
  //setting up projectile tags
  tagnum := 0;
  //set health to 100
  health := 100;
  //test boolean
  test := false;
  //put an enemy ship into the picture
  shipnum := random(2);
  //num := 1;
  imgLShips.getbitmap(shipnum,imgFighter.Picture.bitmap);
  //turn timers on
  timBattle.enabled := true;
  timHP_MOVE.enabled := true;
end;

//MOUSE LEAVES THE TARGET
procedure TfrmEnemy.targetMouseLeave(Sender: TObject);
var what : TImage;
    num  : byte;
begin
  {//typecast it
  what := Sender as TImage;
  //tag for the target
  num := what.tag;
  //change picture back
  case num of
    //WEAPON TARGET
    1: begin
         //swap picture for normal
         what.picture := imgWEPimg.picture;
       end;
    //HULL TARGET
    2: begin
         //swap picture for normal
         what.picture := imgHULLimg.picture;
       end;
    //ENGINE TARGET
    3: begin
         //swap picture for normal
         what.picture := imgENGINEimg.picture;
       end;
    //SHIELD TARGET
    4: begin
         //swap picture out for normal
         what.picture := imgSHIELDimg.picture;
       end;
   end;
  //what.picture := image.picture;
  //resize it back down
  what.Height := 64;
  what.width := 64;}

end;

//MOUSE MOVES OVER TARGET
procedure TfrmEnemy.targetMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var what : TImage;
    num  : byte;
begin
   {//typecast it
   what := Sender as TImage;
   //put tag as num
   num := what.tag;
   //store picture in storage var
   //image.picture := what.picture;
   //change image depending on what image it is
   case num of
    1: begin
         //swap picture for red
         imgWepTar.picture := imgWepRed.picture;
       end;
    2: begin
         //swap picture for red
         imgHulltar.picture := imgHullRed.picture;
       end;
    3: begin
         //swap picture for red
         imgEnginetar.picture := imgEngineRed.picture;
       end;
    4: begin
         //swap picture out for red
         imgShieldTar.picture := imgShieldRed.picture
       end;
   end;
   //increase width and height
   what.Height := 69;
   what.width := 69;}

end;

//TIMER FOR BATTLE
procedure TfrmEnemy.timBattleTimer(Sender: TObject);
var projectile : projectiles;
    ran        : byte;
begin
  if (frmGame.battle)
    then begin
           {case tag of
           1: aim := 'WEAPONS';
           2: aim := 'HULL';
           3: aim := 'ENGINE';
           4: aim := 'SHIELD';
          end;}
           //create the projectile
           projectile := projectiles.create(self);
           projectile.parent := frmEnemy;
           projectile.stretch := true;
           //generate a random number
           ran := random(101);
           //assign a RANDOM image (since it's a drone)
           if (ran < 50)
              then begin
                     projectile.picture := imgProj1.picture;
                     //projectile.tag := projectile.left * 5
                   end
                   else begin
                           projectile.picture := imgProj2.picture;
                           //projectile.tag := projectile.Left * 12;
                        end;
           //position it at the center of the image
           projectile.left := imgFighter.width div 2;
           projectile.top := imgFighter.height div 2;
           //adjust width/height relatively
           projectile.width := 51;
           projectile.height := 51;
           //give it a random addition
           projectile.left := projectile.left + random(imgFighter.width div 2);
           projectile.top := projectile.top + random(imgFighter.height div 2);
           projectile.seen := false;
           projectile.swap := false;
           //setup tag
           projectile.tag := 5+tagnum;
           inc(tagnum);

        end;


end;

//TIM EXPLODE FOR USER PROJ
procedure TfrmEnemy.timExplode2Timer(Sender: TObject);
var i : byte;
    select : expl;
begin
  //check for any explosion images
  for i := (componentcount-1) downto 0 do
      if (components[i] is expl)
         then begin
                //typecast it
                select := components[i] as expl;
                //check the tag
                if (select.user)
                   //destroy it
                   then select.destroy;
              end;
  //disable the timer
  timExplode2.enabled := false;
end;

//EXPLOSION TIMER
procedure TfrmEnemy.timExplodeTimer(Sender: TObject);
var i : byte;
    select : TImage;
begin
  //check for any explosion images
  for i := (componentcount-1) downto 0 do
      if (components[i] is TImage)
         then begin
                //typecast it
                select := components[i] as TImage;
                //check the tag
                if (select.tag = 35)
                   //destroy it
                   then select.destroy;
              end;
  //disable the timer
  timExplode.enabled := false;
end;

//FINAL EXPL TIMER
procedure TfrmEnemy.timFinalTimer(Sender: TObject);
var big  : TImage;
    i    : byte;
    this : expl;
    kill : projectiles;
    waste : TImage;
    death : expl;
begin
  if (bigexpl = false)
     then begin
              //spawn a big explosion
              big := expl.create(self);
              big.parent := frmEnemy;
              big.stretch := true;
              //mock it up
              big.Width := 380;
              big.Height := 380;
              big.left := 80;
              big.top := 144;
              //picture
              big.picture := frmGame.imgExplosion.picture;
              //set bigexpl to true
              bigexpl := true;
              //increase interval
              timFinal.interval := 2000;
              //check for components on game form
              for i := (componentcount-1) downto 0 do
                  begin
                    if (components[i] is projectiles)
                       then begin
                               //typecast it
                               kill := components[i] as projectiles;
                               //kill it
                               kill.destroy;
                            end;
                    if (components[i] is TImage)
                       then begin
                              //check on old algo
                              //typecast it
                              waste := components[i] as TImage;
                              //check
                              if (waste.tag = 35)
                                 //kill it
                                 then waste.destroy;
                            end;
                    if (components[i] is expl)
                       then begin
                              //typecast it
                              death := components[i] as expl;
                              //check if it's not big
                              if (death.width <> 380)
                                 //destroy it
                                 then death.destroy;
                            end;
                  end;
         end
          else begin
                 //get rid of all explosions
                 for i := (componentcount-1) downto 0 do
                     if (components[i] is expl)
                        then begin
                               //typecast it
                               this := components[i] as expl;
                               //destroy it
                               this.destroy;
                             end;
                 timFinal.enabled := false;
                 frmGame.loot;
                 {/move all forms back
                 frmEnemy.hide;
                 frmGame.left := 228;
                 frmGame.top := 113;
                 //set battle to false   }
                 //frmGame.battle := false;
                 //turn off all active weapons
                 if (frmGame.att1B)
                    then begin
                           frmGame.att1B := false;
                           frmGame.changecolor(1,clWhite);
                         end;
                 if (frmGame.att2B)
                    then begin
                           frmGame.att2B := false;
                           frmGame.changecolor(2,clWhite);
                         end;
                 if (frmGame.att3B)
                    then begin
                           frmGame.att3B := false;
                           frmGame.changecolor(3,clWhite);
                         end;
                 if (frmGame.att4B)
                    then begin
                           frmGame.att4B := false;
                           frmGame.changecolor(4,clWhite);
                         end;
                 {frmGame.att2B := false;
                 frmGame.att3B := false;
                 frmGame.att4B := false;
                 frmGame.changecolor(2,clWhite);
                 frmGame.changecolor(1,clWhite);
                 frmGame.changecolor(1,clWhite);}
                 //loot
                 //disable the timer
               end;
end;

//CREATE THE OBJECT ON NEW FORM
procedure TfrmEnemy.create(who : projectiles);
var new : projectiles;
begin
   //there is a new projectile.
   new := projectiles.create(self);
   new.parent := frmGame;
   //mock it up
   new.width := who.width;
   new.height := who.height;
   new.left := frmGame.clientwidth; //because it's on the frmGame form
   new.top := who.top-70;
   new.stretch := true;
   new.tag := who.tag;
   //now the projectile is on the new form
   new.swap := true;
   //check the picture
   {if (random(101) < 50)
      then new.picture := frmGame.imgProj1.picture
      else new.picture := frmGame.imgProj2.picture}
   new.picture := who.picture;
   //other info
   //new.dmg := frmEnemy.who.dmg;
end;

//END GAME PROCEDURE
procedure TfrmEnemy.endgame;
begin
  //the end is near
  //turn ALL the timers off
  timHP_MOVE.enabled := false;
  timBattle.enabled := false;
  frmGame.timEnergy.enabled := false;
  //update hp label and position
  frmGame.labHP.caption := 'Hull HP: 0%';
  frmGame.pbHP.position := 0;
  //hide other forms
  frmGame.hide;
  frmEnemy.hide;
  //update on frmDead
  frmDead.labScore.caption := 'Score: '+inttostr(frmGame.scrap);
  //make the dead thing true
  frmDead.saved := false;
  //show the endgame form
  frmDead.show;
end;

//APPLY ROOM DAMAGE
procedure TfrmEnemy.applydamage;
var damage : byte;
    ran    : byte;
    check,game  : boolean;
begin
  //make a random number for damage
 damage := random(10)+35;
 //setup bool
 check := false;
 game := false;
 //so that something IS hit
 repeat
     //make a random number for a room
     {if ((frmGame.weproom.HP <= 0) and (frmGame.shieldroom.HP <= 0))
        then if ((frmGame.hullroom.HP <= 0) and (frmGame.engineroom.HP <= 0))
                 then ran := 4
                 else ran := random(4);}
     if (frmGame.health - damage/4 > 0)
        then ran := random(4)
        else ran := 4;
     //apply damage to said room
     case ran of
     //weapons room
     0: begin
          {//check if the damage won't go negative
          if (frmGame.weproom.HP - damage >= 1)
            //apply the damage
            then begin
                    frmGame.weproom.HP := frmGame.weproom.HP - damage;
                    //allow to leave the loop
                    check := true;
                 end
                 else check := false;
                 //else check := checkendgame(damage); }
          //if the health of the room is GREATER than one
          if (frmGame.weproom.HP >= 1)
             then begin
                     //do the damage
                     frmGame.weproom.HP := frmGame.weproom.HP - damage;
                     //if the damage is less than 0 set hp to 0
                     if (frmGame.weproom.HP < 0)
                        then frmGame.weproom.HP := 0;
                     //set check to true
                     check := true;
                  end
                  //health of the room was ALREADY 0
                  else check := false;

        end;
     //engine room
      1: begin
           //check if the damage won't go negative
          {if (frmGame.engineroom.HP - damage >= 1)
            //apply the damage
            then begin
                    frmGame.engineroom.HP := frmGame.engineroom.HP - damage;
                    //allow to leave the loop
                    check := true;
                 end
                 else check := false;}
           if (frmGame.engineroom.HP >= 1)
             then begin
                     //do the damage
                     frmGame.engineroom.HP := frmGame.engineroom.HP - damage;
                     //if the damage is less than 0 set hp to 0
                     if (frmGame.engineroom.HP < 0)
                        then frmGame.engineroom.HP := 0;
                     //set check to true
                     check := true;
                  end
                  //health of the room was ALREADY 0
                  else check := false;
         end;
      //shield room
      2: begin
           if (frmGame.shieldroom.HP >= 1)
             then begin
                     //do the damage
                     frmGame.shieldroom.HP := frmGame.shieldroom.HP - damage;
                     //if the damage is less than 0 set hp to 0
                     if (frmGame.shieldroom.HP < 0)
                        then frmGame.shieldroom.HP := 0;
                     //set check to true
                     check := true;
                  end
                  //health of the room was ALREADY 0
                  else check := false;
          //check if the damage won't go negative
          {if (frmGame.shieldroom.HP - damage >= 1)
            //apply the damage
            then begin
                    frmGame.shieldroom.HP := frmGame.shieldroom.HP - damage;
                    //allow to leave the loop
                    check := true;
                 end
                 else check := false;}
         end;
      //hull room
      3: begin
           if (frmGame.hullroom.HP >= 1)
             then begin
                     //do the damage
                     frmGame.hullroom.HP := frmGame.hullroom.HP - damage;
                     //if the damage is less than 0 set hp to 0
                     if (frmGame.hullroom.HP < 0)
                        then frmGame.hullroom.HP := 0;
                     //set check to true
                     check := true;
                  end
                  //health of the room was ALREADY 0
                  else check := false;
         { if (frmGame.hullroom.HP - damage >= 1)
            //apply the damage
            then begin
                    frmGame.hullroom.HP := frmGame.hullroom.HP - damage;
                    //allow to leave the loop
                    check := true;
                 end
                 else check := false;  }

         end;
      4: begin
           check := true;
           game := true;
         end;
    end

  until (check);

  if (game)
    then endgame;
end;

//FUNCTION FOR CHECKING ENDGAME
function TfrmEnemy.checkendgame(damage : byte) : boolean;
begin
   //showmessage(floattostr(damage/4));
   endgame;
   checkendgame := true;
end;

//APPLY DAMAGE TO ENEMY SHIP
procedure TfrmEnemy.hurtenemy(proj : projectiles);
var dmg : byte;
begin
   //take the damage from proj
   dmg := proj.dmg;
   //check if it won't mess the whole enemy HP up
   if (health - dmg >= 1)
      //apply damage
      then health := health - dmg
      //ELSE it does mess the whole game up
      else enemydied;

end;

//UPDATE HP AND MOVE BULLETS (PRACTICALLY EVERYTHING THAT MOVES IS HERE <--)
procedure TfrmEnemy.timHP_MOVETimer(Sender: TObject);
var i,k          : byte;
    proj         : projectiles;
    find         : projectiles;
    dis          : real;
    x2,x1        : integer; //distance formula variables
    y1,y2        : integer;
    ran          : byte;
    damage       : integer;
    explosion    : expl;
    explosio     : TImage;
begin
  //Update the label
  labHPInfo.caption := 'HP Level: ' + inttostr(health) + '%';
  //update position of pb
  pbHealth.position := health;

  if (clear)
    then projclear;

  //move the user projectiles
  //moveUser;

  //find all the projectiles on screen
  for i := (componentcount-1) downto 0 do
      if (components[i] is projectiles)
         then begin
                   //TYPECAST
                   proj := components[i] as projectiles;
                   test := proj.swap;
                   //showmessage('this');
                   //if they've gone off the screen inc the var
                   //proj.left := proj.left - 30;
                   if (proj.left < -proj.width)
                      then if ((test = false)and(proj.user = false))
                              then begin
                                     //setup the projectile
                                     who := proj;
                                     //create it on the other form
                                     create(who);
                                     //destroy it
                                     who.destroy;
                                   end
              end;

  //test for projectiles and move them
  for i :=(componentcount-1) downto 0 do
      if (components[i] is projectiles)
        then begin
               //typecast it
               find := components[i] as projectiles;
               test := find.swap;
               {//check if it's left the enemy form
               if ((find.left < -find.width) and (test = false))
                  then begin
                             //create the projectile on the other form
                             create(who);
                       end;     }
               //check the parent
               if ((find.width = 51)and(find.user = false))
                 then begin
                         //move it
                         find.left := find.left - 30;
                         //test location
                         if ((find.left < 439) and (find.left > 400))
                           then begin if ((test) and (frmGame.battle))
                                     //too close, kill it
                                     then begin
                                             //showmessage('a');
                                             //randomly decide whether it misses or not
                                             if (random(200) < 140)
                                               //it is a HIT
                                               then begin
                                                       //apply the damage to the room
                                                       applydamage;
                                                       //showmessage(inttostr(frmGame.hullroom.hp));
                                                       //spawn an explosion image at the same place
                                                       explosio := TImage.create(self);
                                                       explosio.parent := frmGame;
                                                       explosio.stretch := true;
                                                       //setup a tag to find it
                                                       explosio.tag := 35;
                                                       //position it
                                                       explosio.left := find.left;
                                                       explosio.top := find.top;
                                                       //mock it up
                                                       explosio.picture := frmGame.imgExplosion.picture;
                                                       //enable explosion timer
                                                       timExplode.enabled := true;
                                                       //destroy it
                                                       find.destroy;
                                                    end
                                                    //it was a miss!
                                                    else begin
                                                           //make it visible
                                                           frmGame.labMiss.visible := true;
                                                           frmGame.shMiss.visible := true;
                                                           //enable both miss timers
                                                           frmGame.timMiss.enabled := true;
                                                           frmGame.timMiss2.enabled := true;
                                                         end

                                          end
                                 end;
                                 //else find.left := find.left - 15;
                         //if (find.left < -find.width)
               //check if anything has left the form
               {if (find.left < -find.width)
                      then begin
                             //destroy it
                             who.hide;
                           end;}
                 end
                 else if (find.user)
                   then begin
                           //inc(num);
                           //move it to the right
                            find.left := find.left + 30;
                            //check if it's gone off the screen
                            if (find.left > frmGame.clientwidth + find.width)
                                then begin
                                       //call a function to create a new one on frmEnemy
                                       UserEnemyCreate(find);
                                       //destroy the projectile
                                       find.destroy;
                                     end;

                            //HIT MECHANICS
                            if (find.swap)
                               then if ((find.left > 152) and (find.left < 264))
                                       then begin
                                              //decide if it's a hit or not
                                              if (random(200) < 140)
                                                 //HIT
                                                 then begin
                                                        //apply a said amount of damage to the enemy ship
                                                        hurtenemy(find);
                                                        //destroy the projectile
                                                        //find.destroy;
                                                        //spawn an explosion in
                                                        explosion := expl.create(self);
                                                        explosion.parent := frmEnemy;
                                                        explosion.stretch := true;
                                                        //setup a tag to find it
                                                        //explosion.tag := 35;
                                                        explosion.user := true;
                                                        //position it
                                                        explosion.left := find.left;
                                                        explosion.top := find.top;
                                                        //mock it up
                                                        explosion.picture := frmGame.imgExplosion.picture;
                                                        //setup
                                                        find.hit := true;
                                                        //enable explosion timer
                                                        timExplode2.enabled := true;
                                                        //destroy the projectile
                                                        find.destroy;

                                                      end
                                                      //MISS
                                                      else begin
                                                              //make a, 'you missed' thing appear

                                                           end;
                                            end;

                            //check if it's gone off frmEnemy
                            if ((find.left > clientwidth + find.width)and (find.swap))
                               //destory it since it has
                               then find.destroy;
                        end
                        else if ((frmGame.battle = false)and(find.user = false))
                                   //destroy it
                                   then find.destroy;
             end;
      {//check if any of the projectiles are allowed to be alive
      for i :=(componentcount-1) downto 0 do
      if (components[i] is projectiles)
        then begin
               //typecast it
               find := components[i] as projectiles;
               //check if it needs clearing
               if ((frmGame.battle = false)and(find.user = false))
                 //destroy it
                 then find.destroy;
             end  }
end;

//WHEN THE PLAYER CLICKS A TARGET
procedure TfrmEnemy.targetClick(Sender: TObject);
var what : TImage;
    num  : byte;
begin
  //typecast it
  what := Sender as TImage;
  //setup the tag
  num := what.tag;
  //find which target it is (1 - wep, 2 - hull, 3- engine, 4-shield)
  case num of
   1: aim := 'WEAPONS';
   2: aim := 'HULL';
   3: aim := 'ENGINE';
   4: aim := 'SHIELD';
  end;

  //showmessage(aim);


end;

end.


