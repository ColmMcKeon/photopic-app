function statePage(PluMinus)
{
   PageNum = Number(PageNum + PluMinus);
   AtPage.text = PageNum;
   if(PluMinus == 1)
   {
      ViewPosY += pageINcVal;
   }
   else
   {
      ViewPosY -= pageINcVal;
   }
}
function PageNumSetUP()
{
   PageSze = _root.theScreen._height;
   pageAmount = PageSze / pageINcVal;
   pageAmount = Math.ceil(pageAmount);
   if(_root.theScreen._height == 555.9)
   {
      pageAmount = 1;
   }
   PicPage.text = pageAmount;
}
function RightBtnAction()
{
   if(_root.itemShowing != "nothing")
   {
      _root.theScreen.CyclePhotos(_root.itemShowing,1);
   }
   else if(this.PageNum < this.pageAmount)
   {
      _root.theScreen._y -= this.pageINcVal;
      statePage(1);
   }
}
function LeftBtnAction()
{
   if(_root.itemShowing != "nothing")
   {
      Whatis.text = "Photo";
      _root.theScreen.CyclePhotos(_root.itemShowing,-1);
   }
   else if(this.PageNum > 1)
   {
      Whatis.text = "Page";
      _root.theScreen._y += this.pageINcVal;
      statePage(-1);
   }
}
ViewPosX = 0;
ViewPosY = 0;
pageINcVal = 483.5;
PageNum = 1;
AtPage.text = PageNum;
Whatis.text = "Page";
