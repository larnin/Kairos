// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SHD_ShadowTest1"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Color("Color", Color) = (0,0,0,0)
		_Texture0("Texture 0", 2D) = "white" {}
		_Diffuse("Diffuse", 2D) = "white" {}
		_Contrast("Contrast", Float) = 0
		_MotifOpacity("MotifOpacity", Range( 0 , 1)) = 0
		_MotifColor("MotifColor", Color) = (0,0,0,0)
		_Contrast2("Contrast2", Float) = 0
		_Power("Power", Float) = 0
		_T_LinearMask1("T_LinearMask1", 2D) = "white" {}
		_T_PerlinNoise("T_PerlinNoise", 2D) = "white" {}
		_Turbulences("Turbulences", Range( 0 , 1)) = 0
		_DisplaceIntensity("DisplaceIntensity", Float) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 texcoord_0;
			float3 worldPos;
			float2 texcoord_1;
			float2 texcoord_2;
			float2 texcoord_3;
			float2 texcoord_4;
			float2 texcoord_5;
		};

		uniform float4 _Color;
		uniform float4 _MotifColor;
		uniform sampler2D _Diffuse;
		uniform float _MotifOpacity;
		uniform float _Contrast;
		uniform sampler2D _Texture0;
		uniform float _Contrast2;
		uniform float _Power;
		uniform sampler2D _T_LinearMask1;
		uniform sampler2D _T_PerlinNoise;
		uniform float _Turbulences;
		uniform float _DisplaceIntensity;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,2 ) + float2( 0,0 );
			o.texcoord_1.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			o.texcoord_2.xy = v.texcoord.xy * float2( 0.5,1 ) + float2( 0,0 );
			o.texcoord_3.xy = v.texcoord.xy * float2( 1,2 ) + float2( 0,0 );
			float2 panner361 = ( o.texcoord_3 + 1.0 * _Time.y * float2( 0,-1 ));
			o.texcoord_4.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float2 panner362 = ( o.texcoord_4 + 1.0 * _Time.y * float2( 0,-0.5 ));
			float lerpResult359 = lerp( tex2Dlod( _T_LinearMask1, float4( panner361, 0.0 , 0.0 ) ).r , tex2Dlod( _T_PerlinNoise, float4( panner362, 0.0 , 0.0 ) ).r , _Turbulences);
			float3 ase_vertexNormal = v.normal.xyz;
			o.texcoord_5.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float4 temp_cast_2 = (pow( ( 1.0 - o.texcoord_5.y ) , _Power )).xxxx;
			float4 temp_output_341_0 = CalculateContrast(_Contrast2,temp_cast_2);
			float3 lerpResult367 = lerp( ( ( lerpResult359 * _DisplaceIntensity ) * ase_vertexNormal ) , float3( 0.0,0,0 ) , saturate( ( temp_output_341_0 + -1.0 ) ).rgb);
			v.vertex.xyz += lerpResult367;
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 panner353 = ( i.texcoord_0 + 1.0 * _Time.y * float2( 0,-0.2 ));
			float3 ase_worldPos = i.worldPos;
			float4 transform312 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 temp_cast_0 = (i.texcoord_1.y).xxxx;
			float4 lerpResult306 = lerp( _Color , _MotifColor , saturate( ( tex2D( _Diffuse, panner353 ).r * ( _MotifOpacity * saturate( ( ase_worldPos.y - transform312.y ) ) ) * ( CalculateContrast(4.0,temp_cast_0) + -0.5 ) ) ).r);
			o.Emission = lerpResult306.rgb;
			float2 panner356 = ( i.texcoord_2 + 1.0 * _Time.y * float2( 0,-0.5 ));
			float4 lerpResult290 = lerp( tex2D( _Texture0, panner353 ) , tex2D( _Texture0, panner356 ) , 0.5);
			float4 temp_cast_3 = (pow( ( 1.0 - i.texcoord_1.y ) , _Power )).xxxx;
			float4 temp_output_341_0 = CalculateContrast(_Contrast2,temp_cast_3);
			float4 blendOpSrc340 = saturate( CalculateContrast(_Contrast,lerpResult290) );
			float4 blendOpDest340 = saturate( temp_output_341_0 );
			o.Alpha = ( saturate( ( blendOpDest340 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest340 - 0.5 ) ) * ( 1.0 - blendOpSrc340 ) ) : ( 2.0 * blendOpDest340 * blendOpSrc340 ) ) )).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
