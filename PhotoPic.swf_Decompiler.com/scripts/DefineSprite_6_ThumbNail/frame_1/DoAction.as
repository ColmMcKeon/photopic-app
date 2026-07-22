this.onPress = function()
{
   _parent.startDrag(false);
   trace(_parent.name + " " + this._name);
};
this.onRelease = function()
{
   _parent.stopDrag();
};
