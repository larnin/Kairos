// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_ShadowsAlphaClip_Unlit"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Tiling("Tiling", Range( 0 , 50)) = 2.037486
		_MouvSpeed("MouvSpeed", Float) = 0
		_Paint("Paint", 2D) = "white" {}
		_Color("Color ", Color) = (0,0,0,0)
		_Opacity("Opacity", 2D) = "white" {}
		_Power("Power", Float) = 0
		_BurntEffect("BurntEffect", 2D) = "white" {}
		_EffectTiling("EffectTiling", Float) = 1
		_Ramp("Ramp", 2D) = "white" {}
		_Apparition("Apparition", Range( 0 , 1)) = 1
		_PerlinNoise("PerlinNoise", 2D) = "white" {}
		_PerlinNoiseTiling("PerlinNoiseTiling", Vector) = (0,0,0,0)
		_Scale("Scale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true" "TakeFocus" = "true"}
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float4 _Color;
		uniform sampler2D _Opacity;
		uniform float4 _Opacity_ST;
		uniform sampler2D _Paint;
		uniform float _Tiling;
		uniform float _MouvSpeed;
		uniform float _Power;
		uniform sampler2D _BurntEffect;
		uniform float _EffectTiling;
		uniform sampler2D _Ramp;
		uniform sampler2D _PerlinNoise;
		uniform float2 _PerlinNoiseTiling;
		uniform float _Scale;
		uniform float _Apparition;
		uniform float _Cutoff = 0.5;


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


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = _Color.rgb;
			o.Alpha = 1;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen52 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither52 = Dither8x8Bayer( fmod(clipScreen52.x, 8), fmod(clipScreen52.y, 8) );
			float2 uv_Opacity = i.uv_texcoord * _Opacity_ST.xy + _Opacity_ST.zw;
			float4 appendResult14 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float4 unityObjectToClipPos8 = UnityObjectToClipPos( float3( 0,0,0 ) );
			float4 computeScreenPos9 = ComputeScreenPos( unityObjectToClipPos8 );
			float componentMask10 = computeScreenPos9.w;
			float4 appendResult18 = (float4(( computeScreenPos9 / componentMask10 ).x , ( computeScreenPos9 / componentMask10 ).y , 0.0 , 0.0));
			float4 temp_output_15_0 = ( appendResult14 - appendResult18 );
			float mulTime26 = _Time.y * _MouvSpeed;
			float2 componentMask107 = tex2D( _PerlinNoise, ( appendResult14 * float4( _PerlinNoiseTiling, 0.0 , 0.0 ) ).xy ).rg;
			float temp_output_110_0 = (0.65 + (_Apparition - 0.0) * (0.0 - 0.65) / (1.0 - 0.0));
			float2 temp_cast_6 = (temp_output_110_0).xx;
			float4 blendOpSrc121 = ( 1.0 - tex2D( _BurntEffect, ( temp_output_15_0 * _EffectTiling ).xy ) );
			float4 blendOpDest121 = tex2D( _Ramp, (componentMask107*_Scale + temp_cast_6) );
			dither52 = step( dither52, ( saturate( pow( ( tex2D( _Opacity, uv_Opacity ).r + tex2D( _Paint, ( ( temp_output_15_0 * _Tiling ) + float4( ( float2( 0.1,-1 ) * mulTime26 ), 0.0 , 0.0 ) ).xy ).r ) , _Power ) ) * ( 1.0 - saturate( CalculateContrast(1.5,( saturate( ( blendOpDest121 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest121 - 0.5 ) ) * ( 1.0 - blendOpSrc121 ) ) : ( 2.0 * blendOpDest121 * blendOpSrc121 ) ) ))) ) ) ).r );
			clip( dither52 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
1927;29;1906;1004;193.4945;334.9354;2.387805;True;True
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;8;-2000.711,190.7342;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;9;-1812.769,191.6162;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComponentMaskNode;10;-1590.95,140.4836;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;13;-1166.593,16.97487;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-1337.718,180.4252;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.DynamicAppendNode;14;-906.79,37.30489;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.Vector2Node;103;-1030.584,991.9243;Float;False;Property;_PerlinNoiseTiling;PerlinNoiseTiling;12;0;0,0;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.BreakToComponentsNode;12;-1166.643,205.6552;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;18;-906.5531,205.6665;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-755.6963,974.7606;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;115;343.5218,1135.473;Float;False;Property;_EffectTiling;EffectTiling;8;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;109;-451.6702,1471.304;Float;False;Property;_Apparition;Apparition;10;0;1;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;95;-576.9363,972.3989;Float;True;Property;_PerlinNoise;PerlinNoise;11;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-735.1482,121.6598;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;27;-737.2748,494.9526;Float;False;Property;_MouvSpeed;MouvSpeed;2;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;110;-136.1093,1472.876;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;0.65;False;4;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.Vector2Node;94;-579.0091,262.9326;Float;False;Constant;_Vector0;Vector 0;7;0;0.1,-1;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;17;-1029.281,346.4404;Float;False;Property;_Tiling;Tiling;1;0;2.037486;0;50;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;529.1225,1116.272;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleTimeNode;26;-551.3751,501.4526;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;107;-261.5872,972.6041;Float;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;108;165.9537,1307.658;Float;False;Property;_Scale;Scale;13;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;117;485.257,885.3875;Float;True;Property;_Ramp;Ramp;9;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SamplerNode;118;853.6208,984.3806;Float;True;Property;_BurntEffect;BurntEffect;7;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-561.8188,122.8906;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-366.3357,264.4353;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0.0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.ScaleAndOffsetNode;113;487.9912,1360.38;Float;False;3;0;FLOAT2;0,0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.TexturePropertyNode;37;176.8049,-100.2318;Float;True;Property;_Paint;Paint;3;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-20.84961,136.4177;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;119;855.1733,1200.571;Float;True;Property;_TextureSample5;Texture Sample 5;7;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;120;1262.962,1421.514;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.BlendOpsNode;121;1437.245,1415.425;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;7;594.7392,120.7024;Float;True;Property;_T_Paint02;T_Paint02;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;89;608.8129,-94.75232;Float;True;Property;_Opacity;Opacity;5;0;Assets/Textures/T_Jude_OP.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;122;1666.05,1419.686;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;1.5;False;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;28;1072.033,127.6266;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;91;1061.812,381.6099;Float;False;Property;_Power;Power;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;90;1323.218,287.6403;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;123;1818.05,1421.286;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.OneMinusNode;124;1968.102,1420.96;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;92;1494.073,282.5148;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;2335.191,262.016;Float;False;2;2;0;FLOAT;0.0;False;1;COLOR;0.0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;88;2752.548,-60.4292;Float;False;Property;_Color;Color ;4;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScaleAndOffsetNode;114;488.1367,1226.661;Float;False;3;0;FLOAT2;0,0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.DitheringNode;52;2520.594,257.7491;Float;False;1;2;0;FLOAT;0.0;False;1;SAMPLER2D;;False;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3129.272,-42.66622;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/SHD_ShadowsAlphaClip_Unlit;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Masked;0.5;True;True;0;False;TransparentCutout;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;8;0
WireConnection;10;0;9;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;14;0;13;1
WireConnection;14;1;13;2
WireConnection;12;0;11;0
WireConnection;18;0;12;0
WireConnection;18;1;12;1
WireConnection;102;0;14;0
WireConnection;102;1;103;0
WireConnection;95;1;102;0
WireConnection;15;0;14;0
WireConnection;15;1;18;0
WireConnection;110;0;109;0
WireConnection;116;0;15;0
WireConnection;116;1;115;0
WireConnection;26;0;27;0
WireConnection;107;0;95;0
WireConnection;118;1;116;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;44;0;94;0
WireConnection;44;1;26;0
WireConnection;113;0;107;0
WireConnection;113;1;108;0
WireConnection;113;2;110;0
WireConnection;49;0;16;0
WireConnection;49;1;44;0
WireConnection;119;0;117;0
WireConnection;119;1;113;0
WireConnection;120;0;118;0
WireConnection;121;0;120;0
WireConnection;121;1;119;0
WireConnection;7;0;37;0
WireConnection;7;1;49;0
WireConnection;122;1;121;0
WireConnection;28;0;89;1
WireConnection;28;1;7;1
WireConnection;90;0;28;0
WireConnection;90;1;91;0
WireConnection;123;0;122;0
WireConnection;124;0;123;0
WireConnection;92;0;90;0
WireConnection;125;0;92;0
WireConnection;125;1;124;0
WireConnection;114;0;107;0
WireConnection;114;1;108;0
WireConnection;114;2;110;0
WireConnection;52;0;125;0
WireConnection;0;2;88;0
WireConnection;0;10;52;0
ASEEND*/
//CHKSM=15710F6B70FFFE1CACA1F251B42BD95D45D8C69A