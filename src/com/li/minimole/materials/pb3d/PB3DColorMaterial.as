package com.li.minimole.materials.pb3d
{

	import com.li.minimole.core.Core3D;
	import com.li.minimole.core.Mesh;
	import com.li.minimole.core.utils.ColorUtils;
	import com.li.minimole.core.vo.RGB;
	import com.li.minimole.lights.PointLight;
	import com.li.minimole.materials.IColorMaterial;

	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix3D;

	/*
	 Solid color material (no shading).
	 */
	public class PB3DColorMaterial extends PB3DMaterialBase implements IColorMaterial
	{
		[Embed (source="kernels/vertex/default/vertexProgram.pbasm", mimeType="application/octet-stream")]
		private static const VertexProgram:Class;

		[Embed (source="kernels/material/solidcolor/materialVertexProgram.pbasm", mimeType="application/octet-stream")]
		private static const MaterialVertexProgram:Class;

		[Embed (source="kernels/material/solidcolor/fragmentProgram.pbasm", mimeType="application/octet-stream")]
		private static const FragmentProgram:Class;

		private var _color:Vector.<Number> = Vector.<Number>( [1.0, 1.0, 1.0, 1.0] );

		public function PB3DColorMaterial( color:uint = 0xFFFFFF )
		{
			super();
			this.color = color;
		}

		override protected function buildProgram3d():void
		{
			// Translate PB3D to AGAL and build program3D.
			initPB3D( VertexProgram, MaterialVertexProgram, FragmentProgram );
		}

		override public function drawMesh( mesh:Mesh, light:PointLight ):void
		{
			// Set program.
			_context3d.setProgram( _program3d );

			// Set params.
			var modelViewProjectionMatrix:Matrix3D = new Matrix3D();
			modelViewProjectionMatrix.append( mesh.transform );
			modelViewProjectionMatrix.append( Core3D.instance.camera.viewProjectionMatrix );
			_parameterBufferHelper.setMatrixParameterByName( Context3DProgramType.VERTEX, "objectToClipSpaceTransform", modelViewProjectionMatrix, true );
			_parameterBufferHelper.setNumberParameterByName( Context3DProgramType.FRAGMENT, "colorParam", _color );
			_parameterBufferHelper.update();

			// Set attributes and draw.
			_context3d.setVertexBufferAt( 0, mesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3 );
			_context3d.drawTriangles( mesh.indexBuffer );
		}

		override public function deactivate():void
		{
			_context3d.setVertexBufferAt( 0, null );
		}

		public function get color():uint
		{
			return _color[0] * 255 << 16 | _color[1] * 255 << 8 | _color[2] * 255;
		}

		public function set color( value:uint ):void
		{
			var rgb:RGB = ColorUtils.hexToRGB( value );
			_color = Vector.<Number>( [rgb.r / 255, rgb.g / 255, rgb.b / 255, 1.0] );
		}
	}
}
