function LoadXmlData()
{
   PhotoXML.onLoad = function(success)
   {
      if(success)
      {
         clearInterval(pollingxml);
         WaitScrenwin._x = 206;
         WaitScrenwin._y = 186;
         PlacePromtWin._x = -580;
         PlacePromtWin._y = -68;
         child = PhotoXML.firstChild.childNodes;
         i = 0;
         while(i < child.length)
         {
            PhotoArray.push(child[i].firstChild);
            i++;
         }
         WaitScrn();
      }
      else if(ErrorFlag != "on")
      {
         PlacePromtWin.winInfoTxtScreen.text = "Place your .jpg\'s in the Photos folder and click here.";
         PlacePromtWin._x = 191;
         PlacePromtWin._y = 186;
         ErrorFlag = "on";
      }
   };
   PhotoXML.load("Photos/photos.xml");
}
function firstlist()
{
   PlacePromtWin.winInfoTxtScreen.text = "Please wait..";
   fscommand("exec","PhotoManager.exe");
   pollingxml = setInterval(function()
   {
      LoadXmlData();
   }
   ,2000);
}
function WaitScrn()
{
   WaitScrenwin.statusMes.text = "Loading Images..";
   time = getTimer();
   later = time + 2000;
   this.createEmptyMovieClip("temp6",this.getNextHighestDepth());
   temp6.onEnterFrame = function()
   {
      time = getTimer();
      if(time >= later)
      {
         delete this.onEnterFrame;
         theScreen.LoadThums();
      }
   };
}
this._lockroot = true;
itemShowing = "nothing";
PhotoXML = new XML();
PhotoArray = new Array();
PhotoXML.ignoreWhite = true;
LoadXmlData();
this.onEnterFrame = function()
{
   theStageThing._Height = 480;
   theStageThing._Width = 640;
};
ReturnCall = new Object();
ReturnCall.onKeyDown = function()
{
   if(Key.getCode() == 39)
   {
      _root.TheBOttom.RightBtnAction();
   }
   else if(Key.getCode() == 37)
   {
      _root.TheBOttom.LeftBtnAction();
   }
};
Key.addListener(ReturnCall);
