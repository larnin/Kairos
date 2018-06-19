// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_JudeFX_Simple"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Tiling("Tiling", Range( 0 , 50)) = 2.037486
		_ShadowColor("ShadowColor", Color) = (0,0,0,0)
		_LightColor("LightColor", Color) = (0,0,0,0)
		_T_Round("T_Round", 2D) = "white" {}
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
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 texcoord_0;
			float4 vertexColor : COLOR;
			float2 texcoord_1;
			float2 uv_texcoord;
		};

		uniform float4 _LightColor;
		uniform float4 _ShadowColor;
		uniform sampler2D _T_Smoke;
		uniform float _Tiling;
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
			float2 temp_cast_0 = (_Tiling).xx;
			o.texcoord_0.xy = v.texcoord.xy * temp_cast_0 + float2( 0,0 );
			o.texcoord_1.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 lerpResult47 = lerp( _LightColor , _ShadowColor , saturate( CalculateContrast(3.0,tex2D( _T_Smoke, i.texcoord_0 )) ).r);
			o.Emission = ( ( lerpResult47 * i.vertexColor ) * _Emissive ).rgb;
			float2 uv_T_Round = i.uv_texcoord * _T_Round_ST.xy + _T_Round_ST.zw;
			float blendOpSrc15 = tex2D( _T_Smoke, i.texcoord_0 ).r;
			float blendOpDest15 = (0.0 + (( ( 1.0 - i.texcoord_1.y ) * tex2D( _T_Round, uv_T_Round ).r ) - 0.0) * (0.8 - 0.0) / (1.0 - 0.0));
			float4 temp_cast_2 = (( saturate( ( blendOpDest15 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest15 - 0.5 ) ) * ( 1.0 - blendOpSrc15 ) ) : ( 2.0 * blendOpDest15 * blendOpSrc15 ) ) ))).xxxx;
			o.Alpha = ( saturate( CalculateContrast(_Contrast,temp_cast_2) ) * i.vertexColor.a ).r;
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
7;29;1906;1004;2176.571;544.2328;1.4116;True;False
Node;AmplifyShaderEditor.RangedFloatNode;31;-1288.962,-88.24503;Float;False;Property;_Tiling;Tiling;0;0;2.037486;0;50;0;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1335.769,375.3105;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;45;-886.2357,239.1467;Float;True;Property;_T_Smoke;T_Smoke;6;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SamplerNode;33;-1403.872,502.156;Float;True;Property;_T_Round;T_Round;3;0;Assets/Textures/FX/T_Round.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;-969.0869,-113.244;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;9;-1103.541,419.712;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;46;-564.0828,-248.8044;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-901.4022,504.081;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;53;-356.9841,-352.3353;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;3.0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;1;-574,-22;Float;True;Property;_T_Paint02;T_Paint02;0;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;32;-680.5891,505.2231;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;0.0;False;4;FLOAT;0.8;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;54;-196.7263,-345.1684;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;39;-175.1185,433.2752;Float;False;Property;_Contrast;Contrast;4;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;15;-264.5247,202.4937;Float;True;Overlay;True;2;0;FLOAT;0;False;1;FLOAT;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;42;-58.46584,-396.5439;Float;False;Property;_LightColor;LightColor;2;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;13;-60.09573,-224.5003;Float;False;Property;_ShadowColor;ShadowColor;1;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;11;-13,-35;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;3.0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;47;266.4127,-295.2735;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.VertexColorNode;59;161.2389,345.4559;Float;False;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;14;180.0519,99.69928;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;40;70.75261,255.5418;Float;False;Property;_Emissive;Emissive;5;0;0;0;2;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;553.2805,-94.26218;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;463.2076,174.6591;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;676.4172,11.1552;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.WorldPosInputsNode;71;-1206.083,-8.814379;Float;False;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;924.7435,-81.26988;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/SHD_JudeFX_Simple;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;Back;0;0;False;0;0;Transparent;0.5;True;True;0;False;Transparent;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;68;0;31;0
WireConnection;9;0;3;2
WireConnection;46;0;45;0
WireConnection;46;1;68;0
WireConnection;35;0;9;0
WireConnection;35;1;33;1
WireConnection;53;1;46;0
WireConnection;1;0;45;0
WireConnection;1;1;68;0
WireConnection;32;0;35;0
WireConnection;54;0;53;0
WireConnection;15;0;1;1
WireConnection;15;1;32;0
WireConnection;11;1;15;0
WireConnection;11;0;39;0
WireConnection;47;0;42;0
WireConnection;47;1;13;0
WireConnection;47;2;54;0
WireConnection;14;0;11;0
WireConnection;66;0;47;0
WireConnection;66;1;59;0
WireConnection;60;0;14;0
WireConnection;60;1;59;4
WireConnection;41;0;66;0
WireConnection;41;1;40;0
WireConnection;0;2;41;0
WireConnection;0;9;60;0
ASEEND*/
//CHKSM=AE9A2D048838382C139EE2F1872180777166CB40