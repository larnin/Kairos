// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHD_ShadowTest3"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Color("Color", Color) = (0,0,0,0)
		_Alpha("Alpha", Range( 0 , 1)) = 0
		_Diffuse("Diffuse", 2D) = "white" {}
		_MouvSpeed("MouvSpeed", Range( -1 , 1)) = 0
		_Tiling("Tiling", Range( 0 , 5)) = 2.037486
		_GlobalOpacity("GlobalOpacity", Range( 0 , 1)) = 0
		_Texture0("Texture 0", 2D) = "black" {}
		_Contrast("Contrast", Float) = 0
		_MotifOpacity("MotifOpacity", Range( 0 , 1)) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow 
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float4 vertexColor : COLOR;
			float3 worldNormal;
		};

		uniform float4 _Color;
		uniform sampler2D _Diffuse;
		uniform float _Tiling;
		uniform float _MouvSpeed;
		uniform float _MotifOpacity;
		uniform float _Contrast;
		uniform sampler2D _Texture0;
		uniform float _GlobalOpacity;
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
			float4 appendResult218 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float4 unityObjectToClipPos212 = UnityObjectToClipPos( float3( 0,0,0 ) );
			float4 computeScreenPos213 = ComputeScreenPos( unityObjectToClipPos212 );
			float componentMask214 = computeScreenPos213.w;
			float4 appendResult219 = (float4(( computeScreenPos213 / componentMask214 ).x , ( computeScreenPos213 / componentMask214 ).y , 0.0 , 0.0));
			float4 temp_output_224_0 = ( ( appendResult218 - appendResult219 ) * _Tiling );
			float temp_output_226_0 = ( _Time.y * _MouvSpeed );
			float4 appendResult230 = (float4(( temp_output_224_0.x + temp_output_226_0 ) , ( temp_output_224_0.y + temp_output_226_0 ) , 0.0 , 0.0));
			float3 ase_worldPos = i.worldPos;
			float4 transform260 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 lerpResult252 = lerp( _Color , tex2D( _Diffuse, appendResult230.xy ) , ( _MotifOpacity * saturate( ( ase_worldPos.y - transform260.y ) ) ));
			o.Emission = lerpResult252.rgb;
			float lerpResult251 = lerp( 0.0 , i.vertexColor.r , _GlobalOpacity);
			fixed3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float lerpResult202 = lerp( 0 , tex2D( _Texture0, appendResult230.xy ).r , 1);
			float fresnelNode177 = ( lerpResult202 + 1.5 * pow( 1.0 - dot( ase_worldNormal, ase_worldViewDir ), 5.0 ) );
			float4 temp_cast_5 = (fresnelNode177).xxxx;
			float fresnelNode197 = ( 0.0 + 1.5 * pow( 1.0 - dot( ase_worldNormal, ase_worldViewDir ), 1.0 ) );
			float4 lerpResult248 = lerp( float4( 0,0,0,0 ) , saturate( ( ( CalculateContrast(_Contrast,saturate( ( tex2D( _Texture0, ( temp_output_224_0 + ( temp_output_226_0 * 0.1 ) ).xy ) + tex2D( _Texture0, appendResult230.xy ) ) )) * lerpResult251 ) * ( 1.0 - saturate( ( CalculateContrast(1.0,temp_cast_5) * fresnelNode197 ) ) ) ) ) , _Alpha);
			o.Alpha = lerpResult248.r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
