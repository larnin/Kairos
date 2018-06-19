// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_FolletClothes"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 1
		_TessMin( "Tess Min Distance", Float ) = 10
		_TessMax( "Tess Max Distance", Float ) = 25
		_T_LinearMask1("T_LinearMask1", 2D) = "white" {}
		_Tiling("Tiling", Vector) = (1,1,0,0)
		_RGBtex("RGBtex", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MouvSpeed("MouvSpeed", Float) = 0
		_Emissive("Emissive", Float) = 0
		_DisplacementStrength("DisplacementStrength", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true" "TakeFocus" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows nolightmap  vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		struct appdata
		{
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
			float4 texcoord3 : TEXCOORD3;
			fixed4 color : COLOR;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		uniform sampler2D _RGBtex;
		uniform float4 _RGBtex_ST;
		uniform float _Emissive;
		uniform sampler2D _T_LinearMask1;
		uniform float _MouvSpeed;
		uniform float2 _Tiling;
		uniform float _DisplacementStrength;
		uniform float _Cutoff = 0.5;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64;
		}


		float4 tessFunction( appdata v0, appdata v1, appdata v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata v )
		{
			float2 temp_cast_0 = (_MouvSpeed).xx;
			v.texcoord1.xy = v.texcoord1.xy * _Tiling + float2( 0,0 );
			float2 panner58 = ( v.texcoord1.xy + 1.0 * _Time.y * temp_cast_0);
			float4 uv_RGBtex = float4(v.texcoord * _RGBtex_ST.xy + _RGBtex_ST.zw, 0 ,0);
			float4 tex2DNode2 = tex2Dlod( _RGBtex, uv_RGBtex );
			v.vertex.xyz += ( tex2Dlod( _T_LinearMask1, float4( panner58, 0.0 , 0.0 ) ) * _DisplacementStrength * tex2DNode2.b ).rgb;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_RGBtex = i.uv_texcoord * _RGBtex_ST.xy + _RGBtex_ST.zw;
			float4 tex2DNode2 = tex2D( _RGBtex, uv_RGBtex );
			float3 temp_cast_0 = (tex2DNode2.r).xxx;
			o.Albedo = temp_cast_0;
			float3 temp_cast_1 = (( tex2DNode2.r * _Emissive )).xxx;
			o.Emission = temp_cast_1;
			float temp_output_5_0 = 0.0;
			o.Metallic = temp_output_5_0;
			o.Smoothness = temp_output_5_0;
			o.Alpha = 1;
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 ase_clipPos = ComputeScreenPos( UnityObjectToClipPos( ase_vertex4Pos ) );
			float2 clipScreen17 = ase_clipPos.xy * _ScreenParams.xy;
			float dither17 = Dither8x8Bayer( fmod(clipScreen17.x, 8), fmod(clipScreen17.y, 8) );
			dither17 = step( dither17, tex2DNode2.g );
			clip( dither17 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
7;249;1906;784;1804.384;325.3133;1.449963;True;False
Node;AmplifyShaderEditor.Vector2Node;56;-1490.732,278.5355;Float;False;Property;_Tiling;Tiling;6;0;1,1;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-1272.247,263.3717;Float;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;59;-1256.297,464.9165;Float;False;Property;_MouvSpeed;MouvSpeed;7;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PannerNode;58;-1024.303,274.9713;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;4;-420,154;Float;False;Property;_Emissive;Emissive;9;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-559.55,-52.44994;Float;True;Property;_RGBtex;RGBtex;6;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;9;-763.8965,475.4526;Float;False;Property;_DisplacementStrength;DisplacementStrength;15;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;55;-811.9232,249.9931;Float;True;Property;_T_LinearMask1;T_LinearMask1;5;0;Assets/Textures/T_LinearMask1.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-216,103;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.DitheringNode;17;429.7463,234.8895;Float;False;1;2;0;FLOAT;0.0;False;1;SAMPLER2D;;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;5;-194,12;Float;False;Constant;_Float0;Float 0;3;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-327,402;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;706.165,37.11877;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;Custom/SHD_FolletClothes;False;False;False;False;False;False;True;False;False;False;False;False;False;False;True;False;False;Off;0;0;False;0;0;Masked;0.5;True;True;0;False;TransparentCutout;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;True;0;1;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;7;-1;-1;0;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;57;0;56;0
WireConnection;58;0;57;0
WireConnection;58;2;59;0
WireConnection;55;1;58;0
WireConnection;3;0;2;1
WireConnection;3;1;4;0
WireConnection;17;0;2;2
WireConnection;7;0;55;0
WireConnection;7;1;9;0
WireConnection;7;2;2;3
WireConnection;0;0;2;1
WireConnection;0;2;3;0
WireConnection;0;3;5;0
WireConnection;0;4;5;0
WireConnection;0;10;17;0
WireConnection;0;11;7;0
ASEEND*/
//CHKSM=56208E682A6D61C99E85EFE8015A7A3415311E01