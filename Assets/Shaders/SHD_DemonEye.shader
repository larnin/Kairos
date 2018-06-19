// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_DemonEye"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_EmissiveTint("EmissiveTint", Color) = (1,0.02941179,0.2101419,0)
		_EmissiveStrength("EmissiveStrength", Float) = 0
		_T_Paint02("T_Paint02", 2D) = "white" {}
		_T_DemonEye_1("T_DemonEye_1", 2D) = "white" {}
		_MouvSpeed("MouvSpeed", Float) = 0
		_Float0("Float 0", Float) = 0
		_T_DemonEye_2("T_DemonEye_2", 2D) = "white" {}
		_Expression("Expression", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float2 texcoord_0;
		};

		uniform float4 _EmissiveTint;
		uniform float _EmissiveStrength;
		uniform sampler2D _T_DemonEye_1;
		uniform float4 _T_DemonEye_1_ST;
		uniform sampler2D _T_DemonEye_2;
		uniform float4 _T_DemonEye_2_ST;
		uniform float _Expression;
		uniform sampler2D _T_Paint02;
		uniform float _MouvSpeed;
		uniform float _Float0;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_T_DemonEye_1 = i.uv_texcoord * _T_DemonEye_1_ST.xy + _T_DemonEye_1_ST.zw;
			float2 uv_T_DemonEye_2 = i.uv_texcoord * _T_DemonEye_2_ST.xy + _T_DemonEye_2_ST.zw;
			float4 lerpResult24 = lerp( tex2D( _T_DemonEye_1, uv_T_DemonEye_1 ) , tex2D( _T_DemonEye_2, uv_T_DemonEye_2 ) , _Expression);
			float2 temp_cast_0 = (_MouvSpeed).xx;
			float2 panner14 = ( i.texcoord_0 + 1.0 * _Time.y * temp_cast_0);
			float4 blendOpSrc22 = tex2D( _T_Paint02, panner14 );
			float blendOpDest22 = lerpResult24.g;
			float4 temp_output_22_0 = ( saturate( ( blendOpDest22 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest22 - 0.5 ) ) * ( 1.0 - blendOpSrc22 ) ) : ( 2.0 * blendOpDest22 * blendOpSrc22 ) ) ));
			float4 lerpResult20 = lerp( ( lerpResult24.r + temp_output_22_0 ) , ( lerpResult24.r * temp_output_22_0 ) , _Float0);
			float4 lerpResult2 = lerp( ( _EmissiveTint * _EmissiveStrength ) , float4(0,0,0,0) , saturate( CalculateContrast(10.0,lerpResult20) ).r);
			o.Emission = lerpResult2.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
1958;264;1449;670;406.4013;127.3113;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;16;-1366.79,726.2253;Float;False;Property;_MouvSpeed;MouvSpeed;4;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-1434.79,598.2253;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;23;-1078.26,198.2401;Float;True;Property;_T_DemonEye_2;T_DemonEye_2;6;0;Assets/Textures/FX/T_DemonEye_2.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;7;-1070.085,-5.476868;Float;True;Property;_T_DemonEye_1;T_DemonEye_1;3;0;Assets/Textures/FX/T_DemonEye_1.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;25;-1064.778,395.3726;Float;False;Property;_Expression;Expression;7;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;24;-659.1534,180.7603;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.PannerNode;14;-1109.789,606.2253;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.BreakToComponentsNode;26;-508.8319,181.6362;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;8;-894.6548,603.7429;Float;True;Property;_T_Paint02;T_Paint02;3;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;22;-513.8535,602.1755;Float;True;Overlay;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-71.04815,488.8147;Float;True;2;2;0;FLOAT;0.0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-74.18384,711.2972;Float;True;2;2;0;FLOAT;0.0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;21;-31.3446,926.4188;Float;False;Property;_Float0;Float 0;5;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;20;153.6554,828.4188;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;4;-409,-239;Float;False;Property;_EmissiveTint;EmissiveTint;1;0;1,0.02941179,0.2101419,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;11;187.8161,494.2972;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;10.0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;6;-215,322;Float;False;Property;_EmissiveStrength;EmissiveStrength;2;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;91,119;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;13;346.8161,497.2972;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;3;-404,-59;Float;False;Constant;_Color0;Color 0;1;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;2;290,135;Float;True;3;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;587,90;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/SHD_DemonEye;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;24;0;7;0
WireConnection;24;1;23;0
WireConnection;24;2;25;0
WireConnection;14;0;15;0
WireConnection;14;2;16;0
WireConnection;26;0;24;0
WireConnection;8;1;14;0
WireConnection;22;0;8;0
WireConnection;22;1;26;1
WireConnection;10;0;26;0
WireConnection;10;1;22;0
WireConnection;17;0;26;0
WireConnection;17;1;22;0
WireConnection;20;0;10;0
WireConnection;20;1;17;0
WireConnection;20;2;21;0
WireConnection;11;1;20;0
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;13;0;11;0
WireConnection;2;0;5;0
WireConnection;2;1;3;0
WireConnection;2;2;13;0
WireConnection;0;2;2;0
ASEEND*/
//CHKSM=81F1E62D0AC1E897789DECD6DD031144C1BE4941