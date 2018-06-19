// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/SHD_Emissive"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Emissive("Emissive", Float) = 0
		_Texture1("Texture 1", 2D) = "white" {}
		_Emissivecolor("Emissivecolor", Color) = (1,1,1,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_OverFX("OverFX", Range( 0 , 1)) = 0
		_Texture3("Texture 3", 2D) = "white" {}
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true" "TakeFocus" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog noforwardadd 
		struct Input
		{
			float4 vertexColor : COLOR;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform float4 _Emissivecolor;
		uniform float _Emissive;
		uniform sampler2D _Texture1;
		uniform sampler2D _Texture3;
		uniform float4 _Texture3_ST;
		uniform sampler2D _TextureSample2;
		uniform float _OverFX;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
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

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar20 = TriplanarSampling( _Texture1, _Texture1, _Texture1, ase_worldPos, ase_worldNormal, 5.0, 0.3, 0 );
			float4 temp_cast_0 = (triplanar20.x).xxxx;
			float2 uv_Texture3 = i.uv_texcoord * _Texture3_ST.xy + _Texture3_ST.zw;
			float2 panner26 = ( uv_Texture3 + 1.0 * _Time.y * float2( 0,0.1 ));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 componentMask21 = ( ase_screenPosNorm + (1.0 + (_OverFX - 0.0) * (-1.0 - 1.0) / (1.0 - 0.0)) ).xy;
			float4 lerpResult17 = lerp( float4( 0,0,0,0 ) , ( saturate( CalculateContrast(5.0,temp_cast_0) ) * float4(0,0.9568628,1,0) * 15.0 * tex2D( _Texture3, panner26 ) ) , ( 1.0 - saturate( tex2D( _TextureSample2, componentMask21 ) ) ).r);
			float4 lerpResult9 = lerp( ( _Emissivecolor * _Emissive * i.vertexColor ) , lerpResult17 , _OverFX);
			o.Emission = lerpResult9.rgb;
			o.Alpha = 1;
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			clip( tex2D( _TextureSample0, uv_TextureSample0 ).a - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
2078;119;1677;686;1103.701;298.6374;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;34;-3083.824,-1831.775;Float;False;2316.389;1588.597;Comment;20;33;32;31;28;29;17;18;20;22;15;16;19;21;24;27;30;26;25;23;8;OverFX;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-3033.824,-446.9125;Float;False;Property;_OverFX;OverFX;5;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.ScreenPosInputsNode;15;-2764.088,-636.9502;Float;False;0;False;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;16;-2723.889,-445.1773;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;1.0;False;4;FLOAT;-1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-2512.859,-569.7573;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TexturePropertyNode;18;-2551.105,-1781.775;Float;True;Property;_Texture1;Texture 1;1;0;Assets/Textures/FX/T_Veins4.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.ComponentMaskNode;21;-2373.778,-571.7933;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-2550.612,-919.9546;Float;False;0;23;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.3,0.3;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TriplanarNode;20;-2263.405,-1775.775;Float;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;1;None;Mid Texture 1;_MidTexture1;white;2;None;Bot Texture 1;_BotTexture1;white;3;None;Triplanar Sampler;5;0;SAMPLER2D;;False;1;SAMPLER2D;;False;2;SAMPLER2D;;False;3;FLOAT;0.3;False;4;FLOAT;5.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.PannerNode;26;-2216.104,-1061.822;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.1;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleContrastOpNode;25;-1561.296,-1737.275;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;5.0;False;1;COLOR
Node;AmplifyShaderEditor.TexturePropertyNode;23;-2226.183,-1257.077;Float;True;Property;_Texture3;Texture 3;7;0;Assets/Textures/T_PerlinNoise.png;False;white;Auto;0;1;SAMPLER2D
Node;AmplifyShaderEditor.SamplerNode;24;-1942.796,-592.8161;Float;True;Property;_TextureSample2;Texture Sample 2;8;0;Assets/Textures/FX/T_Ramp.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;30;-1915.332,-1261.115;Float;True;Property;_TextureSample4;Texture Sample 4;9;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;29;-1603.904,-587.2853;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;31;-1615.622,-1631.756;Float;False;Constant;_Color1;Color 1;4;0;0,0.9568628,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;27;-1409.296,-1743.275;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;28;-1565.044,-1453.859;Float;False;Constant;_Float1;Float 1;5;0;15;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1208.435,-1648.404;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;2;-443,-59;Float;False;Property;_Emissivecolor;Emissivecolor;2;0;1,1,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;32;-1446.191,-586.7693;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.VertexColorNode;6;-408,420;Float;False;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;1;-388,129;Float;False;Property;_Emissive;Emissive;1;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;17;-951.4352,-1593.404;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-187,47;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;5;-525,220;Float;True;Property;_TextureSample0;Texture Sample 0;3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;9;74.20776,48.34216;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;414.1181,4.614655;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Unlit/SHD_Emissive;False;False;False;False;True;True;True;True;True;True;False;True;False;False;True;False;False;Back;0;0;False;0;0;Masked;0.5;True;False;0;False;TransparentCutout;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;16;0;8;0
WireConnection;19;0;15;0
WireConnection;19;1;16;0
WireConnection;21;0;19;0
WireConnection;20;0;18;0
WireConnection;26;0;22;0
WireConnection;25;1;20;1
WireConnection;24;1;21;0
WireConnection;30;0;23;0
WireConnection;30;1;26;0
WireConnection;29;0;24;0
WireConnection;27;0;25;0
WireConnection;33;0;27;0
WireConnection;33;1;31;0
WireConnection;33;2;28;0
WireConnection;33;3;30;0
WireConnection;32;0;29;0
WireConnection;17;1;33;0
WireConnection;17;2;32;0
WireConnection;3;0;2;0
WireConnection;3;1;1;0
WireConnection;3;2;6;0
WireConnection;9;0;3;0
WireConnection;9;1;17;0
WireConnection;9;2;8;0
WireConnection;0;2;9;0
WireConnection;0;10;5;4
ASEEND*/
//CHKSM=7E72E6B19E479D452F3E0802A5FBF45FF3BABC9E