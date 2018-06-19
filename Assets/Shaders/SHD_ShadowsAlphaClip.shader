// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_ShadowsAlphaClip"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_EffectTiling("EffectTiling", Float) = 5
		_Texture1("Texture 1", 2D) = "white" {}
		_Tiling("Tiling", Range( 0 , 50)) = 2.037486
		_MouvSpeed("MouvSpeed", Float) = 0
		_Paint("Paint", 2D) = "white" {}
		_Color("Color ", Color) = (0,0,0,0)
		_Opacity("Opacity", 2D) = "white" {}
		_Power("Power", Float) = 0
		_Texture3("Texture 3", 2D) = "white" {}
		_Burnmask("Burn mask", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Ramp("Ramp", 2D) = "white" {}
		_Float4("Float 4", Float) = 0
		_Apparition("Apparition", Range( 0 , 1)) = 1
		_PerlinNoise("Perlin Noise", 2D) = "white" {}
		_PerlinTiling("PerlinTiling", Vector) = (0,0,0,0)
		_Scale("Scale", Float) = 0
		_OverFX("OverFX", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true" "TakeFocus" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform float4 _Color;
		uniform float _OverFX;
		uniform sampler2D _Texture1;
		uniform sampler2D _Texture3;
		uniform float4 _Texture3_ST;
		uniform sampler2D _TextureSample1;
		uniform sampler2D _Opacity;
		uniform float4 _Opacity_ST;
		uniform sampler2D _Paint;
		uniform float _Tiling;
		uniform float _MouvSpeed;
		uniform float _Power;
		uniform sampler2D _Burnmask;
		uniform float _EffectTiling;
		uniform sampler2D _Ramp;
		uniform sampler2D _PerlinNoise;
		uniform float2 _PerlinTiling;
		uniform float _Scale;
		uniform float _Apparition;
		uniform float _Float4;
		uniform float _Cutoff = 0.5;


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


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float4 lerpResult149 = lerp( _Color , float4( 0,0,0,0 ) , _OverFX);
			o.Albedo = lerpResult149.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar134 = TriplanarSampling( _Texture1, _Texture1, _Texture1, ase_worldPos, ase_worldNormal, 5.0, 0.5, 0 );
			float4 temp_cast_1 = (triplanar134.x).xxxx;
			float2 uv_Texture3 = i.uv_texcoord * _Texture3_ST.xy + _Texture3_ST.zw;
			float2 panner138 = ( uv_Texture3 + 1.0 * _Time.y * float2( 0,0.1 ));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 componentMask133 = ( ase_screenPosNorm + (1.0 + (_OverFX - 0.0) * (-1.0 - 1.0) / (1.0 - 0.0)) ).xy;
			float4 lerpResult147 = lerp( float4( 0,0,0,0 ) , ( saturate( CalculateContrast(5.0,temp_cast_1) ) * float4(0,0.9568628,1,0) * 15.0 * tex2D( _Texture3, panner138 ) ) , ( 1.0 - saturate( tex2D( _TextureSample1, componentMask133 ) ) ));
			o.Emission = lerpResult147.rgb;
			o.Smoothness = 0.0;
			o.Alpha = 1;
			float2 clipScreen52 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither52 = Dither8x8Bayer( fmod(clipScreen52.x, 8), fmod(clipScreen52.y, 8) );
			float2 uv_Opacity = i.uv_texcoord * _Opacity_ST.xy + _Opacity_ST.zw;
			float4 appendResult14 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float4 unityObjectToClipPos8 = UnityObjectToClipPos( float3( 0,0,0 ) );
			float4 computeScreenPos9 = ComputeScreenPos( unityObjectToClipPos8 );
			float componentMask10 = computeScreenPos9.w;
			float4 appendResult18 = (float4(( computeScreenPos9 / componentMask10 ).x , ( computeScreenPos9 / componentMask10 ).y , 0.0 , 0.0));
			float mulTime26 = _Time.y * _MouvSpeed;
			float4 appendResult102 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float4 unityObjectToClipPos95 = UnityObjectToClipPos( float3( 0,0,0 ) );
			float4 computeScreenPos96 = ComputeScreenPos( unityObjectToClipPos95 );
			float componentMask97 = computeScreenPos96.w;
			float4 appendResult103 = (float4(( computeScreenPos96 / componentMask97 ).x , ( computeScreenPos96 / componentMask97 ).y , 0.0 , 0.0));
			float2 componentMask110 = ( appendResult102 - appendResult103 ).xy;
			float2 componentMask114 = tex2D( _PerlinNoise, ( appendResult102 * float4( _PerlinTiling, 0.0 , 0.0 ) ).xy ).rg;
			float2 temp_cast_7 = (( (0.65 + (_Apparition - 0.0) * (0.0 - 0.65) / (1.0 - 0.0)) + _Float4 )).xx;
			float4 blendOpSrc121 = ( 1.0 - tex2D( _Burnmask, ( _EffectTiling * componentMask110 ) ) );
			float4 blendOpDest121 = tex2D( _Ramp, (componentMask114*_Scale + temp_cast_7) );
			dither52 = step( dither52, saturate( ( saturate( pow( ( tex2D( _Opacity, uv_Opacity ).r + tex2D( _Paint, ( ( ( appendResult14 - appendResult18 ) * _Tiling ) + float4( ( float2( 0.1,-1 ) * mulTime26 ), 0.0 , 0.0 ) ).xy ).r ) , _Power ) ) * ( 1.0 - saturate( CalculateContrast(1.5,( saturate( ( blendOpDest121 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest121 - 0.5 ) ) * ( 1.0 - blendOpSrc121 ) ) : ( 2.0 * blendOpDest121 * blendOpSrc121 ) ) ))) ) ) ) ).r );
			clip( dither52 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
1927;222;1906;780;-1868.909;593.6844;1;True;False
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;95;-1767.788,1173.114;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;96;-1579.847,1173.996;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComponentMaskNode;97;-1358.027,1122.863;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;8;-2000.711,190.7342;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleDivideOpNode;98;-1104.796,1162.805;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;9;-1812.769,191.6162;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ScreenPosInputsNode;99;-933.6704,999.3546;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;10;-1590.95,140.4836;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.BreakToComponentsNode;100;-933.7205,1188.035;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;102;-673.8674,1019.685;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.Vector2Node;101;-699.8313,799.6174;Float;False;Property;_PerlinTiling;PerlinTiling;13;0;0,0;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-1337.718,180.4252;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.DynamicAppendNode;103;-673.6304,1188.046;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;106;-202.0903,1278.997;Float;False;Property;_Apparition;Apparition;11;0;1;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-506.1164,782.4536;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.BreakToComponentsNode;12;-1166.643,205.6552;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-480.6155,1093.236;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ScreenPosInputsNode;13;-1166.593,16.97487;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;111;535.7906,571.5171;Float;False;Property;_EffectTiling;EffectTiling;1;0;5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;110;487.3066,650.1507;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;108;-327.3564,780.092;Float;True;Property;_PerlinNoise;Perlin Noise;12;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;109;113.4706,1280.57;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;0.65;False;4;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;14;-906.79,37.30489;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.DynamicAppendNode;18;-906.5531,205.6665;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;107;366.1376,1298.234;Float;False;Property;_Float4;Float 4;10;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;27;-737.2748,494.9526;Float;False;Property;_MouvSpeed;MouvSpeed;3;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;115;415.5337,1115.352;Float;False;Property;_Scale;Scale;14;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;769.226,580.3677;Float;False;2;2;0;FLOAT;0,0;False;1;FLOAT2;0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleAddOpNode;112;613.7596,1269.662;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;114;-12.00739,780.2972;Float;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleTimeNode;26;-551.3751,501.4526;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.Vector2Node;94;-579.0091,262.9326;Float;False;Constant;_Vector0;Vector 0;7;0;0.1,-1;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-735.1482,121.6598;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;17;-1029.281,346.4404;Float;False;Property;_Tiling;Tiling;2;0;2.037486;0;50;0;1;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;118;722.6257,929.2138;Float;True;Property;_Ramp;Ramp;9;0;Assets/Textures/FX/T_Ramp.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SamplerNode;117;1054.895,556.2365;Float;True;Property;_Burnmask;Burn mask;8;0;Assets/Textures/FX/T_burnt_mask.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-561.8188,122.8906;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;116;737.571,1168.073;Float;False;3;0;FLOAT2;0,0,0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-366.3357,264.4353;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0.0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.CommentaryNode;148;538.0763,-2059.633;Float;False;2046.652;1588.597;Comment;19;129;130;131;132;133;134;135;136;137;138;139;140;141;142;143;144;145;146;147;OverFX;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;120;1104.753,1008.264;Float;True;Property;_TextureSample5;Texture Sample 5;7;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;119;1349.295,556.8318;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.TexturePropertyNode;37;176.8049,-100.2318;Float;True;Property;_Paint;Paint;4;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-20.84961,136.4177;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;127;255.9707,-654.0804;Float;False;Property;_OverFX;OverFX;16;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;89;608.8129,-94.75232;Float;True;Property;_Opacity;Opacity;6;0;Assets/Textures/T_Jude_OP.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;121;1686.825,1223.118;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;7;594.7392,120.7024;Float;True;Property;_T_Paint02;T_Paint02;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;130;628.2753,-673.0361;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;1.0;False;4;FLOAT;-1.0;False;1;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;129;588.0763,-864.8088;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;91;1061.812,381.6099;Float;False;Property;_Power;Power;7;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;28;1072.033,127.6266;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;122;1915.629,1227.379;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;1.5;False;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;132;839.3054,-797.616;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TexturePropertyNode;131;801.0594,-2009.633;Float;True;Property;_Texture1;Texture 1;1;0;Assets/Textures/FX/T_Veins4.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.ComponentMaskNode;133;978.3865,-799.652;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TriplanarNode;134;1088.759,-2003.633;Float;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;1;None;Mid Texture 1;_MidTexture1;white;2;None;Bot Texture 1;_BotTexture1;white;3;None;Triplanar Sampler;5;0;SAMPLER2D;;False;1;SAMPLER2D;;False;2;SAMPLER2D;;False;3;FLOAT;0.5;False;4;FLOAT;5.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;135;801.5524,-1147.813;Float;False;0;136;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.3,0.3;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;123;2067.629,1228.979;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.PowerNode;90;1323.218,287.6403;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;137;1409.368,-820.6748;Float;True;Property;_TextureSample1;Texture Sample 1;8;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;136;1125.981,-1484.935;Float;True;Property;_Texture3;Texture 3;7;0;Assets/Textures/T_PerlinNoise.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.PannerNode;138;1136.06,-1289.68;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.1;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleContrastOpNode;139;1790.868,-1965.133;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;5.0;False;1;COLOR
Node;AmplifyShaderEditor.OneMinusNode;125;2243.091,1205.431;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;92;1494.073,282.5148;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;143;1942.868,-1971.133;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;141;1787.12,-1681.717;Float;False;Constant;_Float2;Float 2;5;0;15;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;142;1748.26,-815.144;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;140;1736.542,-1859.614;Float;False;Constant;_Color1;Color 1;4;0;0,0.9568628,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;144;1436.832,-1488.974;Float;True;Property;_TextureSample3;Texture Sample 3;9;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;1842.677,497.1344;Float;False;2;2;0;FLOAT;0.0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;2143.728,-1876.262;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;88;2506.548,-57.4292;Float;False;Property;_Color;Color ;5;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;29;2370.98,264.0244;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.OneMinusNode;146;1905.973,-814.628;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;149;2807.445,-98.37329;Float;False;3;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.DitheringNode;52;2520.594,257.7491;Float;False;1;2;0;FLOAT;0.0;False;1;SAMPLER2D;;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;147;2400.729,-1821.262;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;50;2493.808,130.3675;Float;False;Constant;_Float0;Float 0;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3129.272,-42.66622;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/SHD_ShadowsAlphaClip;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Masked;0.5;True;True;0;False;TransparentCutout;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;96;0;95;0
WireConnection;97;0;96;0
WireConnection;98;0;96;0
WireConnection;98;1;97;0
WireConnection;9;0;8;0
WireConnection;10;0;9;0
WireConnection;100;0;98;0
WireConnection;102;0;99;1
WireConnection;102;1;99;2
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;103;0;100;0
WireConnection;103;1;100;1
WireConnection;105;0;102;0
WireConnection;105;1;101;0
WireConnection;12;0;11;0
WireConnection;104;0;102;0
WireConnection;104;1;103;0
WireConnection;110;0;104;0
WireConnection;108;1;105;0
WireConnection;109;0;106;0
WireConnection;14;0;13;1
WireConnection;14;1;13;2
WireConnection;18;0;12;0
WireConnection;18;1;12;1
WireConnection;113;0;111;0
WireConnection;113;1;110;0
WireConnection;112;0;109;0
WireConnection;112;1;107;0
WireConnection;114;0;108;0
WireConnection;26;0;27;0
WireConnection;15;0;14;0
WireConnection;15;1;18;0
WireConnection;117;1;113;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;116;0;114;0
WireConnection;116;1;115;0
WireConnection;116;2;112;0
WireConnection;44;0;94;0
WireConnection;44;1;26;0
WireConnection;120;0;118;0
WireConnection;120;1;116;0
WireConnection;119;0;117;0
WireConnection;49;0;16;0
WireConnection;49;1;44;0
WireConnection;121;0;119;0
WireConnection;121;1;120;0
WireConnection;7;0;37;0
WireConnection;7;1;49;0
WireConnection;130;0;127;0
WireConnection;28;0;89;1
WireConnection;28;1;7;1
WireConnection;122;1;121;0
WireConnection;132;0;129;0
WireConnection;132;1;130;0
WireConnection;133;0;132;0
WireConnection;134;0;131;0
WireConnection;123;0;122;0
WireConnection;90;0;28;0
WireConnection;90;1;91;0
WireConnection;137;1;133;0
WireConnection;138;0;135;0
WireConnection;139;1;134;1
WireConnection;125;0;123;0
WireConnection;92;0;90;0
WireConnection;143;0;139;0
WireConnection;142;0;137;0
WireConnection;144;0;136;0
WireConnection;144;1;138;0
WireConnection;124;0;92;0
WireConnection;124;1;125;0
WireConnection;145;0;143;0
WireConnection;145;1;140;0
WireConnection;145;2;141;0
WireConnection;145;3;144;0
WireConnection;29;0;124;0
WireConnection;146;0;142;0
WireConnection;149;0;88;0
WireConnection;149;2;127;0
WireConnection;52;0;29;0
WireConnection;147;1;145;0
WireConnection;147;2;146;0
WireConnection;0;0;149;0
WireConnection;0;2;147;0
WireConnection;0;4;50;0
WireConnection;0;10;52;0
ASEEND*/
//CHKSM=5C37F56022D1C5E2C71145CD2F5C5ADF3E12EB8A