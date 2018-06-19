// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_Hairs"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_T_LinearMask1("T_LinearMask1", 2D) = "white" {}
		_MouvSpeed("MouvSpeed", Float) = 0
		_MouvementStrength("MouvementStrength", Float) = 0
		_T_PerlinNoise("T_PerlinNoise", 2D) = "white" {}
		_TilingGradient("Tiling Gradient", Vector) = (0,0,0,0)
		_OpacityContrast("OpacityContrast", Float) = 0
		_OpacityPosition("OpacityPosition", Float) = 0
		_TilingCloud("TilingCloud", Float) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 texcoord_0;
			float2 texcoord_1;
			float2 texcoord_2;
		};

		uniform float _OpacityContrast;
		uniform float2 _TilingGradient;
		uniform float _OpacityPosition;
		uniform sampler2D _T_LinearMask1;
		uniform float _MouvSpeed;
		uniform sampler2D _T_PerlinNoise;
		uniform float _TilingCloud;
		uniform float _MouvementStrength;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * _TilingGradient + float2( 0,0 );
			float4 temp_cast_0 = (0.0).xxxx;
			float2 temp_cast_1 = (_MouvSpeed).xx;
			o.texcoord_1.xy = v.texcoord.xy * _TilingGradient + float2( 0,0 );
			float4 appendResult7 = (float4(o.texcoord_1.y , o.texcoord_1.x , 0.0 , 0.0));
			float2 panner5 = ( appendResult7.xy + 1.0 * _Time.y * temp_cast_1);
			float2 temp_cast_4 = (( _MouvSpeed * _TilingCloud )).xx;
			o.texcoord_2.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float2 panner22 = ( o.texcoord_2 + 1.0 * _Time.y * temp_cast_4);
			float4 lerpResult18 = lerp( tex2Dlod( _T_LinearMask1, float4( panner5, 0.0 , 0.0 ) ) , tex2Dlod( _T_PerlinNoise, float4( panner22, 0.0 , 0.0 ) ) , 0.5);
			float4 lerpResult9 = lerp( temp_cast_0 , ( lerpResult18 * _MouvementStrength ) , saturate( pow( o.texcoord_1.x , 2.0 ) ));
			v.vertex.xyz += lerpResult9.rgb;
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = float4(1,1,1,0).rgb;
			float4 temp_cast_1 = (( ( 1.0 - i.texcoord_0.x ) + _OpacityPosition )).xxxx;
			o.Alpha = saturate( CalculateContrast(_OpacityContrast,temp_cast_1) ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
1927;29;1906;1004;1041.768;269.208;1.526976;True;True
Node;AmplifyShaderEditor.Vector2Node;24;-1245.114,260.7246;Float;False;Property;_TilingGradient;Tiling Gradient;4;0;0,0;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-954,268;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;36;-1038.715,749.2844;Float;False;Property;_TilingCloud;TilingCloud;7;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;8;-682,441;Float;False;Property;_MouvSpeed;MouvSpeed;1;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-782.5604,719.4117;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;7;-673,291;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-680.9325,862.7469;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.PannerNode;22;-478.7613,723.999;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.PannerNode;5;-520,291;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;16;-233.8641,729.7207;Float;True;Property;_T_PerlinNoise;T_PerlinNoise;3;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;19;-122.5789,939.0916;Float;False;Constant;_Float1;Float 1;4;0;0.5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;3;-281,271;Float;True;Property;_T_LinearMask1;T_LinearMask1;0;0;Assets/Textures/T_LinearMask1.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;31;292.2201,766.6188;Float;False;Property;_OpacityPosition;OpacityPosition;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;28;313.2632,684.5504;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;18;287.714,276.591;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;30;526.2201,675.6188;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;11;212.742,398.2967;Float;False;Property;_MouvementStrength;MouvementStrength;2;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;29;524.8218,775.0545;Float;False;Property;_OpacityContrast;OpacityContrast;5;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;14;282.4764,492.2006;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;2.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;27;742.5989,680.6316;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0.0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;15;485.7672,492.1098;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;13;487.0478,397.6219;Float;False;Constant;_Float0;Float 0;3;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;493.045,277.3152;Float;False;2;2;0;COLOR;0.0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;33;904.2201,682.6188;Float;False;1;0;COLOR;0.0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;2;427.0022,59.65994;Float;False;Constant;_Color0;Color 0;0;0;1,1,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;9;664.197,326.1636;Float;False;3;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;926.381,97.62836;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/SHD_Hairs;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Transparent;0.5;True;True;0;False;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;24;0
WireConnection;23;0;36;0
WireConnection;7;0;6;2
WireConnection;7;1;6;1
WireConnection;35;0;8;0
WireConnection;35;1;36;0
WireConnection;22;0;23;0
WireConnection;22;2;35;0
WireConnection;5;0;7;0
WireConnection;5;2;8;0
WireConnection;16;1;22;0
WireConnection;3;1;5;0
WireConnection;28;0;6;1
WireConnection;18;0;3;0
WireConnection;18;1;16;0
WireConnection;18;2;19;0
WireConnection;30;0;28;0
WireConnection;30;1;31;0
WireConnection;14;0;6;1
WireConnection;27;1;30;0
WireConnection;27;0;29;0
WireConnection;15;0;14;0
WireConnection;10;0;18;0
WireConnection;10;1;11;0
WireConnection;33;0;27;0
WireConnection;9;0;13;0
WireConnection;9;1;10;0
WireConnection;9;2;15;0
WireConnection;0;2;2;0
WireConnection;0;9;33;0
WireConnection;0;11;9;0
ASEEND*/
//CHKSM=D86227AFDEE2A53C05B12B6F1E8790DD7CABF631