// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SHD_HighlightPP"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_DeformationStrength("DeformationStrength", Range( 0 , 1)) = 0
		_T_Vignette("T_Vignette", 2D) = "white" {}
		_Focus("Focus", Range( 0 , 1)) = 0
		_FocusColor("FocusColor", Color) = (0,0,0,0)
		_OverlayColor("OverlayColor", Color) = (0,0,0,0)
		_OverlayEmissive("OverlayEmissive", Float) = 1
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
			
			uniform sampler2D _TextureSample1;
			uniform float _DeformationStrength;
			uniform sampler2D _T_Vignette;
			uniform float4 _T_Vignette_ST;
			uniform float _Focus;
			uniform float4 _FocusColor;
			uniform float4 _OverlayColor;
			uniform float _OverlayEmissive;
			uniform sampler2D _GlowPrepassTex;
			uniform float4 _GlowPrepassTex_ST;
			uniform sampler2D _GlowBlurredTex;
			uniform float4 _GlowBlurredTex_ST;

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
				float2 uv146 = i.uv.xy*float2( 1,1 ) + float2( 0,0 );
				float2 uv152 = i.uv.xy*float2( 2,2 ) + float2( 0,0 );
				float2 componentMask148 = tex2D( _TextureSample1, uv152 ).rg;
				float2 uv_T_Vignette = i.uv.xy*_T_Vignette_ST.xy + _T_Vignette_ST.zw;
				float4 tex2DNode142 = tex2D( _T_Vignette, uv_T_Vignette );
				float2 lerpResult147 = lerp( uv146 , componentMask148 , ( ( _DeformationStrength * saturate( pow( ( 1.0 - tex2DNode142.r ) , 4.0 ) ) ) * _Focus ));
				float4 tex2DNode80 = tex2D( _MainTex, lerpResult147 );
				float4 lerpResult137 = lerp( tex2DNode80 , ( Luminance(tex2DNode80.rgb) * _FocusColor ) , _Focus);
				float2 uv_GlowPrepassTex = i.uv.xy*_GlowPrepassTex_ST.xy + _GlowPrepassTex_ST.zw;
				float4 tex2DNode24 = tex2D( _GlowPrepassTex, uv_GlowPrepassTex );
				float2 uv_GlowBlurredTex = i.uv.xy*_GlowBlurredTex_ST.xy + _GlowBlurredTex_ST.zw;
				float4 lerpResult118 = lerp( lerpResult137 , ( _OverlayColor * _OverlayEmissive ) , saturate( ( ( tex2DNode24 * tex2D( _GlowBlurredTex, uv_GlowBlurredTex ) ) + tex2DNode24 ) ).r);
				float lerpResult157 = lerp( 1.0 , tex2DNode142.r , _Focus);
				float4 lerpResult144 = lerp( float4( 0,0,0,0 ) , lerpResult118 , lerpResult157);
				float4 lerpResult160 = lerp( tex2DNode80 , lerpResult144 , _Focus);

				finalColor = lerpResult160;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
1927;60;1906;780;1872.003;3005.988;1.46256;True;False
Node;AmplifyShaderEditor.SamplerNode;142;-570.2466,-2739.108;Float;True;Property;_T_Vignette;T_Vignette;7;0;Assets/Textures/T_Vignette.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;151;-2830.526,-2500.97;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;155;-2651.403,-2494.285;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;4.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;154;-2484.966,-2492.887;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;152;-2745.114,-2932.06;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;149;-2600.98,-2573.053;Float;False;Property;_DeformationStrength;DeformationStrength;9;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;139;-1406.376,-2476.451;Float;False;Property;_Focus;Focus;6;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;-2303.041,-2565.568;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;145;-2446.371,-2904.542;Float;True;Property;_TextureSample1;Texture Sample 1;8;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;-2155.704,-2567.212;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;146;-2388.357,-2697.621;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;148;-2154.796,-2905.727;Float;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TexturePropertyNode;107;-1611.785,-2127.091;Float;True;Global;_GlowBlurredTex;_GlowBlurredTex;7;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.LerpOp;147;-2081.436,-2697.62;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.0,0;False;2;FLOAT;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;16;-1695.434,-2668.57;Float;False;_MainTex;0;1;SAMPLER2D
Node;AmplifyShaderEditor.TexturePropertyNode;66;-1592.008,-1864.569;Float;True;Global;_GlowPrepassTex;_GlowPrepassTex;7;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SamplerNode;80;-1425.724,-2678.626;Float;True;Property;_TextureSample0;Texture Sample 0;3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;24;-1355.289,-1865.652;Float;True;Property;_TextureSample7;Texture Sample 7;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;108;-1359.243,-2125.388;Float;True;Property;_TextureSample6;Texture Sample 6;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;138;-1005.776,-2852.353;Float;False;Property;_FocusColor;FocusColor;5;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-1085.957,-2258.105;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.TFHCGrayscale;140;-1003.177,-2934.253;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;116;-973.7264,-2542.412;Float;False;Property;_OverlayColor;OverlayColor;2;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;159;-974.2554,-2364.481;Float;False;Property;_OverlayEmissive;OverlayEmissive;10;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-748.3765,-2884.854;Float;False;2;2;0;FLOAT;0,0,0,0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;128;-963.6059,-1993.3;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-727.2554,-2394.481;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;115;-797.278,-1994.112;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;137;-730.1766,-2695.053;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;157;-240.5288,-2587.664;Float;False;3;0;FLOAT;1.0;False;1;FLOAT;1.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;118;-573.2949,-2455.323;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;144;-154.0322,-2297.634;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LerpOp;160;172.6548,-2176.717;Float;False;3;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.TemplateMasterNode;65;335.9058,-2307.628;Float;False;True;2;Float;ASEMaterialInspector;0;1;Custom/SHD_HighlightPP;c71b220b631b6344493ea3cf87110c93;1;0;FLOAT4;0,0,0,0;False;0
WireConnection;151;0;142;1
WireConnection;155;0;151;0
WireConnection;154;0;155;0
WireConnection;150;0;149;0
WireConnection;150;1;154;0
WireConnection;145;1;152;0
WireConnection;156;0;150;0
WireConnection;156;1;139;0
WireConnection;148;0;145;0
WireConnection;147;0;146;0
WireConnection;147;1;148;0
WireConnection;147;2;156;0
WireConnection;80;0;16;0
WireConnection;80;1;147;0
WireConnection;24;0;66;0
WireConnection;108;0;107;0
WireConnection;133;0;24;0
WireConnection;133;1;108;0
WireConnection;140;0;80;0
WireConnection;141;0;140;0
WireConnection;141;1;138;0
WireConnection;128;0;133;0
WireConnection;128;1;24;0
WireConnection;158;0;116;0
WireConnection;158;1;159;0
WireConnection;115;0;128;0
WireConnection;137;0;80;0
WireConnection;137;1;141;0
WireConnection;137;2;139;0
WireConnection;157;1;142;1
WireConnection;157;2;139;0
WireConnection;118;0;137;0
WireConnection;118;1;158;0
WireConnection;118;2;115;0
WireConnection;144;1;118;0
WireConnection;144;2;157;0
WireConnection;160;0;80;0
WireConnection;160;1;144;0
WireConnection;160;2;139;0
WireConnection;65;0;160;0
ASEEND*/
//CHKSM=2FE55F8806E7F6D81494695E396DADE72DCE1CB7