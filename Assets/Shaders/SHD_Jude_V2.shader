// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_JudeV2"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.25
		_Texture1("Texture 1", 2D) = "white" {}
		_Tiling("Tiling", Range( 0 , 50)) = 2.037486
		_MouvSpeed("MouvSpeed", Float) = 0
		_Paint("Paint", 2D) = "white" {}
		_Emissive("Emissive", Float) = 0
		_T_Ramp("T_Ramp", 2D) = "white" {}
		_Float1("Float 1", Float) = 0
		_Texture3("Texture 3", 2D) = "white" {}
		_T_PerlinNoise("T_PerlinNoise", 2D) = "white" {}
		_Good("Good", Range( 0 , 1)) = 0
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Bad("Bad", Range( 0 , 1)) = 0
		_OverFX("OverFX", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true" "TakeFocus" = "True" }
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
			float4 screenPos;
			float3 worldPos;
			float2 texcoord_0;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform sampler2D _Paint;
		uniform float _Tiling;
		uniform float _MouvSpeed;
		uniform sampler2D _T_Ramp;
		uniform float _Good;
		uniform sampler2D _T_PerlinNoise;
		uniform float _Float1;
		uniform float _OverFX;
		uniform float _Emissive;
		uniform sampler2D _Texture1;
		uniform sampler2D _Texture3;
		uniform sampler2D _TextureSample1;
		uniform float4 _TextureSample1_ST;
		uniform float _Bad;
		uniform float _Cutoff = 0.25;


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
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 appendResult14 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float4 unityObjectToClipPos8 = UnityObjectToClipPos( float3( 0,0,0 ) );
			float4 computeScreenPos9 = ComputeScreenPos( unityObjectToClipPos8 );
			float componentMask10 = computeScreenPos9.w;
			float4 appendResult18 = (float4(( computeScreenPos9 / componentMask10 ).x , ( computeScreenPos9 / componentMask10 ).y , 0.0 , 0.0));
			float mulTime26 = _Time.y * _MouvSpeed;
			float2 appendResult48 = (float2(0.1 , ( mulTime26 * -1.0 )));
			float4 tex2DNode7 = tex2D( _Paint, ( ( ( appendResult14 - appendResult18 ) * _Tiling ) + float4( appendResult48, 0.0 , 0.0 ) ).xy );
			float3 ase_worldPos = i.worldPos;
			float4 transform68 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float temp_output_70_0 = ( ase_worldPos.y - transform68.y );
			float2 panner77 = ( i.texcoord_0 + 1.0 * _Time.y * float2( 0.05,0.05 ));
			float4 tex2DNode63 = tex2D( _T_PerlinNoise, panner77 );
			float lerpResult64 = lerp( ( (0.0 + (temp_output_70_0 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) + (-0.2 + (_Good - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ) , tex2DNode63.r , _Float1);
			float4 temp_cast_2 = (lerpResult64).xxxx;
			float blendOpSrc54 = saturate( tex2DNode7.r );
			float4 blendOpDest54 = tex2D( _T_Ramp, saturate( CalculateContrast(0.5,temp_cast_2) ).rg );
			float4 temp_output_67_0 = saturate( ( saturate( ( blendOpDest54 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest54 - 0.5 ) ) * ( 1.0 - blendOpSrc54 ) ) : ( 2.0 * blendOpDest54 * blendOpSrc54 ) ) )) );
			float4 lerpResult65 = lerp( float4( 0,0,0,0 ) , float4( 1,1,1,0 ) , temp_output_67_0.r);
			float4 lerpResult90 = lerp( lerpResult65 , float4( 0,0,0,0 ) , _OverFX);
			o.Albedo = lerpResult90.rgb;
			float lerpResult66 = lerp( _Emissive , 1.2 , temp_output_67_0.r);
			float4 temp_cast_7 = (lerpResult66).xxxx;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar96 = TriplanarSampling( _Texture1, _Texture1, _Texture1, ase_worldPos, ase_worldNormal, 5.0, 0.5, 0 );
			float4 temp_cast_8 = (triplanar96.x).xxxx;
			float2 uv_TextureSample1 = i.uv_texcoord * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
			float2 panner102 = ( uv_TextureSample1 + 1.0 * _Time.y * float2( 0,0.1 ));
			float2 componentMask98 = ( ase_screenPosNorm + (1.0 + (_OverFX - 0.0) * (-1.0 - 1.0) / (1.0 - 0.0)) ).xy;
			float4 lerpResult110 = lerp( float4( 0,0,0,0 ) , ( saturate( CalculateContrast(5.0,temp_cast_8) ) * float4(0,0.9568628,1,0) * 15.0 * tex2D( _Texture3, panner102 ) ) , ( 1.0 - saturate( tex2D( _TextureSample1, componentMask98 ) ) ));
			float4 lerpResult91 = lerp( temp_cast_7 , lerpResult110 , _OverFX);
			o.Emission = lerpResult91.rgb;
			o.Smoothness = 0.0;
			o.Alpha = 1;
			float2 clipScreen52 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither52 = Dither4x4Bayer( fmod(clipScreen52.x, 4), fmod(clipScreen52.y, 4) );
			float lerpResult82 = lerp( tex2DNode7.r , tex2DNode63.r , 0.5);
			float temp_output_86_0 = ( 1.0 - _Bad );
			float lerpResult75 = lerp( ( lerpResult82 * (0.0 + (temp_output_70_0 - -1.0) * (temp_output_86_0 - 0.0) / (1.0 - -1.0)) ) , 1.0 , temp_output_86_0);
			dither52 = step( dither52, saturate( ( lerpResult75 + tex2DNode7.r ) ) );
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
1927;194;1906;780;-867.2424;1976.825;3.075449;True;False
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;8;-2000.711,190.7342;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;9;-1812.769,191.6162;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComponentMaskNode;10;-1590.95,140.4836;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-1337.718,180.4252;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;27;-737.2748,494.9526;Float;False;Property;_MouvSpeed;MouvSpeed;2;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.BreakToComponentsNode;12;-1166.643,205.6552;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;13;-1166.593,16.97487;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldPosInputsNode;69;1179.561,1343.089;Float;False;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;68;1172.889,1172.845;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;18;-906.5531,205.6665;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.DynamicAppendNode;14;-906.79,37.30489;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleTimeNode;26;-551.3751,501.4526;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;74;1183.552,1499.721;Float;False;Property;_Good;Good;8;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;1443.384,1298.083;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;606.0406,881.4888;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;17;-1029.281,346.4404;Float;False;Property;_Tiling;Tiling;1;0;2.037486;0;50;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-366.3357,264.4353;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;-1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-735.1482,121.6598;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.PannerNode;77;845.5484,881.4891;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.05,0.05;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.TFHCRemap;72;1618.747,1297.027;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;-1.0;False;2;FLOAT;1.0;False;3;FLOAT;0.0;False;4;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;87;1582.037,1500.659;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;-0.2;False;4;FLOAT;0.2;False;1;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;48;-193.8496,243.4177;Float;False;FLOAT2;4;0;FLOAT;0.1;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-561.8188,122.8906;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;89;828.5827,-536.9217;Float;False;Property;_OverFX;OverFX;11;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;73;1836.552,1297.721;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;111;1066.464,-1940.67;Float;False;2046.652;1588.596;Comment;19;92;93;94;95;96;97;98;99;100;101;102;103;104;105;106;107;108;109;110;OverFX;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;63;1088.687,865.8447;Float;True;Property;_T_PerlinNoise;T_PerlinNoise;7;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;62;1201.488,1065.018;Float;False;Property;_Float1;Float 1;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;93;1156.663,-554.0733;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;1.0;False;4;FLOAT;-1.0;False;1;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;92;1116.464,-745.8461;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;80;1192.445,1679.611;Float;False;Property;_Bad;Bad;9;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-20.84961,136.4177;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.LerpOp;64;1413.149,864.5615;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;37;176.8049,-100.2318;Float;True;Property;_Paint;Paint;3;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.TexturePropertyNode;94;1329.447,-1890.67;Float;True;Property;_Texture1;Texture 1;1;0;Assets/Textures/FX/T_Veins4.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SimpleAddOpNode;95;1367.693,-678.6533;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleContrastOpNode;56;1744.198,878.2649;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0.5;False;1;COLOR
Node;AmplifyShaderEditor.OneMinusNode;86;1593.072,1682.277;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;7;594.7392,120.7024;Float;True;Property;_T_Paint02;T_Paint02;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;98;1506.774,-680.6893;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TextureCoordinatesNode;97;1329.94,-1028.85;Float;False;0;99;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.3,0.3;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TriplanarNode;96;1617.147,-1884.67;Float;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;1;None;Mid Texture 1;_MidTexture1;white;2;None;Bot Texture 1;_BotTexture1;white;3;None;Triplanar Sampler;5;0;SAMPLER2D;;False;1;SAMPLER2D;;False;2;SAMPLER2D;;False;3;FLOAT;0.5;False;4;FLOAT;5.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;85;1850.919,1535.416;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;-1.0;False;2;FLOAT;1.0;False;3;FLOAT;0.0;False;4;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;82;2296.701,1078.679;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.5;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;58;1899.074,1075.034;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;55;2394.48,561.691;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;2578.187,1235.788;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;61;2149.222,854.6779;Float;True;Property;_T_Ramp;T_Ramp;5;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleContrastOpNode;101;2319.256,-1846.17;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;5.0;False;1;COLOR
Node;AmplifyShaderEditor.PannerNode;102;1664.448,-1170.717;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.1;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;99;1937.756,-701.7123;Float;True;Property;_TextureSample1;Texture Sample 1;8;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;100;1654.369,-1365.972;Float;True;Property;_Texture3;Texture 3;7;0;Assets/Textures/T_PerlinNoise.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SamplerNode;106;1965.22,-1370.011;Float;True;Property;_TextureSample3;Texture Sample 3;9;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;107;2264.93,-1740.651;Float;False;Constant;_Color1;Color 1;4;0;0,0.9568628,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;105;2471.256,-1852.17;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;103;2315.507,-1562.754;Float;False;Constant;_Float3;Float 3;5;0;15;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;104;2276.648,-696.1813;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.BlendOpsNode;54;2587.969,652.1013;Float;False;Overlay;True;2;0;FLOAT;0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;75;2028.403,408.8046;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;1.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;67;2797.36,655.6437;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;28;2235.781,265.2243;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;109;2434.361,-695.6653;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;2672.116,-1757.299;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;51;2498.191,48.37586;Float;False;Property;_Emissive;Emissive;4;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;65;2834.013,-47.56748;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;110;2929.116,-1702.299;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;66;2778.283,189.9271;Float;False;3;0;FLOAT;0,0,0,0;False;1;FLOAT;1.2;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;29;2370.98,264.0244;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.DitheringNode;52;2520.594,259.4576;Float;False;0;2;0;FLOAT;0.0;False;1;SAMPLER2D;;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;50;2493.808,130.3675;Float;False;Constant;_Float0;Float 0;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;90;3075.074,-86.25732;Float;False;3;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;91;3070.074,34.74268;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3440.272,-49.66622;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/SHD_JudeV2;False;False;False;False;False;False;True;False;True;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Masked;0.25;True;True;0;False;TransparentCutout;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;8;0
WireConnection;10;0;9;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;12;0;11;0
WireConnection;18;0;12;0
WireConnection;18;1;12;1
WireConnection;14;0;13;1
WireConnection;14;1;13;2
WireConnection;26;0;27;0
WireConnection;70;0;69;2
WireConnection;70;1;68;2
WireConnection;44;0;26;0
WireConnection;15;0;14;0
WireConnection;15;1;18;0
WireConnection;77;0;78;0
WireConnection;72;0;70;0
WireConnection;87;0;74;0
WireConnection;48;1;44;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;73;0;72;0
WireConnection;73;1;87;0
WireConnection;63;1;77;0
WireConnection;93;0;89;0
WireConnection;49;0;16;0
WireConnection;49;1;48;0
WireConnection;64;0;73;0
WireConnection;64;1;63;1
WireConnection;64;2;62;0
WireConnection;95;0;92;0
WireConnection;95;1;93;0
WireConnection;56;1;64;0
WireConnection;86;0;80;0
WireConnection;7;0;37;0
WireConnection;7;1;49;0
WireConnection;98;0;95;0
WireConnection;96;0;94;0
WireConnection;85;0;70;0
WireConnection;85;4;86;0
WireConnection;82;0;7;1
WireConnection;82;1;63;1
WireConnection;58;0;56;0
WireConnection;55;0;7;1
WireConnection;84;0;82;0
WireConnection;84;1;85;0
WireConnection;61;1;58;0
WireConnection;101;1;96;1
WireConnection;102;0;97;0
WireConnection;99;1;98;0
WireConnection;106;0;100;0
WireConnection;106;1;102;0
WireConnection;105;0;101;0
WireConnection;104;0;99;0
WireConnection;54;0;55;0
WireConnection;54;1;61;0
WireConnection;75;0;84;0
WireConnection;75;2;86;0
WireConnection;67;0;54;0
WireConnection;28;0;75;0
WireConnection;28;1;7;1
WireConnection;109;0;104;0
WireConnection;108;0;105;0
WireConnection;108;1;107;0
WireConnection;108;2;103;0
WireConnection;108;3;106;0
WireConnection;65;2;67;0
WireConnection;110;1;108;0
WireConnection;110;2;109;0
WireConnection;66;0;51;0
WireConnection;66;2;67;0
WireConnection;29;0;28;0
WireConnection;52;0;29;0
WireConnection;90;0;65;0
WireConnection;90;2;89;0
WireConnection;91;0;66;0
WireConnection;91;1;110;0
WireConnection;91;2;89;0
WireConnection;0;0;90;0
WireConnection;0;2;91;0
WireConnection;0;4;50;0
WireConnection;0;10;52;0
ASEEND*/
//CHKSM=0A5BB05EB8FE230343D45F41FB7E55EFCDF55C7B