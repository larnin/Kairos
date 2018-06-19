// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SHD_PostProcessEffects"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_GameOver("GameOver", Range( 0 , 1)) = 0
		_T_burnt_mask("T_burnt_mask", 2D) = "white" {}
		_T_Ramp("T_Ramp", 2D) = "white" {}
		_T_ObjectsFade("T_ObjectsFade", 2D) = "white" {}
		_T_Vignette("T_Vignette", 2D) = "white" {}
		_Pause("Pause", Range( 0 , 1)) = 0
		_T_UVFisheye("T_UVFisheye", 2D) = "white" {}
		_PerlinNoise("PerlinNoise", 2D) = "white" {}
		_FastForward("FastForward", Range( 0 , 1)) = 0
		_Stripes("Stripes", 2D) = "white" {}
		_Sens("Sens", Range( 0 , 1)) = 0
	}

	SubShader
	{
		Tags{  }
		
		ZTest Always Cull Off ZWrite Off
		


		Pass
		{ 
			CGPROGRAM 

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _GameOver;
			uniform sampler2D _T_burnt_mask;
			uniform sampler2D _T_Ramp;
			uniform sampler2D _T_ObjectsFade;
			uniform float4 _T_ObjectsFade_ST;
			uniform sampler2D _T_Vignette;
			uniform float4 _T_Vignette_ST;
			uniform float _Pause;
			uniform sampler2D _T_UVFisheye;
			uniform float4 _T_UVFisheye_ST;
			uniform sampler2D _PerlinNoise;
			uniform float _FastForward;
			uniform sampler2D _Stripes;
			uniform float _Sens;

			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				o.pos = UnityObjectToClipPos ( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#ifdef UNITY_HALF_TEXEL_OFFSET
						o.uv.y += _MainTex_TexelSize.y;
				#endif

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv91 = i.uv.xy*float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode96 = tex2D( _MainTex, uv91 );
				float2 uv140 = i.uv.xy*float2( 5,3 ) + float2( 0,0 );
				float2 uv_T_ObjectsFade = i.uv.xy*_T_ObjectsFade_ST.xy + _T_ObjectsFade_ST.zw;
				float2 uv_T_Vignette = i.uv.xy*_T_Vignette_ST.xy + _T_Vignette_ST.zw;
				float4 tex2DNode94 = tex2D( _T_Vignette, uv_T_Vignette );
				float4 lerpResult146 = lerp( tex2D( _T_ObjectsFade, uv_T_ObjectsFade ) , tex2DNode94 , 0.4264706);
				float2 componentMask142 = lerpResult146.rg;
				float2 temp_cast_0 = ((-0.5 + (( 1.0 - _GameOver ) - 0.0) * (0.6 - -0.5) / (1.0 - 0.0))).xx;
				float blendOpSrc144 = ( 1.0 - tex2D( _T_burnt_mask, uv140 ).r );
				float4 blendOpDest144 = tex2D( _T_Ramp, (componentMask142*1.0 + temp_cast_0) );
				float4 lerpResult136 = lerp( float4( 0,0,0,0 ) , tex2DNode96 , ( saturate( ( blendOpDest144 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest144 - 0.5 ) ) * ( 1.0 - blendOpSrc144 ) ) : ( 2.0 * blendOpDest144 * blendOpSrc144 ) ) )).r);
				float2 uv_T_UVFisheye = i.uv.xy*_T_UVFisheye_ST.xy + _T_UVFisheye_ST.zw;
				float2 componentMask102 = tex2D( _T_UVFisheye, uv_T_UVFisheye ).rg;
				float2 temp_cast_2 = (0.05).xx;
				float2 uv115 = i.uv.xy*float2( 0.01,0.01 ) + float2( 0,0 );
				float2 panner116 = ( uv115 + 1.0 * _Time.y * temp_cast_2);
				float2 temp_cast_3 = (0.05).xx;
				float2 uv125 = i.uv.xy*float2( 0.01,0.01 ) + float2( 0.2,0.2 );
				float2 panner126 = ( uv125 + 1.0 * _Time.y * temp_cast_3);
				float2 appendResult127 = (float2(tex2D( _PerlinNoise, panner116 ).r , tex2D( _PerlinNoise, panner126 ).g));
				float2 lerpResult117 = lerp( componentMask102 , ( componentMask102 + (float2( -1,-1 ) + (appendResult127 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 ))) ) , 0.05);
				float2 lerpResult101 = lerp( uv91 , lerpResult117 , ( 0.15 * ( 1.0 - tex2DNode94.r ) * _Pause ));
				float4 blendOpSrc106 = float4(1,0,0.2647056,0);
				float blendOpDest106 = Luminance(tex2D( _MainTex, lerpResult101 ).rgb);
				float4 blendOpSrc110 = tex2DNode96;
				float4 blendOpDest110 = 	max( blendOpSrc106, blendOpDest106 );
				float4 lerpResult129 = lerp( tex2DNode96 , min( blendOpSrc110 , blendOpDest110 ) , ( ( 1.0 - saturate( pow( tex2DNode94.r , 4.0 ) ) ) * _Pause ));
				float2 uv7 = i.uv.xy*float2( 1,1 ) + float2( 0,0 );
				float2 _MouvSpeed = float2(10,0.1);
				float2 lerpResult77 = lerp( _MouvSpeed , ( _MouvSpeed * float2( -1,-1 ) ) , _Sens);
				float2 lerpResult84 = lerp( float2( 0,0 ) , lerpResult77 , _FastForward);
				float2 panner11 = ( uv7 + 1.0 * _Time.y * lerpResult84);
				float4 tex2DNode6 = tex2D( _Stripes, panner11 );
				float componentMask20 = tex2DNode6.r;
				float lerpResult85 = lerp( 0.0 , 0.02 , _FastForward);
				float lerpResult8 = lerp( 0.0 , componentMask20 , lerpResult85);
				float2 appendResult72 = (float2(lerpResult8 , 0.0));
				float2 lerpResult80 = lerp( ( uv7 + appendResult72 ) , ( uv7 - appendResult72 ) , _Sens);
				float lerpResult86 = lerp( 0.0 , 0.0025 , _FastForward);
				float4 temp_output_68_0 = ( ( ( tex2D( _MainTex, ( lerpResult80 + ( float2( -1,1 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 0 ][ 0 ] ) + ( tex2D( _MainTex, ( lerpResult80 + ( float2( 0,1 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 0 ][ 1 ] ) + ( tex2D( _MainTex, ( lerpResult80 + ( float2( 1,1 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 0 ][ 2 ] ) + ( tex2D( _MainTex, ( lerpResult80 + ( float2( -1,0 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 1 ][ 0 ] ) + ( tex2D( _MainTex, ( lerpResult80 + ( float2( 0,0 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 1 ][ 1 ] ) + ( tex2D( _MainTex, ( lerpResult80 + ( float2( 1,0 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 1 ][ 2 ] ) + ( tex2D( _MainTex, ( lerpResult80 + ( float2( -1,-1 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 2 ][ 0 ] ) + ( tex2D( _MainTex, ( lerpResult80 + ( float2( 0,-1 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 2 ][ 1 ] ) + ( tex2D( _MainTex, ( lerpResult80 + ( float2( 1,-1 ) * lerpResult86 ) ) ) * float3x3(0,0,0,1,1,1,0,0,0)[ 2 ][ 2 ] ) ) * ( 1.0 / 3.0 ) );
				float4 blendOpSrc73 = tex2DNode6;
				float4 blendOpDest73 = temp_output_68_0;
				float lerpResult87 = lerp( 0.0 , 0.2 , _FastForward);
				float4 lerpResult74 = lerp( temp_output_68_0 , ( saturate( ( blendOpDest73 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest73 - 0.5 ) ) * ( 1.0 - blendOpSrc73 ) ) : ( 2.0 * blendOpDest73 * blendOpSrc73 ) ) )) , lerpResult87);
				float4 ifLocalVar154 = 0;
				if( _FastForward <= 0.0 )
					ifLocalVar154 = tex2DNode96;
				else
					ifLocalVar154 = lerpResult74;
				float4 ifLocalVar155 = 0;
				if( _Pause <= 0.0 )
					ifLocalVar155 = ifLocalVar154;
				else
					ifLocalVar155 = lerpResult129;
				float4 ifLocalVar156 = 0;
				if( _GameOver <= 0.0 )
					ifLocalVar156 = ifLocalVar155;
				else
					ifLocalVar156 = lerpResult136;

				finalColor = ifLocalVar156;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
2094;363;1449;670;1196.477;-2144.19;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;133;-3654.142,-159.8554;Float;False;5220.289;861.52;Fast forward / rewind;30;2;63;10;74;85;78;71;6;76;8;77;75;83;13;7;73;86;70;79;69;15;11;80;20;66;72;84;43;68;87;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;13;-3603.436,296.9862;Float;False;Constant;_MouvSpeed;MouvSpeed;0;0;10,0.1;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-3373.311,245.6743;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;78;-3604.142,419.5259;Float;False;Property;_Sens;Sens;5;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;83;-3595.974,519.8416;Float;False;Property;_FastForward;FastForward;6;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;77;-3198.178,295.3746;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.CommentaryNode;132;-1762.823,1014.94;Float;False;3396.269;2070.751;Pause;33;122;125;115;126;116;124;123;114;109;127;94;102;121;128;120;119;113;103;117;112;91;101;98;100;99;107;104;131;106;96;130;110;129;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;84;-2619.071,272.071;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-2691.942,107.8672;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;115;-1630.968,2679.248;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.01,0.01;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;125;-1626.879,2902.47;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.01,0.01;False;1;FLOAT2;0.2,0.2;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.PannerNode;11;-2421.414,230.4368;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;122;-1712.823,2821.129;Float;False;Constant;_ChromaticAbberationMouvSpeed;ChromaticAbberationMouvSpeed;12;0;0.05;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;15;-2671.76,-109.8554;Float;True;Property;_Stripes;Stripes;3;0;Assets/Textures/FX/T_AnisotropicNoise.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.TexturePropertyNode;124;-1405.415,2470.066;Float;True;Property;_PerlinNoise;PerlinNoise;14;0;Assets/Textures/T_PerlinNoise.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.RangedFloatNode;10;-1787.036,453.8537;Float;False;Constant;_Intensity;Intensity;1;0;0.02;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.PannerNode;126;-1359.489,2902.47;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.02,0.02;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.PannerNode;116;-1363.579,2679.249;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.02,0.02;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;6;-2192.414,199.4368;Float;True;Property;_T_AnisotropicNoise;T_AnisotropicNoise;1;0;Assets/Textures/FX/T_AnisotropicNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;20;-1686.735,209.1979;Float;False;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;123;-1161.672,2855.691;Float;True;Property;_TextureSample3;Texture Sample 3;10;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;85;-1492.591,435.8912;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;114;-1168.948,2651.964;Float;True;Property;_T_PerlinNoise;T_PerlinNoise;10;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;127;-757.9178,2770.347;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.LerpOp;8;-1239.289,206.1496;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;109;-777.7419,2154.317;Float;True;Property;_T_UVFisheye;T_UVFisheye;9;0;Assets/Textures/FX/T_UVFisheye.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;121;-357.3437,2667.759;Float;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2
Node;AmplifyShaderEditor.ComponentMaskNode;102;-375.5763,2153.08;Float;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;94;401.6461,1868.608;Float;True;Property;_T_Vignette;T_Vignette;7;0;Assets/Textures/T_Vignette.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;72;-1075.432,204.5282;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-802.889,97.36173;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-135.4283,2469.491;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;103;-781.5607,2385.743;Float;False;Constant;_VignetteDeformation;VignetteDeformation;9;0;0.15;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;-801.2448,325.3823;Float;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;43;-494.5403,586.6646;Float;False;Constant;_Offset;Offset;2;0;0.0025;0;0.005;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;119;-450.1115,2936.97;Float;False;Constant;_ChromaticAberationMouvStrength;ChromaticAberationMouvStrength;11;0;0.05;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;113;-635.1337,2477.808;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;128;-751.3561,2560.798;Float;False;Property;_Pause;Pause;14;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;117;37.37469,2365.808;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.LerpOp;80;-494.288,219.3304;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-405.7148,2423.554;Float;False;3;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;149;-885.2811,3343.885;Float;False;2339.912;638.772;dead end;13;139;135;146;148;147;140;142;143;134;141;145;144;136;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;63.63859,60.87449;Float;False;_MainTex;0;1;SAMPLER2D
Node;AmplifyShaderEditor.LerpOp;86;-175.4299,439.9872;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;91;-281.8466,1669.557;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;101;31.14694,2134.632;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.0,0;False;2;FLOAT;0.0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.FunctionNode;70;286.1363,111.3505;Float;False;SHDF_GetNeighbourPixels;-1;;16;3;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.0;False;9;COLOR;COLOR;COLOR;COLOR;COLOR;COLOR;COLOR;COLOR;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;139;-835.2811,3762.304;Float;False;Property;_GameOver;GameOver;17;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;135;-492.7845,3421.477;Float;True;Property;_T_ObjectsFade;T_ObjectsFade;16;0;Assets/Textures/FX/T_ObjectsFade.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.Matrix3X3Node;63;248.446,385.0963;Float;False;Constant;_Matrix0;Matrix 0;4;0;0,0,0,1,1,1,0,0,0;0;1;FLOAT3x3
Node;AmplifyShaderEditor.PowerNode;98;708.1268,1900.199;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;4.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;100;400.7416,2102.835;Float;True;Property;_TextureSample1;Texture Sample 1;8;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;69;643.247,396.8015;Float;False;2;0;FLOAT;1.0;False;1;FLOAT;3.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;146;-148.9378,3557.721;Float;False;3;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.4264706;False;1;COLOR
Node;AmplifyShaderEditor.OneMinusNode;148;-516.9989,3779.812;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;66;574.4907,110.204;Float;False;SHDF_Convolution;-1;;17;10;0;COLOR;0,0,0;False;1;COLOR;0,0,0;False;2;COLOR;0,0,0;False;3;COLOR;0,0,0;False;4;COLOR;0,0,0;False;5;COLOR;0,0,0;False;6;COLOR;0,0,0;False;7;COLOR;0,0,0;False;8;COLOR;0,0,0;False;9;FLOAT3x3;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.TFHCRemap;147;-265.0658,3780.657;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;-0.5;False;4;FLOAT;0.6;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;830.0517,119.9699;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;99;874.3804,1903.199;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;75;831.412,314.4178;Float;False;Constant;_OverlayIntensity;OverlayIntensity;4;0;0.2;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;142;50.86953,3422.344;Float;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TFHCGrayscale;104;694.8242,2104.971;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;107;488.8242,2305.121;Float;False;Constant;_PauseEffectColor;PauseEffectColor;10;0;1,0,0.2647056,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;140;68.72327,3673.103;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;5,3;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;134;359.4425,3644.491;Float;True;Property;_T_burnt_mask;T_burnt_mask;15;0;Assets/Textures/FX/T_burnt_mask.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;106;933.0958,2192.511;Float;False;Lighten;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;96;398.7644,1633.633;Float;True;Property;_TextureSample0;Texture Sample 0;8;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;73;1025.182,90.68776;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.OneMinusNode;131;983.6397,2412.814;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ScaleAndOffsetNode;143;290.5755,3422.343;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT;1.0;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.LerpOp;87;1113.911,295.8068;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;145;651.7982,3672.948;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;141;517.3209,3393.885;Float;True;Property;_T_Ramp;T_Ramp;18;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;110;1178.614,2174.409;Float;False;Darken;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;1301.558,2423.23;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;74;1382.147,85.63001;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.BlendOpsNode;144;836.661,3408.056;Float;False;Overlay;True;2;0;FLOAT;0,0,0,0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.ConditionalIfNode;154;1939.16,689.1036;Float;False;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;129;1449.446,2180.533;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;136;1270.631,3410.337;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ConditionalIfNode;155;2192.389,687.6548;Float;False;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ConditionalIfNode;156;2469.756,683.7944;Float;False;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.TemplateMasterNode;1;2670.619,681.172;Float;False;True;2;Float;ASEMaterialInspector;0;1;Custom/SHD_PostProcessEffects;c71b220b631b6344493ea3cf87110c93;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;76;0;13;0
WireConnection;77;0;13;0
WireConnection;77;1;76;0
WireConnection;77;2;78;0
WireConnection;84;1;77;0
WireConnection;84;2;83;0
WireConnection;11;0;7;0
WireConnection;11;2;84;0
WireConnection;126;0;125;0
WireConnection;126;2;122;0
WireConnection;116;0;115;0
WireConnection;116;2;122;0
WireConnection;6;0;15;0
WireConnection;6;1;11;0
WireConnection;20;0;6;0
WireConnection;123;0;124;0
WireConnection;123;1;126;0
WireConnection;85;1;10;0
WireConnection;85;2;83;0
WireConnection;114;0;124;0
WireConnection;114;1;116;0
WireConnection;127;0;114;1
WireConnection;127;1;123;2
WireConnection;8;1;20;0
WireConnection;8;2;85;0
WireConnection;121;0;127;0
WireConnection;102;0;109;0
WireConnection;72;0;8;0
WireConnection;71;0;7;0
WireConnection;71;1;72;0
WireConnection;120;0;102;0
WireConnection;120;1;121;0
WireConnection;79;0;7;0
WireConnection;79;1;72;0
WireConnection;113;0;94;1
WireConnection;117;0;102;0
WireConnection;117;1;120;0
WireConnection;117;2;119;0
WireConnection;80;0;71;0
WireConnection;80;1;79;0
WireConnection;80;2;78;0
WireConnection;112;0;103;0
WireConnection;112;1;113;0
WireConnection;112;2;128;0
WireConnection;86;1;43;0
WireConnection;86;2;83;0
WireConnection;101;0;91;0
WireConnection;101;1;117;0
WireConnection;101;2;112;0
WireConnection;70;0;80;0
WireConnection;70;1;2;0
WireConnection;70;2;86;0
WireConnection;98;0;94;1
WireConnection;100;0;2;0
WireConnection;100;1;101;0
WireConnection;146;0;135;0
WireConnection;146;1;94;0
WireConnection;148;0;139;0
WireConnection;66;0;70;0
WireConnection;66;1;70;1
WireConnection;66;2;70;2
WireConnection;66;3;70;3
WireConnection;66;4;70;4
WireConnection;66;5;70;5
WireConnection;66;6;70;6
WireConnection;66;7;70;7
WireConnection;66;8;70;8
WireConnection;66;9;63;0
WireConnection;147;0;148;0
WireConnection;68;0;66;0
WireConnection;68;1;69;0
WireConnection;99;0;98;0
WireConnection;142;0;146;0
WireConnection;104;0;100;0
WireConnection;134;1;140;0
WireConnection;106;0;107;0
WireConnection;106;1;104;0
WireConnection;96;0;2;0
WireConnection;96;1;91;0
WireConnection;73;0;6;0
WireConnection;73;1;68;0
WireConnection;131;0;99;0
WireConnection;143;0;142;0
WireConnection;143;2;147;0
WireConnection;87;1;75;0
WireConnection;87;2;83;0
WireConnection;145;0;134;1
WireConnection;141;1;143;0
WireConnection;110;0;96;0
WireConnection;110;1;106;0
WireConnection;130;0;131;0
WireConnection;130;1;128;0
WireConnection;74;0;68;0
WireConnection;74;1;73;0
WireConnection;74;2;87;0
WireConnection;144;0;145;0
WireConnection;144;1;141;0
WireConnection;154;0;83;0
WireConnection;154;2;74;0
WireConnection;154;3;96;0
WireConnection;154;4;96;0
WireConnection;129;0;96;0
WireConnection;129;1;110;0
WireConnection;129;2;130;0
WireConnection;136;1;96;0
WireConnection;136;2;144;0
WireConnection;155;0;128;0
WireConnection;155;2;129;0
WireConnection;155;3;154;0
WireConnection;155;4;154;0
WireConnection;156;0;139;0
WireConnection;156;2;136;0
WireConnection;156;3;155;0
WireConnection;156;4;155;0
WireConnection;1;0;156;0
ASEEND*/
//CHKSM=937FEBA5C3A91777DF6A2700087435BD668DF729