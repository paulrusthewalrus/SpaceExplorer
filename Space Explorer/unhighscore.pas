unit unHighscore;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type
  user = record
    name : string[40];
    score: integer;
  end;

  { TfrmHighscore }

  TfrmHighscore = class(TForm)
    btnBack: TButton;
    imgBack: TImage;
    labTitle: TLabel;
    memLoad: TMemo;
    memFinal: TMemo;
    shTitleBack: TShape;
    shMemBack: TShape;
    procedure btnBackClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure loadscore;
    procedure sort;
    procedure setup;
  private

  public

  end;

var
  frmHighscore: TfrmHighscore;

implementation

uses unMain;

{$R *.lfm}

{ TfrmHighscore }

//GLOBAL VARS
Var group : array of integer;
    dict     : array of user;
    spawn    : boolean;
    hide     : boolean;
    lengroup : integer;

//SETUP THE SCORES ON THE MEMFINAL
procedure TfrmHighScore.setup;
var i,rank,k : byte;
    len      : byte;
    plate,nm : string;
    score    : integer;
    del      : boolean;
    max      : byte;
begin
  //setup del boolean
  del := true;
  //find the length of the unsorted array
  len := length(group);
  //if the length is greater or equal to 10
  if (len > 10)
       //set the length var to 10
       then len := 9;
  //setup a ranking var (starting at 1)
  rank := 1;

  //do this for as many times as num length (Setup the memo box)
  for i := len downto 0 do
     begin
       //showmessage(inttostr(memFinal.lines.count));
       //get the score
       score := group[i];
       //search for the score in dict, if it's found
       for k := 0 to length(dict) do
          //check if the value equals score
          if (dict[k].score = score)
               //find the name
               then nm := dict[k].name;
                    //showmessage(nm);

       //plate it up as ranking var) name : score
       plate := '  '+inttostr(rank-1)+') '+nm+' : '+inttostr(score);
       //add it to the memFinal
       memFinal.Lines.add(plate);
       //memFinal.Lines.add('');
       //inc the ranking
       inc(rank);

     end;

  //clear plate
  plate := '';
  //mem final fail safe
  {for i := 0 to (memFinal.lines.count)-1 do
     begin
       //showmessage(memFinal.lines[i]);
       for k := 1 to length(memFinal.lines[i])-1 do
          begin
            //showmessage(inttostr(length(memFinal.lines[i])));
            //showmessage(memFinal.lines[i][k]);
            //add it to the plate
            plate := plate + memFinal.lines[i][k];
            //showmessage(plate);
            //check the plate
            if (plate = '  0)')
                 then memFinal.lines.Strings[i] := '';
                      //showmessage('this');
          end;
       //clear plate
       plate := '';
        {if (memFinal.lines[k] = '0')
             then //memFinal.lines[k] := '';
                  showmessage('this');   }
     end;}
  //setup variables
  max := memFinal.lines.count-1;
  k := 1;
  //mem final fail safe v2 with while
 for i := 0 to max do
    begin
      //while the 0 line hasn't been found
      while del do
          begin
            //add it to the plate
            plate := plate + memFinal.lines[i][k];
            //showmessage(plate);
            //check the plate
            if (plate = '  0)')
                 then begin
                         memFinal.lines.Strings[i] := '';
                         //boolean setup
                         del := false;
                      end;
                      //showmessage('this');
            if (k <> length(memFinal.lines[i]))
                 then inc(k);
          end;
    end;

end;

//LOAD THE SCORES
procedure TfrmHighScore.loadscore;
var count     : byte; //counts how many lines
    notfound  : boolean; //searching boolean
    temp,line : string; //stores the parsed variable
    i,k       : byte; //for going through the lines
    nm        : string; //name storage
    score     : integer; //score storage
