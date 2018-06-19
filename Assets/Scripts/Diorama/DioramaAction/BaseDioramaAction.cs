using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

[Serializable]
public abstract class BaseDioramaAction
{
    public abstract void triggerEnd();
	public abstract void triggerBegin();

}