function ClickMe(PhotoIsUP)
{
   if(ThumClick == "Set")
   {
      _root.itemShowing = this._name;
      ThumClick = "unset";
      _parent.HideAll(this._name);
      _root.theScreen.HiLight._height = 4;
      _root.theScreen.HiLight._width = 4;
      _root.theScreen.HiLight._x = 32;
      _root.theScreen.HiLight._y = 310;
      if(PhotoIsUP != 1)
      {
         _root.TheBOttom.Whatis.text = "Photo";
         _root.TheBOttom.AtPage.text = thePhotoNum;
         _root.TheBOttom.PicPage.text = totalPhotoNum;
         growObj(this._name,rawHeight,5,rawWidth,5);
         moveObj(this._name,_root.TheBOttom.ViewPosX,5,_root.TheBOttom.ViewPosY,5);
      }
      else
      {
         _root.TheBOttom.Whatis.text = "Photo";
         _root.TheBOttom.AtPage.text = thePhotoNum;
         _root.TheBOttom.PicPage.text = totalPhotoNum;
         this._x = _root.TheBOttom.ViewPosX;
         this._y = _root.TheBOttom.ViewPosY;
         this._height = rawHeight;
         this._width = rawWidth;
      }
   }
   else
   {
      _root.itemShowing = "nothing";
      ThumClick = "Set";
      if(PhotoIsUP != 1)
      {
         _root.TheBOttom.Whatis.text = "Page";
         _root.TheBOttom.AtPage.text = _root.TheBOttom.PageNum;
         _root.TheBOttom.PicPage.text = _root.TheBOttom.pageAmount;
         moveObj(this._name,Xpos,5,Ypos,5,"big");
         growObj(this._name,thumHeight,5,thumWidth,5);
      }
      else
      {
         _root.TheBOttom.Whatis.text = "Page";
         _root.TheBOttom.AtPage.text = _root.TheBOttom.PageNum;
         _root.TheBOttom.PicPage.text = _root.TheBOttom.pageAmount;
         this._x = Xpos;
         this._y = Ypos;
         this._height = Number(thumHeight);
         this._width = Number(thumWidth);
      }
      _parent.ShowAll(this._name);
   }
}
function moveObj(target, new_x, speed_x, new_y, speed_y, growSm)
{
   winLev = this.getNextHighestDepth();
   PosNewMovClip = "W" + this._name;
   if(_root.theScreen[target]._x < new_x || _root.theScreen[target]._y < new_y || _root.theScreen[target]._x > new_x || _root.theScreen[target]._y > new_y)
   {
      this.createEmptyMovieClip(PosNewMovClip,winLev);
      this[PosNewMovClip].onEnterFrame = function()
      {
         var _loc4_ = _root.theScreen[target]._x;
         var _loc3_ = _root.theScreen[target]._y;
         _root.theScreen[target]._x += (new_x - _loc4_) / speed_x;
         _root.theScreen[target]._y += (new_y - _loc3_) / speed_y;
         if(Math.floor(_root.theScreen[target]._x) == Math.floor(new_x) && Math.floor(_root.theScreen[target]._y) == Math.floor(new_y) || Math.ceil(_root.theScreen[target]._x) == Math.ceil(new_x) && Math.ceil(_root.theScreen[target]._y) == Math.ceil(new_y))
         {
            this.removeMovieClip();
         }
      };
   }
   if(growSm == "big")
   {
      theQuestionPage = Math.ceil(new_y / 483.5);
      adjNum = Math.ceil(theQuestionPage - 1);
      finNum = Math.ceil(adjNum * -483.5);
      _root.theScreen._y = finNum;
      finNum *= -1;
      _root.TheBOttom.ViewPosY = finNum;
      _root.TheBOttom.AtPage.text = theQuestionPage;
      _root.TheBOttom.PageNum = theQuestionPage;
   }
}
function growObj(gtarget, new_height, speed_height, new_width, speed_width)
{
   winLev = this.getNextHighestDepth();
   SizNewMovClip = "X" + this._name;
   if(_root.theScreen[gtarget]._height < new_height || _root.theScreen[gtarget]._width < new_width || _root.theScreen[gtarget]._height > new_height || _root.theScreen[gtarget]._width > new_width)
   {
      this.createEmptyMovieClip(SizNewMovClip,winLev);
      this[SizNewMovClip].onEnterFrame = function()
      {
         var _loc4_ = _root.theScreen[gtarget]._height;
         var _loc3_ = _root.theScreen[gtarget]._width;
         _root.theScreen[gtarget]._height += (new_height - _loc4_) / speed_height;
         _root.theScreen[gtarget]._width += (new_width - _loc3_) / speed_width;
         if(Math.floor(_root.theScreen[gtarget]._height) == Math.floor(new_height) && Math.floor(_root.theScreen[gtarget]._width) == Math.floor(new_width) || Math.ceil(_root.theScreen[gtarget]._height) == Math.ceil(new_height) && Math.ceil(_root.theScreen[gtarget]._width) == Math.ceil(new_width))
         {
            this.removeMovieClip();
         }
      };
   }
}
thumWidth = 100;
thumHeight = 80;
ThumClick = "Set";
h_limit = 480;
w_limit = 640;
thePhotoNum = Number(this.ThumNumb + 1);
totalPhotoNum = _root.PhotoArray.length;
this.onEnterFrame = function()
{
   if(this._width > 110 && this._height > 95)
   {
      rawWidth = this._width;
      rawHeight = this._height;
      Xpos = this._x;
      Ypos = this._y;
      if(rawHeight > rawWidth)
      {
         this.photoview = "UP";
         aspectRat = rawWidth / rawHeight;
         if(rawHeight > 480)
         {
            rawHeight = h_limit;
            rawWidth = Math.ceil(rawHeight * aspectRat);
         }
         thumWidth = Math.ceil(thumHeight * aspectRat);
      }
      else if(rawWidth >= rawHeight)
      {
         this.photoview = "Side";
         aspectRat = rawHeight / rawWidth;
         if(rawWidth > 640)
         {
            rawWidth = w_limit;
            rawHeight = Math.ceil(rawWidth * aspectRat);
         }
         thumHeight = Math.ceil(thumWidth * aspectRat);
      }
      this._width = thumWidth;
      this._height = thumHeight;
      delete this.onEnterFrame;
   }
};
this.onRollOver = function()
{
   _root.theScreen.HiLight._height = thumHeight + 6;
   _root.theScreen.HiLight._width = thumWidth + 6;
   _root.theScreen.HiLight._x = this._x - 3;
   _root.theScreen.HiLight._y = this._y - 3;
};
this.onRollOut = function()
{
   _root.theScreen.HiLight._height = 4;
   _root.theScreen.HiLight._width = 4;
   _root.theScreen.HiLight._x = 32;
   _root.theScreen.HiLight._y = 310;
};
this.onPress = function()
{
   ClickMe(2);
};