begin
  //clear the memFinal and memLoad
  memFinal.lines.clear;
  memLoad.lines.clear;
  //load the scores into a memo box
  memLoad.Lines.LoadFromFile('highscores.lsr');
  //count the lines and find how many there are
  count := memLoad.lines.Count-1;
  //set starting lengths of unsorted and dict
  setlength(group,0);
  //increase the length of dict
  setlength(dict,count);
  //for as many lines there are in the memo box, do this algorithm
  for i := 0 to count do
      begin
        //reset temp
        temp := '';
        //setup k var
        k := 1;
        //find the line
        line := memLoad.lines[i];
        //set notfound to true
        notfound := true;
        //memFinal.lines.Add(memLoad.Lines[i]);

        //while notfound go through the line and add all the numbers to a temp
        while (notfound) do
          begin
               //go through the line looking for numbers
               if ((line[k] <> ' ') and not(line.isEmpty))
                  //it is a number, add it to temp
                  then temp := temp + line[k]
                  //it is NOT a number, finish
                  else notfound := false;
               //increment k for next char
               if (notfound)
                  then inc(k);
          end;
        //store in score
        score := strtoint(temp);
        //increase the length of the group array
        setlength(group,length(group)+1);
        //add the number to UNSORTED array (using length index)
        group[length(group)-1] := strtoint(temp);
        //clear temp
        temp := '';
        //set notfound to true
        notfound := true;
        //reset k
        k := 1;

        //while notfound go through the line and look for any letters (add any letters to a temp)
        {while (notfound) do
            begin
               //check if the char is a letter
               if ((line[k] in ['a'..'z']) or (line[k] in ['A'..'Z']))
              //if ((line[k] <> '') or (line[k] <> ' '))
                  //if it is add it to the temp
                  then temp := temp + line[k]
                  //check the length comparison to where k is
                  else begin
                         //compare
                         {if (k + 1 > length(line))
                            //probably finished, move out
                            then notfound := false
                            //not finished, keep going ADD IT TO TEMP
                            else temp := temp + line[k]; }
                          notfound := false;
                          showmessage(inttostr(length(temp)));
                       end;
                //increase k if notfound
                inc(k);
            end;      }
         for k := 1 to length(line) do
               //check if the char is a letter
               if ((line[k] in ['a'..'z']) or (line[k] in ['A'..'Z']))
              //if ((line[k] <> '') or (line[k] <> ' '))
                  //if it is add it to the temp
                  then temp := temp + line[k];

        //store in name
        nm := temp;
        //showmessage(nm);

        //add this to dict
        dict[i].name := nm;
        dict[i].score := score;

        //showmessage(dict[0].name);
        //showmessage(dict[1].name);
        {//var length
        lengroup := length(group);
        //delete last
        dec(lengroup);
        //delete last from dict and group
        setlength(dict,lengroup);
        setlength(group,lengroup);}

     end;
  //showmessage(inttostr(memLoad.Lines.count));
  //for i := 0 to length(dict) do
     //memFinal.Lines.add(dict[i].name);
  //showmessage(inttostr(length(dict)));
  //sort the array
  sort;
  //setup the array on the memFinal
  setup;
end;

//SORT THE ARRAY (Insertion Sort) (Thoroughly Commented)
procedure TfrmHighScore.sort;
var i   : integer; //variable for going through the entire array
    k   : integer; //variable for referring back to the indexed number
    len : integer; //variable for the length of the array
    num : integer; //the number that needs to be sorted
begin
  //USE INSERTION SORT TO SORT THE ARRAY
  //(thoroughly commented to show understanding)

  //setup the len variable as length of the array
  len := length(group)-1;

  //i starts on 1 as unsorted[0] is already considered sorted.
  //unsorted[0] can be the 'pivot' element so to speak
  //this goes through every single value in the unsorted array
  for i := 1 to len do
    begin
      //the number that needs to be sorted
      num := group[i];
      //the index of the number TO TEST
      k := i;
      //whilst the index is larger than 0 (because no index -1) (dyn. array)
      //AND the (number before this one) > (current number to be sorted)
      //because the number NEEDS to be smaller than the SORTING num
      while ((k>0) and (group[k-1] > num)) do
          //still haven't found an adequate place to replace the number
          begin
             //try a new comparison number, the one before it
             group[k] := group[k-1];
             //make sure that the said index follows this number
             //This is because the number will have to be INSERTED at this index
             dec(k);
          end;

      //A VALUE HAS BEEN FOUND which meets all required conditions
      //set the current index in the array. Set it to the sorting number
      group[k] := num;
    end;
  //showmessage(inttostr(length(group)));
  {for i := 1 to len do
    begin
      //the number that needs to be sorted
      num := group[i];
      //the index of the number TO TEST
      k := i;
      //whilst the index is larger than 1 (because no index 0)
      //AND the (number before this one) > (current number to be sorted)
      //because the number NEEDS to be smaller than the SORTING num
      while ((k>1) and (group[k-1] > num)) do
          //still haven't found an adequate place to replace the number
          begin
             //try a new comparison number, the one before it
             group[k] := group[k-1];
             //make sure that the said index follows this number
             //This is because the number will have to be INSERTED at this index
             dec(k);
          end;

      //A VALUE HAS BEEN FOUND which meets all required conditions
      //set the current index in the array. Set it to the sorting number
      group[k] := num;

    end;  }

  //test stuff
  //for i := 0 to length(group) do
    //memFinal.lines.add(inttostr(group[i]));

  {//most left hand side value is already sorted hence, i := 1; (2nd num)
  i := 1;
  //find the length of the unsorted array
  len := length(unsorted);
  //go through the dynamic array for as many times there as values
  for i := 1 to len do
       //check if this value is smaller than the previous value
       if (unsorted[i] < unsorted[i-1])
          //insert back when value is the smallest
          then begin

               end; }

end;

//FORM CREATE
procedure TfrmHighscore.FormCreate(Sender: TObject);
begin
   //position form
  frmHighscore.left := 419;
  frmHighscore.top := 144;
  //spawn := true;
  //check
  //check;
end;

//BACK BUTTON
procedure TfrmHighscore.btnBackClick(Sender: TObject);
begin
   //show main form
   frmMain.show;
   //hide this form
   frmHighscore.hide;
end;

end.

//from the sort array, go through it systematically and it to the memFinal

