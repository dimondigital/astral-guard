/**
 * Created by Sith on 03.07.14.
 */
package levelStuff.bosses.concreteBosses
{
import custom.ClipLabel;
import custom.CustomEvent;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.geom.Point;
import levelStuff.bosses.ABoss;
import levelStuff.bosses.IBoss;
import levelStuff.bosses.Step;
import levelStuff.bosses.StepPoint;
import levelStuff.bosses.StepPoint;
import levelStuff.bosses.StepPoint;
import levelStuff.bosses.StepPoint;
import levelStuff.bullets.BossCastleShell;
import levelStuff.bullets.BossUnrealShoot;
import levelStuff.bullets.BossVolcanoShoot;
import levelStuff.bullets.BossVolcanoSpecialShoot;
import levelStuff.bullets.BulletController;
import levelStuff.bullets.CrownShell;
import levelStuff.bullets.DesertLaser;
import levelStuff.bullets.DesertShell;
import levelStuff.bullets.FallingCastleCeil;
import levelStuff.bullets.IBullet;
import levelStuff.enemies.BossUnrealCocoon;
import levelStuff.enemies.EList;
import levelStuff.enemies.MeteorShield;
import levelStuff.bullets.Mine;
import levelStuff.controllers.EnemyController;
import levelStuff.enemies.IEnemy;
import levelStuff.enemies.Trajectory;
import levelStuff.treasures.TList;
import player.PlayerController;
import xmlParsingTiledLevel.LevelObject;

public class BossLordOfUnreal extends ABoss implements IEnemy, IBoss
{
    private var _o:LevelObject;
    private var _player:PlayerController;
    private var _bulletController:BulletController;
    private var _gameScreen:Sprite;
    private var _enemyController:EnemyController;

    private var _fallingPlatformAmount:int; // количество  платформ, падающих с потолка

    /* CONSTRUCTOR */
    public function BossLordOfUnreal(o:LevelObject, player:PlayerController, bulletController:BulletController, gameScreen:Sprite, enemyController:EnemyController)
    {
        initLabels();
        _o = o;
        _player = player;
        _bulletController = bulletController;
        _gameScreen = gameScreen;
        _enemyController = enemyController;
        var view:MovieClip = new McBossLordOfUnreal();
        var startPoint:Point = o.getPathTriggerCenter(5);
        super(view, startPoint.x-44, startPoint.y-55, 88, 110, 0, EList.getBossHealth(BossLordOfUnreal), 0.1, [TList.GREEN_COIN, TList.BLUE_COIN], _player);
    }

    /* INIT LABELS */
    private function initLabels():void
    {
        clipLabels = new Vector.<ClipLabel>();
        clipLabels.push(new ClipLabel(ClipLabel.WALK, 8, 0.5));
        clipLabels.push(new ClipLabel(ClipLabel.SHOOT, 1, 0.4));
    }

    /* INIT */
    private var shakePoint:Point;
    public override function init():void
    {
        initStrategy(_o);
        _currentStrategy = _commonStrategy;
        _currentStep = _currentStrategy[0];

//        shakePoint = _o.getPathTriggerCenter(5);
        _fallingPlatformAmount = 4;
    }

    /* INIT STRATEGY */
    private var step1:Step;
    private var step2:Step;
    private var step3:Step;
    public function initStrategy(o:LevelObject):void
    {
        _commonStrategy = new Vector.<Step>();
        _angryStrategy = new Vector.<Step>();
        // init points
        /* STEP 1
         Появляется в точке 1. Стреляет  */
        var pathTriggers1:Array = [2, 6, 3, 5, 1, 4, 2];
        var step1_path:Vector.<StepPoint> = ABoss.buildPath(o, 1, pathTriggers1);
        var step1_speed:Number = 1.5;
        var step1_trajectory:Trajectory = new Trajectory(view, step1_path[0].x, step1_path[0].y, 0, Trajectory.TWEENMAX_TO_POINT, step1_speed, step1_speed);
        step1 = new Step(Step.SHOOT, step1_trajectory, step1_path, step1_speed, step1_speed, 0, true, 0, 1000);
        /* STEP 2
         * Передвигается по пути 2 - 4 - 1 - 3 - 2 * */
        var pathTriggers2:Array = [1, 5, 3];
        var step2_path:Vector.<StepPoint> = ABoss.buildPath(o, 2, pathTriggers2);
        var step2_speed:Number = 0.5;
        var step2_trajectoryType:String = Trajectory.TWEENMAX_TO_POINT;
        var step2_trajectory:Trajectory = new Trajectory(view, step2_path[0].x, step2_path[0].y, 0, step2_trajectoryType, step2_speed, step2_speed);
        step2 = new Step(Step.SPECIAL_SHOOT, step2_trajectory, step2_path, step2_speed, step2_speed, 10, true, 0, 1500);


        // COMMON STRATEGY
//        _commonStrategy.push(step1, step2, step3);
        _commonStrategy.push(step1, step2);
        // ANGRY STRATEGY
//        _angryStrategy.push(step1, step2, step3);
    }

    /* ANGRY */
    protected override function angry():void
    {
        if(_commonStrategy.length < 3) _commonStrategy.push(step2);
    }

    /* SET NEW POINT */
    public override function curPoint(pnt:StepPoint):void
    {
        /*if(pnt == shakePoint)
         {
         // shake game screen
         _view.dispatchEvent(new CustomEvent(CustomEvent.SHAKE_GAMESCREEN, BossLordOfCastle, true, false, {duration:0.1, repeatCount:10, randomRange:7}));
         // falling platforms
         for (var i:int = 0; i < _fallingPlatformAmount; i++)
         {
         var randomX:Number = (Math.random() * 170) + 90;
         var Y:Number = _gameScreen.y+40;
         var shell:FallingCastleCeil = new FallingCastleCeil(randomX, Y, _player.view.x, _player.view.y, true);
         _bulletController.addBullet(shell, _player);
         }
         }*/
    }

    /* SHOOT */
    private var _specialShootCounter:int = 0;
    private var _laser:DesertLaser;
    public override function shoot(e:TimerEvent):void
    {
        if(_currentStep.stepName == Step.SHOOT)
        {
            if(_currentStep.shootAmount > 0)
            {
                _currentStep.shootAmount--;
                if(_currentStep.shootAmount <= 0)
                {
                    stopShoot();
                    setNewCurrentTargetPoint();
                    return;
                }
            }

            var radius:uint = 20;
            var delta:int = 180 / 3;
            var randomOffset:int = Math.ceil(Math.random()*10);
            var angle:Number;
            for (var i:int = 0; i < 3; i++)
            {
                angle = -((i * (delta+randomOffset) * Math.PI)/180);
                var pos:Point = Point.polar(radius, angle);
                var shell:BossUnrealShoot = new BossUnrealShoot(pos.x+_view.x, pos.y+_view.y, _view.x, _view.y, true);
//                shell.view.rotation = angle * 180 / Math.PI;
                _bulletController.addBullet(shell, _player);
            }
//            _view.dispatchEvent(new CustomEvent(CustomEvent.ENEMY_SHOOT, BossLordOfFire, true, false,
//                    {startX:_view.x, startY:_view.y, targetX:_player.view.x, targetY:_player.view.y, bulletClass:BossUnrealShoot}));
            playState(ClipLabel.SHOOT, null, ClipLabel.WALK);
        }
        else if(_currentStep.stepName == Step.SPECIAL_SHOOT)
        {
            var cocoon:BossUnrealCocoon = new BossUnrealCocoon(view.x, view.y, _player.view.x, _player.view.y, false, view, _gameScreen, _player, [15]);
            _enemyController.updateEnemy(cocoon);

            playState(ClipLabel.SHOOT, null, ClipLabel.WALK);
        }
    }
}
}
