// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LightVolume"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_LightColor("LightColor", Color) = (0,0,0,0)
		_Opacity("Opacity", Float) = 0
		_RowsAndColumnw("RowsAndColumnw", Vector) = (6,5,0,0)
		_Emission("Emission", Float) = 0
		_FresnelBias("FresnelBias", Range( 0 , 1)) = 0
		_FresnelPower("FresnelPower", Range( 0 , 5)) = 0
		_Depth("Depth", Float) = 0
		_SmokeTexture("SmokeTexture", 2D) = "white" {}
		_SmokeIntensity("SmokeIntensity", Float) = 0
		_Speed("Speed", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap noforwardadd 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float4 _LightColor;
		uniform float _Emission;
		uniform float _FresnelBias;
		uniform float _FresnelPower;
		uniform float _Opacity;
		uniform sampler2D _CameraDepthTexture;
		uniform float _Depth;
		uniform sampler2D _SmokeTexture;
		uniform float _Speed;
		uniform float2 _RowsAndColumnw;
		uniform float4 _SmokeTexture_ST;
		uniform float _SmokeIntensity;

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = ( _LightColor * _Emission ).rgb;
			float3 ase_worldPos = i.worldPos;
			fixed3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNode3 = ( _FresnelBias + 1.0 * pow( 1.0 - dot( ase_worldNormal, ase_worldViewDir ), _FresnelPower ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth14 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth14 = abs( ( screenDepth14 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Depth ) );
			float temp_output_30_0 = ( _Time.y * _Speed );
			float temp_output_4_0_g7 = ( temp_output_30_0 - frac( temp_output_30_0 ) );
			float componentMask13_g7 = _RowsAndColumnw.x;
			float2 temp_output_8_0_g7 = ( float2( 1,1 ) / _RowsAndColumnw );
			float componentMask9_g7 = temp_output_8_0_g7.x;
			float2 appendResult6_g7 = (float2(fmod( temp_output_4_0_g7 , componentMask13_g7 ) , ( 1.0 - floor( ( temp_output_4_0_g7 * componentMask9_g7 ) ) )));
			float2 uv_SmokeTexture = i.uv_texcoord * _SmokeTexture_ST.xy + _SmokeTexture_ST.zw;
			float temp_output_4_0_g6 = ( ( temp_output_30_0 + 1.0 ) - frac( ( temp_output_30_0 + 1.0 ) ) );
			float componentMask13_g6 = _RowsAndColumnw.x;
			float2 temp_output_8_0_g6 = ( float2( 1,1 ) / _RowsAndColumnw );
			float componentMask9_g6 = temp_output_8_0_g6.x;
			float2 appendResult6_g6 = (float2(fmod( temp_output_4_0_g6 , componentMask13_g6 ) , ( 1.0 - floor( ( temp_output_4_0_g6 * componentMask9_g6 ) ) )));
			float lerpResult59 = lerp( tex2D( _SmokeTexture, ( ( appendResult6_g7 + uv_SmokeTexture ) * temp_output_8_0_g7 ) ).a , tex2D( _SmokeTexture, ( ( appendResult6_g6 + uv_SmokeTexture ) * temp_output_8_0_g6 ) ).a , frac( temp_output_30_0 ));
			float lerpResult25 = lerp( 1.0 , lerpResult59 , _SmokeIntensity);
			o.Alpha = ( saturate( ( 1.0 - fresnelNode3 ) ) * _Opacity * saturate( distanceDepth14 ) * lerpResult25 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
2078;119;1677;686;3927.065;-178.9445;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;27;-3164.272,349.0927;Float;False;446.0966;291.2595;Frame Nb;3;30;28;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-3103.065,500.9445;Float;False;Property;_Speed;Speed;9;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleTimeNode;28;-3114.272,399.0927;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2887.174,446.9809;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-2926.998,210.6082;Float;False;0;56;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.Vector2Node;33;-2682.012,450.5938;Float;False;Property;_RowsAndColumnw;RowsAndColumnw;2;0;6,5;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-2651.94,628.6298;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;13;-1064,144;Float;False;Property;_FresnelBias;FresnelBias;3;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;12;-1059,63;Float;False;Property;_FresnelPower;FresnelPower;4;0;0;0;5;0;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;34;-2434.939,578.6299;Float;False;SHDF_SubUV;-1;;6;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.FunctionNode;35;-2439.052,272.1936;Float;False;SHDF_SubUV;-1;;7;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.TexturePropertyNode;56;-1964.135,82.89359;Float;True;Property;_SmokeTexture;SmokeTexture;5;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SamplerNode;58;-1509.751,252.5913;Float;True;Property;_TextureSample7;Texture Sample 7;0;0;Assets/Textures/OutputSlate.PNG;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.FresnelNode;3;-661,26;Float;True;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;5.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;15;-400,337;Float;False;Property;_Depth;Depth;5;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.FractNode;43;-1811.687,810.9742;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;57;-1495.56,514.8217;Float;True;Property;_TextureSample5;Texture Sample 5;0;0;Assets/Textures/OutputSlate.PNG;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DepthFade;14;-216,341;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;59;-1083.82,345.0386;Float;False;3;0;FLOAT;0,0,0,0;False;1;FLOAT;0,0,0,0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;4;-343,23;Float;True;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;26;-192.29,982.3488;Float;False;Property;_SmokeIntensity;SmokeIntensity;8;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;25;120.1736,838.7839;Float;False;3;0;FLOAT;1.0;False;1;FLOAT;0,0,0,0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;8;-336,245;Float;False;Property;_Opacity;Opacity;1;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;16;-8,341;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;2;-985.9634,-146.926;Float;False;Property;_LightColor;LightColor;0;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;11;-777.9636,39.07397;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;10;-932.9636,-235.9261;Float;False;Property;_Emission;Emission;2;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-639.9636,-144.926;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;26,18;Float;False;4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0;False;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1;320,-211;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;LightVolume;False;False;False;False;True;True;True;True;True;False;False;True;False;False;True;False;False;Back;0;0;False;0;0;Transparent;0.5;True;False;0;False;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;0;28;0
WireConnection;30;1;60;0
WireConnection;32;0;30;0
WireConnection;34;0;31;0
WireConnection;34;1;33;0
WireConnection;34;2;32;0
WireConnection;35;0;31;0
WireConnection;35;1;33;0
WireConnection;35;2;30;0
WireConnection;58;0;56;0
WireConnection;58;1;35;0
WireConnection;3;1;13;0
WireConnection;3;3;12;0
WireConnection;43;0;30;0
WireConnection;57;0;56;0
WireConnection;57;1;34;0
WireConnection;14;0;15;0
WireConnection;59;0;58;4
WireConnection;59;1;57;4
WireConnection;59;2;43;0
WireConnection;4;0;3;0
WireConnection;25;1;59;0
WireConnection;25;2;26;0
WireConnection;16;0;14;0
WireConnection;11;0;4;0
WireConnection;9;0;2;0
WireConnection;9;1;10;0
WireConnection;7;0;11;0
WireConnection;7;1;8;0
WireConnection;7;2;16;0
WireConnection;7;3;25;0
WireConnection;1;2;9;0
WireConnection;1;9;7;0
ASEEND*/
//CHKSM=76F887708F0AA56F6BDCC4D11B774E6B40DC0CEB