1927;31;1906;1002;-5767.943;-1732.549;1;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;363;5729.912,1758.818;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,2;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;366;5753.912,1995.818;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;317;3034.774,1724.274;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;355;3479.239,888.9781;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.5,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;312;4366.899,2180.729;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;354;3444.308,473.781;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,2;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldPosInputsNode;311;4371.604,2014.222;Float;False;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.PannerNode;361;6048.912,1793.818;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.PannerNode;362;6058.912,1984.818;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.5;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.OneMinusNode;318;3372.712,1915.213;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;346;4278.911,2525.422;Float;False;Property;_Power;Power;7;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;313;4596.877,2139.445;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.PannerNode;356;3744.233,891.6697;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.5;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.PannerNode;353;3709.302,476.4727;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.2;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.TexturePropertyNode;268;3148.306,488.7;Float;True;Property;_Texture0;Texture 0;1;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SamplerNode;265;3941.875,698.4771;Float;True;Property;_TextureSample1;Texture Sample 1;5;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;357;6312.493,1768.218;Float;True;Property;_T_LinearMask1;T_LinearMask1;8;0;Assets/Textures/T_LinearMask1.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;360;6339.594,2175.045;Float;False;Property;_Turbulences;Turbulences;10;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;347;4499.911,2532.422;Float;False;Property;_Contrast2;Contrast2;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;345;4484.7,2433.061;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;3.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;358;6317.219,1973.244;Float;True;Property;_T_PerlinNoise;T_PerlinNoise;9;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;307;4777.117,1239.939;Float;False;Property;_MotifOpacity;MotifOpacity;4;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;330;3292.649,1616.506;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;4.0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;291;4092.608,1118.07;Float;False;Constant;_Float0;Float 0;7;0;0.5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;332;3536.526,1722.617;Float;False;Constant;_Float4;Float 4;11;0;-0.5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;316;4745.248,2136.845;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;240;3945.095,916.6674;Float;True;Property;_T_Paint02;T_Paint02;5;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;365;6675.912,2033.818;Float;False;Property;_DisplaceIntensity;DisplaceIntensity;11;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;341;4647.638,2429.438;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;8.0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;359;6678.594,1901.045;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;315;5103.545,1253.858;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;290;4340.608,996.0701;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;289;4302.131,1346.415;Float;False;Property;_Contrast;Contrast;3;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;308;4867.562,737.6103;Float;True;Property;_Diffuse;Diffuse;2;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;331;3872.573,1581.99;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;372;6340.484,2451.691;Float;False;Constant;_Float1;Float 1;12;0;-1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;371;6539.318,2418.67;Float;False;2;2;0;COLOR;0.0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.NormalVertexDataNode;370;6947.115,2373.034;Float;False;0;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;5262.654,1238.73;Float;False;3;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleContrastOpNode;278;4474.655,1156.368;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;1.0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;364;6864.912,1898.818;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;274;4646.546,1156.772;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;328;5260.654,849.7303;Float;False;Property;_MotifColor;MotifColor;5;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;369;7211.903,1982.232;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT3;0;False;1;FLOAT3
Node;AmplifyShaderEditor.SaturateNode;373;6675.917,2418.018;Float;False;1;0;COLOR;0.0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;281;4963.8,996.2323;Float;False;Property;_Color;Color;0;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;342;4977.235,2434.056;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;329;5401.151,1237.17;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.BlendOpsNode;340;5149.007,2402.541;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.WorldNormalVector;368;6963.063,2195.977;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;367;7269.583,1614.556;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0.0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.LerpOp;306;5562.783,1170.066;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;7421.583,1210.972;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;SHD_ShadowTest1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Transparent;0.5;True;False;0;False;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;2;False;0;0,0,0,0;VertexScale;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;361;0;363;0
WireConnection;362;0;366;0
WireConnection;318;0;317;2
WireConnection;313;0;311;2
WireConnection;313;1;312;2
WireConnection;356;0;355;0
WireConnection;353;0;354;0
WireConnection;265;0;268;0
WireConnection;265;1;353;0
WireConnection;357;1;361;0
WireConnection;345;0;318;0
WireConnection;345;1;346;0
WireConnection;358;1;362;0
WireConnection;330;1;317;2
WireConnection;316;0;313;0
WireConnection;240;0;268;0
WireConnection;240;1;356;0
WireConnection;341;1;345;0
WireConnection;341;0;347;0
WireConnection;359;0;357;1
WireConnection;359;1;358;1
WireConnection;359;2;360;0
WireConnection;315;0;307;0
WireConnection;315;1;316;0
WireConnection;290;0;265;0
WireConnection;290;1;240;0
WireConnection;290;2;291;0
WireConnection;308;1;353;0
WireConnection;331;0;330;0
WireConnection;331;1;332;0
WireConnection;371;0;341;0
WireConnection;371;1;372;0
WireConnection;327;0;308;1
WireConnection;327;1;315;0
WireConnection;327;2;331;0
WireConnection;278;1;290;0
WireConnection;278;0;289;0
WireConnection;364;0;359;0
WireConnection;364;1;365;0
WireConnection;274;0;278;0
WireConnection;369;0;364;0
WireConnection;369;1;370;0
WireConnection;373;0;371;0
WireConnection;342;0;341;0
WireConnection;329;0;327;0
WireConnection;340;0;274;0
WireConnection;340;1;342;0
WireConnection;367;0;369;0
WireConnection;367;2;373;0
WireConnection;306;0;281;0
WireConnection;306;1;328;0
WireConnection;306;2;329;0
WireConnection;0;2;306;0
WireConnection;0;9;340;0
WireConnection;0;11;367;0
ASEEND*/
//CHKSM=3E025163EE75319E40664A71226E33DA1BA1DCE9