1927;31;1906;1002;-1213.319;-436.1282;1.448255;True;True
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;212;-1167.846,-225.6229;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;213;-979.9045,-224.7409;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComponentMaskNode;214;-758.0856,-275.8735;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;215;-504.8525,-235.9319;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.BreakToComponentsNode;217;-333.7776,-210.7019;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;216;-333.7275,-399.3822;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;218;-73.92554,-379.0522;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.DynamicAppendNode;219;-64.9856,-208.95;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;176;-838.6962,-33.36443;Float;False;Property;_Tiling;Tiling;4;0;2.037486;0;5;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;221;97.71655,-294.6973;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;250.2043,-296.2427;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleTimeNode;222;-82.95044,-4.577881;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;137;-187.4618,84.75753;Float;False;Property;_MouvSpeed;MouvSpeed;3;0;0;-1;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;115.7314,21.40405;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.BreakToComponentsNode;227;426.2734,-292.8861;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;229;728.5364,-100.7219;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;265;736.1523,-204.7883;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;239;959.4725,-782.5766;Float;True;Property;_Texture0;Texture 0;6;0;None;False;black;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.RangedFloatNode;225;131.3735,155.1901;Float;False;Constant;_Float9;Float 9;5;0;0.1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;230;898.5435,-296.4127;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;228;314.6404,65.3551;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;233;1355.723,1336.296;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;202;1841.968,1404.796;Float;False;3;0;FLOAT;0;False;1;FLOAT;0,0,0,0;False;2;FLOAT;1;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;231;758.4285,-337.1107;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.FresnelNode;177;2068.581,1385.493;Float;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.5;False;3;FLOAT;5.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;136;1358.224,-431.6914;Float;True;Property;_TextureSample3;Texture Sample 3;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;135;1351.773,-652.4565;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.FresnelNode;197;2067.949,1569.765;Float;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.5;False;3;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;188;2324.872,1385.111;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;1.0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;257;1729.274,-669.0101;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;255;1793.584,-424.7437;Float;False;Property;_Contrast;Contrast;7;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.VertexColorNode;234;2013.555,-40.366;Float;False;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;258;1879.541,-665.2216;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;2499.031,1374.174;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;250;2018.864,207.6528;Float;False;Property;_GlobalOpacity;GlobalOpacity;5;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;181;2698.675,1359.622;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleContrastOpNode;232;2088.727,-528.3049;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;1.0;False;1;COLOR
Node;AmplifyShaderEditor.WorldPosInputsNode;261;2883.354,101.9678;Float;False;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;260;2878.65,268.4747;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;251;2232.805,90.55884;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;182;2711.93,1020.543;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleSubtractOpNode;262;3108.628,227.1908;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;235;2381.619,-107.7958;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;2873.531,803.2495;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;263;3265.909,228.7995;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;256;2893.276,-23.24982;Float;False;Property;_MotifOpacity;MotifOpacity;8;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;259;2867.066,-249.493;Float;True;Property;_Diffuse;Diffuse;2;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;247;2944.798,-443.628;Float;False;Property;_Color;Color;0;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;264;3328.179,31.18481;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;149;3167.876,841.6722;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;249;3446.547,1035.372;Float;False;Property;_Alpha;Alpha;1;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;248;3796.163,978.3715;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;252;3621.082,-200.7497;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4304.319,807.6949;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;SHD_ShadowTest3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Transparent;0.5;True;False;0;False;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexScale;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;213;0;212;0
WireConnection;214;0;213;0
WireConnection;215;0;213;0
WireConnection;215;1;214;0
WireConnection;217;0;215;0
WireConnection;218;0;216;1
WireConnection;218;1;216;2
WireConnection;219;0;217;0
WireConnection;219;1;217;1
WireConnection;221;0;218;0
WireConnection;221;1;219;0
WireConnection;224;0;221;0
WireConnection;224;1;176;0
WireConnection;226;0;222;0
WireConnection;226;1;137;0
WireConnection;227;0;224;0
WireConnection;229;0;227;1
WireConnection;229;1;226;0
WireConnection;265;0;227;0
WireConnection;265;1;226;0
WireConnection;230;0;265;0
WireConnection;230;1;229;0
WireConnection;228;0;226;0
WireConnection;228;1;225;0
WireConnection;233;0;239;0
WireConnection;233;1;230;0
WireConnection;202;1;233;1
WireConnection;231;0;224;0
WireConnection;231;1;228;0
WireConnection;177;1;202;0
WireConnection;136;0;239;0
WireConnection;136;1;230;0
WireConnection;135;0;239;0
WireConnection;135;1;231;0
WireConnection;188;1;177;0
WireConnection;257;0;135;0
WireConnection;257;1;136;0
WireConnection;258;0;257;0
WireConnection;203;0;188;0
WireConnection;203;1;197;0
WireConnection;181;0;203;0
WireConnection;232;1;258;0
WireConnection;232;0;255;0
WireConnection;251;1;234;1
WireConnection;251;2;250;0
WireConnection;182;0;181;0
WireConnection;262;0;261;2
WireConnection;262;1;260;2
WireConnection;235;0;232;0
WireConnection;235;1;251;0
WireConnection;183;0;235;0
WireConnection;183;1;182;0
WireConnection;263;0;262;0
WireConnection;259;1;230;0
WireConnection;264;0;256;0
WireConnection;264;1;263;0
WireConnection;149;0;183;0
WireConnection;248;1;149;0
WireConnection;248;2;249;0
WireConnection;252;0;247;0
WireConnection;252;1;259;0
WireConnection;252;2;264;0
WireConnection;0;2;252;0
WireConnection;0;9;248;0
ASEEND*/
//CHKSM=A1738A39839D5FDBA0FF974ED7AE66CDC1BA81B1