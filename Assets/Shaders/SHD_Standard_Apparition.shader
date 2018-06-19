// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_Standard_Apparition"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Albedo("Albedo", 2D) = "white" {}
		[Header(SHDF_Veins)]
		_Veins("Veins", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_metalSmoothness("metalSmoothness", 2D) = "white" {}
		_VeinsTiling("VeinsTiling", Float) = 0.5
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Float) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Tiling("Tiling", Vector) = (0,0,0,0)
		_T_Paint02("T_Paint02", 2D) = "white" {}
		_VeinsPerlin("VeinsPerlin", 2D) = "white" {}
		_EffectTiling("EffectTiling", Float) = 1
		_VeinsRamp("VeinsRamp", 2D) = "white" {}
		_Ramp("Ramp", 2D) = "white" {}
		_BlackAreaSize("BlackAreaSize", Float) = 0
		_Apparition("Apparition", Range( 0 , 1)) = 1
		_T_PerlinNoise("T_PerlinNoise", 2D) = "white" {}
		_PerlinTiling("Perlin Tiling", Vector) = (0,0,0,0)
		_Scale("Scale", Float) = 0
		_Emission("Emission", Float) = 0
		_Emissivecolor("Emissivecolor", Color) = (0,0,0,0)
		_AlbedoTint("AlbedoTint", Color) = (0,0,0,0)
		_EmissiveTexture("EmissiveTexture", 2D) = "white" {}
		_OverFX("OverFX", Range( 0 , 1)) = 0
		_PerlinTile("PerlinTile", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true" "TakeFocus" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 texcoord_0;
			float4 screenPos;
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 texcoord_1;
		};

		uniform float _NormalIntensity;
		uniform sampler2D _NormalMap;
		uniform float2 _Tiling;
		uniform sampler2D _Albedo;
		uniform float4 _AlbedoTint;
		uniform sampler2D _T_Paint02;
		uniform float _EffectTiling;
		uniform sampler2D _Ramp;
		uniform sampler2D _T_PerlinNoise;
		uniform float2 _PerlinTiling;
		uniform float _Scale;
		uniform float _Apparition;
		uniform float _OverFX;
		uniform float _Emission;
		uniform float4 _Emissivecolor;
		uniform sampler2D _EmissiveTexture;
		uniform float4 _EmissiveTexture_ST;
		uniform sampler2D _Veins;
		uniform float _VeinsTiling;
		uniform sampler2D _VeinsPerlin;
		uniform float _PerlinTile;
		uniform sampler2D _VeinsRamp;
		uniform sampler2D _metalSmoothness;
		uniform float _Smoothness;
		uniform float _BlackAreaSize;
		uniform float _Cutoff = 0.5;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline float4 TriplanarSampling( sampler2D topTexMap, sampler2D midTexMap, sampler2D botTexMap, float3 worldPos, float3 worldNormal, float falloff, float tilling, float vertex )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= projNormal.x + projNormal.y + projNormal.z;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			if(vertex == 1){
			xNorm = ( tex2Dlod( topTexMap, float4((tilling * worldPos.zy * float2( nsign.x, 1.0 )).xy,0,0) ) );
			yNorm = ( tex2Dlod( topTexMap, float4((tilling * worldPos.zx).xy,0,0) ) );
			zNorm = ( tex2Dlod( topTexMap, float4((tilling * worldPos.xy * float2( -nsign.z, 1.0 )).xy,0,0) ) );
			} else {
			xNorm = ( tex2D( topTexMap, tilling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( topTexMap, tilling * worldPos.zx ) );
			zNorm = ( tex2D( topTexMap, tilling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			}
			return xNorm* projNormal.x + yNorm* projNormal.y + zNorm* projNormal.z;
		}


		inline float Dither4x4Bayer( int x, int y )
		{
			const float dither[ 16 ] = {
				 1,  9,  3, 11,
				13,  5, 15,  7,
				 4, 12,  2, 10,
				16,  8, 14,  6 };
			int r = y * 4 + x;
			return dither[r] / 16;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * _Tiling + float2( 0,0 );
			float2 temp_cast_0 = (_PerlinTile).xx;
			o.texcoord_1.xy = v.texcoord.xy * temp_cast_0 + float2( 0,0 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, i.texcoord_0 ) ,_NormalIntensity );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 appendResult63 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float4 unityObjectToClipPos57 = UnityObjectToClipPos( float3( 0,0,0 ) );
			float4 computeScreenPos58 = ComputeScreenPos( unityObjectToClipPos57 );
			float componentMask59 = computeScreenPos58.w;
			float4 appendResult64 = (float4(( computeScreenPos58 / componentMask59 ).x , ( computeScreenPos58 / componentMask59 ).y , 0.0 , 0.0));
			float4 tex2DNode21 = tex2D( _T_Paint02, ( ( appendResult63 - appendResult64 ) * _EffectTiling ).xy );
			float2 componentMask82 = tex2D( _T_PerlinNoise, ( appendResult63 * float4( _PerlinTiling, 0.0 , 0.0 ) ).xy ).rg;
			float temp_output_47_0 = (0.65 + (_Apparition - 0.0) * (0.0 - 0.65) / (1.0 - 0.0));
			float2 temp_cast_3 = (temp_output_47_0).xx;
			float4 blendOpSrc22 = tex2DNode21;
			float4 blendOpDest22 = tex2D( _Ramp, (componentMask82*_Scale + temp_cast_3) );
			float4 lerpResult13 = lerp( ( tex2D( _Albedo, i.texcoord_0 ) * _AlbedoTint ) , float4( 0,0,0,0 ) , saturate( CalculateContrast(3.0,( saturate( ( blendOpDest22 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest22 - 0.5 ) ) * ( 1.0 - blendOpSrc22 ) ) : ( 2.0 * blendOpDest22 * blendOpSrc22 ) ) ))) ).r);
			float4 lerpResult99 = lerp( lerpResult13 , float4( 0,0,0,0 ) , _OverFX);
			o.Albedo = lerpResult99.rgb;
			float2 uv_EmissiveTexture = i.uv_texcoord * _EmissiveTexture_ST.xy + _EmissiveTexture_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar5_g4 = TriplanarSampling( _Veins, _Veins, _Veins, ase_worldPos, ase_worldNormal, 5.0, _VeinsTiling, 0 );
			float4 temp_cast_6 = (triplanar5_g4.x).xxxx;
			float2 panner10_g4 = ( i.texcoord_1 + 1.0 * _Time.y * float2( 0,0.1 ));
			float2 componentMask6_g4 = ( ase_screenPosNorm + (1.0 + (_OverFX - 0.0) * (-1.0 - 1.0) / (1.0 - 0.0)) ).xy;
			float4 lerpResult19_g4 = lerp( float4( 0,0,0,0 ) , ( saturate( CalculateContrast(5.0,temp_cast_6) ) * float4(0,0.9568628,1,0) * 15.0 * tex2D( _VeinsPerlin, panner10_g4 ) ) , ( 1.0 - saturate( tex2D( _VeinsRamp, componentMask6_g4 ) ) ).r);
			float4 lerpResult103 = lerp( ( lerpResult13 * _Emission * _Emissivecolor * tex2D( _EmissiveTexture, uv_EmissiveTexture ) ) , lerpResult19_g4 , _OverFX);
			o.Emission = lerpResult103.rgb;
			float4 tex2DNode2 = tex2D( _metalSmoothness, i.texcoord_0 );
			o.Metallic = tex2DNode2.r;
			float lerpResult5 = lerp( 0.0 , tex2DNode2.a , _Smoothness);
			o.Smoothness = lerpResult5;
			o.Alpha = 1;
			float2 clipScreen32 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither32 = Dither4x4Bayer( fmod(clipScreen32.x, 4), fmod(clipScreen32.y, 4) );
			float2 temp_cast_9 = (( temp_output_47_0 + _BlackAreaSize )).xx;
			float4 blendOpSrc54 = ( 1.0 - tex2DNode21 );
			float4 blendOpDest54 = tex2D( _Ramp, (componentMask82*_Scale + temp_cast_9) );
			dither32 = step( dither32, ( 1.0 - saturate( CalculateContrast(1.5,( saturate( ( blendOpDest54 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest54 - 0.5 ) ) * ( 1.0 - blendOpSrc54 ) ) : ( 2.0 * blendOpDest54 * blendOpSrc54 ) ) ))) ) ).r );
			clip( dither32 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
1927;60;1906;780;-137.0482;905.7358;1.3;True;False
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;57;-3396.887,-174.7984;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;58;-3208.945,-173.9164;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ScreenPosInputsNode;61;-2562.769,-348.5577;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;59;-2987.126,-225.0489;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.Vector2Node;87;-2328.93,-548.2949;Float;False;Property;_PerlinTiling;Perlin Tiling;13;0;0,0;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;63;-2302.966,-328.2276;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleDivideOpNode;60;-2733.894,-185.1073;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-2135.215,-565.4587;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.BreakToComponentsNode;62;-2562.819,-159.8773;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;80;-1956.455,-567.8203;Float;True;Property;_T_PerlinNoise;T_PerlinNoise;12;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;64;-2302.729,-159.866;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;46;-1831.189,-68.91546;Float;False;Property;_Apparition;Apparition;11;0;1;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;88;-1213.565,-232.5605;Float;False;Property;_Scale;Scale;14;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;82;-1641.106,-567.6151;Float;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TFHCRemap;47;-1515.628,-67.34276;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;0.65;False;4;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;38;-1262.961,-49.67869;Float;False;Property;_BlackAreaSize;BlackAreaSize;10;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;24;-1035.997,-404.7466;Float;False;Property;_EffectTiling;EffectTiling;8;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;65;-2109.714,-254.6767;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TexturePropertyNode;34;-894.2617,-654.8318;Float;True;Property;_Ramp;Ramp;9;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.ScaleAndOffsetNode;26;-891.3821,-313.5579;Float;False;3;0;FLOAT2;0,0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-1015.339,-78.25054;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-850.3963,-423.9466;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;18;-541.7899,-554.9678;Float;True;Property;_Ramp;Ramp;7;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.Vector2Node;7;-1279.595,129.6514;Float;False;Property;_Tiling;Tiling;6;0;0,0;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScaleAndOffsetNode;36;-891.5275,-179.8392;Float;False;3;0;FLOAT2;0,0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;21;-530.3978,-768.8261;Float;True;Property;_T_Paint02;T_Paint02;7;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1085.997,129.6517;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;22;-172.3696,-689.3221;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;35;-524.3455,-339.6483;Float;True;Property;_TextureSample1;Texture Sample 1;7;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;53;-116.5565,-118.7051;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;93;603.4727,-265.8614;Float;False;Property;_AlbedoTint;AlbedoTint;17;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;29;56.43526,-685.0612;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;3.0;False;1;COLOR
Node;AmplifyShaderEditor.BlendOpsNode;54;57.72607,-124.7943;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;1;-552,-92.5;Float;True;Property;_Albedo;Albedo;0;0;Assets/Textures/T_textured_soft_paint02_basecolor.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;31;208.4353,-683.4613;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;817.4965,-88.37794;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleContrastOpNode;55;286.5309,-120.5334;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;1.5;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;95;1016.665,282.6264;Float;True;Property;_EmissiveTexture;EmissiveTexture;19;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;89;689.0062,77.4491;Float;False;Property;_Emission;Emission;15;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;102;820.4248,-728.5303;Float;False;Property;_PerlinTile;PerlinTile;21;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;13;1097.256,-62.65728;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;97;698.9283,-634.9778;Float;False;Property;_OverFX;OverFX;20;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;56;438.531,-118.9335;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;91;1104.881,110.4176;Float;False;Property;_Emissivecolor;Emissivecolor;16;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;6;-491.2387,549.5;Float;False;Property;_Smoothness;Smoothness;5;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-605,348.5;Float;True;Property;_metalSmoothness;metalSmoothness;2;0;Assets/Textures/T_textured_soft_paint02_metal_smoothness.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.FunctionNode;104;1082.993,-624.502;Float;False;SHDF_Veins;0;;4;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;COLOR
Node;AmplifyShaderEditor.OneMinusNode;33;386.7756,202.4416;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;4;-765,179.5;Float;False;Property;_NormalIntensity;Normal Intensity;4;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;1335.823,46.43409;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.DitheringNode;32;567.9595,196.7796;Float;False;0;2;0;FLOAT;0.0;False;1;SAMPLER2D;;False;1;FLOAT
Node;AmplifyShaderEditor.ScreenDepthNode;66;73.84169,392.772;Float;False;0;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;5;-170,444.5;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;99;1577.33,-199.299;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;3;-526,133.5;Float;True;Property;_NormalMap;Normal Map;3;0;Assets/Textures/T_textured_soft_paint02_normal.png;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;103;1578.847,-67.48994;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1872.166,-3.378693;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/SHD_Standard_Apparition;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Masked;0.5;True;True;0;False;TransparentCutout;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;58;0;57;0
WireConnection;59;0;58;0
WireConnection;63;0;61;1
WireConnection;63;1;61;2
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;86;0;63;0
WireConnection;86;1;87;0
WireConnection;62;0;60;0
WireConnection;80;1;86;0
WireConnection;64;0;62;0
WireConnection;64;1;62;1
WireConnection;82;0;80;0
WireConnection;47;0;46;0
WireConnection;65;0;63;0
WireConnection;65;1;64;0
WireConnection;26;0;82;0
WireConnection;26;1;88;0
WireConnection;26;2;47;0
WireConnection;37;0;47;0
WireConnection;37;1;38;0
WireConnection;23;0;65;0
WireConnection;23;1;24;0
WireConnection;18;0;34;0
WireConnection;18;1;26;0
WireConnection;36;0;82;0
WireConnection;36;1;88;0
WireConnection;36;2;37;0
WireConnection;21;1;23;0
WireConnection;8;0;7;0
WireConnection;22;0;21;0
WireConnection;22;1;18;0
WireConnection;35;0;34;0
WireConnection;35;1;36;0
WireConnection;53;0;21;0
WireConnection;29;1;22;0
WireConnection;54;0;53;0
WireConnection;54;1;35;0
WireConnection;1;1;8;0
WireConnection;31;0;29;0
WireConnection;92;0;1;0
WireConnection;92;1;93;0
WireConnection;55;1;54;0
WireConnection;13;0;92;0
WireConnection;13;2;31;0
WireConnection;56;0;55;0
WireConnection;2;1;8;0
WireConnection;104;0;102;0
WireConnection;104;1;97;0
WireConnection;33;0;56;0
WireConnection;90;0;13;0
WireConnection;90;1;89;0
WireConnection;90;2;91;0
WireConnection;90;3;95;0
WireConnection;32;0;33;0
WireConnection;66;0;61;0
WireConnection;5;1;2;4
WireConnection;5;2;6;0
WireConnection;99;0;13;0
WireConnection;99;2;97;0
WireConnection;3;1;8;0
WireConnection;3;5;4;0
WireConnection;103;0;90;0
WireConnection;103;1;104;0
WireConnection;103;2;97;0
WireConnection;0;0;99;0
WireConnection;0;1;3;0
WireConnection;0;2;103;0
WireConnection;0;3;2;1
WireConnection;0;4;5;0
WireConnection;0;10;32;0
ASEEND*/
//CHKSM=8F459B1F75998EED1FB65C81EA71E58805BF64BD