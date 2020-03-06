unit unWepTable;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  wep = class(TImage)
    public
      nm       : string[20];
      weapon   : boolean; //whether it's a weapon or not
      dmg      : byte;    //how much damage it does
      interval : integer; //the time between attacks
      projimg  : TImage;
      projimgref : byte;
      equipped : byte; //where does the player have it?
      allow    : boolean;
  end;

  { TfrmWepTable }

  TfrmWepTable = class(TForm)
    img11: TImage;
    img12: TImage;
    img13: TImage;
    img14: TImage;
    img21: TImage;
    img22: TImage;
    img23: TImage;
    img24: TImage;
    img31: TImage;
    img32: TImage;
    img33: TImage;
    img34: TImage;
    img41: TImage;
    img42: TImage;
    img43: TImage;
    img44: TImage;
    imgBack: TImage;
    sh11: TShape;
    sh12: TShape;
    sh13: TShape;
    sh14: TShape;
    sh21: TShape;
    sh22: TShape;
    sh23: TShape;
    sh24: TShape;
    sh31: TShape;
    sh32: TShape;
    sh33: TShape;
    sh34: TShape;
    sh41: TShape;
    sh42: TShape;
    sh43: TShape;
    sh44: TShape;
    shBack: TShape;
    procedure FormCreate(Sender: TObject);
    procedure update; //update inventory
    procedure setup;
    procedure front;
    procedure iconMouseEnter(Sender: TObject);
    procedure iconMouseLeave(Sender: TObject);
    procedure boxMouseEnter(Sender: TObject);
    procedure boxMouseLeave(Sender: TObject);
    procedure imgupdate;
    procedure click(Sender: TObject);
    procedure newPick;

  private

  public
     //pick : unGame.items;
  end;

var
  frmWepTable: TfrmWepTable;

implementation

uses unMyShip,unGame;

{$R *.lfm}

{ TfrmWepTable }

Var table   : array[1..4,1..4] of TImage;
    group   : array[1..4,1..4] of unGame.items;
    col,row : byte;

//CLICK A WEAPON
procedure TfrmWepTable.click(Sender: TObject);
var who : TImage;
    num : byte;
    nm  : string;
    eq  : byte;
    r,c : byte;
    replacevar : byte;
begin
   //typecast it
   who := Sender as TImage;
   //find the tag
   num := who.tag;

   //convert the tag into a location
   case num of
      5: col := 1;
      6: col := 2;
      7: col := 3;
      8: col := 4;
      9: col := 1;
      10: col := 2;
      11: col := 3;
      12: col := 4;
      13: col := 1;
      14: col := 2;
      15: col := 3;
      16: col := 4;
   end;

   //row was tricky
   if (num <= 4)
      then row := 1
      else if (num <= 8)
         then row := 2
         else if (num <= 12)
            then row := 3
            else row := 4;

   //get the name
   nm := frmGame.inventory[row,col].name;
   eq := frmGame.inventory[row,col].equipped;
   //frmWepTable.caption := nm +'' +inttostr(eq);

   //store variables
   replacevar := frmMyShip.replace;

   //check if something actually exists there
   if (not(nm.IsEmpty) and (eq = 0))
      then begin
             //go through the inventory and find any replacements -delete
             for r := 1 to 4 do
               for c := 1 to 4 do
                 if (frmGame.inventory[r,c].equipped = replacevar)
                    then frmGame.inventory[r,c].equipped := 0;


             //find what to set the new equipped to
             frmGame.inventory[row,col].equipped := frmMyShip.replace;
             //call weppick on frmMyShip
             frmMyShip.wepcheck;
             //equip it
             case replacevar of
              1: frmGame.att1 := frmGame.inventory[row,col];
              2: frmGame.att2 := frmGame.inventory[row,col];
              3: frmGame.att3 := frmGame.inventory[row,col];
              4: frmGame.att4 := frmGame.inventory[row,col];
             end;
             //hide the pick form
             frmWepTable.hide;
           end;


   {//showmessage(inttostr(eq));
   //check if something exists
   if (not(nm.IsEmpty) and (eq = 0))
      then begin
               //put the new pick in
               newPick;
               //call
               frmMyShip.wepcheck;
               //hide the form
               frmWepTable.hide;
           end; }
end;

//NEW PICK
procedure TfrmWepTable.newPick;
var replace : byte;
    r,c     : byte;
    item    : unGame.items;
begin
   //variable to be replaced
   replace := frmMyShip.replace;
   //change the pick to equipped replace ROW COL STANDS FOR PICK
   frmGame.inventory[row,col].equipped := replace;
end;

//UPDATE THE TABLE VAR
procedure TfrmWepTable.update;
var r,c  : byte;
    item : unGame.items;
    nm   : string;
    this : byte;
