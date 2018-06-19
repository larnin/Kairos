// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_SmokeFX_Unlit"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Color3("Color 3", Color) = (0,0,0,0)
		_TextureSample9("Texture Sample 9", 2D) = "white" {}
		_RowsAndColumns("RowsAndColumns", Vector) = (6,5,0,0)
		_Speed("Speed", Float) = 5
		_BaseTexture("BaseTexture", 2D) = "white" {}
		_Color1("Color 1", Color) = (0,0,0,0)
		_EmissiveStrength("EmissiveStrength", Range( 0 , 10)) = 0
		_DisplacementStrength("DisplacementStrength", Float) = 0
		_T_PerlinNoise("T_PerlinNoise", 2D) = "white" {}
		_DisplacementMouvSpeed("DisplacementMouvSpeed", Float) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 texcoord_0;
			float2 texcoord_1;
			float4 vertexColor : COLOR;
			float2 texcoord_2;
		};

		uniform float4 _Color3;
		uniform float4 _Color1;
		uniform sampler2D _TextureSample9;
		uniform float _EmissiveStrength;
		uniform sampler2D _BaseTexture;
		uniform float2 _RowsAndColumns;
		uniform float _Speed;
		uniform sampler2D _T_PerlinNoise;
		uniform float _DisplacementMouvSpeed;
		uniform float _DisplacementStrength;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 2,6 ) + float2( 0,0 );
			o.texcoord_1.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float2 temp_cast_0 = (_DisplacementMouvSpeed).xx;
			o.texcoord_2.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float2 panner148 = ( o.texcoord_2 + 1.0 * _Time.y * temp_cast_0);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( tex2Dlod( _T_PerlinNoise, float4( panner148, 0.0 , 0.0 ) ) * float4( ase_vertexNormal , 0.0 ) * _DisplacementStrength ).rgb;
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 panner77 = ( i.texcoord_0 + 1.0 * _Time.y * float2( 0.1,-1 ));
			float4 lerpResult93 = lerp( _Color3 , _Color1 , saturate( tex2D( _TextureSample9, panner77 ).r ));
			o.Emission = ( lerpResult93 * _EmissiveStrength ).rgb;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles141 = _RowsAndColumns.x * _RowsAndColumns.y;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset141 = 1.0f / _RowsAndColumns.x;
			float fbrowsoffset141 = 1.0f / _RowsAndColumns.y;
			// Speed of animation
			float fbspeed141 = _Time[1] * ( _Speed * (0.5 + (i.vertexColor.r - 0.0) * (1.0 - 0.5) / (1.0 - 0.0)) );
			// UV Tiling (col and row offset)
			float2 fbtiling141 = float2(fbcolsoffset141, fbrowsoffset141);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex141 = round( fmod( fbspeed141 + 0.0, fbtotaltiles141) );
			fbcurrenttileindex141 += ( fbcurrenttileindex141 < 0) ? fbtotaltiles141 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox141 = round ( fmod ( fbcurrenttileindex141, _RowsAndColumns.x ) );
			// Multiply Offset X by coloffset
			float fboffsetx141 = fblinearindextox141 * fbcolsoffset141;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy141 = round( fmod( ( fbcurrenttileindex141 - fblinearindextox141 ) / _RowsAndColumns.x, _RowsAndColumns.y ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy141 = (int)(_RowsAndColumns.y-1) - fblinearindextoy141;
			// Multiply Offset Y by rowoffset
			float fboffsety141 = fblinearindextoy141 * fbrowsoffset141;
			// UV Offset
			float2 fboffset141 = float2(fboffsetx141, fboffsety141);
			// Flipbook UV
			half2 fbuv141 = float4( i.texcoord_1, 0.0 , 0.0 ) * fbtiling141 + fboffset141;
			// *** END Flipbook UV Animation vars ***
			o.Alpha = saturate( tex2D( _BaseTexture, fbuv141 ).a );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog noforwardadd vertex:vertexDataFunc 

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
1927;29;1906;1004;729.2866;451.1306;1.640782;True;True
Node;AmplifyShaderEditor.VertexColorNode;151;-2462.626,391.5903;Float;False;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;75;-1797.707,-1387.74;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,6;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;153;-2279.649,398.2153;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;0.5;False;4;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;11;-2261.194,265.7334;Float;False;Property;_Speed;Speed;3;0;5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PannerNode;77;-1532.713,-1385.048;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,-1;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-2031.958,317.5195;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.Vector2Node;15;-2197.763,120.22;Float;False;Property;_RowsAndColumns;RowsAndColumns;2;0;6,5;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-2324.861,-221.0324;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;150;-362.3513,465.6471;Float;False;Property;_DisplacementMouvSpeed;DisplacementMouvSpeed;9;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;149;-332.9469,342.0447;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;86;-1320.481,-1414.83;Float;True;Property;_TextureSample9;Texture Sample 9;1;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TexturePropertyNode;38;-291.5431,72.45701;Float;True;Property;_BaseTexture;BaseTexture;4;0;None;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;141;-1876.436,77.14451;Float;False;0;0;5;0;FLOAT2;0,0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;91;-893.079,-1287.234;Float;False;Property;_Color3;Color 3;0;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;92;-786.8932,-915.2705;Float;False;1;0;FLOAT;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.PannerNode;148;-39.78396,413.1643;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.ColorNode;90;-851.0789,-1108.331;Float;False;Property;_Color1;Color 1;5;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;1;212.0891,147.45;Float;True;Property;_BaseTexture;BaseTexture;0;0;Assets/Textures/OutputSlate.PNG;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;143;-10.3335,-64.78156;Float;False;Property;_EmissiveStrength;EmissiveStrength;6;0;0;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;146;197.4107,747.9691;Float;False;Property;_DisplacementStrength;DisplacementStrength;7;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;93;-625.2609,-982.3745;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.NormalVertexDataNode;145;253.4107,595.9691;Float;False;0;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;147;145.1476,384.5005;Float;True;Property;_T_PerlinNoise;T_PerlinNoise;8;0;Assets/Textures/T_PerlinNoise.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;157;806.4861,233.0757;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;510.4104,572.969;Float;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;362.6665,44.21844;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1010.5,4.299999;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Custom/SHD_SmokeFX_Unlit;False;False;False;False;True;True;True;True;True;True;False;True;False;False;True;False;False;Off;0;0;False;0;0;Transparent;0.5;True;True;0;False;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;153;0;151;1
WireConnection;77;0;75;0
WireConnection;152;0;11;0
WireConnection;152;1;153;0
WireConnection;86;1;77;0
WireConnection;141;0;14;0
WireConnection;141;1;15;1
WireConnection;141;2;15;2
WireConnection;141;3;152;0
WireConnection;92;0;86;1
WireConnection;148;0;149;0
WireConnection;148;2;150;0
WireConnection;1;0;38;0
WireConnection;1;1;141;0
WireConnection;93;0;91;0
WireConnection;93;1;90;0
WireConnection;93;2;92;0
WireConnection;147;1;148;0
WireConnection;157;0;1;4
WireConnection;144;0;147;0
WireConnection;144;1;145;0
WireConnection;144;2;146;0
WireConnection;142;0;93;0
WireConnection;142;1;143;0
WireConnection;0;2;142;0
WireConnection;0;9;157;0
WireConnection;0;11;144;0
ASEEND*/
//CHKSM=A10ED68C81D007C22A3EB5B6CE4907BCDC58904F