package love.math;

import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class Transform extends Object
{

	public function apply(other:Transform) : Transform;

	public function clone() : Transform;

	public function getMatrix() : TransformGetMatrixResult;

	public function inverse() : Transform;

	public function inverseTransformPoint(localX:Float, localY:Float) : TransformInverseTransformPointResult;

	public function isAffine2DTransform() : Bool;

	public function reset() : Transform;

	public function rotate(angle:Float) : Transform;

	public function scale(sx:Float, ?sy:Float) : Transform;

	@:overload(function (layout:MatrixLayout, e1_1:Float, e1_2:Float, e1_3:Float, e1_4:Float, e2_1:Float, e2_2:Float, e2_3:Float, e2_4:Float, e3_1:Float, e3_2:Float, e3_3:Float, e3_4:Float, e4_1:Float, e4_2:Float, e4_3:Float, e4_4:Float) : Transform {})
	@:overload(function (layout:MatrixLayout, matrix:Table<Dynamic,Dynamic>) : Transform {})
	@:overload(function (layout:MatrixLayout, matrix:Table<Dynamic,Dynamic>) : Transform {})
	public function setMatrix(e1_1:Float, e1_2:Float, e1_3:Float, e1_4:Float, e2_1:Float, e2_2:Float, e2_3:Float, e2_4:Float, e3_1:Float, e3_2:Float, e3_3:Float, e3_4:Float, e4_1:Float, e4_2:Float, e4_3:Float, e4_4:Float) : Transform;

	public function setTransformation(x:Float, y:Float, ?angle:Float, ?sx:Float, ?sy:Float, ?ox:Float, ?oy:Float, ?kx:Float, ?ky:Float) : Transform;

	public function shear(kx:Float, ky:Float) : Transform;

	public function transformPoint(globalX:Float, globalY:Float) : TransformTransformPointResult;

	public function translate(dx:Float, dy:Float) : Transform;
}

@:multiReturn
extern class TransformTransformPointResult
{
	var localX : Float;
	var localY : Float;
}

@:multiReturn
extern class TransformGetMatrixResult
{
	var e1_1 : Float;
	var e1_2 : Float;
	var e1_3 : Float;
	var e1_4 : Float;
	var e2_1 : Float;
	var e2_2 : Float;
	var e2_3 : Float;
	var e2_4 : Float;
	var e3_1 : Float;
	var e3_2 : Float;
	var e3_3 : Float;
	var e3_4 : Float;
	var e4_1 : Float;
	var e4_2 : Float;
	var e4_3 : Float;
	var e4_4 : Float;
}

@:multiReturn
extern class TransformInverseTransformPointResult
{
	var globalX : Float;
	var globalY : Float;
}