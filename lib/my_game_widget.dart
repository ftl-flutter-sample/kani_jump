import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';

/// MyGameWidget取得
Widget getMyGameWidget() => GameWidget(game: MyGame());

/// 背景用コンポ－ネントクラス
class Background extends SpriteComponent with HasGameRef {
  Background({required Vector2 targetSize, required Vector2 targetPosition}) : _targetSize = targetSize, _targetPosition = targetPosition;

  /// ターゲットサイズ
  final Vector2 _targetSize;

  /// ターゲット位置
  final Vector2 _targetPosition;

  /// ロードイベント
  ///
  /// targetSizeに収まるようにする。
  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite("background_pedestrian_crossing.png");
    size = _fittedSize(sprite!.originalSize, _targetSize);
    position = (_targetPosition - size * 0.5);
  }

  /// サイズフィッティング
  ///
  /// アスペクト比を変更せずにターゲットサイズにフィットするサイズを計算する。
  Vector2 _fittedSize(Vector2 originalSize, Vector2 targetSize) {
    double xRatio = originalSize.x / targetSize.x;
    double yRatio = originalSize.y / targetSize.y;
    return originalSize / ((xRatio > yRatio)? xRatio : yRatio);
  }
}

/// プレーヤー用コンポ－ネントクラス
class Player extends SpriteComponent with HasGameRef, TapCallbacks {
  Player({required Vector2 targetSize, required Vector2 targetPosition, void Function()? onTapDown})
      : _targetSize = targetSize, _targetPosition = targetPosition, _onTapDown = onTapDown;

  /// ターゲットサイズ
  final Vector2 _targetSize;

  /// ターゲット位置
  final Vector2 _targetPosition;

  /// タップDownイベント
  final void Function()? _onTapDown;

  /// ロードイベント
  ///
  /// targetSizeに収まるようにする。
  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite("player_kani_1gou.png");
    size = _fittedSize(sprite!.originalSize, _targetSize);
    position = (_targetPosition - size * 0.5);
  }

  /// タップDownイベント
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (_onTapDown != null) {
      _onTapDown();
    }
  }

  /// サイズフィッティング
  ///
  /// アスペクト比を変更せずにターゲットサイズにフィットするサイズを計算する。
  Vector2 _fittedSize(Vector2 originalSize, Vector2 targetSize) {
    double xRatio = originalSize.x / targetSize.x;
    double yRatio = originalSize.y / targetSize.y;
    return originalSize / ((xRatio > yRatio)? xRatio : yRatio);
  }
}

/// マイゲームクラス
class MyGame extends FlameGame {
  // コンポーネント
  late Background _background;
  late Player _player;

  /// ロードイベント
  @override
  Future<void> onLoad() async {
    super.onLoad();
    // コンポーネントインスタンス生成
    _background = Background(targetSize: size, targetPosition: size * 0.5);
    _player = Player(
      targetSize: size * 0.3,
      targetPosition: Vector2(size.x * 0.5, size.y * 0.7),
      onTapDown: () {
        // ジャンプ動作アニメーション
        //  - 50%の高さまでジャンプする。頂点までは0.3sで移動する。
        final MoveByEffect effect = MoveByEffect(
          Vector2(0, -size.y * 0.5),
          EffectController(
            duration: 0.3,
            curve : Curves.easeInOut,
            reverseDuration: 0.3,
          ),
        );
        _player.add(effect);
      }
    );
    // 追加
    await add(_background);
    await add(_player);
  }
}
