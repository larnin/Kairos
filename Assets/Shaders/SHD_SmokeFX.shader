// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_SmokeFX"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_DefautNormal("DefautNormal", 2D) = "bump" {}
		_Flowmap("Flowmap", 2D) = "white" {}
		_RowsAndColumns("RowsAndColumns", Vector) = (6,5,0,0)
		_Speed("Speed", Float) = 5
		_Normal("Normal", 2D) = "bump" {}
		_BaseTexture("BaseTexture", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_EmissiveIntensity("EmissiveIntensity", Float) = 0
		_NormalIntensity("Normal Intensity", Range( 0 , 1)) = 0
		_UVsDeformation("UVsDeformation", Range( -1 , 1)) = 0
		_Depth("Depth", Float) = 0
		_OpacityMultiplier("OpacityMultiplier", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float2 texcoord_0;
			float2 texcoord_1;
			float4 screenPos;
		};

		uniform sampler2D _DefautNormal;
		uniform float4 _DefautNormal_ST;
		uniform sampler2D _Normal;
		uniform float _Speed;
		uniform float2 _RowsAndColumns;
		uniform sampler2D _Flowmap;
		uniform float _UVsDeformation;
		uniform float _NormalIntensity;
		uniform float4 _Color;
		uniform sampler2D _BaseTexture;
		uniform float _EmissiveIntensity;
		uniform sampler2D _CameraDepthTexture;
		uniform float _Depth;
		uniform sampler2D _OpacityMultiplier;
		uniform float4 _OpacityMultiplier_ST;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			o.texcoord_1.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_DefautNormal = i.uv_texcoord * _DefautNormal_ST.xy + _DefautNormal_ST.zw;
			float temp_output_10_0 = ( _Time.y * _Speed );
			float temp_output_4_0_g7 = ( temp_output_10_0 - frac( temp_output_10_0 ) );
			float componentMask13_g7 = _RowsAndColumns.x;
			float2 temp_output_8_0_g7 = ( float2( 1,1 ) / _RowsAndColumns );
			float componentMask9_g7 = temp_output_8_0_g7.x;
			float2 appendResult6_g7 = (float2(fmod( temp_output_4_0_g7 , componentMask13_g7 ) , ( 1.0 - floor( ( temp_output_4_0_g7 * componentMask9_g7 ) ) )));
			float2 componentMask23 = tex2D( _Flowmap, ( ( appendResult6_g7 + i.texcoord_0 ) * temp_output_8_0_g7 ) ).rg;
			float temp_output_31_0 = frac( temp_output_10_0 );
			float2 temp_output_36_0 = ( ( ( appendResult6_g7 + i.texcoord_0 ) * temp_output_8_0_g7 ) - ( ( ( ( componentMask23 * float2( 2,2 ) ) - float2( 1,1 ) ) * temp_output_31_0 ) * _UVsDeformation ) );
			float temp_output_4_0_g6 = ( ( temp_output_10_0 + 1.0 ) - frac( ( temp_output_10_0 + 1.0 ) ) );
			float componentMask13_g6 = _RowsAndColumns.x;
			float2 temp_output_8_0_g6 = ( float2( 1,1 ) / _RowsAndColumns );
			float componentMask9_g6 = temp_output_8_0_g6.x;
			float2 appendResult6_g6 = (float2(fmod( temp_output_4_0_g6 , componentMask13_g6 ) , ( 1.0 - floor( ( temp_output_4_0_g6 * componentMask9_g6 ) ) )));
			float2 componentMask27 = tex2D( _Flowmap, ( ( appendResult6_g6 + i.texcoord_0 ) * temp_output_8_0_g6 ) ).rg;
			float2 temp_output_37_0 = ( ( ( ( ( componentMask27 * float2( 2,2 ) ) - float2( 1,1 ) ) * ( 1.0 - temp_output_31_0 ) ) * _UVsDeformation ) + ( ( appendResult6_g6 + i.texcoord_0 ) * temp_output_8_0_g6 ) );
			float4 lerpResult62 = lerp( tex2D( _Normal, temp_output_36_0 ) , tex2D( _Normal, temp_output_37_0 ) , temp_output_31_0);
			float4 lerpResult73 = lerp( float4( UnpackScaleNormal( tex2D( _DefautNormal, uv_DefautNormal ) ,0.2 ) , 0.0 ) , lerpResult62 , _NormalIntensity);
			o.Normal = lerpResult73.rgb;
			float4 tex2DNode1 = tex2D( _BaseTexture, temp_output_36_0 );
			float4 tex2DNode39 = tex2D( _BaseTexture, temp_output_37_0 );
			float4 lerpResult4 = lerp( tex2DNode1 , tex2DNode39 , temp_output_31_0);
			float4 lerpResult55 = lerp( ( _Color * lerpResult4 ) , float4( 0,0,0,0 ) , i.texcoord_1.y);
			float4 temp_output_57_0 = ( lerpResult55 * _EmissiveIntensity );
			o.Albedo = temp_output_57_0.rgb;
			o.Emission = temp_output_57_0.rgb;
			float temp_output_59_0 = 0.0;
			o.Metallic = temp_output_59_0;
			o.Smoothness = temp_output_59_0;
			float lerpResult40 = lerp( tex2DNode1.a , tex2DNode39.a , temp_output_31_0);
			float lerpResult56 = lerp( ( _Color.a * lerpResult40 ) , 0.0 , i.texcoord_1.y);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth75 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth75 = abs( ( screenDepth75 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Depth ) );
			float2 uv_OpacityMultiplier = i.uv_texcoord * _OpacityMultiplier_ST.xy + _OpacityMultiplier_ST.zw;
			o.Alpha = ( lerpResult56 * saturate( distanceDepth75 ) * tex2D( _OpacityMultiplier, uv_OpacityMultiplier ).r );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog vertex:vertexDataFunc 

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
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
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
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
2078;119;1677;686;1446.466;439.9473;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;12;-3697.958,10.10308;Float;False;446.0966;291.2595;Frame Nb;3;9;10;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-3638.014,186.3626;Float;False;Property;_Speed;Speed;3;0;5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleTimeNode;9;-3647.958,60.1031;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3420.861,107.9912;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.Vector2Node;15;-3215.7,111.6042;Float;False;Property;_RowsAndColumns;RowsAndColumns;2;0;6,5;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-3185.628,289.64;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-3460.684,-128.3814;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;22;-2595.8,156.2512;Float;False;371;280;Next frame;1;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2605.607,-149.0893;Float;False;371;280;Current frame;1;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;20;-2889.801,388.2511;Float;True;Property;_Flowmap;Flowmap;1;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.FunctionNode;43;-2968.628,239.6401;Float;False;SHDF_SubUV;-1;;6;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.FunctionNode;42;-2972.74,-66.79595;Float;False;SHDF_SubUV;-1;;7;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;2;-2555.606,-99.08934;Float;True;Property;_Current;Current;2;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;19;-2545.8,206.2512;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;27;-2163.429,197.8005;Float;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.ComponentMaskNode;23;-2160.6,-106.1688;Float;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1927.428,201.8005;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1924.6,-102.1688;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2
Node;AmplifyShaderEditor.FractNode;31;-2345.376,471.9846;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-1775.428,200.8005;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2
Node;AmplifyShaderEditor.OneMinusNode;32;-1791.161,317.6976;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;25;-1772.6,-103.1688;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;67;-1930.406,30.8429;Float;False;Property;_UVsDeformation;UVsDeformation;9;0;0;-1;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1610.6,-103.1688;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1613.428,200.8005;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1458.43,201.6612;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1444.451,-103.1089;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TexturePropertyNode;38;-1259.911,-248.5036;Float;True;Property;_BaseTexture;BaseTexture;5;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-1265.503,240.806;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-1262.706,-52.77991;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;1;-805.5264,-78.80592;Float;True;Property;_BaseTexture;BaseTexture;0;0;Assets/Textures/OutputSlate.PNG;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;39;-809.745,215.6416;Float;True;Property;_TextureSample3;Texture Sample 3;0;0;Assets/Textures/OutputSlate.PNG;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;76;-75.985,517.5026;Float;False;Property;_Depth;Depth;11;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;48;-453.5417,-348.4542;Float;False;Property;_Color;Color;6;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;63;-1237.829,636.0322;Float;True;Property;_Normal;Normal;4;0;None;True;bump;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.LerpOp;4;-379.5958,13.64141;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;40;-369.5567,170.0191;Float;False;3;0;FLOAT;0,0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.DepthFade;75;112.1262,515.7928;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;61;-912.3475,573.1381;Float;True;Property;_TextureSample4;Texture Sample 4;1;0;Assets/Textures/OutputSlate.PNG;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.5;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;60;-907.4659,775.2857;Float;True;Property;_TextureSample2;Texture Sample 2;2;0;Assets/Textures/OutputSlate.PNG;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.5;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-154.5422,184.5454;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;54;-354.7417,339.2456;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-127.2422,3.845459;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;56;89.85817,205.3453;Float;False;3;0;FLOAT;0,0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;64;-897.8729,986.9077;Float;True;Property;_DefautNormal;DefautNormal;0;0;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.2;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;62;-377.2169,583.6855;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;78;326.6604,521.0878;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;58;-2.442225,431.5454;Float;False;Property;_EmissiveIntensity;EmissiveIntensity;7;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;55;88.55824,7.745362;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;66;-423.0731,1091.208;Float;False;Property;_NormalIntensity;Normal Intensity;8;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;80;213.6604,655.0877;Float;True;Property;_OpacityMultiplier;OpacityMultiplier;12;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;59;440.8579,140.3454;Float;False;Constant;_Float1;Float 1;9;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;77;-1308.135,-253.4619;Float;False;Property;_Distance;Distance;10;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;73;-65.56983,710.4288;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;330.3577,46.74543;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.VertexColorNode;44;-415.8423,-175.5545;Float;False;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;513.1195,384.4046;Float;False;3;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;717.4999,1.3;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/SHD_SmokeFX;False;False;False;False;True;True;True;True;True;True;False;False;False;False;True;False;False;Back;0;0;False;0;0;Transparent;0.5;True;True;0;False;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;0
WireConnection;10;1;11;0
WireConnection;17;0;10;0
WireConnection;43;0;14;0
WireConnection;43;1;15;0
WireConnection;43;2;17;0
WireConnection;42;0;14;0
WireConnection;42;1;15;0
WireConnection;42;2;10;0
WireConnection;2;0;20;0
WireConnection;2;1;42;0
WireConnection;19;0;20;0
WireConnection;19;1;43;0
WireConnection;27;0;19;0
WireConnection;23;0;2;0
WireConnection;28;0;27;0
WireConnection;24;0;23;0
WireConnection;31;0;10;0
WireConnection;29;0;28;0
WireConnection;32;0;31;0
WireConnection;25;0;24;0
WireConnection;26;0;25;0
WireConnection;26;1;31;0
WireConnection;30;0;29;0
WireConnection;30;1;32;0
WireConnection;35;0;30;0
WireConnection;35;1;67;0
WireConnection;33;0;26;0
WireConnection;33;1;67;0
WireConnection;37;0;35;0
WireConnection;37;1;43;0
WireConnection;36;0;42;0
WireConnection;36;1;33;0
WireConnection;1;0;38;0
WireConnection;1;1;36;0
WireConnection;39;0;38;0
WireConnection;39;1;37;0
WireConnection;4;0;1;0
WireConnection;4;1;39;0
WireConnection;4;2;31;0
WireConnection;40;0;1;4
WireConnection;40;1;39;4
WireConnection;40;2;31;0
WireConnection;75;0;76;0
WireConnection;61;0;63;0
WireConnection;61;1;36;0
WireConnection;60;0;63;0
WireConnection;60;1;37;0
WireConnection;45;0;48;4
WireConnection;45;1;40;0
WireConnection;46;0;48;0
WireConnection;46;1;4;0
WireConnection;56;0;45;0
WireConnection;56;2;54;2
WireConnection;62;0;61;0
WireConnection;62;1;60;0
WireConnection;62;2;31;0
WireConnection;78;0;75;0
WireConnection;55;0;46;0
WireConnection;55;2;54;2
WireConnection;73;0;64;0
WireConnection;73;1;62;0
WireConnection;73;2;66;0
WireConnection;57;0;55;0
WireConnection;57;1;58;0
WireConnection;74;0;56;0
WireConnection;74;1;78;0
WireConnection;74;2;80;1
WireConnection;0;0;57;0
WireConnection;0;1;73;0
WireConnection;0;2;57;0
WireConnection;0;3;59;0
WireConnection;0;4;59;0
WireConnection;0;9;74;0
ASEEND*/
//CHKSM=68AD71EF8EFE0D7B91E17ADF2F6447BF7C341B75