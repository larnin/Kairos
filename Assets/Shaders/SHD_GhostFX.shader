// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_GhostFX"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Tiling("Tiling", Range( 0 , 50)) = 2.037486
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_LightColor("LightColor", Color) = (0,0,0,0)
		_Speed("Speed", Vector) = (0,0,0,0)
		_Contrast("Contrast", Float) = 0
		_Emissive("Emissive", Range( 0 , 2)) = 0
		_T_Smoke("T_Smoke", 2D) = "white" {}
		_Alpha("Alpha", Range( 0 , 1)) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Front
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow exclude_path:deferred 
		struct Input
		{
			float4 screenPos;
		};

		uniform float4 _LightColor;
		uniform float4 _ShadowColor;
		uniform sampler2D _T_Smoke;
		uniform float _Tiling;
		uniform float2 _Speed;
		uniform float _Emissive;
		uniform float _Contrast;
		uniform float _Alpha;


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
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 appendResult28 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float4 unityObjectToClipPos22 = UnityObjectToClipPos( float3( 0,0,0 ) );
			float4 computeScreenPos23 = ComputeScreenPos( unityObjectToClipPos22 );
			float componentMask24 = computeScreenPos23.w;
			float4 appendResult29 = (float4(( computeScreenPos23 / componentMask24 ).x , ( computeScreenPos23 / componentMask24 ).y , 0.0 , 0.0));
			float4 temp_output_18_0 = ( appendResult28 - appendResult29 );
			float4 transform58 = mul(unity_WorldToObject,float4( 0,0,0,1 ));
			float2 temp_output_37_0 = ( _Speed * _Time.y * frac( transform58.y ) );
			float4 temp_output_56_0 = ( transform58 * float4( 4,4,0,0 ) );
			float4 lerpResult47 = lerp( _LightColor , _ShadowColor , saturate( CalculateContrast(3.0,tex2D( _T_Smoke, ( ( temp_output_18_0 * float4( 1.2,1.2,0,0 ) * _Tiling ) + float4( ( temp_output_37_0 * float2( 2,2 ) ), 0.0 , 0.0 ) + temp_output_56_0 ).xy )) ).r);
			o.Emission = ( lerpResult47 * _Emissive ).rgb;
			float4 temp_cast_6 = (tex2D( _T_Smoke, ( ( temp_output_18_0 * _Tiling ) + float4( temp_output_37_0, 0.0 , 0.0 ) + temp_output_56_0 ).xy ).r).xxxx;
			o.Alpha = ( saturate( CalculateContrast(_Contrast,temp_cast_6) ) * _Alpha ).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
1927;29;1906;1004;893.6028;483.9334;1.366374;True;True
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;22;-2885.23,91.55404;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;23;-2697.288,92.43607;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComponentMaskNode;24;-2475.468,41.30341;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-2222.236,81.24506;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.BreakToComponentsNode;27;-2051.159,106.4751;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;26;-2051.108,-82.20538;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldToObjectTransfNode;58;-1638.921,-191.8246;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1436.237,-223.0403;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;29;-1791.07,106.4864;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.Vector2Node;36;-1438.348,-358.7461;Float;False;Property;_Speed;Speed;3;0;0,0;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;28;-1791.307,-61.87531;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.FractNode;57;-1395.072,-147.4884;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;31;-1333.117,234.817;Float;False;Property;_Tiling;Tiling;0;0;2.037486;0;50;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1221.348,-247.7461;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;2;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-1619.665,22.47962;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1060.708,-246.6605;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-887.4511,111.6148;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;1.2,1.2,0,0;False;2;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-916.5062,-439.584;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;4,4,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-886.4958,7.191056;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-904.942,-192.4136;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TexturePropertyNode;45;-886.2357,239.1467;Float;True;Property;_T_Smoke;T_Smoke;6;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-711.2029,7.376359;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0.0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;46;-564.0828,-248.8044;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;1;-574,-22;Float;True;Property;_T_Paint02;T_Paint02;0;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;53;-356.9841,-352.3353;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;3.0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;39;-471.6216,187.3279;Float;False;Property;_Contrast;Contrast;4;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;42;-58.46584,-396.5439;Float;False;Property;_LightColor;LightColor;2;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;11;-13,-35;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;3.0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;13;-60.09573,-224.5003;Float;False;Property;_ShadowColor;ShadowColor;1;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;54;-196.7263,-345.1684;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;60;69.69196,348.1886;Float;False;Property;_Alpha;Alpha;7;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;14;180.0519,99.69928;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;47;266.4127,-295.2735;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;40;70.75261,255.5418;Float;False;Property;_Emissive;Emissive;5;0;0;0;2;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;38;184.8815,-5.724762;Float;False;Constant;_Float0;Float 0;5;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;490.5351,249.8096;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;470.6071,22.88531;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;720,-93;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/SHD_GhostFX;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Front;0;0;False;0;0;Transparent;0.5;True;False;0;False;Transparent;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;22;0
WireConnection;24;0;23;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;27;0;25;0
WireConnection;29;0;27;0
WireConnection;29;1;27;1
WireConnection;28;0;26;1
WireConnection;28;1;26;2
WireConnection;57;0;58;2
WireConnection;37;0;36;0
WireConnection;37;1;19;0
WireConnection;37;2;57;0
WireConnection;18;0;28;0
WireConnection;18;1;29;0
WireConnection;44;0;37;0
WireConnection;43;0;18;0
WireConnection;43;2;31;0
WireConnection;56;0;58;0
WireConnection;20;0;18;0
WireConnection;20;1;31;0
WireConnection;48;0;43;0
WireConnection;48;1;44;0
WireConnection;48;2;56;0
WireConnection;21;0;20;0
WireConnection;21;1;37;0
WireConnection;21;2;56;0
WireConnection;46;0;45;0
WireConnection;46;1;48;0
WireConnection;1;0;45;0
WireConnection;1;1;21;0
WireConnection;53;1;46;0
WireConnection;11;1;1;1
WireConnection;11;0;39;0
WireConnection;54;0;53;0
WireConnection;14;0;11;0
WireConnection;47;0;42;0
WireConnection;47;1;13;0
WireConnection;47;2;54;0
WireConnection;59;0;14;0
WireConnection;59;1;60;0
WireConnection;41;0;47;0
WireConnection;41;1;40;0
WireConnection;0;2;41;0
WireConnection;0;9;59;0
ASEEND*/
//CHKSM=9AB684B69886507C7B11B795ABA89FBAC73B2567