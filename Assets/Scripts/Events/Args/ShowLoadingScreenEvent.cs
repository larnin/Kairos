using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class ShowLoadingScreenEvent : EventArgs
{
    public ShowLoadingScreenEvent(bool _show)
    {
        show = _show;
    }

    public bool show;
}