begin
   //go through the inventory and update the table
   for r := 1 to 4 do
     for c := 1 to 4 do
       begin
         //typecast it
         item := frmGame.inventory[r,c];
         //grab the name
         nm := item.name;
         //check if it exists            j
         if not(nm.IsEmpty)
            //something does exist
            then begin
                   frmMyShip.labWepTitle.caption := inttostr(r) + ' ' + inttostr(c);
                   frmGame.imgLMiniProj.GetBitmap(item.projimgref,table[r,c].picture.bitmap);
                   group[r,c] := item;
                 end;
        end;
end;

//IMAGE UPDATE
procedure TfrmWepTable.imgupdate;
var r,c : byte;
    num : byte;
    nm  : string;
    item: unGame.items;
begin
   for r := 1 to 4 do
     for c := 1 to 4 do
       begin
          //typecast it
          item := frmGame.inventory[r,c];
          //get the name
          nm := item.name;
          //check if it exists
          if not(nm.IsEmpty)
             //something DOES exist there
             then begin
                      //showmessage('ay');
                      frmGame.imgLMiniProj.getbitmap(item.projimgref,table[r,c].picture.bitmap)
                  end
       end
end;

//BRING EVERYTHING TO FRONT
procedure TfrmWepTable.front;
var r,c : byte;
begin
   //bring everything to front
   for r := 1 to 4 do
     for c := 1 to 4 do
       table[r,c].BringToFront;
end;

//SETUP THE TABLE
procedure TfrmWepTable.setup;
begin
  //allocate array to Image
  table[1,1] := img11;
  table[1,2] := img12;
  table[1,3] := img13;
  table[1,4] := img14;
  table[2,1] := img21;
  table[2,2] := img22;
  table[2,3] := img23;
  table[2,4] := img24;
  table[3,1] := img31;
  table[3,2] := img32;
  table[3,3] := img33;
  table[3,4] := img34;
  table[4,1] := img41;
  table[4,2] := img42;
  table[4,3] := img43;
  table[4,4] := img44;
end;

//FORM CREATE
procedure TfrmWepTable.FormCreate(Sender: TObject);
begin
  //LINK ARRAY AND IMAGES
  setup;
  //BRING ALL TO FRONT
  front;
  //UPDATE ALL PLACES
  //update;
  imgupdate;
end;

//WHEN THE MOUSE ENTERS THE ICON
procedure TfrmWepTable.iconMouseEnter(Sender: TObject);
var who : TImage;
    num : byte;
begin
   //typecast it
   who := Sender as TImage;
   //find the tag
   num := who.tag;
   //form caption
   //frmWepTable.caption :=
   //find which shape it belongs to and change the color;
   case num of
    1: sh11.brush.color := clYellow;
    2: sh12.brush.color := clYellow;
    3: sh13.brush.color := clYellow;
    4: sh14.brush.color := clYellow;
    5: sh21.brush.color := clYellow;
    6: sh22.brush.color := clYellow;
    7: sh23.brush.color := clYellow;
    8: sh24.brush.color := clYellow;
    9: sh31.brush.color := clYellow;
    10: sh32.brush.color := clYellow;
    11: sh33.brush.color := clYellow;
    12: sh34.brush.color := clYellow;
    13: sh41.brush.color := clYellow;
    14: sh42.brush.color := clYellow;
    15: sh43.brush.color := clYellow;
    16: sh44.brush.color := clYellow;
   end
end;

//WHEN THE MOUSE LEAVES THE ICON
procedure TfrmWepTable.iconMouseLeave(Sender: TObject);
begin
   //change all of them to white
    sh11.brush.color := clWhite;
    sh12.brush.color := clWhite;
    sh13.brush.color := clWhite;
    sh14.brush.color := clWhite;
    sh21.brush.color := clWhite;
    sh22.brush.color := clWhite;
    sh23.brush.color := clWhite;
    sh24.brush.color := clWhite;
    sh31.brush.color := clWhite;
    sh32.brush.color := clWhite;
    sh33.brush.color := clWhite;
    sh34.brush.color := clWhite;
    sh41.brush.color := clWhite;
    sh42.brush.color := clWhite;
    sh43.brush.color := clWhite;
    sh44.brush.color := clWhite;
end;

//WHEN THE MOUSE ENTERS THE BOX
procedure TfrmWepTable.boxMouseEnter(Sender: TObject);
var who : TShape;
begin
   //typecast it
   who := Sender as TShape;
   //change the colour
   who.brush.color := clYellow;
end;

//WHEN THE MOUSE LEAVES THE BOX
procedure TfrmWepTable.boxMouseLeave(Sender: TObject);
var who : TShape;
begin
   //typecast it
   who := Sender as TShape;
   //change the color back
   who.brush.color := clWhite;

end;

end.

