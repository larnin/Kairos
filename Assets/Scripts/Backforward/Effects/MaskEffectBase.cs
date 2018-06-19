using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public abstract class MaskEffectBase
{
    public abstract void exec(MaskLogic mask);

    protected void onEndEffect()
    {
        Event<MaskEffectEndEvent>.Broadcast(new MaskEffectEndEvent());
    }
}
