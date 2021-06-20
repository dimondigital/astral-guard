/**
 * Created by Sith on 27.08.14.
 */
package levels.bg
{
import custom.ClipLabel;
import custom.CustomMovieClip;

import flash.display.MovieClip;

import player.MovableModel;

public class BgUnreal extends CustomMovieClip
{
    /*CONSTRUCTOR*/
    public function BgUnreal(x:Number, y:Number, height:Number, width:Number)
    {
        var view:MovieClip = new McUnrealBg();
        var model:MovableModel = new MovableModel();
        clipLabels = new Vector.<ClipLabel>();
        clipLabels.push(new ClipLabel(ClipLabel.WALK, 1, 1));
        super(this, model, view, x, y, height, width);
        addChild(view);
        playState(ClipLabel.WALK);
    }
}
}
