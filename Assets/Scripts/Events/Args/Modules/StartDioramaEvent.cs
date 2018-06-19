using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class StartDioramaEvent : EventArgs
{
    public StartDioramaEvent(string _dioramaName)
    {
        dioramaName = _dioramaName;
    }

    public string dioramaName;
}
