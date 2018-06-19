// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_JudeFX"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Tiling("Tiling", Range( 0 , 50)) = 2.037486
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_LightColor("LightColor", Color) = (0,0,0,0)
		_T_Round("T_Round", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_Contrast("Contrast", Float) = 0
		_Emissive("Emissive", Range( 0 , 2)) = 0
		_T_Smoke("T_Smoke", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float4 screenPos;
			float4 vertexColor : COLOR;
			float2 texcoord_0;
			float2 uv_texcoord;
		};

		uniform float4 _LightColor;
		uniform float4 _ShadowColor;
		uniform sampler2D _T_Smoke;
		uniform float _Tiling;
		uniform float2 _Speed;
		uniform float _Emissive;
		uniform float _Contrast;
		uniform sampler2D _T_Round;
		uniform float4 _T_Round_ST;


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
			float4 appendResult62 = (float4(_Speed.x , ( abs( ( _Speed.y + frac( transform58.y ) ) ) * -1.0 ) , 0.0 , 0.0));
			float4 temp_output_37_0 = ( appendResult62 * _Time.y );
			float4 temp_output_56_0 = ( transform58 * float4( 4,4,0,0 ) );
			float4 lerpResult47 = lerp( _LightColor , _ShadowColor , saturate( CalculateContrast(3.0,tex2D( _T_Smoke, ( ( temp_output_18_0 * float4( 1.2,1.2,0,0 ) * _Tiling ) + ( temp_output_37_0 * float4( 2,2,0,0 ) ) + temp_output_56_0 ).xy )) ).r);
			o.Emission = ( ( lerpResult47 * i.vertexColor ) * _Emissive ).rgb;
			float4 tex2DNode1 = tex2D( _T_Smoke, ( ( temp_output_18_0 * _Tiling ) + temp_output_37_0 + temp_output_56_0 ).xy );
			float2 uv_T_Round = i.uv_texcoord * _T_Round_ST.xy + _T_Round_ST.zw;
			float temp_output_35_0 = ( ( 1.0 - i.texcoord_0.y ) * tex2D( _T_Round, uv_T_Round ).r );
			float blendOpSrc15 = tex2DNode1.r;
			float blendOpDest15 = (0.0 + (temp_output_35_0 - 0.0) * (0.8 - 0.0) / (1.0 - 0.0));
			float4 temp_cast_4 = (( saturate( ( blendOpDest15 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest15 - 0.5 ) ) * ( 1.0 - blendOpSrc15 ) ) : ( 2.0 * blendOpDest15 * blendOpSrc15 ) ) ))).xxxx;
			o.Alpha = ( saturate( CalculateContrast(_Contrast,temp_cast_4) ) * i.vertexColor.a ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			# include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD6;
				float4 screenPos : TEXCOORD7;
				float4 texcoords01 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.texcoords01 = float4( v.texcoord.xy, v.texcoord1.xy );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord.xy = IN.texcoords01.xy;
				float3 worldPos = IN.worldPos;
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
7;62;1906;971;663.4523;421.639;1.066374;True;True
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;22;-2885.23,91.55404;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.WorldToObjectTransfNode;58;-2160.378,-284.5992;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;23;-2697.288,92.43607;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.Vector2Node;36;-2132.557,-416.3304;Float;False;Property;_Speed;Speed;4;0;0,0;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.FractNode;57;-1965.583,-238.1303;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;24;-2475.468,41.30341;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1824.733,-366.1879;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.AbsOpNode;64;-1688.237,-357.6571;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-2222.236,81.24506;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1524.015,-357.6569;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;-1.0;False;1;FLOAT
Node;AmplifyShaderEditor.BreakToComponentsNode;27;-2051.159,106.4751;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;26;-2051.108,-82.20538;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;28;-1791.307,-61.87531;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.DynamicAppendNode;29;-1791.07,106.4864;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.DynamicAppendNode;62;-1291.547,-387.5155;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1436.237,-223.0403;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;31;-1333.117,234.817;Float;False;Property;_Tiling;Tiling;0;0;2.037486;0;50;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1221.348,-247.7461;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-1619.665,22.47962;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1060.708,-246.6605;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;2,2,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-916.5062,-439.584;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;4,4,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1335.769,375.3105;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-887.4511,111.6148;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;1.2,1.2,0,0;False;2;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-904.942,-192.4136;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TexturePropertyNode;45;-886.2357,239.1467;Float;True;Property;_T_Smoke;T_Smoke;7;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.OneMinusNode;9;-1103.541,419.712;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-886.4958,7.191056;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;33;-1403.872,502.156;Float;True;Property;_T_Round;T_Round;3;0;Assets/Textures/FX/T_Round.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;46;-564.0828,-248.8044;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-901.4022,504.081;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-711.2029,7.376359;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleContrastOpNode;53;-356.9841,-352.3353;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;3.0;False;1;COLOR
Node;AmplifyShaderEditor.TFHCRemap;32;-783.7444,577.9008;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;0.0;False;4;FLOAT;0.8;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;1;-574,-22;Float;True;Property;_T_Paint02;T_Paint02;0;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;42;-58.46584,-396.5439;Float;False;Property;_LightColor;LightColor;2;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;54;-196.7263,-345.1684;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;13;-60.09573,-224.5003;Float;False;Property;_ShadowColor;ShadowColor;1;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;39;-175.1185,433.2752;Float;False;Property;_Contrast;Contrast;5;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;15;-264.5247,202.4937;Float;True;Overlay;True;2;0;FLOAT;0;False;1;FLOAT;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.VertexColorNode;59;161.2389,345.4559;Float;False;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;47;266.4127,-295.2735;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleContrastOpNode;11;-13,-35;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;3.0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;553.2805,-94.26218;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;40;70.75261,255.5418;Float;False;Property;_Emissive;Emissive;6;0;0;0;2;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;14;180.0519,99.69928;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;676.4172,11.1552;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;8;-263,-36;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.8;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;463.2076,174.6591;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;38;184.8815,-5.724762;Float;False;Constant;_Float0;Float 0;5;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;924.7435,-81.26988;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/SHD_JudeFX;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;Back;0;0;False;0;0;Transparent;0.5;True;True;0;False;Transparent;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;22;0
WireConnection;57;0;58;2
WireConnection;24;0;23;0
WireConnection;61;0;36;2
WireConnection;61;1;57;0
WireConnection;64;0;61;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;65;0;64;0
WireConnection;27;0;25;0
WireConnection;28;0;26;1
WireConnection;28;1;26;2
WireConnection;29;0;27;0
WireConnection;29;1;27;1
WireConnection;62;0;36;1
WireConnection;62;1;65;0
WireConnection;37;0;62;0
WireConnection;37;1;19;0
WireConnection;18;0;28;0
WireConnection;18;1;29;0
WireConnection;44;0;37;0
WireConnection;56;0;58;0
WireConnection;43;0;18;0
WireConnection;43;2;31;0
WireConnection;48;0;43;0
WireConnection;48;1;44;0
WireConnection;48;2;56;0
WireConnection;9;0;3;2
WireConnection;20;0;18;0
WireConnection;20;1;31;0
WireConnection;46;0;45;0
WireConnection;46;1;48;0
WireConnection;35;0;9;0
WireConnection;35;1;33;1
WireConnection;21;0;20;0
WireConnection;21;1;37;0
WireConnection;21;2;56;0
WireConnection;53;1;46;0
WireConnection;32;0;35;0
WireConnection;1;0;45;0
WireConnection;1;1;21;0
WireConnection;54;0;53;0
WireConnection;15;0;1;1
WireConnection;15;1;32;0
WireConnection;47;0;42;0
WireConnection;47;1;13;0
WireConnection;47;2;54;0
WireConnection;11;1;15;0
WireConnection;11;0;39;0
WireConnection;66;0;47;0
WireConnection;66;1;59;0
WireConnection;14;0;11;0
WireConnection;41;0;66;0
WireConnection;41;1;40;0
WireConnection;8;0;1;1
WireConnection;8;2;35;0
WireConnection;60;0;14;0
WireConnection;60;1;59;4
WireConnection;0;2;41;0
WireConnection;0;9;60;0
ASEEND*/
//CHKSM=F8BE8548FC3ED5229B5ECF5D331EB0F4AB19996D