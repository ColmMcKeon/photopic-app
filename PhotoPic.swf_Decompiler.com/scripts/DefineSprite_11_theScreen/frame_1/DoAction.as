function LoadThums()
{
   GrwoNum = 1;
   i = 0;
   while(i < _root.PhotoArray.length)
   {
      ArrayindexNum = i;
      ThumNailName = _root.PhotoArray[i];
      ThumNailName = "P" + String(ThumNailName);
      FirstSearch = ThumNailName.indexOf(".");
      LastPart = ThumNailName.substr(0,FirstSearch);
      ThumNailName = LastPart;
      attachMovie("ThumbnailContainer",ThumNailName,this.getNextHighestDepth());
      if(PhotoCount < 5)
      {
         PhotoCount += 1;
         this[ThumNailName]._x = Startx;
         this[ThumNailName]._y = Starty;
      }
      else
      {
         Startx = 12.3;
         Starty += yincr;
         this[ThumNailName]._x = Startx;
         this[ThumNailName]._y = Starty;
         PhotoCount = 1;
      }
      this[ThumNailName].ThumNumb = ArrayindexNum;
      loadMovie("Photos/" + _root.PhotoArray[i],this[ThumNailName].inset);
      Startx += xincr;
      _root.TheBOttom.PageNumSetUP();
      GrwoNum = Number(GrwoNum + 1);
      _root.WaitScrenwin.countScreen.text = GrwoNum;
      i++;
   }
   _root.WaitScrenwin._x = -800;
}
function HideAll(slot_MC)
{
   i = 0;
   while(i < _root.PhotoArray.length)
   {
      ThumNailName = _root.PhotoArray[i];
      ThumNailName = "P" + String(ThumNailName);
      FirstSearch = ThumNailName.indexOf(".");
      LastPart = ThumNailName.substr(0,FirstSearch);
      ThumNailName = LastPart;
      if(ThumNailName != slot_MC)
      {
         this[ThumNailName]._visible = false;
      }
      i++;
   }
}
function ShowAll()
{
   i = 0;
   while(i < _root.PhotoArray.length)
   {
      ThumNailName = _root.PhotoArray[i];
      ThumNailName = "P" + String(ThumNailName);
      FirstSearch = ThumNailName.indexOf(".");
      LastPart = ThumNailName.substr(0,FirstSearch);
      ThumNailName = LastPart;
      this[ThumNailName]._visible = true;
      i++;
   }
}
function CyclePhotos(thePhoto, PlusMinusNum)
{
   this[thePhoto].ClickMe(1);
   LastPart = thePhoto.substr(1);
   ArrayItem = LastPart;
   i = 0;
   while(i < _root.PhotoArray.length)
   {
      itemInLine = String(_root.PhotoArray[i]);
      FirstdotSearch = itemInLine.indexOf(".");
      LastItemCut = itemInLine.substr(0,FirstdotSearch);
      ArrayName = LastItemCut;
      if(ArrayName == ArrayItem)
      {
         indexStart = i;
         indexStart += PlusMinusNum;
         lastItemInArray = Number(_root.PhotoArray.length - 1);
         if(indexStart < 0)
         {
            indexStart = lastItemInArray;
         }
         if(indexStart > lastItemInArray)
         {
            indexStart = 0;
         }
         nextPic = _root.PhotoArray[indexStart];
         nextPic = "P" + nextPic;
         FirstNextPicSearch = nextPic.indexOf(".");
         LastNextPicPart = nextPic.substr(0,FirstNextPicSearch);
         this[LastNextPicPart].ClickMe(1);
      }
      i++;
   }
}
Startx = 12.3;
Starty = 18.4;
xincr = 129;
yincr = 120.9;
PhotoCount = 0;
GrwoNum = 0;
