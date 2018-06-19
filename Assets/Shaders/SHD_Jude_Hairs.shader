// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_Jude_Hairs"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.45
		_Texture1("Texture 1", 2D) = "white" {}
		_Tiling("Tiling", Range( 0 , 50)) = 2.037486
		_T_Jude_OP("T_Jude_OP", 2D) = "white" {}
		_MouvSpeed("MouvSpeed", Float) = 0
		_Paint("Paint", 2D) = "white" {}
		_Emissive("Emissive", Float) = 0
		_Texture3("Texture 3", 2D) = "white" {}
		_T_Ramp("T_Ramp", 2D) = "white" {}
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		_Float1("Float 1", Float) = 0
		_T_PerlinNoise("T_PerlinNoise", 2D) = "white" {}
		_Bad("Bad", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 0
		_EmissiveTex("EmissiveTex", 2D) = "white" {}
		_Tex("Tex", 2D) = "white" {}
		_Contrast("Contrast", Float) = 0.5
		_OverFX("OverFX", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true" "TakeFocus" = "True"  }
		Cull Back
		CGINCLUDE
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
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
			float2 texcoord_0;
			float3 worldNormal;
			INTERNAL_DATA
			float2 texcoord_1;
		};

		uniform sampler2D _Tex;
		uniform float4 _Tex_ST;
		uniform sampler2D _Paint;
		uniform float _Tiling;
		uniform float _MouvSpeed;
		uniform sampler2D _T_Ramp;
		uniform float _Contrast;
		uniform float _Bad;
		uniform sampler2D _T_PerlinNoise;
		uniform float _Float1;
		uniform float _OverFX;
		uniform float _Emissive;
		uniform sampler2D _EmissiveTex;
		uniform float4 _EmissiveTex_ST;
		uniform sampler2D _Texture1;
		uniform sampler2D _Texture3;
		uniform sampler2D _TextureSample2;
		uniform float4 _TextureSample2_ST;
		uniform sampler2D _T_Jude_OP;
		uniform float4 _T_Jude_OP_ST;
		uniform float _Alpha;
		uniform float _Cutoff = 0.45;


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
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			o.texcoord_1.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_Tex = i.uv_texcoord * _Tex_ST.xy + _Tex_ST.zw;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 appendResult14 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float4 unityObjectToClipPos8 = UnityObjectToClipPos( float3( 0,0,0 ) );
			float4 computeScreenPos9 = ComputeScreenPos( unityObjectToClipPos8 );
			float componentMask10 = computeScreenPos9.w;
			float4 appendResult18 = (float4(( computeScreenPos9 / componentMask10 ).x , ( computeScreenPos9 / componentMask10 ).y , 0.0 , 0.0));
			float4 temp_output_16_0 = ( ( appendResult14 - appendResult18 ) * _Tiling );
			float mulTime26 = _Time.y * _MouvSpeed;
			float temp_output_44_0 = ( mulTime26 * -1.0 );
			float2 appendResult48 = (float2(0.0 , temp_output_44_0));
			float4 tex2DNode7 = tex2D( _Paint, ( temp_output_16_0 + float4( appendResult48, 0.0 , 0.0 ) ).xy );
			float3 ase_worldPos = i.worldPos;
			float4 transform68 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float2 panner77 = ( i.texcoord_0 + 1.0 * _Time.y * float2( 0.05,0.05 ));
			float lerpResult64 = lerp( ( (0.0 + (( ase_worldPos.y - transform68.y ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) + (-0.35 + (_Bad - 0.0) * (-0.5 - -0.35) / (1.0 - 0.0)) ) , tex2D( _T_PerlinNoise, panner77 ).r , _Float1);
			float4 temp_cast_2 = (lerpResult64).xxxx;
			float blendOpSrc54 = saturate( tex2DNode7.r );
			float4 blendOpDest54 = tex2D( _T_Ramp, saturate( CalculateContrast(_Contrast,temp_cast_2) ).rg );
			float4 temp_output_67_0 = saturate( ( saturate( ( blendOpDest54 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest54 - 0.5 ) ) * ( 1.0 - blendOpSrc54 ) ) : ( 2.0 * blendOpDest54 * blendOpSrc54 ) ) )) );
			float4 lerpResult65 = lerp( float4( 0,0,0,0 ) , tex2D( _Tex, uv_Tex ) , temp_output_67_0.r);
			float4 lerpResult108 = lerp( lerpResult65 , float4( 0,0,0,0 ) , _OverFX);
			o.Albedo = lerpResult108.rgb;
			float2 uv_EmissiveTex = i.uv_texcoord * _EmissiveTex_ST.xy + _EmissiveTex_ST.zw;
			float4 lerpResult66 = lerp( float4( 0.0,0,0,0 ) , ( _Emissive * tex2D( _EmissiveTex, uv_EmissiveTex ) ) , temp_output_67_0.r);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar92 = TriplanarSampling( _Texture1, _Texture1, _Texture1, ase_worldPos, ase_worldNormal, 5.0, 0.5, 0 );
			float4 temp_cast_7 = (triplanar92.x).xxxx;
			float2 uv_TextureSample2 = i.uv_texcoord * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
			float2 panner98 = ( uv_TextureSample2 + 1.0 * _Time.y * float2( 0,0.1 ));
			float2 componentMask94 = ( ase_screenPosNorm + (1.0 + (_OverFX - 0.0) * (-1.0 - 1.0) / (1.0 - 0.0)) ).xy;
			float4 lerpResult106 = lerp( float4( 0,0,0,0 ) , ( saturate( CalculateContrast(5.0,temp_cast_7) ) * float4(0,0.9568628,1,0) * 15.0 * tex2D( _Texture3, panner98 ) ) , ( 1.0 - saturate( tex2D( _TextureSample2, componentMask94 ) ) ));
			float4 lerpResult85 = lerp( lerpResult66 , lerpResult106 , _OverFX);
			o.Emission = lerpResult85.rgb;
			o.Smoothness = 0.0;
			o.Alpha = 1;
			float2 clipScreen52 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither52 = Dither4x4Bayer( fmod(clipScreen52.x, 4), fmod(clipScreen52.y, 4) );
			float2 uv_T_Jude_OP = i.uv_texcoord * _T_Jude_OP_ST.xy + _T_Jude_OP_ST.zw;
			float lerpResult75 = lerp( tex2D( _T_Jude_OP, uv_T_Jude_OP ).r , 1.0 , _Alpha);
			float2 appendResult45 = (float2(0.0 , temp_output_44_0));
			float2 appendResult36 = (float2(( temp_output_16_0 + float4( appendResult45, 0.0 , 0.0 ) ).x , ( 1.0 - ( temp_output_16_0 + float4( appendResult45, 0.0 , 0.0 ) ).y )));
			float lerpResult39 = lerp( tex2DNode7.r , tex2D( _Paint, appendResult36 ).r , step( i.texcoord_1.x , 0.5 ));
			dither52 = step( dither52, saturate( ( lerpResult75 + lerpResult39 ) ) );
			clip( dither52 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows nolightmap  nodirlightmap vertex:vertexDataFunc 

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
1927;60;1906;780;165.1444;1744.5;2.853175;True;False
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;8;-2000.711,190.7342;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;9;-1812.769,191.6162;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComponentMaskNode;10;-1590.95,140.4836;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-1337.718,180.4252;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;27;-904.8674,-46.8003;Float;False;Property;_MouvSpeed;MouvSpeed;3;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.BreakToComponentsNode;12;-1166.643,205.6552;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;13;-1166.593,16.97487;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;14;-906.79,37.30489;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleTimeNode;26;-718.9677,-40.30027;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;18;-906.5531,205.6665;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.WorldPosInputsNode;69;1179.561,1343.089;Float;False;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;68;1172.889,1172.845;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-735.1482,121.6598;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;17;-1029.281,346.4404;Float;False;Property;_Tiling;Tiling;1;0;2.037486;0;50;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-366.3358,55.91889;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;-1.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;74;1180.951,1496.298;Float;False;Property;_Bad;Bad;10;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;606.0406,881.4888;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;1443.384,1298.083;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;83;1615.913,1944.514;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;-0.35;False;4;FLOAT;-0.5;False;1;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;45;-202.8496,-47.58228;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.PannerNode;77;845.5484,881.4891;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.05,0.05;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-561.8188,122.8906;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TFHCRemap;72;1618.747,1297.027;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;-1.0;False;2;FLOAT;1.0;False;3;FLOAT;0.0;False;4;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-28.12984,-65.2218;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleAddOpNode;73;1836.552,1297.721;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;86;324.9115,-916.6489;Float;False;Property;_OverFX;OverFX;16;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;107;574.5063,-2299.744;Float;False;2046.653;1588.597;Comment;19;88;89;90;91;92;93;94;95;96;97;98;99;100;101;102;103;104;105;106;OverFX;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;63;1088.687,865.8447;Float;True;Property;_T_PerlinNoise;T_PerlinNoise;9;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;62;1201.488,1065.018;Float;False;Property;_Float1;Float 1;8;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;89;664.7053,-913.1471;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;1.0;False;4;FLOAT;-1.0;False;1;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;88;624.5063,-1104.92;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;64;1413.149,864.5615;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;82;1420.838,1005.716;Float;False;Property;_Contrast;Contrast;14;0;0.5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.BreakToComponentsNode;35;119.6053,-64.80199;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;48;-193.8496,243.4177;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleAddOpNode;91;875.7354,-1037.727;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TexturePropertyNode;90;837.4894,-2249.744;Float;True;Property;_Texture1;Texture 1;1;0;Assets/Textures/FX/T_Veins4.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.OneMinusNode;40;188.7136,-130.1146;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-20.84961,136.4177;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleContrastOpNode;56;1621.056,866.0726;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0.5;False;1;COLOR
Node;AmplifyShaderEditor.TexturePropertyNode;37;122.1165,282.587;Float;True;Property;_Paint;Paint;4;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.ComponentMaskNode;94;1014.816,-1039.763;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TriplanarNode;92;1125.189,-2243.744;Float;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;1;None;Mid Texture 1;_MidTexture1;white;2;None;Bot Texture 1;_BotTexture1;white;3;None;Triplanar Sampler;5;0;SAMPLER2D;;False;1;SAMPLER2D;;False;2;SAMPLER2D;;False;3;FLOAT;0.5;False;4;FLOAT;5.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;36;407.2295,-62.97528;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;613.1578,341.7037;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;58;1899.074,1075.034;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;7;594.7392,120.7024;Float;True;Property;_T_Paint02;T_Paint02;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;837.9823,-1387.924;Float;False;0;95;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.3,0.3;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;96;1162.411,-1725.046;Float;True;Property;_Texture3;Texture 3;7;0;Assets/Textures/T_PerlinNoise.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SimpleContrastOpNode;97;1827.298,-2205.244;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;5.0;False;1;COLOR
Node;AmplifyShaderEditor.PannerNode;98;1172.49,-1529.791;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.1;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;95;1445.798,-1060.786;Float;True;Property;_TextureSample2;Texture Sample 2;8;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;61;2149.222,854.6779;Float;True;Property;_T_Ramp;T_Ramp;7;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;38;593.0687,-88.59653;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;76;1697.403,542.8046;Float;False;Property;_Alpha;Alpha;11;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;23;1675.925,349.7549;Float;True;Property;_T_Jude_OP;T_Jude_OP;2;0;Assets/Textures/T_Jude_OP.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.StepOpNode;34;871.8267,365.0432;Float;True;2;0;FLOAT;0.0;False;1;FLOAT;0.5;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;55;2394.48,561.691;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;81;1771.771,99.42816;Float;True;Property;_EmissiveTex;EmissiveTex;12;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;75;2028.403,408.8046;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;1.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;54;2587.969,652.1013;Float;False;Overlay;True;2;0;FLOAT;0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;102;1473.262,-1729.085;Float;True;Property;_TextureSample4;Texture Sample 4;9;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;103;1772.973,-2099.725;Float;False;Constant;_Color1;Color 1;4;0;0,0.9568628,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;101;1979.298,-2211.244;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;99;1823.55,-1921.828;Float;False;Constant;_Float3;Float 3;5;0;15;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;100;1784.69,-1055.255;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;39;1144.498,136.5209;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;51;1947.906,187.4478;Float;False;Property;_Emissive;Emissive;5;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;79;2358.076,-167.7101;Float;True;Property;_Tex;Tex;13;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;105;1942.403,-1054.739;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;2180.159,-2116.373;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;28;2235.781,265.2243;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;67;2797.36,655.6437;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;2153.969,121.4395;Float;False;2;2;0;FLOAT;0.0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;66;2463.283,445.9271;Float;False;3;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;106;2437.159,-2061.373;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;29;2370.98,264.0244;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;65;2834.013,-47.56748;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;85;3123.638,94.26616;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;60;1765.48,773.691;Float;False;Property;_WhiteArea;WhiteArea;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;108;3110.589,-129.2738;Float;False;3;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.TextureCoordinatesNode;53;1140.683,710.2239;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DitheringNode;52;2520.594,259.4576;Float;False;0;2;0;FLOAT;0.0;False;1;SAMPLER2D;;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;1944.48,691.691;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;57;2087.48,693.691;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;4.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;50;2493.808,130.3675;Float;False;Constant;_Float0;Float 0;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3549.862,-26.79491;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/SHD_Jude_Hairs;False;False;False;False;False;False;True;False;True;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Masked;0.45;True;True;0;False;TransparentCutout;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;8;0
WireConnection;10;0;9;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;12;0;11;0
WireConnection;14;0;13;1
WireConnection;14;1;13;2
WireConnection;26;0;27;0
WireConnection;18;0;12;0
WireConnection;18;1;12;1
WireConnection;15;0;14;0
WireConnection;15;1;18;0
WireConnection;44;0;26;0
WireConnection;70;0;69;2
WireConnection;70;1;68;2
WireConnection;83;0;74;0
WireConnection;45;1;44;0
WireConnection;77;0;78;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;72;0;70;0
WireConnection;25;0;16;0
WireConnection;25;1;45;0
WireConnection;73;0;72;0
WireConnection;73;1;83;0
WireConnection;63;1;77;0
WireConnection;89;0;86;0
WireConnection;64;0;73;0
WireConnection;64;1;63;1
WireConnection;64;2;62;0
WireConnection;35;0;25;0
WireConnection;48;1;44;0
WireConnection;91;0;88;0
WireConnection;91;1;89;0
WireConnection;40;0;35;1
WireConnection;49;0;16;0
WireConnection;49;1;48;0
WireConnection;56;1;64;0
WireConnection;56;0;82;0
WireConnection;94;0;91;0
WireConnection;92;0;90;0
WireConnection;36;0;35;0
WireConnection;36;1;40;0
WireConnection;58;0;56;0
WireConnection;7;0;37;0
WireConnection;7;1;49;0
WireConnection;97;1;92;1
WireConnection;98;0;93;0
WireConnection;95;1;94;0
WireConnection;61;1;58;0
WireConnection;38;0;37;0
WireConnection;38;1;36;0
WireConnection;34;0;32;1
WireConnection;55;0;7;1
WireConnection;75;0;23;1
WireConnection;75;2;76;0
WireConnection;54;0;55;0
WireConnection;54;1;61;0
WireConnection;102;0;96;0
WireConnection;102;1;98;0
WireConnection;101;0;97;0
WireConnection;100;0;95;0
WireConnection;39;0;7;1
WireConnection;39;1;38;1
WireConnection;39;2;34;0
WireConnection;105;0;100;0
WireConnection;104;0;101;0
WireConnection;104;1;103;0
WireConnection;104;2;99;0
WireConnection;104;3;102;0
WireConnection;28;0;75;0
WireConnection;28;1;39;0
WireConnection;67;0;54;0
WireConnection;80;0;51;0
WireConnection;80;1;81;0
WireConnection;66;1;80;0
WireConnection;66;2;67;0
WireConnection;106;1;104;0
WireConnection;106;2;105;0
WireConnection;29;0;28;0
WireConnection;65;1;79;0
WireConnection;65;2;67;0
WireConnection;85;0;66;0
WireConnection;85;1;106;0
WireConnection;85;2;86;0
WireConnection;108;0;65;0
WireConnection;108;2;86;0
WireConnection;52;0;29;0
WireConnection;59;0;53;2
WireConnection;59;1;60;0
WireConnection;57;0;59;0
WireConnection;0;0;108;0
WireConnection;0;2;85;0
WireConnection;0;4;50;0
WireConnection;0;10;52;0
ASEEND*/
//CHKSM=A92B2941E230A5614217DA85D9B51AC074717D7F